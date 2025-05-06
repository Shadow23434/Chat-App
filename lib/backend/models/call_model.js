import mongoose from "mongoose";

const callSchema = new mongoose.Schema({
    callerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    receiverId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    status: {
        type: String,
        default: 'missed',
        enum: ['missed', 'received']
    },
    duration: {
        type: Number,
        default: 0,
    },
    startedAt: Date,
    endedAt: Date,
});

export const Call = mongoose.model('Call', callSchema);
