import { Chat } from '../models/chat_model.js';
import { Types } from 'mongoose';

export const getChat = async (req, res) => {
    const userId = req.userId;
    const { page = 1, limit = 10 } = req.query;
    try {
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        const objectId = Types.ObjectId.createFromHexString(userId);

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
                        { $project: { content: 1, createdAt: 1, isRead: 1 } }
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
                            if: { $and: [{ $ne: ['$lastMessage', null] }, { $ne: ['$lastMessage.content', null] }, { $ne: ['$lastMessage.content', ''] }] },
                            then: '$lastMessage.content',
                            else: { $concat: ['$participant.username', ' sent an image.'] }
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
