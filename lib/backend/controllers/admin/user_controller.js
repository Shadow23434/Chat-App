import { User } from '../../models/user_model.js';
import { Chat } from '../../models/chat_model.js';
import { Message } from '../../models/message_model.js';
import { Story } from '../../models/story_model.js';
import { Call } from '../../models/call_model.js';
import { Contact } from '../../models/contact_model.js';
import { Comment } from '../../models/comment_model.js';
import { Support } from '../../models/support_model.js';
import { uploadImage, deleteImage } from '../../utils/cloudinary.js';
import bcryptjs from 'bcryptjs';
import multer from 'multer';

const defaultPermissions = {
    user: {
        'user:profile:read': true,
        'user:profile:edit': true,
        'chat:read': true,
        'chat:write': true,
        'story:read': true,
        'story:write': true,
        'call:create': true,
        'contact:manage': true,
        'admin:users:read': false,
        'admin:users:write': false,
        'admin:stats:read': false,
        'admin:chats:read': false,
        'admin:stories:read': false,
        'admin:calls:read': false,
        'admin:support:read': false,
        'admin:support:write': false
    },
    admin: {
        'user:profile:read': true,
        'user:profile:edit': true,
        'chat:read': true,
        'chat:write': true,
        'story:read': true,
        'story:write': true,
        'call:create': true,
        'contact:manage': true,
        'admin:users:read': true,
        'admin:users:write': true,
        'admin:stats:read': true,
        'admin:chats:read': true,
        'admin:stories:read': true,
        'admin:calls:read': true,
        'admin:support:read': true,
        'admin:support:write': true
    }
};

// Configure multer for memory storage
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB limit
    },
    fileFilter: function (req, file, cb) {
        // Accept images only
        if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
            return cb(new Error('Only image files are allowed!'), false);
        }
        cb(null, true);
    }
}).single('profilePic');

export const getUsers = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;
        const sort = req.query.sort || 'desc';
        const sortField = req.query.sortField || 'createdAt';
        const search = req.query.search || '';

        // Create search query
        const searchQuery = search ? {
            $or: [
                { username: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } },
                { phoneNumber: { $regex: search, $options: 'i' } },
                { role: { $regex: search, $options: 'i' } }
            ]
        } : {};

        // Create sort object
        const sortObj = {};
        sortObj[sortField] = sort === 'asc' ? 1 : -1;

        // Get total count first
        const total = await User.countDocuments(searchQuery);

        // Get users with pagination
        const users = await User.find(searchQuery)
            .select('-password')
            .skip(skip)
            .limit(limit)
            .sort(sortObj);

        // Get statistics
        const maleCount = await User.countDocuments({ gender: 'male' });
        const femaleCount = await User.countDocuments({ gender: 'female' });
        const unknownGenderCount = await User.countDocuments({
            $or: [
                { gender: { $exists: false } },
                { gender: null },
                { gender: { $nin: ['male', 'female'] } }
            ]
        });
        const adminCount = await User.countDocuments({
            role: { $in: ['admin', 'super_admin'] }
        });

        // Calculate total user count (non-admin users across all data)
        const totalUserCount = total - adminCount;
        const overallTotalUsers = await User.countDocuments();
        const trueTotalUserCount = overallTotalUsers - adminCount;

        // Calculate filtered user count (non-admin users matching search)
        const totalUsersMatchingSearch = await User.countDocuments(searchQuery);
        const filteredAdminCountMatchingSearch = await User.countDocuments({
            ...searchQuery,
            role: { $in: ['admin', 'super_admin'] }
        });
        const trueFilteredUserCount = totalUsersMatchingSearch - filteredAdminCountMatchingSearch;

        // Format users for frontend
        const formattedUsers = users.map(user => ({
            id: user._id.toString(),
            username: user.username,
            email: user.email,
            gender: user.gender || 'Unknown',
            phoneNumber: user.phoneNumber || '',
            profilePic: user.profilePic || '',
            role: user.role,
            status: user.status,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        }));

        // Calculate total pages
        const totalPages = Math.ceil(total / limit);

        res.status(200).json({
            users: formattedUsers,
            stats: {
                maleCount,
                femaleCount,
                unknownGenderCount,
                adminCount,
                totalUsers: total,
                filteredUserCount: trueFilteredUserCount,
                totalUserCount: trueTotalUserCount,
            },
            pagination: {
                total,
                page,
                pages: totalPages,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1
            }
        });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            message: 'Server error',
            error: error.message
        });
    }
};

export const addUser = async (req, res) => {
    try {
        // Handle file upload first
        upload(req, res, async function (err) {
            if (err instanceof multer.MulterError) {
                return res.status(400).json({
                    message: 'File upload error',
                    error: err.message
                });
            } else if (err) {
                return res.status(400).json({
                    message: 'Invalid file type',
                    error: err.message
                });
            }

            const { username, email, password, role, gender, phoneNumber
            } = req.body;

            if (!username || !email || !password || !role) {
                return res.status(400).json({ message: 'Missing required fields' });
            }

            // Check if user already exists
            const existing = await User.findOne({ email });
            if (existing) {
                return res.status(400).json({ message: 'User already exists' });
            }

            // Hash password
            const hashedPassword = await bcryptjs.hash(password, 10);

            let uploadedProfilePic = '';
            try {
                if (req.file) {
                    // Convert buffer to base64
                    const base64Image = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
                    // Upload to Cloudinary
                    const uploadResult = await uploadImage(base64Image, 'chat_app/profiles');
                    if (!uploadResult || !uploadResult.url) {
                        throw new Error('Failed to upload image to Cloudinary');
                    }
                    uploadedProfilePic = uploadResult.url;
                } else {
                    // Generate a deterministic but unique ID based on username and timestamp
                    const timestamp = Date.now();
                    const usernameHash = username.split('').reduce((acc, char) => {
                        return acc + char.charCodeAt(0);
                    }, 0);
                    const randomId = Math.abs((timestamp + usernameHash) % 10000000);

                    // Use GitHub avatars with the generated ID
                    const githubAvatarUrl = `https://avatars.githubusercontent.com/u/${randomId}`;

                    // Upload to Cloudinary
                    const uploadResult = await uploadImage(githubAvatarUrl, 'chat_app/profiles');
                    if (!uploadResult || !uploadResult.url) {
                        throw new Error('Failed to upload default avatar to Cloudinary');
                    }
                    uploadedProfilePic = uploadResult.url;
                }
            } catch (error) {
                console.error('Error uploading profile picture:', error);
                return res.status(400).json({
                    message: 'Cannot upload profile picture',
                    error: error.message
                });
            }

            let permissions = {};
            if (role === 'super_admin') {
                permissions = Object.fromEntries(
                    Object.keys(defaultPermissions.admin).map(key => [key, true])
                );
            } else if (role === 'admin') {
                permissions = { ...defaultPermissions.admin };
            } else {
                permissions = { ...defaultPermissions.user };
            }

            const user = new User({
                username,
                email,
                password: hashedPassword,
                role,
                permissions,
                gender,
                phoneNumber,
                profilePic: uploadedProfilePic,
                isVerified: true,
            });

            await user.save();

            // Format response to ensure profilePic is Cloudinary URL
            const formattedUser = {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                permissions: user.permissions,
                gender: user.gender || 'Unknown',
                phoneNumber: user.phoneNumber || '',
                profilePic: user.profilePic,
                status: user.status,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            };

            res.status(201).json({
                success: true,
                message: 'User created successfully',
                info: formattedUser
            });
        });
    } catch (error) {
        console.error('Add user error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

export const deleteUser = async (req, res) => {
    try {
        const { userId } = req.params;

        // Find user first to get their data
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        try {
            // 1. Delete user's profile picture from Cloudinary if exists
            if (user.profilePic && user.profilePic.includes('cloudinary.com')) {
                try {
                    // Extract public_id from Cloudinary URL
                    // Example URL: https://res.cloudinary.com/dgoaerv0k/image/upload/v1748073665/chat_app/profiles/3663579_hy6z2m.png
                    const urlParts = user.profilePic.split('/upload/');
                    if (urlParts.length === 2) {
                        // Remove version ID and file extension
                        const parts = urlParts[1].split('/');
                        const publicId = parts.slice(1).join('/').split('.')[0];
                        console.log('Deleting profile picture with publicId:', publicId);
                        await deleteImage(publicId);
                    }
                } catch (error) {
                    console.error('Error deleting profile picture:', error);
                }
            }

            // 2. Delete user's stories and their media
            const userStories = await Story.find({ userId });
            for (const story of userStories) {
                if (story.mediaUrl && story.mediaUrl.includes('cloudinary.com')) {
                    try {
                        // Extract public_id from Cloudinary URL
                        const urlParts = story.mediaUrl.split('/upload/');
                        if (urlParts.length === 2) {
                            // Remove version ID and file extension
                            const parts = urlParts[1].split('/');
                            const publicId = parts.slice(1).join('/').split('.')[0];
                            console.log('Deleting story media with publicId:', publicId);
                            await deleteImage(publicId);
                        }
                    } catch (error) {
                        console.error('Error deleting story media:', error);
                    }
                }
            }
            await Story.deleteMany({ userId });

            // 3. Delete user's messages
            await Message.deleteMany({ senderId: userId });

            // 4. Delete user's comments
            await Comment.deleteMany({ userId });

            // 5. Delete user's calls
            await Call.deleteMany({
                $or: [
                    { callerId: userId },
                    { receiverId: userId }
                ]
            });

            // 6. Delete user's support tickets
            await Support.deleteMany({ userId });

            // 7. Remove user from others' contacts
            await Contact.updateMany(
                { contacts: userId },
                { $pull: { contacts: userId } }
            );

            // 8. Delete user's own contacts
            await Contact.deleteMany({ userId });

            // 9. Update or delete chats
            const userChats = await Chat.find({
                $or: [
                    { participants: userId },
                    { createdBy: userId }
                ]
            });

            for (const chat of userChats) {
                // If chat has only one participant (the user being deleted), delete the chat
                if (chat.participants.length === 1) {
                    await Chat.deleteOne({ _id: chat._id });
                } else {
                    // Otherwise, remove user from participants
                    await Chat.updateOne(
                        { _id: chat._id },
                        {
                            $pull: { participants: userId },
                            $set: { updatedAt: new Date() }
                        }
                    );
                }
            }

            // 10. Finally, delete the user
            await User.deleteOne({ _id: userId });

            res.status(200).json({
                success: true,
                message: 'User and all related data deleted successfully'
            });
        } catch (error) {
            console.error('Error during deletion process:', error);
            throw error;
        }
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            message: 'Error deleting user',
            error: error.message
        });
    }
};

export const editUser = async (req, res) => {
    try {
        // Handle file upload first
        upload(req, res, async function (err) {
            if (err instanceof multer.MulterError) {
                return res.status(400).json({
                    message: 'File upload error',
                    error: err.message
                });
            } else if (err) {
                return res.status(400).json({
                    message: 'Invalid file type',
                    error: err.message
                });
            }

            const { userId } = req.params;
            const { username, email, password, gender, phoneNumber, role } = req.body;

            // Find user first
            const user = await User.findById(userId);
            if (!user) {
                return res.status(404).json({ message: 'User not found' });
            }

            // Check if email is being changed and if it's already taken
            if (email !== user.email) {
                const existingUser = await User.findOne({ email });
                if (existingUser) {
                    return res.status(400).json({ message: 'Email already in use' });
                }
            }

            // Validate role if provided
            if (role && !['user', 'admin', 'super_admin'].includes(role)) {
                return res.status(400).json({ message: 'Invalid role' });
            }

            // Handle profile picture upload
            let uploadedProfilePic = user.profilePic; // Keep existing by default
            try {
                if (req.file) {
                    // If there's an existing profile pic on Cloudinary, delete it
                    if (user.profilePic && user.profilePic.includes('cloudinary.com')) {
                        try {
                            const urlParts = user.profilePic.split('/upload/');
                            if (urlParts.length === 2) {
                                // Remove version ID and file extension
                                const parts = urlParts[1].split('/');
                                const publicId = parts.slice(1).join('/').split('.')[0];
                                console.log('Deleting old profile picture with publicId:', publicId);
                                await deleteImage(publicId);
                            }
                        } catch (error) {
                            console.error('Error deleting old profile picture:', error);
                            // Continue even if old image deletion fails
                        }
                    }

                    // Convert buffer to base64
                    const base64Image = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
                    // Upload to Cloudinary
                    const uploadResult = await uploadImage(base64Image, 'chat_app/profiles');
                    if (!uploadResult || !uploadResult.url) {
                        throw new Error('Failed to upload image to Cloudinary');
                    }
                    uploadedProfilePic = uploadResult.url;
                }
            } catch (error) {
                console.error('Error handling profile picture:', error);
                return res.status(400).json({
                    message: 'Cannot upload profile picture',
                    error: error.message
                });
            }

            // Update user fields
            user.username = username;
            user.email = email;
            user.gender = gender;
            user.phoneNumber = phoneNumber;
            user.profilePic = uploadedProfilePic;

            // Update role and permissions if role is provided
            if (role) {
                user.role = role;
                // Update permissions based on new role
                if (role === 'super_admin') {
                    user.permissions = Object.fromEntries(
                        Object.keys(defaultPermissions.admin).map(key => [key, true])
                    );
                } else if (role === 'admin') {
                    user.permissions = { ...defaultPermissions.admin };
                } else {
                    user.permissions = { ...defaultPermissions.user };
                }
            }

            // Only update password if it's provided
            if (password) {
                user.password = password;
            }

            await user.save();

            // Format response
            const formattedUser = {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                permissions: user.permissions,
                gender: user.gender || 'unknown',
                phoneNumber: user.phoneNumber || 'unknown',
                profilePic: user.profilePic,
                status: user.status,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            };

            res.status(200).json({
                success: true,
                message: 'User updated successfully',
                info: formattedUser
            });
        });
    } catch (error) {
        console.error('Edit user error:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating user',
            error: error.message
        });
    }
};