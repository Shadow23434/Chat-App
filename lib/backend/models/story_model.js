import mongoose from 'mongoose';

const storySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    caption: { type: String },
    type: {
        type: String,
        enum: ['image', 'video', 'audio'],
        required: true
    },
    backgroundUrl: {
        type: String,
        default: 'https://wallpapers.com/images/hd/blue-background-nsslj0em6ihbyo5q.jpg',
    },
    mediaName: { type: String },
    mediaUrl: {
        type: String,
    },
    createdAt: {
        type: Date,
        required: true,
    },
    expiresAt: {
        type: Date,
        required: true,
    },
    likes: { type: Number, default: 0 }
});

export const Story = mongoose.model('Story', storySchema);
