import bcryptjs from 'bcryptjs';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { User } from '../../models/user_model.js';
import { sendVerificationEmail, sendWelcomeEmail, sendPasswordResetEmail, sendResetSuccessEmail } from '../../mailtrap/emails.js';

const generateTokenAndSetCookie = (res, user) => {
    const token = jwt.sign(
        { userId: user._id, role: user.role },
        process.env.JWT_SECRET || 'your_jwt_secret_key',
        { expiresIn: '7d' }
    );

    res.cookie('token', token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    return token;
};

export const signup = async (req, res) => {
    const { email, password, username } = req.body;
    try {
        if (!email || !password || !username) {
            throw new Error('All fields are required');
        }

        const userAlreadyExists = await User.findOne({ email });
        if (userAlreadyExists) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }

        const verificationToken = Math.floor(100000 + Math.random() * 900000).toString();

        const user = new User({
            username,
            email,
            password, // Password will be hashed by the pre-save hook
            verificationToken,
            verificationTokenExpiresAt: Date.now() + 24 * 60 * 60 * 1000 // 24 hours
        });

        await user.save();

        // Generate JWT token
        const token = generateTokenAndSetCookie(res, user);

        await sendVerificationEmail(user.email, verificationToken);

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                isAdmin: user.role === 'admin' || user.role === 'super_admin',
                isVerified: user.isVerified
            },
            token
        });

    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
}

export const login = async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({
                success: false,
                message: 'Invalid email'
            });
        }

        const isPasswordValid = await bcryptjs.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(400).json({
                success: false,
                message: 'Invalid password'
            });
        }

        if (!user.isVerified) {
            return res.status(400).json({
                success: false,
                message: 'Please verify your email before logging in'
            });
        }

        // Generate token and set cookie
        const token = generateTokenAndSetCookie(res, user);

        user.lastLogin = new Date();
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Login successfully',
            info: {
                id: user._id,
                username: user.username,
                profilePic: user.profilePic,
                role: user.role,
                email: user.email,
                phoneNumber: user.phoneNumber || 'Unknown',
                lastLogin: user.lastLogin
            },
            token
        });
    } catch (error) {
        console.log('Error in login', error);
        res.status(400).json({ success: false, error: error.message });
    }
}

export const signout = async (req, res) => {
    res.clearCookie('token');
    res.status(200).json({
        success: true,
        message: 'Sign out successfully',
    });
}

export const verifyEmail = async (req, res) => {
    const { code } = req.body;
    try {
        const user = await User.findOne({
            verificationToken: code,
            verificationTokenExpiresAt: { $gt: Date.now() },
        });

        if (!user) {
            return res.status(400).json({ success: false, message: 'Invalid or expired verification code' })
        }

        user.isVerified = true;
        user.verificationToken = undefined;
        user.verificationTokenExpiresAt = undefined;
        await user.save();

        await sendWelcomeEmail(user.email, user.username);

        res.status(200).json({
            success: true,
            message: 'Email verified successfully',
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                isAdmin: user.role === 'admin' || user.role === 'super_admin'
            }
        });
    } catch (error) {
        console.log('Error in verifyEmail', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
}

export const forgotPassword = async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({
                success: false,
                message: 'User not found',
            });
        }

        // Generate reset token
        const resetToken = crypto.randomBytes(20).toString('hex');
        const resetTokenExpireAt = Date.now() + 1 * 60 * 60 * 1000 // 1 hour 

        user.resetPasswordToken = resetToken;
        user.resetPasswordExpiresAt = resetTokenExpireAt;
        await user.save();

        await sendPasswordResetEmail(user.email, `${process.env.CLIENT_URL}/reset-password/${resetToken}`);

        res.status(200).json({
            success: true,
            message: 'Password reset link sent to your email',
        });
    } catch (error) {
        console.log('Error in forgotPassword', error);
        res.status(400).json({ success: false, error: error.message });
    }
}

export const resetPassword = async (req, res) => {
    try {
        const { token } = req.params;
        const { password } = req.body;

        const user = await User.findOne({
            resetPasswordToken: token,
            resetPasswordExpiresAt: { $gt: Date.now() },
        });

        if (!user) {
            return res.status(400).json({
                success: false,
                message: 'Invalid or expired reset token'
            });
        }

        // Update password - will be hashed by pre-save hook
        user.password = password;
        user.resetPasswordToken = undefined;
        user.resetPasswordExpiresAt = undefined;
        await user.save();

        await sendResetSuccessEmail(user.email);

        res.status(200).json({
            success: true,
            message: 'Password reset successfully',
        });
    } catch (error) {
        console.log('Error in resetPassword', error);
        res.status(400).json({ success: false, error: error.message });
    }
}

export const checkAuth = async (req, res) => {
    try {
        res.status(200).json({
            success: true,
            user: {
                id: req.user._id,
                username: req.user.username,
                email: req.user.email,
                profilePic: req.user.profilePic,
                role: req.user.role,
                isAdmin: req.isAdmin
            }
        });
    } catch (error) {
        console.log('Error in checkAuth ', error);
        res.status(400).json({ success: false, message: error.message });
    }
}
