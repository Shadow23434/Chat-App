import express from 'express';
import { getCall } from '../../controllers/client/call_controller.js';

const router = express.Router();

router.get('/get', getCall);

export default router;
