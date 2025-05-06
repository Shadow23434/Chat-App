import express from 'express';
import { getProfile } from '../controllers/profile_controller.js';
import { verifyToken } from '../middleware/verifyToken.js';

const router = express.Router();

router.get('/get-profile/:userId', verifyToken, getProfile);

export default router;
