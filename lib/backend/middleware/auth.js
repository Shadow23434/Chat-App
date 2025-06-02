import jwt from 'jsonwebtoken';
import { User } from '../models/user_model.js';
import { Types } from 'mongoose';

export const authenticate = async (req, res, next) => {
    try {
        // Get token from cookie or Authorization header
        let token = req.cookies.token;

        // Check Authorization header if no cookie
        const authHeader = req.header('Authorization');
        if (!token && authHeader) {
            // Extract token from "Bearer TOKEN" format
            if (authHeader.startsWith('Bearer ')) {
                token = authHeader.substring(7);
            } else {
                token = authHeader; // Accept token directly
            }
        }

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'No authentication token',
            });
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_key');

        // Validate that decoded userId is a valid ObjectId
        if (!decoded.userId || !Types.ObjectId.isValid(decoded.userId)) {
            return res.status(401).json({
                success: false,
                message: 'Invalid user ID in token',
            });
        }

        // Find user
        const user = await User.findById(decoded.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        // Update last login time
        user.lastLogin = new Date();
        await user.save();

        // Add user and permissions to request
        req.user = user;
        req.userId = user._id.toString(); // Store as string for consistency
        req.userRole = user.role;
        req.permissions = user.permissions;
        req.isAdmin = user.role === 'admin' || user.role === 'super_admin';

        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Token expired'
            });
        }

        console.error('Auth error:', error);
        return res.status(500).json({
            success: false,
            message: 'Server error',
        });
    }
}; 