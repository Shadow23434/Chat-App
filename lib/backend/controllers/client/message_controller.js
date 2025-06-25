import { Message } from '../../models/message_model.js';
import { Chat } from '../../models/chat_model.js';
import { User } from '../../models/user_model.js';
import { Types } from 'mongoose';
import { uploadImage, deleteImage } from '../../utils/cloudinary.js';

export const getMessage = async (req, res) => {
    const { chatId } = req.params;
    const userId = req.userId;

    try {
        if (!chatId) {
            return res.status(400).json({
                success: false,
                message: 'Chat ID is required'
            });
        }

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const messages = await Message.find({ chatId })
            .sort({ createdAt: -1 });

        if (messages.length > 0) {
            const updateResult = await Message.updateMany(
                {
                    chatId,
                    senderId: { $ne: userId },
                    isRead: false
                },
                { $set: { isRead: true } }
            );

            // If messages were marked as read, emit chat update
            if (updateResult.modifiedCount > 0) {
                try {
                    const participants = await getChatParticipants(chatId);
                    for (const participantId of participants) {
                        const updatedChat = await updateChatAfterRead(chatId, participantId);
                        if (updatedChat) {
                            const io = req.app.get('io');
                            if (io) {
                                const roomName = `user_chats:${participantId}`;
                                io.to(roomName).emit('chatUpdate', updatedChat);
                            }
                        }
                    }
                } catch (error) {
                    console.error('Failed to emit chat update after marking as read:', error);
                }
            }
        }

        res.status(200).json({
            success: true,
            messages: messages
        });
    } catch (error) {
        console.error('Error in getMessage:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch messages',
        });
    }
};

export async function saveMessageToDB({ chatId, senderId, content, type, mediaUrl }) {
    console.log('Backend: saveMessageToDB called with:', { chatId, senderId, content, type, mediaUrl });

    // Validate content based on message type
    let finalContent = content;
    if (type === 'text') {
        if (!content || content.trim() === '') {
            throw new Error('Content is required for text messages');
        }
        finalContent = content.trim();
    } else if (type === 'image') {
        finalContent = 'Sent an image';
    } else if (type === 'audio') {
        finalContent = 'Sent an audio';
    } else {
        finalContent = content || '';
    }

    console.log('Backend: Final content for message:', finalContent);

    let finalMediaUrl = mediaUrl;
    if ((type === 'image' || type === 'audio') && mediaUrl) {
        console.log(`Backend: Processing ${type} message with mediaUrl:`, mediaUrl.substring(0, 100) + '...');
        if (!mediaUrl.includes('cloudinary.com') || mediaUrl.startsWith('data:')) {
            try {
                // Validate base64 data URL format
                if (mediaUrl.startsWith('data:')) {
                    if (!mediaUrl.includes('base64,')) {
                        console.error('Backend: Invalid base64 data URL format');
                        throw new Error('Invalid base64 data URL format');
                    }

                    // Check if base64 data is not empty
                    const base64Data = mediaUrl.split('base64,')[1];
                    if (!base64Data || base64Data.length === 0) {
                        console.error('Backend: Empty base64 data');
                        throw new Error('Empty base64 data');
                    }

                    console.log(`Backend: Valid base64 data URL with ${base64Data.length} characters`);
                }

                const folder = `chat_app/messages/${type}s`;
                console.log(`Backend: Uploading ${type} to folder:`, folder);

                // Determine MIME type from data URL
                let mimeType = type === 'image' ? 'image/jpeg' : 'audio/mpeg'; // default
                if (mediaUrl.startsWith('data:')) {
                    const mimeMatch = mediaUrl.match(/^data:([^;]+);/);
                    if (mimeMatch) {
                        mimeType = mimeMatch[1];
                        console.log(`Backend: Detected MIME type: ${mimeType}`);
                    }
                }

                // Use different upload options for audio vs image
                const uploadOptions = {
                    resource_type: type === 'audio' ? 'video' : 'auto', // Cloudinary treats audio as video
                    use_filename: true,
                    unique_filename: true
                };

                if (type === 'audio') {
                    uploadOptions.format = 'mp3'; // Convert audio to MP3 for better compatibility
                }

                const uploadResult = await uploadImage(mediaUrl, folder, uploadOptions);
                if (uploadResult && uploadResult.url) {
                    finalMediaUrl = uploadResult.url;
                    console.log(`Backend: ${type} uploaded successfully:`, finalMediaUrl);
                } else {
                    console.error(`Backend: Failed to upload ${type} - no URL returned`);
                }
            } catch (error) {
                console.error(`Error uploading message ${type}:`, error);
                // Continue with the original mediaUrl if upload fails
            }
        } else {
            console.log(`Backend: ${type} already has cloudinary URL:`, mediaUrl);
        }
    }

    const newMessage = new Message({
        chatId,
        senderId,
        type: type || 'text',
        content: finalContent,
        mediaUrl: finalMediaUrl,
        createdAt: new Date(),
        isRead: false
    });

    console.log('Backend: Saving message to DB:', {
        chatId: newMessage.chatId,
        senderId: newMessage.senderId,
        type: newMessage.type,
        content: newMessage.content,
        mediaUrl: newMessage.mediaUrl ? newMessage.mediaUrl.substring(0, 100) + '...' : null
    });

    console.log('Backend: Content handling - original content:', content, 'type:', type, 'final content:', finalContent);

    await newMessage.save();
    console.log('Backend: Message saved successfully with ID:', newMessage._id);
    return newMessage;
}

// Controller HTTP
export const saveMessage = async (req, res) => {
    const { chatId, content, type, mediaUrl } = req.body;
    const userId = req.userId;
    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }
        if (!chatId) {
            return res.status(400).json({
                success: false,
                message: 'Chat ID is required'
            });
        }

        // Validate content for text messages
        if (type === 'text' && (!content || content.trim() === '')) {
            return res.status(400).json({
                success: false,
                message: 'Content is required for text messages'
            });
        }

        const newMessage = await saveMessageToDB({
            chatId,
            senderId: userId,
            content,
            type,
            mediaUrl
        });
        res.status(201).json(newMessage);
    } catch (error) {
        console.error('Error in saveMessage:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to save message',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const deleteMessage = async (req, res) => {
    const { messageId } = req.params;
    const userId = req.userId;
    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const message = await Message.findById(messageId);
        if (!message) {
            return res.status(404).json({
                success: false,
                message: 'Message not found'
            });
        }

        if (message.senderId.toString() !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized: You can only delete your own message'
            });
        }

        // Delete media from Cloudinary if message has media URL
        if (message.mediaUrl && message.mediaUrl.includes('cloudinary.com')) {
            try {
                // Extract the public_id from the Cloudinary URL
                const urlParts = message.mediaUrl.split('/upload/');
                if (urlParts.length > 1) {
                    const publicIdWithExtension = urlParts[1].split('/').slice(1).join('/');
                    const publicId = publicIdWithExtension.split('.')[0];

                    // Determine the folder based on message type
                    let folder = 'chat_app/messages';
                    if (message.type === 'image') {
                        folder += '/images';
                    } else if (message.type === 'video') {
                        folder += '/videos';
                    } else if (message.type === 'file') {
                        folder += '/files';
                    }

                    await deleteImage(`${folder}/${publicId}`);
                }
            } catch (error) {
                console.error('Error deleting message media from Cloudinary:', error);
                // Continue with message deletion even if media deletion fails
            }
        }

        await Message.deleteOne({ _id: messageId });

        res.status(200).json({
            success: true,
            message: 'Message deleted successfully'
        });
    } catch (error) {
        console.error('Error in deleteMessage:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete message',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Helper function to update chat after messages are marked as read
export const updateChatAfterRead = async (chatId, currentUserId) => {
    try {
        const chat = await Chat.findById(chatId)
            .populate('participantOneId', 'username profilePic lastLogin')
            .populate('participantTwoId', 'username profilePic lastLogin');

        if (!chat) {
            console.error('Chat not found:', chatId);
            return null;
        }

        // Get the other participant (not the current user)
        const otherParticipant = currentUserId === chat.participantOneId._id.toString()
            ? chat.participantTwoId
            : chat.participantOneId;

        const latestMessage = await Message.findOne({ chatId })
            .sort({ createdAt: -1 });

        if (!latestMessage) {
            return null;
        }

        const sender = latestMessage.senderId.toString() === chat.participantOneId._id.toString()
            ? chat.participantOneId
            : chat.participantTwoId;

        const chatUpdate = {
            _id: chat._id.toString(),
            participant_id: otherParticipant._id.toString(),
            participant_name: otherParticipant.username,
            participant_profile_pic: otherParticipant.profilePic || '',
            participant_last_login: otherParticipant.lastLogin?.toISOString() || new Date().toISOString(),
            last_message: latestMessage.type === 'text' ? latestMessage.content :
                latestMessage.type === 'audio' ? `${sender.username} sent an audio.` :
                    `${sender.username} sent an image.`,
            last_message_at: latestMessage.createdAt.toISOString(),
            is_read: true,
            created_at: chat.createdAt.toISOString(),
            last_message_sender_id: latestMessage.senderId.toString(),
        };

        return chatUpdate;
    } catch (error) {
        console.error('Error updating chat after read:', error);
        return null;
    }
};

// Helper function to update chat after a message is sent
export const updateChatAfterMessage = async (chatId, message, currentUserId) => {
    try {
        const chat = await Chat.findById(chatId)
            .populate('participantOneId', 'username profilePic lastLogin')
            .populate('participantTwoId', 'username profilePic lastLogin');

        if (!chat) {
            console.error('Chat not found:', chatId);
            return null;
        }

        // Get the other participant (not the current user)
        const otherParticipant = currentUserId === chat.participantOneId._id.toString()
            ? chat.participantTwoId
            : chat.participantOneId;

        const sender = message.senderId === chat.participantOneId._id.toString()
            ? chat.participantOneId
            : chat.participantTwoId;

        const chatUpdate = {
            _id: chat._id.toString(),
            participant_id: otherParticipant._id.toString(),
            participant_name: otherParticipant.username,
            participant_profile_pic: otherParticipant.profilePic || '',
            participant_last_login: otherParticipant.lastLogin?.toISOString() || new Date().toISOString(),
            last_message: message.type === 'text' ? message.content :
                message.type === 'audio' ? `${sender.username} sent an audio.` :
                    `${sender.username} sent an image.`,
            last_message_at: message.createdAt.toISOString(),
            is_read: false,
            created_at: chat.createdAt.toISOString(),
            last_message_sender_id: message.senderId.toString(),
        };

        return chatUpdate;
    } catch (error) {
        console.error('Error updating chat after message:', error);
        return null;
    }
};

// Helper function to get chat participants
export const getChatParticipants = async (chatId) => {
    try {
        const chat = await Chat.findById(chatId);
        if (!chat) {
            return [];
        }

        return [
            chat.participantOneId.toString(),
            chat.participantTwoId.toString()
        ];
    } catch (error) {
        console.error('Error getting chat participants:', error);
        return [];
    }
};
