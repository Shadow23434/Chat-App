import { Story } from '../../models/story_model.js';
import { Contact } from '../../models/contact_model.js';
import { Comment } from '../../models/comment_model.js';
import { Types } from 'mongoose';
import { uploadImage, deleteImage } from '../../utils/cloudinary.js';

export const getStory = async (req, res) => {
    const userId = req.userId;

    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const contacts = await Contact.find({
            $or: [
                { userId1: userId, status: 'accepted' },
                { userId2: userId, status: 'accepted' }
            ]
        }).lean();

        const contactUserIds = contacts.map(contact =>
            contact.userId1.toString() === userId.toString()
                ? contact.userId2
                : contact.userId1
        );

        if (contactUserIds.length === 0) {
            return res.status(200).json({
                success: true,
                stories: []
            });
        }

        const stories = await Story.find({
            userId: { $in: contactUserIds },
            expiresAt: { $gt: new Date() }
        })
            .populate({
                path: 'userId',
                select: 'username profilePic'
            })
            .sort({ createdAt: -1 })
            .lean();

        return res.status(200).json({
            success: true,
            stories
        });
    } catch (error) {
        console.error('Error in getStory:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch stories'
        });
    }
};

export const getOwnStory = async (req, res) => {
    const userId = req.userId;

    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const stories = await Story.find({
            userId: userId,
            expiresAt: { $gt: new Date() }
        })
            .populate({
                path: 'userId',
                select: 'username profilePic'
            })
            .sort({ createdAt: -1 })
            .lean();

        return res.status(200).json({
            success: true,
            stories
        });
    } catch (error) {
        console.error('Error in getOwnStory:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch own stories'
        });
    }
};

export const createStory = async (req, res) => {
    const { caption, type, mediaName, mediaUrl, backgroundUrl } = req.body;
    const userId = req.userId;

    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!type) {
            return res.status(400).json({
                success: false,
                message: 'Story type is required'
            });
        }

        // Debug Cloudinary configuration
        const cloudinaryConfig = {
            cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
            api_key: process.env.CLOUDINARY_API_KEY,
            api_secret: process.env.CLOUDINARY_API_SECRET ? '***' : undefined
        };

        console.log('Cloudinary configuration check:', {
            cloud_name: cloudinaryConfig.cloud_name ? 'Set' : 'Not set',
            api_key: cloudinaryConfig.api_key ? 'Set' : 'Not set',
            api_secret: cloudinaryConfig.api_secret ? 'Set' : 'Not set'
        });

        let finalMediaUrl = mediaUrl;
        let finalBackgroundUrl = backgroundUrl;
        let cloudinaryError = false;

        if ((type === 'audio' || type === 'video') && !finalBackgroundUrl) {
            finalBackgroundUrl = '/assets/images/default_story_bg.png'; // Thay bằng URL mặc định của bạn nếu cần
        }

        // Upload media to Cloudinary if it's a base64 string or local file path
        if (mediaUrl && (mediaUrl.startsWith('data:') || !mediaUrl.includes('cloudinary.com'))) {
            try {
                console.log('Uploading media to Cloudinary:', mediaUrl.substring(0, 100) + '...');
                const uploadResult = await uploadImage(mediaUrl, 'chat_app/stories');
                if (uploadResult && uploadResult.url) {
                    finalMediaUrl = uploadResult.url;
                    console.log('Media uploaded successfully to Cloudinary:', finalMediaUrl);
                }
            } catch (error) {
                cloudinaryError = true;
                console.error('Error uploading story media to Cloudinary:', error);
                // Continue with original media URL if upload fails
            }
        }

        // Upload background to Cloudinary if provided and not already a Cloudinary URL
        if (backgroundUrl && (backgroundUrl.startsWith('data:') || !backgroundUrl.includes('cloudinary.com'))) {
            try {
                console.log('Uploading background to Cloudinary:', backgroundUrl.substring(0, 100) + '...');
                const uploadResult = await uploadImage(backgroundUrl, 'chat_app/stories/backgrounds');
                if (uploadResult && uploadResult.url) {
                    finalBackgroundUrl = uploadResult.url;
                    console.log('Background uploaded successfully to Cloudinary:', finalBackgroundUrl);
                }
            } catch (error) {
                cloudinaryError = true;
                console.error('Error uploading story background to Cloudinary:', error);
                // Continue with original background URL if upload fails
            }
        }

        const createdAt = new Date();
        const expiresAt = new Date(createdAt.getTime() + 24 * 60 * 60 * 1000); // 24 hours

        const story = new Story({
            userId: userId,
            caption,
            type,
            mediaName,
            mediaUrl: finalMediaUrl,
            backgroundUrl: finalBackgroundUrl,
            createdAt: createdAt,
            expiresAt: expiresAt,
            likes: 0,
        });

        await story.save();

        const response = {
            success: true,
            message: 'Create story successfully',
            story: story
        };

        // Add a warning if Cloudinary had issues
        if (cloudinaryError) {
            response.warning = 'Some media files could not be uploaded to Cloudinary. Check your Cloudinary configuration and ensure CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET are properly set in your environment variables.';
            console.warn('Cloudinary upload failed for story creation. Check environment variables and Cloudinary configuration.');
        } else if (mediaUrl || backgroundUrl) {
            console.log('Story created successfully with Cloudinary uploads');
        }

        res.status(201).json(response);
    } catch (error) {
        console.error('Error in createStory:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create story',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const likeStory = async (req, res) => {
    try {
        const { storyId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!storyId || !Types.ObjectId.isValid(storyId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid story ID'
            });
        }

        const story = await Story.findById(storyId);
        if (!story) {
            return res.status(404).json({
                success: false,
                message: 'Story not found'
            });
        }

        if (story.expiresAt < new Date()) {
            return res.status(410).json({
                success: false,
                message: 'Story has expired'
            });
        }

        story.likes += 1;
        await story.save();

        res.status(200).json({
            success: true,
            likes: story.likes
        });
    } catch (error) {
        console.error('Error in likeStory:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to like story',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const unlikeStory = async (req, res) => {
    try {
        const { storyId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!storyId || !Types.ObjectId.isValid(storyId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid story ID'
            });
        }

        const story = await Story.findById(storyId);
        if (!story) {
            return res.status(404).json({
                success: false,
                message: 'Story not found'
            });
        }

        if (story.expiresAt < new Date()) {
            return res.status(410).json({
                success: false,
                message: 'Story has expired'
            });
        }

        if (story.likes > 0) {
            story.likes -= 1;
            await story.save();
        } else {
            return res.status(400).json({
                success: false,
                message: 'Story has no likes to remove'
            });
        }

        return res.status(200).json({
            success: true,
            likes: story.likes
        });
    } catch (error) {
        console.error('Error in unlikeStory:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to unlike story',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const deleteStory = async (req, res) => {
    try {
        const { storyId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!storyId || !Types.ObjectId.isValid(storyId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid story ID'
            });
        }

        const story = await Story.findById(storyId);
        if (!story) {
            return res.status(404).json({
                success: false,
                message: 'Story not found'
            });
        }

        if (story.userId.toString() !== userId.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized: You can only delete your own stories'
            });
        }

        // Delete media from Cloudinary if it's a Cloudinary URL
        if (story.mediaUrl && story.mediaUrl.includes('cloudinary.com')) {
            try {
                // Extract public_id correctly from Cloudinary URL
                const urlParts = story.mediaUrl.split('/upload/');
                if (urlParts.length > 1) {
                    const filePathWithExtension = urlParts[1];
                    // Remove version number if present (v1234567890/)
                    const pathWithoutVersion = filePathWithExtension.replace(/v\d+\//, '');
                    // Get the filename without extension
                    const publicId = pathWithoutVersion.substring(0, pathWithoutVersion.lastIndexOf('.'));
                    console.log('Extracted public_id for media:', publicId);

                    await deleteImage(publicId);
                }
            } catch (error) {
                console.error('Error deleting story media from Cloudinary:', error);
                // Continue with story deletion even if media deletion fails
            }
        }

        // Delete background from Cloudinary if it exists and is a Cloudinary URL
        if (story.backgroundUrl && story.backgroundUrl.includes('cloudinary.com')) {
            try {
                // Extract public_id correctly from Cloudinary URL
                const urlParts = story.backgroundUrl.split('/upload/');
                if (urlParts.length > 1) {
                    const filePathWithExtension = urlParts[1];
                    // Remove version number if present (v1234567890/)
                    const pathWithoutVersion = filePathWithExtension.replace(/v\d+\//, '');
                    // Get the filename without extension
                    const publicId = pathWithoutVersion.substring(0, pathWithoutVersion.lastIndexOf('.'));
                    console.log('Extracted public_id for background:', publicId);

                    await deleteImage(publicId);
                }
            } catch (error) {
                console.error('Error deleting story background from Cloudinary:', error);
                // Continue with story deletion even if background deletion fails
            }
        }

        // Delete all comments associated with the story
        await Comment.deleteMany({ storyId: storyId });

        // Delete the story
        await Story.deleteOne({ _id: storyId });

        res.status(200).json({
            success: true,
            message: 'Story deleted successfully'
        });
    } catch (error) {
        console.error('Error in deleteStory:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete story',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
