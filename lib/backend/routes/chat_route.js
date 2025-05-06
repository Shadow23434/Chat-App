import express from 'express';
import { verifyToken } from '../middleware/verifyToken.js';
import { getChat } from '../controllers/chat_controller.js';

const router = express.Router();

router.get('/get-chat', verifyToken, getChat);

export default router;