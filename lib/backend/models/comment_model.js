import mongoose from 'mongoose';

const commentSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
        storyId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Story',
            required: true
        },
        parentCommentId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Comment',
            default: null
        },
        content: {
            type: String,
            required: true
        },
        createdAt: {
            type: Date,
            default: Date.now
        },
        likes: {
            type: Number,
            default: 0
        }
    },
    {
        timestamps: true,
        toJSON: { virtuals: true }
    }
);

commentSchema.virtual('replies', {
    ref: 'Comment',
    localField: '_id',
    foreignField: 'parentCommentId'
});

commentSchema.index({ storyId: 1, createdAt: -1 });
commentSchema.index({ parentCommentId: 1 });

export const Comment = mongoose.model('Comment', commentSchema);
