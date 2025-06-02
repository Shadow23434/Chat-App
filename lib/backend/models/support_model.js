import mongoose from 'mongoose';

const supportSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    subject: {
        type: String,
        required: true,
        trim: true
    },
    message: {
        type: String,
        required: true
    },
    category: {
        type: String,
        enum: ['account', 'technical', 'billing', 'feature', 'other'],
        default: 'other'
    },
    status: {
        type: String,
        enum: ['pending', 'in_progress', 'answered', 'resolved', 'closed'],
        default: 'pending'
    },
    priority: {
        type: String,
        enum: ['low', 'medium', 'high', 'critical'],
        default: 'medium'
    },
    attachments: [{
        url: String,
        type: String,
        name: String
    }],
    responses: [{
        adminId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Admin',
        },
        message: String,
        createdAt: {
            type: Date,
            default: Date.now
        }
    }],
    assignedTo: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Admin',
        default: null
    },
    closedAt: {
        type: Date,
        default: null
    }
}, { timestamps: true });

// Virtual for time elapsed since creation
supportSchema.virtual('timeElapsed').get(function () {
    const now = new Date();
    const createdAt = this.createdAt;
    const diff = now - createdAt;

    // Convert to hours
    return Math.floor(diff / (1000 * 60 * 60));
});

// Add a method to update status based on responses
supportSchema.methods.updateStatus = function () {
    if (this.status === 'closed' || this.status === 'resolved') {
        return;
    }

    if (this.responses && this.responses.length > 0) {
        this.status = 'answered';
    } else {
        this.status = 'pending';
    }
};

export const Support = mongoose.model('Support', supportSchema);
