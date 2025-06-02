import express from 'express';
import { checkPermission } from '../../middleware/check-permission.js';
import { getContact, addContact, acceptContact, deleteContact } from '../../controllers/client/contact_controller.js';

const router = express.Router();

// Các routes đã được bảo vệ bởi authenticate và checkPermission('contact:manage')
router.get('/get', getContact);
router.post('/add', checkPermission('contact:manage'), addContact);
router.post('/accept/:contactId', checkPermission('contact:manage'), acceptContact);
router.post('/delete/:contactId', checkPermission('contact:manage'), deleteContact);

export default router;