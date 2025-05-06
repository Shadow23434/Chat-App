import express from 'express';
import { verifyToken } from '../middleware/verifyToken.js';
import { getComment, createComment, likeComment, unlikeComment, deleteComment } from '../controllers/comment_controller.js';

const router = express.Router();

router.get('/get-comment/:storyId', verifyToken, getComment);
router.post('/create-comment', verifyToken, createComment);
router.post('/like-comment/:commentId', verifyToken, likeComment);
router.post('/unlike-comment/:commentId', verifyToken, unlikeComment);
router.post('/delete-comment/:commentId', verifyToken, deleteComment);

export default router;
