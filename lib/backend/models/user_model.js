import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        require: true,
    },
    email: {
        type: String,
        require: true,
        unique: true,
    },
    password: {
        type: String,
        require: true,
    },
    phoneNumber: String,
    gender: {
        type: String,
        default: 'unknown',
        enum: ['male', 'female', 'unknown'],
    },
    profilePic: String,
    isVerified: {
        type: Boolean,
        default: false,
    },
    lastLogin: {
        type: Date,
        default: Date.now,
    },
    resetPasswordToken: String,
    resetPasswordExpiresAt: Date,
    verificationToken: String,
    verificationTokenExpiresAt: Date,
}, { timestamps: true });

export const User = mongoose.model('User', userSchema);
