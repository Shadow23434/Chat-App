import { connectDB } from '../db/connect.js';
import { Story } from '../models/story_model.js';
import { uploadImage } from '../utils/cloudinary.js';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Get the current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../../.env') });
dotenv.config({ path: path.resolve(__dirname, '../../.env') });
dotenv.config();

const migrateStoryBackgrounds = async () => {
    try {
        // Connect to MongoDB
        await connectDB();
        console.log('Connected to MongoDB');

        // Get all stories with background URLs
        const stories = await Story.find({ backgroundUrl: { $exists: true, $ne: null } });
        console.log(`Found ${stories.length} stories with background images`);

        // Process each story
        for (const story of stories) {
            try {
                console.log(`Processing story ${story._id}`);

                // Upload to Cloudinary in chat_app/stories/background folder
                const result = await uploadImage(story.backgroundUrl, 'chat_app/stories/background');

                // Update story's background URL
                story.backgroundUrl = result.url;
                await story.save();

                console.log(`Successfully migrated background image for story ${story._id}`);
            } catch (error) {
                console.error(`Error processing story ${story._id}:`, error.message);
                continue; // Continue with next story even if one fails
            }
        }

        console.log('Migration completed');
        process.exit(0);
    } catch (error) {
        console.error('Migration failed:', error);
        process.exit(1);
    }
};

// Run the migration
migrateStoryBackgrounds(); 