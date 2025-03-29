import express from 'express'
import { login, signup, signout, verifyEmail, forgotPassword, resetPassword } from '../controllers/auth_controller.js';
const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.post('/signout', signout);
router.post('/verify-email', verifyEmail);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password/:token', resetPassword);

export default router;
