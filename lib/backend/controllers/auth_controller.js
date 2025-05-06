import bcryptjs from 'bcryptjs';
import crypto from 'crypto';
import { User } from '../models/user_model.js';
import { generateTokenAndSetCookie } from '../utils/generate_token_and_set_cookie.js'
import { sendVerificationEmail, sendWelcomeEmail, sendPasswordResetEmail, sendResetSuccessEmail } from '../mailtrap/emails.js';

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

        const hashedPassword = await bcryptjs.hash(password, 10);
        const verificationToken = Math.floor(100000 + Math.random() * 900000).toString();

        const user = new User({
            username,
            email,
            password: hashedPassword,
            verificationToken,
            verificationTokenExpiresAt: Date.now() + 24 * 60 * 60 * 1000 // 24 hours
        });

        await user.save();

        // jwt: json web token
        generateTokenAndSetCookie(res, user._id);

        await sendVerificationEmail(user.email, verificationToken);

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            user: {
                ...user._doc,
            }
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

        const token = generateTokenAndSetCookie(res, user._id);

        user.lastLogin = new Date();
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Loged in successfully',
            user: {
                ...user._doc,
                token,
            },
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
                ...user._doc,
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

        // Update password
        const hashedPassword = await bcryptjs.hash(password, 10);

        user.password = hashedPassword;
        user.resetPasswordToken = undefined;
        user.resetPasswordExpiresAt = undefined;
        await user.save();

        await sendResetSuccessEmail(user.email);

        res.status(200).json({
            success: true,
            message: 'Password reset successfully',
            user: {
                ...user._doc,
            },
        });
    } catch (error) {
        console.log('Error in resetPassword', error);
        res.status(400).json({ success: false, error: error.message });
    }


}

export const checkAuth = async (req, res) => {
    try {
        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(400).json({
                success: false,
                message: 'User not found',
            });
        }

        res.status(200).json({
            success: true,
            user,
        });
    } catch (error) {
        console.log('Error in checkAuth ', error);
        res.status(400).json({ success: false, message: error.message });
    }
}
