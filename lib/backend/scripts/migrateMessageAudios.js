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
dotenv.config({ path: path.join(__dirname, '../../.env') });
dotenv.config();

const migrateMessageAudios = async () => {
    try {
        // Connect to MongoDB
        await connectDB();
        console.log('Connected to MongoDB');

        // Find all messages with mediaUrl and type = audio that are not already on Cloudinary
        const messages = await Message.find({
            mediaUrl: { $exists: true, $ne: null },
            type: 'audio',
            mediaUrl: { $not: /cloudinary\.com/ } // Only get messages with non-Cloudinary URLs
        });

        console.log(`Found ${messages.length} messages with audio files not on Cloudinary`);

        // Process each message
        for (const message of messages) {
            try {
                console.log(`Processing message ${message._id}`);
                console.log(`Audio URL: ${message.mediaUrl}`);

                // Skip if URL is invalid
                if (!message.mediaUrl.startsWith('http')) {
                    console.log(`Skipping message ${message._id} - invalid URL format`);
                    continue;
                }

                // Skip if already on Cloudinary
                if (message.mediaUrl.includes('cloudinary.com')) {
                    console.log(`Skipping message ${message._id} - already on Cloudinary`);
                    continue;
                }

                console.log(`Attempting to upload to Cloudinary in folder: chat_app/messages/audio`);

                // Upload to Cloudinary
                const result = await uploadImage(message.mediaUrl, 'chat_app/messages/audio');

                // Use secure_url if available, otherwise use url
                const newUrl = result.secure_url || result.url;
                if (!newUrl) {
                    throw new Error('Upload failed - no Cloudinary URL returned');
                }

                console.log(`Upload successful. Audio URL: ${newUrl}`);

                // Update message with new URL while preserving content
                await Message.findByIdAndUpdate(message._id, {
                    mediaUrl: newUrl,
                    content: message.content // Preserve the original content
                });

                console.log(`Updated message ${message._id} with new Cloudinary URL`);
            } catch (error) {
                console.error(`Error processing message ${message._id}:`, error.message);
                if (error.response) {
                    console.error('Response data:', error.response.data);
                    console.error('Response status:', error.response.status);
                }
                continue; // Continue with next message
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
migrateMessageAudios(); 