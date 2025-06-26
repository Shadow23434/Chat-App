import express from 'express';
const router = express.Router();
import { getAgoraToken } from '../../controllers/client/agora_call_controller.js';

router.post('/get-token', getAgoraToken);

export default router;
