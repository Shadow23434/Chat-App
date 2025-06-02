import { Call } from '../../models/call_model.js';
import { Types } from 'mongoose';

export const getCall = async (req, res) => {
    const userId = req.userId;
    try {
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: User ID not provided'
            });
        }

        const objectId = Types.ObjectId.createFromHexString(userId);
        const calls = await Call.aggregate([
            {
                $match: {
                    $or: [
                        { callerId: objectId },
                        { receiverId: objectId }
                    ]
                }
            },
            {
                $lookup: {
                    from: 'users',
                    let: {
                        otherParticipantId: {
                            $cond: [
                                { $eq: ['$callerId', objectId] },
                                '$receiverId',
                                '$callerId'
                            ]
                        }
                    },
                    pipeline: [
                        { $match: { $expr: { $eq: ['$_id', '$$otherParticipantId'] } } },
                        { $project: { username: 1, profilePic: 1 } }
                    ],
                    as: 'partipant'
                }
            },
            { $unwind: '$partipant' },
            {
                $project: {
                    partipant_id: '$partipant._id',
                    partipant_name: '$partipant.username',
                    partipant_profile_pic: '$partipant.profilePic',
                    status: '$status',
                    endedAt: '$endedAt',
                }
            },
            { $sort: { endedAt: -1 } }
        ]);

        res.json(calls);
    } catch (error) {
        console.error('Error in getCall:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error',
        });
    }
}