import { User } from '../../models/user_model.js';
import { Contact } from '../../models/contact_model.js';
import { Types } from 'mongoose';
import bcryptjs from 'bcryptjs';
import { uploadImage, deleteImage } from '../../utils/cloudinary.js';

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

export const editProfile = async (req, res) => {
    try {
        const userId = req.userId;
        const { username, gender, phoneNumber, profilePic } = req.body;

        // Tìm người dùng
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Cập nhật thông tin cơ bản
        if (username) user.username = username;
        if (gender) user.gender = gender;
        if (phoneNumber) user.phoneNumber = phoneNumber;

        // Upload profile picture to Cloudinary if provided
        if (profilePic && profilePic !== user.profilePic) {
            try {
                // If the current profile pic is from Cloudinary, delete it first
                if (user.profilePic && user.profilePic.includes('cloudinary.com')) {
                    try {
                        // Extract public_id correctly from Cloudinary URL
                        const urlParts = user.profilePic.split('/upload/');
                        if (urlParts.length > 1) {
                            const filePathWithExtension = urlParts[1];
                            // Remove version number if present (v1234567890/)
                            const pathWithoutVersion = filePathWithExtension.replace(/v\d+\//, '');
                            // Get the filename without extension
                            const publicId = pathWithoutVersion.substring(0, pathWithoutVersion.lastIndexOf('.'));
                            console.log('Deleting old profile picture with public_id:', publicId);

                            await deleteImage(publicId);
                        }
                    } catch (deleteError) {
                        console.error('Error deleting old profile picture:', deleteError);
                        // Continue with upload even if deletion fails
                    }
                }

                // Upload the new profile picture
                const uploadResult = await uploadImage(profilePic, 'chat_app/profiles');
                // Only update if upload was successful
                if (uploadResult && uploadResult.url) {
                    user.profilePic = uploadResult.url;
                    console.log('Uploaded new profile picture:', uploadResult.url);
                }
            } catch (error) {
                console.error('Error uploading profile picture:', error);
                // Continue with the profile update even if image upload fails
            }
        }

        await user.save();

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                gender: user.gender,
                phoneNumber: user.phoneNumber,
                profilePic: user.profilePic
            }
        });
    } catch (error) {
        console.error('Error in updateProfile:', error);
        res.status(500).json({
            success: false,
            message: 'Server error',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const searchProfile = async (req, res) => {
    try {
        const { query } = req.query;

        if (!query) {
            return res.status(400).json({
                success: false,
                message: 'Search query is required.'
            });
        }

        // Create a case-insensitive regex for searching username or email
        const searchRegex = new RegExp(query, 'i');

        // Find users matching the regex in username or email, limit to 10 results
        const users = await User.find({
            $and: [
                {
                    $or: [
                        { username: { $regex: searchRegex } },
                        { email: { $regex: searchRegex } }
                    ]
                },
                { _id: { $ne: req.userId } }
            ]
        })
            .limit(10)
            .select('_id username profilePic email'); // Select necessary fields

        res.status(200).json({ success: true, users });

    } catch (error) {
        console.error('Error searching users:', error);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
};
