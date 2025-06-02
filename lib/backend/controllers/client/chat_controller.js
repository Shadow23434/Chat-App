import { Chat } from '../../models/chat_model.js';
import { User } from '../../models/user_model.js';
import { Types } from 'mongoose';

export const getChat = async (req, res) => {
    const userId = req.userId;
    const { page = 1, limit = 20 } = req.query;
    try {
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        // Check if userId is a valid ObjectId
        if (!Types.ObjectId.isValid(userId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid user ID format'
            });
        }

        // Convert userId to ObjectId
        const objectId = new Types.ObjectId(userId);

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
                $lookup: {
                    from: 'users',
                    let: {
                        otherParticipantId: {
                            $cond: [
                                { $eq: ['$participantOneId', objectId] },
                                '$participantTwoId',
                                '$participantOneId'
                            ]
                        }
                    },
                    pipeline: [
                        { $match: { $expr: { $eq: ['$_id', '$$otherParticipantId'] } } },
                        { $project: { username: 1, profilePic: 1 } }
                    ],
                    as: 'participant'
                }
            },
            { $unwind: '$participant' },
            {
                $lookup: {
                    from: 'messages',
                    let: { chatId: '$_id' },
                    pipeline: [
                        { $match: { $expr: { $eq: ['$chatId', '$$chatId'] } } },
                        { $sort: { createdAt: -1 } },
                        { $limit: 1 },
                        { $project: { content: 1, createdAt: 1, isRead: 1, type: 1 } }
                    ],
                    as: 'lastMessage'
                }
            },
            { $unwind: { path: '$lastMessage', preserveNullAndEmptyArrays: true } },
            {
                $project: {
                    participant_id: '$participant._id',
                    participant_name: '$participant.username',
                    participant_profile_pic: '$participant.profilePic',
                    last_message: {
                        $cond: {
                            if: { $and: [{ $ne: ['$lastMessage', null] }, { $ne: ['$lastMessage.content', null] }, { $ne: ['$lastMessage.content', ''] }, { $ne: ['$lastMessage.type', 'audio'] }, { $ne: ['$lastMessage.type', 'image'] }] },
                            then: '$lastMessage.content',
                            else: {
                                $cond: {
                                    if: { $eq: ['$lastMessage.type', 'audio'] },
                                    then: { $concat: ['$participant.username', ' sent an audio.'] },
                                    else: { $concat: ['$participant.username', ' sent an image.'] } // Default to image for any other non-text type or if message is null/empty
                                }
                            }
                        }
                    },
                    last_message_at: { $ifNull: ['$lastMessage.createdAt', null] },
                    is_read: { $ifNull: ['$lastMessage.isRead', false] },
                    created_at: '$createdAt'
                }
            },
            { $sort: { last_message_at: -1 } }
        ]);

        res.status(200).json(chats);

    } catch (error) {
        console.error('Error in getChat:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
        });
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


// export const deleteChat = async (req, res) => {
//     try {
//         const { chatId } = req.params;
//         const currentUserId = req.userId;

//         if (!currentUserId) {
//             return res.status(401).json({
//                 success: false,
//                 message: 'Unauthorized: User ID not provided'
//             });
//         }

//         // Validate current user ID
//         if (!Types.ObjectId.isValid(currentUserId)) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Invalid user ID format'
//             });
//         }

//         // Validate chat ID
//         if (!chatId || !Types.ObjectId.isValid(chatId)) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Invalid chat ID format'
//             });
//         }

//         // Kiểm tra xem cuộc trò chuyện có tồn tại không
//         const chat = await Chat.findById(chatId);
//         if (!chat) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Không tìm thấy cuộc trò chuyện'
//             });
//         }

//         // Kiểm tra xem người dùng hiện tại có phải là người tham gia cuộc trò chuyện không
//         if (chat.participantOneId.toString() !== currentUserId &&
//             chat.participantTwoId.toString() !== currentUserId) {
//             return res.status(403).json({
//                 success: false,
//                 message: 'Không được phép xóa cuộc trò chuyện này'
//             });
//         }

//         // Xóa cuộc trò chuyện
//         await Chat.findByIdAndDelete(chatId);

//         // Tùy chọn: Xóa tất cả tin nhắn liên quan
//         // await Message.deleteMany({ chatId });

//         res.status(200).json({
//             success: true,
//             message: 'Cuộc trò chuyện đã được xóa thành công'
//         });
//     } catch (error) {
//         console.error('Error in deleteChat:', error);
//         res.status(500).json({
//             success: false,
//             message: 'Lỗi server'
//         });
//     }
// };
