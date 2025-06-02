import jwt from 'jsonwebtoken';
import bcryptjs from 'bcryptjs';
import { User } from '../../models/user_model.js';

/**
 * Xử lý đăng nhập cho admin
 */
export const adminLogin = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find admin by email
        const query = {
            role: { $in: ['admin', 'super_admin'] }
        };

        // Use email if provided
        if (email) {
            query.email = email;
        } else {
            return res.status(400).json({ message: 'Email is required' });
        }

        // Find admin by email
        const admin = await User.findOne(query);

        if (!admin) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Kiểm tra mật khẩu
        const isPasswordValid = await bcryptjs.compare(password, admin.password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Tạo token
        const token = jwt.sign(
            { userId: admin._id, role: admin.role },
            process.env.JWT_SECRET || 'your_jwt_secret_key',
            { expiresIn: '24h' }
        );

        // Đặt cookie
        res.cookie('token', token, {
            httpOnly: true,
            maxAge: 24 * 60 * 60 * 1000 // 24 giờ
        });

        // Trả về token trong response body cho mobile clients
        res.status(200).json({
            success: true,
            message: 'Login successfully',
            info: {
                id: admin._id,
                username: admin.username,
                profilePic: admin.profilePic,
                role: admin.role,
                email: admin.email,
                phoneNumber: admin.phoneNumber || 'Unknown',
                lastLogin: admin.lastLogin
            },
            token: token,
        });
    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

/**
 * Xử lý đăng xuất cho admin
 */
export const adminLogout = (req, res) => {
    res.clearCookie('token');
    res.status(200).json({ message: 'Logout successfully' });
};

/**
 * Kiểm tra xác thực admin
 */
export const validateAdmin = async (req, res) => {
    try {
        const admin = await User.findById(req.userId).select('-password');
        if (!admin || (admin.role !== 'admin' && admin.role !== 'super_admin')) {
            return res.status(404).json({ message: 'Admin not found' });
        }

        res.status(200).json({
            admin: admin
        });
    } catch (error) {
        console.error('Validate admin error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};