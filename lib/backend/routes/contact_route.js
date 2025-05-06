import express from 'express';
import { fetchContacts, addContact, acceptContact, deleteContact } from '../controllers/contact_controller.js';
import { verifyToken } from '../middleware/verifyToken.js';

const router = express.Router();

router.get('/get-contact', verifyToken, fetchContacts);
router.post('/add-contact', verifyToken, addContact);
router.post('/accept-contact/:contactId', verifyToken, acceptContact);
router.post('/delete-contact/:contactId', verifyToken, deleteContact);

export default router;