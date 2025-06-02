import { connectDB } from '../db/connect.js';
import { User } from '../models/user_model.js';
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

const migrateProfilePics = async () => {
    try {
        // Connect to MongoDB
        await connectDB();
        console.log('Connected to MongoDB');

        // Get all users with profile pictures
        const users = await User.find({ profilePic: { $exists: true, $ne: null } });
        console.log(`Found ${users.length} users with profile pictures`);

        // Process each user
        for (const user of users) {
            try {
                console.log(`Processing user ${user._id}`);

                // Upload to Cloudinary in chat_app/profiles folder
                const result = await uploadImage(user.profilePic, 'chat_app/profiles');

                // Update user's profile picture URL
                user.profilePic = result.url;
                await user.save();

                console.log(`Successfully migrated profile picture for user ${user._id}`);
            } catch (error) {
                console.error(`Error processing user ${user._id}:`, error.message);
                continue; // Continue with next user even if one fails
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
migrateProfilePics(); 