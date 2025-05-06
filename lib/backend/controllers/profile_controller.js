import { User } from '../models/user_model.js';
import { Contact } from '../models/contact_model.js';
import { Types } from 'mongoose';

export const getProfile = async (req, res) => {
    const { userId } = req.params;
    const requesterId = req.userId;

    try {
        if (!userId) {
            return res.status(400).json({
                success: false,
                message: 'User ID is required'
            });
        }
        if (!Types.ObjectId.isValid(userId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid User ID format'
            });
        }

        if (!requesterId) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Requester ID not provided'
            });
        }
        if (!Types.ObjectId.isValid(requesterId)) {
            return res.status(401).json({
                success: false,
                message: 'Invalid Requester ID format'
            });
        }

        const profileUserId = new Types.ObjectId(userId);
        const requesterUserId = new Types.ObjectId(requesterId);

        const contact = await Contact.findOne({
            $or: [
                { userId1: profileUserId, userId2: requesterUserId },
                { userId1: requesterUserId, userId2: profileUserId }
            ]
        });

        const contactStatus = contact ? contact.status : 'none';

        const user = await User.findById(profileUserId).select(
            'username profilePic gender email phoneNumber'
        );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            profile: {
                ...user.toObject(),
                contactStatus
            }
        });

    } catch (error) {
        if (error.name === 'CastError') {
            return res.status(400).json({
                success: false,
                message: 'Invalid User ID format'
            });
        }

        res.status(500).json({
            success: false,
            message: 'Failed to fetch profile',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
