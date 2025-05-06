import express from 'express';
import { verifyToken } from '../middleware/verifyToken.js';
import { getStory, createStory, likeStory, unlikeStory, deleteStory } from '../controllers/story_controller.js';

const router = express.Router();

router.get('/get-story', verifyToken, getStory);
router.post('/create-story', verifyToken, createStory);
router.post('/like-story/:storyId', verifyToken, likeStory);
router.post('/unlike-story/:storyId', verifyToken, unlikeStory);
router.post('/delete-story/:storyId', verifyToken, deleteStory);

export default router;
