import express from 'express';
import { fetchAllMessagesByChatId, saveMessage, deleteMessage } from '../controllers/message_controller.js';
import { verifyToken } from '../middleware/verifyToken.js';

const router = express.Router();

router.post('/get-message/:chatId', verifyToken, fetchAllMessagesByChatId);
router.post('/save-message', verifyToken, saveMessage);
router.post('/delete-message/:messageId', verifyToken, deleteMessage);

export default router;