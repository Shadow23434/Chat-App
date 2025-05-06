import { Story } from '../models/story_model.js';
import { Contact } from '../models/contact_model.js';
import { Comment } from '../models/comment_model.js';
import { Types } from 'mongoose';

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

        if (!mediaUrl || !type) {
            return res.status(400).json({
                success: false,
                message: 'mediaUrl and type are required'
            });
        }

        const createdAt = new Date();
        const expiresAt = new Date(createdAt.getTime() + 24 * 60 * 60 * 1000); // 24 hours

        const story = new Story({
            userId: userId,
            caption,
            type,
            mediaName,
            mediaUrl,
            backgroundUrl,
            createdAt: createdAt,
            expiresAt: expiresAt,
            likes: 0,
        });

        await story.save();

        res.status(201).json({
            success: true,
            message: 'Create story successfully',
            story: story
        });
    } catch (error) {
        console.error('Error in createStory:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create story',
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

        if (story.userId.toString() !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized: You can only delete your own stories'
            });
        }

        await Story.deleteOne({ _id: storyId });
        await Comment.deleteMany({ storyId });

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
