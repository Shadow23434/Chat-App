import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Get the current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables from .env file, prioritizing parent directories
dotenv.config({ path: path.resolve(__dirname, '../../../.env') });
dotenv.config({ path: path.resolve(__dirname, '../../.env') });
dotenv.config();

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'your_cloud_name',
    api_key: process.env.CLOUDINARY_API_KEY || 'your_api_key',
    api_secret: process.env.CLOUDINARY_API_SECRET || 'your_api_secret',
    secure: true
});

/**
 * Check if Cloudinary is properly configured
 * @returns {boolean} - True if Cloudinary is configured with valid credentials
 */
const isCloudinaryConfigured = () => {
    return !!(process.env.CLOUDINARY_CLOUD_NAME &&
        process.env.CLOUDINARY_API_KEY &&
        process.env.CLOUDINARY_API_SECRET);
};

/**
 * Upload image to Cloudinary
 * @param {String} imagePath - The path or base64 string of the image
 * @param {String} folder - Optional folder name in Cloudinary
 * @returns {Promise} - Cloudinary upload response or local URL if upload fails
 */
export const uploadImage = async (imagePath, folder = 'chat_app') => {
    try {
        // Check if Cloudinary is configured
        if (!isCloudinaryConfigured()) {
            throw new Error('Cloudinary is not properly configured. Please check your environment variables.');
        }

        // Validate input - ensure it's a string
        if (typeof imagePath !== 'string') {
            throw new Error('Invalid image input type. Expected string but got ' + typeof imagePath);
        }

        // For base64 data, ensure it has the proper format
        if (imagePath.startsWith('data:')) {
            if (!imagePath.includes('base64,')) {
                throw new Error('Invalid base64 image format');
            }
        }

        console.log(`Attempting to upload to Cloudinary in folder: ${folder}`);
        const result = await cloudinary.uploader.upload(imagePath, {
            folder,
            resource_type: 'auto',
            use_filename: true,
            unique_filename: true
        });
        console.log('Upload successful. Image URL:', result.secure_url);

        return {
            public_id: result.public_id,
            url: result.secure_url,
            format: result.format,
            width: result.width,
            height: result.height
        };
    } catch (error) {
        console.error('Error uploading to Cloudinary:', error.message);
        throw new Error('Failed to upload image: ' + error.message);
    }
};

/**
 * Delete image from Cloudinary
 * @param {String} publicId - The public ID of the image
 * @returns {Promise} - Cloudinary delete response
 */
export const deleteImage = async (publicId) => {
    try {
        // Check if Cloudinary is configured
        if (!isCloudinaryConfigured()) {
            throw new Error('Cloudinary is not properly configured. Please check your environment variables.');
        }

        console.log(`Attempting to delete image with public ID: ${publicId}`);
        const result = await cloudinary.uploader.destroy(publicId);
        console.log('Delete result:', result);
        return result;
    } catch (error) {
        console.error('Error deleting from Cloudinary:', error.message);
        throw new Error('Failed to delete image: ' + error.message);
    }
};

export default cloudinary; 