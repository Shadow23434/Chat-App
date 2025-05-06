import express from 'express';
import { verifyToken } from '../middleware/verifyToken.js';
import { getCall } from '../controllers/call_controller.js';

const router = express.Router();

router.get('/get-call', verifyToken, getCall);

export default router;
