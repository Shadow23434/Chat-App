import { Story } from '../../models/story_model.js';
import { Comment } from '../../models/comment_model.js';
import { deleteImage } from '../../utils/cloudinary.js';

export const getStories = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;
        const sort = req.query.sort === 'asc' ? 1 : -1; // 1 for asc, -1 for desc
        const search = req.query.search || '';
        const statusFilter = req.query.status; // 'active', 'expired', or undefined

        let pipeline = [];

        pipeline.push({
            $lookup: {
                from: 'users',
                localField: 'userId',
                foreignField: '_id',
                as: 'userDetails'
            }
        });

        pipeline.push({
            $unwind: {
                path: '$userDetails',
                preserveNullAndEmptyArrays: true
            }
        });

        // Add search condition if search term is provided
        if (search) {
            const searchRegex = new RegExp(search, 'i');
            pipeline.push({
                $match: {
                    $or: [
                        { 'userDetails.email': { $exists: true, $regex: searchRegex } },
                        { 'caption': { $exists: true, $regex: searchRegex } }
                    ]
                }
            });
        }

        // Add status filter condition
        if (statusFilter === 'active') {
            pipeline.push({
                $match: {
                    expiresAt: { $gt: new Date() }
                }
            });
        } else if (statusFilter === 'expired') {
            pipeline.push({
                $match: {
                    expiresAt: { $lte: new Date() }
                }
            });
        }

        // Lookup comments for each story
        pipeline.push({
            $lookup: {
                from: 'comments',
                localField: '_id',
                foreignField: 'storyId',
                as: 'comments'
            }
        });

        // Add commentCount field
        pipeline.push({
            $addFields: {
                commentCount: { $size: '$comments' }
            }
        });

        // Remove the temporary comments array
        pipeline.push({
            $unset: 'comments'
        });

        // Add sort condition (fixed to createdAt)
        const sortStage = {};
        sortStage['createdAt'] = sort;
        pipeline.push({ $sort: sortStage });

        // Add pagination stages
        pipeline.push(
            { $skip: skip },
            { $limit: limit }
        );

        // Execute the aggregation pipeline for stories
        const stories = await Story.aggregate(pipeline);

        // Get total count with search and status filtering applied
        const countPipeline = [];

        countPipeline.push({
            $lookup: {
                from: 'users',
                localField: 'userId',
                foreignField: '_id',
                as: 'userDetails'
            }
        });
        countPipeline.push({
            $unwind: {
                path: '$userDetails',
                preserveNullAndEmptyArrays: true
            }
        });
        // Add the same search match stage as the main pipeline
        if (search) {
            const searchRegex = new RegExp(search, 'i');
            countPipeline.push({
                $match: {
                    $or: [
                        { 'userDetails.email': { $exists: true, $regex: searchRegex } },
                        { 'caption': { $exists: true, $regex: searchRegex } }
                    ]
                }
            });
        }
        // Add the same status filter condition to the count pipeline
        if (statusFilter === 'active') {
            countPipeline.push({
                $match: {
                    expiresAt: { $gt: new Date() }
                }
            });
        } else if (statusFilter === 'expired') {
            countPipeline.push({
                $match: {
                    expiresAt: { $lte: new Date() }
                }
            });
        }

        countPipeline.push({
            $lookup: {
                from: 'comments',
                localField: '_id',
                foreignField: 'storyId',
                as: 'comments'
            }
        });

        countPipeline.push({
            $addFields: {
                commentCount: { $size: '$comments' }
            }
        });

        // Remove the temporary comments array in count pipeline
        countPipeline.push({
            $unset: 'comments'
        });

        countPipeline.push({ $count: 'total' });

        const totalResult = await Story.aggregate(countPipeline);
        const totalStories = totalResult.length > 0 ? totalResult[0].total : 0;

        const formattedStories = stories.map(story => {
            // Create a base story object without userDetails
            const formattedStory = { ...story };
            delete formattedStory.userDetails;

            // Handle user data
            if (story.userDetails && typeof story.userDetails === 'object') {
                formattedStory.userId = {
                    _id: story.userDetails._id,
                    username: story.userDetails.username,
                    email: story.userDetails.email,
                    profilePic: story.userDetails.profilePic,
                };
            } else {
                formattedStory.userId = null;
            }

            return formattedStory;
        });

        res.status(200).json({
            stories: formattedStories,
            pagination: {
                total: totalStories,
                page,
                pages: Math.ceil(totalStories / limit)
            }
        });
    } catch (error) {
        console.error('Get stories error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

export const deleteStory = async (req, res) => {
    try {
        const { storyId } = req.params;

        const story = await Story.findById(storyId);
        if (!story) {
            return res.status(404).json({
                success: false,
                message: 'Story not found'
            });
        }

        // Delete media from Cloudinary if it's a Cloudinary URL
        if (story.mediaUrl && story.mediaUrl.includes('cloudinary.com')) {
            try {
                // Extract public_id from Cloudinary URL
                const publicId = story.mediaUrl.split('/upload/')[1].split('/').slice(1).join('/').split('.')[0];
                await deleteImage('chat_app/stories/' + publicId);
            } catch (error) {
                console.error('Error deleting story media from Cloudinary:', error);
                // Continue with story deletion even if media deletion fails
            }
        }

        // Delete background from Cloudinary if it exists and is a Cloudinary URL
        if (story.backgroundUrl && story.backgroundUrl.includes('cloudinary.com')) {
            try {
                // Extract public_id from Cloudinary URL
                const publicId = story.backgroundUrl.split('/upload/')[1].split('/').slice(1).join('/').split('.')[0];
                await deleteImage('chat_app/stories/backgrounds/' + publicId);
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
        console.error('Delete story error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error',
            error: error.message
        });
    }
};

export const getComments = async (req, res) => {
    try {
        const { storyId } = req.params;

        if (!storyId) {
            return res.status(400).json({ message: 'Story ID is required' });
        }

        const comments = await Comment.find({ storyId: storyId })
            .populate('userId', 'username email profilePic')
            .sort({ createdAt: 1 });
        res.status(200).json(comments);

    } catch (error) {
        console.error('Get comments error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

export const cleanupExpiredStories = async () => {
    try {
        const oneMonthAgo = new Date();
        oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);

        // Find stories that expired more than a month ago
        const expiredStories = await Story.find({
            expiresAt: { $lt: oneMonthAgo }
        });

        console.log(`Found ${expiredStories.length} stories to clean up`);

        for (const story of expiredStories) {
            try {
                // Delete media from Cloudinary if it's a Cloudinary URL
                if (story.mediaUrl && story.mediaUrl.includes('cloudinary.com')) {
                    try {
                        const publicId = story.mediaUrl.split('/upload/')[1].split('/').slice(1).join('/').split('.')[0];
                        await deleteImage('chat_app/stories/' + publicId);
                    } catch (error) {
                        console.error('Error deleting story media from Cloudinary:', error);
                    }
                }

                // Delete background from Cloudinary if it exists
                if (story.backgroundUrl && story.backgroundUrl.includes('cloudinary.com')) {
                    try {
                        const publicId = story.backgroundUrl.split('/upload/')[1].split('/').slice(1).join('/').split('.')[0];
                        await deleteImage('chat_app/stories/backgrounds/' + publicId);
                    } catch (error) {
                        console.error('Error deleting story background from Cloudinary:', error);
                    }
                }

                // Delete all comments associated with the story
                await Comment.deleteMany({ storyId: story._id });

                // Delete the story
                await Story.deleteOne({ _id: story._id });

                console.log(`Successfully cleaned up story: ${story._id}`);
            } catch (error) {
                console.error(`Error cleaning up story ${story._id}:`, error);
            }
        }

        console.log('Story cleanup completed');
    } catch (error) {
        console.error('Error in cleanupExpiredStories:', error);
    }
}; 