import { connectDB } from '../db/connect.js';
import { Message } from '../models/message_model.js';
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

const migrateMessageImages = async () => {
    try {
        // Connect to MongoDB
        await connectDB();
        console.log('Connected to MongoDB');

        // Get all messages with mediaUrl and type = image
        const messages = await Message.find({
            mediaUrl: { $exists: true, $ne: null },
            type: 'image',
            mediaUrl: { $not: /cloudinary\.com/ } // Only get messages with non-Cloudinary URLs
        });
        console.log(`Found ${messages.length} messages with images not on Cloudinary`);

        // Process each message
        for (const message of messages) {
            try {
                console.log(`Processing message ${message._id}`);
                console.log(`Image URL: ${message.mediaUrl}`);

                // Skip if already on Cloudinary
                if (message.mediaUrl.includes('cloudinary.com')) {
                    console.log(`Skipping message ${message._id} - already on Cloudinary`);
                    continue;
                }

                // Skip if URL is invalid
                if (!message.mediaUrl.startsWith('http')) {
                    console.log(`Skipping message ${message._id} - invalid URL format`);
                    continue;
                }

                // Upload to Cloudinary in chat_app/messages/image folder
                console.log(`Attempting to upload to Cloudinary in folder: chat_app/messages/image`);
                const result = await uploadImage(message.mediaUrl, 'chat_app/messages/image');
                console.log(`Upload successful. Image URL: ${result.url}`);

                // Update message's media URL
                message.mediaUrl = result.url;
                await message.save();

                console.log(`Successfully migrated image for message ${message._id}`);
            } catch (error) {
                console.error(`Error processing message ${message._id}:`, error.message);
                if (error.response) {
                    console.error('Response data:', error.response.data);
                    console.error('Response status:', error.response.status);
                }
                continue; // Continue with next message even if one fails
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
migrateMessageImages(); 