import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getChat, createChat, testChatData, deleteChat } from '../../controllers/client/chat_controller.js';

const router = express.Router();

// Route cơ bản đã được bảo vệ bởi authenticate và checkPermission('chat:read') 
router.get('/get', getChat);
router.get('/test', testChatData);

// Cần quyền ghi để tạo và xóa chat
router.post('/create', checkPermission('chat:write'), createChat);
router.post('/delete/:chatId', checkPermission('chat:write'), deleteChat);

export default router;