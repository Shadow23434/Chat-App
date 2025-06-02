import express from 'express';
import { getUsers, deleteUser, addUser, editUser } from '../../controllers/admin/user_controller.js';
import { getChats, getChatDetails, deleteChat, deleteMessage, downloadChat, downloadAllChats } from '../../controllers/admin/chat_controller.js';
import { deleteStory, getComments, getStories } from '../../controllers/admin/story_controller.js';
import { deleteCall, getCalls } from '../../controllers/admin/call_controller.js';
import { getSupport, getSupportDetails, respondToSupport } from '../../controllers/admin/support_controller.js';
import { validateAdmin } from '../../controllers/admin/auth_controller.js';
import { checkPermission } from '../../middleware/check-permission.js';

const router = express.Router();

// Admin profile validation
router.get('/profile', validateAdmin);

// Users Management
router.get('/users', checkPermission('admin:users:read'), getUsers);
router.post('/users/add', checkPermission('admin:users:write'), addUser);
router.post('/users/delete/:userId', checkPermission('admin:users:write'), deleteUser);
router.post('/users/edit/:userId', checkPermission('admin:users:write'), editUser);

// Chat Management
router.get('/chats', checkPermission('admin:chats:read'), getChats);
router.get('/chats/download-all', checkPermission('admin:chats:write'), downloadAllChats);
router.get('/chats/download/:chatId', checkPermission('admin:chats:write'), downloadChat);
router.get('/chats/:chatId', checkPermission('admin:chats:read'), getChatDetails);
router.post('/chats/delete/:chatId', checkPermission('admin:chats:write'), deleteChat);
router.post('/messages/delete/:messageId', checkPermission('admin:chats:write'), deleteMessage);

// Story Management
router.get('/stories', checkPermission('admin:stories:read'), getStories);
router.get('/comments/:storyId', checkPermission('admin:stories:read'), getComments);
router.post('/stories/delete/:storyId', checkPermission('admin:stories:write'), deleteStory);

// Call Management
router.get('/calls', checkPermission('admin:calls:read'), getCalls);
router.post('/calls/delete/:callId', checkPermission('admin:calls:write'), deleteCall);

// Support Management
router.get('/support', checkPermission('admin:support:read'), getSupport);
router.get('/support/:ticketId', checkPermission('admin:support:read'), getSupportDetails);
router.post('/support/:ticketId/respond', checkPermission('admin:support:write'), respondToSupport);

export default router; 