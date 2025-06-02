import express from 'express';
import {
    login,
    signup,
    signout,
    verifyEmail,
    forgotPassword,
    resetPassword,
    checkAuth
} from '../controllers/client/auth_controller.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/login', login);
router.post('/signup', signup);
router.post('/verify-email', verifyEmail);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password/:token', resetPassword);

// Protected routes
router.post('/signout', authenticate, signout);
router.get('/me', authenticate, checkAuth);

export default router; 