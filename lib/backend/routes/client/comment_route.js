import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getComment, createComment, likeComment, unlikeComment, deleteComment } from '../../controllers/client/comment_controller.js';

const router = express.Router();

// Các routes đã được bảo vệ bởi authenticate và checkPermission('story:read')
router.get('/get/:storyId', getComment);

// Cần quyền ghi để tạo, thích và xóa comment
router.post('/create', checkPermission('story:write'), createComment);
router.post('/like/:commentId', checkPermission('story:write'), likeComment);
router.post('/unlike/:commentId', checkPermission('story:write'), unlikeComment);
router.post('/delete/:commentId', checkPermission('story:write'), deleteComment);

export default router;
