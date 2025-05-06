import { Comment } from '../models/comment_model.js';
import { Story } from '../models/story_model.js';
import { Types } from 'mongoose';

export const getComment = async (req, res) => {
    try {
        const { storyId } = req.params;

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

        const comments = await Comment.find({ storyId })
            .populate('userId', 'username profilePic')
            .sort({ createdAt: -1 })
            .lean();

        console.log('Fetched comments:', JSON.stringify(comments, null, 2));

        const commentMap = new Map();
        const topLevelComments = [];

        comments.forEach(comment => {
            comment.replies = [];
            commentMap.set(comment._id.toString(), comment);
        });

        comments.forEach(comment => {
            if (!comment.parentCommentId) {
                topLevelComments.push(comment);
            } else {
                const parent = commentMap.get(comment.parentCommentId.toString());
                if (parent) {
                    parent.replies.push(comment);
                } else {
                    console.log('Parent not found for comment:', comment._id.toString());
                }
            }
        });

        topLevelComments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        topLevelComments.forEach(comment => {
            comment.replies.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        });

        console.log('Top-level comments:', JSON.stringify(topLevelComments, null, 2));

        res.status(200).json({
            success: true,
            comments: topLevelComments
        });
    } catch (error) {
        console.error('Error in getComments:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch comments',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

export const createComment = async (req, res) => {
    try {
        const { storyId, parentCommentId, content } = req.body;
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

        if (!content) {
            return res.status(400).json({
                success: false,
                message: 'Comment content is required'
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

        if (parentCommentId) {
            if (!Types.ObjectId.isValid(parentCommentId)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid parent comment ID'
                });
            }

            const parentComment = await Comment.findById(parentCommentId);
            if (!parentComment) {
                return res.status(404).json({
                    success: false,
                    message: 'Parent comment not found'
                });
            }

            if (parentComment.storyId.toString() !== storyId) {
                return res.status(400).json({
                    success: false,
                    message: 'Parent comment does not belong to this story'
                });
            }
        }

        const comment = new Comment({
            userId: userId,
            storyId,
            parentCommentId: parentCommentId || null,
            content,
            likes: 0
        });

        await comment.save();

        res.status(201).json({
            success: true,
            comment: comment
        });
    } catch (error) {
        console.error('Error in createComment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create comment',
        });
    }
};

export const likeComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!commentId || !Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid comment ID'
            });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({
                success: false,
                message: 'Comment not found'
            });
        }

        const story = await Story.findById(comment.storyId);
        if (!story || story.expiresAt < new Date()) {
            return res.status(410).json({
                success: false,
                message: 'Story has expired or not found'
            });
        }

        comment.likes += 1;
        await comment.save();

        res.status(200).json({
            success: true,
            likes: comment.likes
        });
    } catch (error) {
        console.error('Error in likeComment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to like comment',
        });
    }
};

export const unlikeComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!commentId || !Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid comment ID'
            });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({
                success: false,
                message: 'Comment not found'
            });
        }

        const story = await Story.findById(comment.storyId);
        if (!story || story.expiresAt < new Date()) {
            return res.status(410).json({
                success: false,
                message: 'Story has expired or not found'
            });
        }

        if (comment.likes > 0) {
            comment.likes -= 1;
            await comment.save();
        } else {
            return res.status(400).json({
                success: false,
                message: 'Story has no likes to remove'
            });
        }

        res.status(200).json({
            success: true,
            likes: comment.likes
        });
    } catch (error) {
        console.error('Error in unlikeComment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to unlike comment',
        });
    }
};

export const deleteComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const userId = req.userId;

        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        if (!commentId || !Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid comment ID'
            });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({
                success: false,
                message: 'Comment not found'
            });
        }

        if (comment.userId.toString() !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized: You can only delete your own comments'
            });
        }

        const story = await Story.findById(comment.storyId);
        if (!story || story.expiresAt < new Date()) {
            return res.status(410).json({
                success: false,
                message: 'Story has expired or not found'
            });
        }

        await Comment.deleteMany({ $or: [{ _id: commentId }, { parentCommentId: commentId }] });

        res.status(200).json({
            success: true,
            message: 'Comment and its replies deleted successfully'
        });
    } catch (error) {
        console.error('Error in deleteComment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete comment',
        });
    }
};
