import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getStory, createStory, likeStory, unlikeStory, deleteStory } from '../../controllers/client/story_controller.js';

const router = express.Router();

// Route cơ bản đã được bảo vệ bởi authenticate và checkPermission('story:read')
router.get('/get', getStory);

// Cần quyền ghi để tạo, thích và xóa story
router.post('/create', checkPermission('story:write'), createStory);
router.post('/like/:storyId', checkPermission('story:write'), likeStory);
router.post('/unlike/:storyId', checkPermission('story:write'), unlikeStory);
router.post('/delete/:storyId', checkPermission('story:write'), deleteStory);

export default router;
