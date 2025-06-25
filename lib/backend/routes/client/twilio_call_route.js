import express from 'express';
const router = express.Router();
import { getTwilioToken } from '../../controllers/client/twilio_call_controller.js';

router.post('/twilio-token', getTwilioToken);

export default router;
