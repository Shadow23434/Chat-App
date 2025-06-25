import { Chat } from '../../models/chat_model.js';
import { User } from '../../models/user_model.js';
import { Types } from 'mongoose';

export const getChat = async (req, res) => {
    const userId = req.userId;
    const { page = 1, limit = 20 } = req.query;
    try {
        console.log('getChat: Request from user ID:', userId);

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        if (!Types.ObjectId.isValid(userId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid user ID format'
            });
        }

        // Convert userId to ObjectId
        const objectId = new Types.ObjectId(userId);
        console.log('getChat: Looking for chats with participantOneId or participantTwoId:', objectId.toString());

        const chats = await Chat.aggregate([
            {
                $match: {
                    $or: [
                        { participantOneId: objectId },
                        { participantTwoId: objectId }
                    ]
                }
            },
            {
                $addFields: {
                    otherParticipantId: {
                        $cond: {
                            if: { $eq: ['$participantOneId', objectId] },
                            then: '$participantTwoId',
                            else: '$participantOneId'
                        }
                    }
                }
            },
            {
                $lookup: {
                    from: 'users',
                    localField: 'otherParticipantId',
                    foreignField: '_id',
                    pipeline: [
                        { $project: { username: 1, profilePic: 1, lastLogin: 1 } }
                    ],
                    as: 'otherParticipant'
                }
            },
            { $unwind: '$otherParticipant' },
            {
                $lookup: {
                    from: 'messages',
                    let: { chatId: '$_id' },
                    pipeline: [
                        { $match: { $expr: { $eq: ['$chatId', '$$chatId'] } } },
                        { $sort: { createdAt: -1 } },
                        { $limit: 1 },
                        { $project: { content: 1, createdAt: 1, isRead: 1, type: 1, senderId: 1 } }
                    ],
                    as: 'lastMessage'
                }
            },
            { $unwind: { path: '$lastMessage', preserveNullAndEmptyArrays: true } },
            {
                $lookup: {
                    from: 'users',
                    localField: 'lastMessage.senderId',
                    foreignField: '_id',
                    pipeline: [
                        { $project: { username: 1 } }
                    ],
                    as: 'messageSender'
                }
            },
            { $unwind: { path: '$messageSender', preserveNullAndEmptyArrays: true } },
            {
                $project: {
                    _id: 1,
                    participant_id: '$otherParticipant._id',
                    participant_name: '$otherParticipant.username',
                    participant_profile_pic: '$otherParticipant.profilePic',
                    participant_last_login: '$otherParticipant.lastLogin',
                    last_message: {
                        $cond: {
                            if: { $and: [{ $ne: ['$lastMessage', null] }, { $ne: ['$lastMessage.content', null] }, { $ne: ['$lastMessage.content', ''] }, { $ne: ['$lastMessage.type', 'audio'] }, { $ne: ['$lastMessage.type', 'image'] }] },
                            then: '$lastMessage.content',
                            else: {
                                $cond: {
                                    if: { $eq: ['$lastMessage.type', 'audio'] },
                                    then: { $concat: [{ $ifNull: ['$messageSender.username', 'Someone'] }, ' sent an audio.'] },
                                    else: { $concat: [{ $ifNull: ['$messageSender.username', 'Someone'] }, ' sent an image.'] }
                                }
                            }
                        }
                    },
                    last_message_at: { $ifNull: ['$lastMessage.createdAt', null] },
                    is_read: { $ifNull: ['$lastMessage.isRead', false] },
                    created_at: '$createdAt',
                    last_message_sender_id: {
                        $cond: {
                            if: { $ne: ['$lastMessage', null] },
                            then: { $toString: '$lastMessage.senderId' },
                            else: ''
                        }
                    },
                    debug_info: {
                        currentUserId: objectId.toString(),
                        participantOneId: '$participantOneId',
                        participantTwoId: '$participantTwoId',
                        otherParticipantId: '$otherParticipantId',
                        otherParticipantName: '$otherParticipant.username'
                    }
                }
            },
            { $sort: { last_message_at: -1 } }
        ]);

        console.log('getChat: Found', chats.length, 'chats');
        chats.forEach((chat, index) => {
            console.log(`getChat: Chat ${index + 1}:`, {
                chatId: chat._id,
                participant_id: chat.participant_id,
                participant_name: chat.participant_name,
                participant_profile_pic: chat.participant_profile_pic,
                last_message: chat.last_message,
                is_read: chat.is_read,
                debug_info: chat.debug_info
            });
        });

        res.status(200).json(chats);

    } catch (error) {
        console.error('Error in getChat:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
        });
    }
};

// Test endpoint to verify chat data
export const testChatData = async (req, res) => {
    const userId = req.userId;
    try {
        console.log('testChatData: Testing with user ID:', userId);

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ error: 'Invalid user ID' });
        }

        const objectId = new Types.ObjectId(userId);

        // Get a simple chat to test
        const testChat = await Chat.findOne({
            $or: [
                { participantOneId: objectId },
                { participantTwoId: objectId }
            ]
        }).populate('participantOneId', 'username profilePic')
            .populate('participantTwoId', 'username profilePic');

        if (!testChat) {
            return res.status(404).json({ error: 'No chat found for this user' });
        }

        const isCurrentUserParticipantOne = testChat.participantOneId._id.equals(objectId);
        const otherParticipant = isCurrentUserParticipantOne ? testChat.participantTwoId : testChat.participantOneId;

        const testResult = {
            chatId: testChat._id,
            currentUserId: userId,
            isCurrentUserParticipantOne,
            participantOne: {
                id: testChat.participantOneId._id,
                username: testChat.participantOneId.username,
                profilePic: testChat.participantOneId.profilePic
            },
            participantTwo: {
                id: testChat.participantTwoId._id,
                username: testChat.participantTwoId.username,
                profilePic: testChat.participantTwoId.profilePic
            },
            otherParticipant: {
                id: otherParticipant._id,
                username: otherParticipant.username,
                profilePic: otherParticipant.profilePic
            }
        };

        console.log('testChatData: Test result:', testResult);
        res.status(200).json(testResult);

    } catch (error) {
        console.error('Error in testChatData:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

export const createChat = async (req, res) => {
    try {
        const { participantId } = req.body;
        const currentUserId = req.userId;

        if (!currentUserId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        // Validate current user ID
        if (!Types.ObjectId.isValid(currentUserId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid user ID format'
            });
        }

        if (!participantId) {
            return res.status(400).json({
                success: false,
                message: 'ID participant missing'
            });
        }

        // Validate participant ID
        if (!Types.ObjectId.isValid(participantId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid participant ID format'
            });
        }

        // Check if the participant user exists
        const participantUser = await User.findById(participantId);
        if (!participantUser) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check if the chat already exists
        const existingChat = await Chat.findOne({
            $or: [
                { participantOneId: currentUserId, participantTwoId: participantId },
                { participantOneId: participantId, participantTwoId: currentUserId }
            ]
        });

        if (existingChat) {
            return res.status(200).json({
                success: true,
                message: 'Chat already exists',
                chat: existingChat
            });
        }

        // Create a new chat
        const newChat = new Chat({
            participantOneId: currentUserId,
            participantTwoId: participantId
        });

        await newChat.save();

        // Emit newChat event to both participants via Socket.IO
        try {
            const io = req.app.get('io'); // Get Socket.IO instance
            if (io) {
                // Get both users
                const participantOne = await User.findById(currentUserId);
                const participantTwo = participantUser;
                // Emit to both participants with correct participant info
                if (participantOne && participantTwo) {
                    // For currentUserId
                    const chatDataForCurrent = {
                        _id: newChat._id.toString(),
                        participant_id: participantTwo._id.toString(),
                        participant_name: participantTwo.username,
                        participant_profile_pic: participantTwo.profilePic || '',
                        participant_last_login: participantTwo.lastLogin?.toISOString() || new Date().toISOString(),
                        last_message: '',
                        last_message_at: null,
                        is_read: true,
                        created_at: newChat.createdAt.toISOString()
                    };
                    io.to(`user_chats:${currentUserId}`).emit('newChat', chatDataForCurrent);

                    // For participantId
                    const chatDataForOther = {
                        _id: newChat._id.toString(),
                        participant_id: participantOne._id.toString(),
                        participant_name: participantOne.username,
                        participant_profile_pic: participantOne.profilePic || '',
                        participant_last_login: participantOne.lastLogin?.toISOString() || new Date().toISOString(),
                        last_message: '',
                        last_message_at: null,
                        is_read: true,
                        created_at: newChat.createdAt.toISOString()
                    };
                    io.to(`user_chats:${participantId}`).emit('newChat', chatDataForOther);
                }
            }
        } catch (socketError) {
            console.error('Failed to emit newChat event:', socketError);
        }

        res.status(201).json({
            success: true,
            message: 'Chat created successfully',
            chat: newChat
        });
    } catch (error) {
        console.error('Error in createChat:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

export const deleteChat = async (req, res) => {
    try {
        const { chatId } = req.params;
        const currentUserId = req.userId;

        if (!currentUserId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        // Validate current user ID
        if (!Types.ObjectId.isValid(currentUserId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid user ID format'
            });
        }

        // Validate chat ID
        if (!chatId || !Types.ObjectId.isValid(chatId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid chat ID format'
            });
        }

        // Kiểm tra xem cuộc trò chuyện có tồn tại không
        const chat = await Chat.findById(chatId);
        if (!chat) {
            return res.status(404).json({
                success: false,
                message: 'Chat not found'
            });
        }

        // Check if the current user is a participant of the chat
        if (chat.participantOneId.toString() !== currentUserId &&
            chat.participantTwoId.toString() !== currentUserId) {
            return res.status(403).json({
                success: false,
                message: 'Can not delete this chat'
            });
        }

        // Delete chat
        await Chat.findByIdAndDelete(chatId);

        res.status(200).json({
            success: true,
            message: 'Chat deleted successfully'
        });
    } catch (error) {
        console.error('Error in deleteChat:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};
