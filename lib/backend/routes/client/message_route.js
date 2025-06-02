import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getMessage, saveMessage, deleteMessage } from '../../controllers/client/message_controller.js';

const router = express.Router();

// Các routes này đã được bảo vệ bởi authenticate và checkPermission('chat:read')
router.post('/get/:chatId', getMessage);

// Cần quyền ghi để lưu và xóa tin nhắn
router.post('/save', checkPermission('chat:write'), saveMessage);
router.post('/delete/:messageId', checkPermission('chat:write'), deleteMessage);

export default router;