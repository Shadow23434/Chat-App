import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getProfile, editProfile, searchProfile } from '../../controllers/client/profile_controller.js';

const router = express.Router();

router.get('/get/:userId', getProfile);
router.get('/search', searchProfile);
router.put('/edit', checkPermission('user:profile:edit'), editProfile);

export default router;
