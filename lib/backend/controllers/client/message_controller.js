import { Message } from '../../models/message_model.js';
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
            .sort({ createdAt: 1 });

        if (messages.length > 0) {
            const updateResult = await Message.updateMany(
                {
                    chatId,
                    senderId: { $ne: userId },
                    isRead: false
                },
                { $set: { isRead: true } }
            );
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

export const saveMessage = async (req, res) => {
    const { chatId, content, type, mediaUrl } = req.body;
    const userId = req.userId;

    // Debug log
    console.log('Request body:', JSON.stringify(req.body));
    console.log('ChatId type:', typeof chatId, 'Value:', chatId);

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

        // Process content based on message type
        let finalMediaUrl = mediaUrl;

        // Upload media to Cloudinary for image, video, or file type messages
        if ((type === 'image' || type === 'video' || type === 'file') && mediaUrl) {
            // Only upload if it's a base64 string or not already a Cloudinary URL
            if (!mediaUrl.includes('cloudinary.com') || mediaUrl.startsWith('data:')) {
                try {
                    const folder = `chat_app/messages/${type}s`;
                    const uploadResult = await uploadImage(mediaUrl, folder);
                    if (uploadResult && uploadResult.url) {
                        finalMediaUrl = uploadResult.url;
                    }
                } catch (error) {
                    console.error(`Error uploading message ${type}:`, error);
                    // Continue with original media URL if upload fails
                }
            }
        }

        const newMessage = new Message({
            chatId,
            senderId: userId,
            type: type || 'text',
            content,
            mediaUrl: finalMediaUrl,
            createdAt: new Date(),
            isRead: false
        });

        await newMessage.save();
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
