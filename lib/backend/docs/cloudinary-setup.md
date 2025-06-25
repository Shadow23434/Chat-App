# Cloudinary Setup Guide

## Overview
This guide explains how to set up Cloudinary for media uploads in the chat app backend.

## Prerequisites
1. A Cloudinary account (free tier available at https://cloudinary.com)
2. Your Cloudinary credentials

## Environment Variables Setup

Create a `.env` file in the `lib/backend/` directory with the following variables:

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Other environment variables...
NODE_ENV=development
PORT=3000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

## Getting Your Cloudinary Credentials

1. **Sign up/Login to Cloudinary**: Go to https://cloudinary.com and create an account or login
2. **Access Dashboard**: After login, you'll be taken to your dashboard
3. **Find Credentials**: In the dashboard, you'll see:
   - **Cloud Name**: Usually displayed prominently
   - **API Key**: Found in the "API Environment variable" section
   - **API Secret**: Found in the "API Environment variable" section

## Example .env file

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=myapp123
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz123456

# Database
MONGODB_URI=mongodb://localhost:27017/chat_app

# JWT
JWT_SECRET=your_super_secret_jwt_key_here

# Server
NODE_ENV=development
PORT=3000
```

## Testing the Setup

After setting up your environment variables:

1. **Restart your server** to load the new environment variables
2. **Create a story** with media upload
3. **Check the console logs** for Cloudinary upload messages
4. **Verify in Cloudinary dashboard** that files are being uploaded

## Troubleshooting

### Common Issues

1. **"Cloudinary is not properly configured" error**
   - Check that all three environment variables are set
   - Ensure no extra spaces or quotes around the values
   - Restart the server after changing .env file

2. **Upload fails with authentication error**
   - Verify your API key and secret are correct
   - Check that your Cloudinary account is active
   - Ensure you haven't exceeded your plan's upload limits

3. **Files not uploading to Cloudinary**
   - Check the server console for error messages
   - Verify the mediaUrl is a valid file path or base64 string
   - Ensure the file size is within Cloudinary's limits

### Debug Steps

1. Check environment variables are loaded:
   ```javascript
   console.log('CLOUDINARY_CLOUD_NAME:', process.env.CLOUDINARY_CLOUD_NAME);
   console.log('CLOUDINARY_API_KEY:', process.env.CLOUDINARY_API_KEY);
   console.log('CLOUDINARY_API_SECRET:', process.env.CLOUDINARY_API_SECRET ? 'Set' : 'Not set');
   ```

2. Test Cloudinary connection:
   ```javascript
   const cloudinary = require('cloudinary').v2;
   cloudinary.config({
       cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
       api_key: process.env.CLOUDINARY_API_KEY,
       api_secret: process.env.CLOUDINARY_API_SECRET
   });
   
   // Test upload
   cloudinary.uploader.upload('https://example.com/test.jpg', 
       { folder: 'test' }, 
       (error, result) => {
           if (error) console.error('Cloudinary test failed:', error);
           else console.log('Cloudinary test successful:', result.secure_url);
       }
   );
   ```

## Security Notes

- Never commit your `.env` file to version control
- Keep your API secret secure and don't share it
- Consider using environment-specific configurations for production
- Regularly rotate your API keys for security

## Cloudinary Plan Limits

- **Free Tier**: 25 GB storage, 25 GB bandwidth/month
- **Paid Plans**: Higher limits and additional features
- Check your usage in the Cloudinary dashboard

## Folder Structure

Files uploaded through the story creation will be organized in Cloudinary as:
- Media files: `chat_app/stories/`
- Background files: `chat_app/stories/backgrounds/`
- Profile pictures: `chat_app/profiles/` (if implemented) 