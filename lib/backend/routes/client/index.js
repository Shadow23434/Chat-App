import express from 'express';
import chatRoutes from './chat_route.js';
import messageRoutes from './message_route.js';
import storyRoutes from './story_route.js';
import commentRoutes from './comment_route.js';
import contactRoutes from './contact_route.js';
import profileRoutes from './profile_route.js';
import callRoutes from './call_route.js';
import { checkPermission } from '../../middleware/check-permission.js';

const router = express.Router();

// Tổ chức routes theo chức năng và kiểm tra quyền ở mức độ fine-grained
router.use('/chats', checkPermission('chat:read'), chatRoutes);
router.use('/messages', checkPermission('chat:read'), messageRoutes);
router.use('/stories', checkPermission('story:read'), storyRoutes);
router.use('/comments', checkPermission('story:read'), commentRoutes);
router.use('/contacts', checkPermission('contact:manage'), contactRoutes);
router.use('/profiles', checkPermission('user:profile:read'), profileRoutes);
router.use('/calls', checkPermission('call:create'), callRoutes);

export default router; 