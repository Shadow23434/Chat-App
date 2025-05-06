import mongoose from "mongoose";

const chatSchema = new mongoose.Schema({
    participantOneId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    participantTwoId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

chatSchema.statics.findByParticipants = function (userId1, userId2) {
    return this.findOne({
        $or: [
            { participantOne: userId1, participantTwo: userId2 },
            { participantOne: userId2, participantTwo: userId1 }
        ]
    });
};

export const Chat = mongoose.model('Chat', chatSchema);