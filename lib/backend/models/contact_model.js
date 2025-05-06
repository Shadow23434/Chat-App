import mongoose from "mongoose";

const contactSchema = new mongoose.Schema({
    userId1: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    userId2: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    status: {
        type: String,
        default: 'pending',
        enum: ['pending', 'accepted']
    }
});

export const Contact = mongoose.model('Contact', contactSchema);
