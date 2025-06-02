import mongoose from "mongoose";
import bcryptjs from "bcryptjs";

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
    role: {
        type: String,
        enum: ['user', 'admin', 'super_admin'],
        default: 'user'
    },
    permissions: {
        type: Map,
        of: Boolean,
        default: () => ({
            // User default permissions
            'user:profile:read': true,
            'user:profile:edit': true,
            'chat:read': true,
            'chat:write': true,
            'story:read': true,
            'story:write': true,
            'call:create': true,
            'contact:manage': true,
            // Admin permissions are false by default
            'admin:users:read': false,
            'admin:users:write': false,
            'admin:stats:read': false,
            'admin:chats:read': false,
            'admin:stories:read': false,
            'admin:calls:read': false,
            'admin:support:read': false,
            'admin:support:write': false
        })
    },
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

// Pre-save hook to set permissions based on role
userSchema.pre('save', function (next) {
    if (this.isModified('role')) {
        if (this.role === 'admin') {
            // Grant admin permissions
            this.permissions.set('admin:users:read', true);
            this.permissions.set('admin:stats:read', true);
            this.permissions.set('admin:chats:read', true);
            this.permissions.set('admin:stories:read', true);
            this.permissions.set('admin:calls:read', true);
            this.permissions.set('admin:support:read', true);
            this.permissions.set('admin:support:write', true);
        }
        else if (this.role === 'super_admin') {
            // Grant all permissions
            this.permissions.set('admin:users:read', true);
            this.permissions.set('admin:users:write', true);
            this.permissions.set('admin:stats:read', true);
            this.permissions.set('admin:chats:read', true);
            this.permissions.set('admin:stories:read', true);
            this.permissions.set('admin:calls:read', true);
            this.permissions.set('admin:support:read', true);
            this.permissions.set('admin:support:write', true);
        }
    }

    // Hash password if it's modified
    if (this.isModified('password')) {
        this.password = bcryptjs.hashSync(this.password, 10);
    }

    next();
});

export const User = mongoose.model('User', userSchema);
