import express from 'express';
import clientRoutes from './client/index.js';
import adminRoutes from './admin/index.js';
import authRoutes from './auth_routes.js';
import { adminLogin, adminLogout } from '../controllers/admin/auth_controller.js';
import { authenticate } from '../middleware/auth.js';
import { checkPermission } from '../middleware/check-permission.js';

const router = express.Router();

// Auth routes (public)
router.use('/api/auth', authRoutes);

// Admin auth routes (public)
const adminAuthRouter = express.Router();
adminAuthRouter.post('/login', adminLogin);
adminAuthRouter.post('/logout', adminLogout);
router.use('/api/admin/auth', adminAuthRouter);

// Client routes
router.use('/api', authenticate, clientRoutes);

// Admin protected routes
router.use('/api/admin', authenticate, checkPermission('admin:users:read'), adminRoutes);

export default router; 