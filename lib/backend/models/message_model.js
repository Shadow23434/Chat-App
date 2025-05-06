import mongoose from "mongoose";

const messageSchema = new mongoose.Schema({
    chatId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Chat',
        required: true
    },
    senderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String,
    },
    content: {
        type: String,
        required: true
    },
    mediaUrl: {
        type: String
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    isRead: {
        type: Boolean
    },
});

export const Message = mongoose.model('Message', messageSchema);