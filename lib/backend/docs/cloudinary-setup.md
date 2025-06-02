# Cloudinary Integration Setup

This document explains how to set up Cloudinary integration with your Chat App backend.

## Prerequisites

1. Create a Cloudinary account at [https://cloudinary.com/](https://cloudinary.com/) (free tier available)
2. Get your account credentials from the Cloudinary dashboard

## Setup Steps

### 1. Environment Variables

Add the following environment variables to your `.env` file in the backend directory:

```
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

Replace `your_cloud_name`, `your_api_key`, and `your_api_secret` with your actual Cloudinary credentials.

### 2. Install Cloudinary Package

```bash
npm install cloudinary
```

## Usage

### Uploading Images

Send a POST request to `/api/images/upload` with the following JSON payload:

```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEA...", // Base64 image string or URL
  "type": "profile" // Optional: specifies the folder in Cloudinary (profile, chat, story, etc.)
}
```

The response will contain the Cloudinary image details:

```json
{
  "success": true,
  "data": {
    "public_id": "chat_app/profile/image123",
    "url": "https://res.cloudinary.com/your-cloud/image/upload/v1621234567/chat_app/profile/image123.jpg",
    "format": "jpg",
    "width": 800,
    "height": 600
  }
}
```

### Deleting Images

Send a DELETE request to `/api/images/delete` with the following JSON payload:

```json
{
  "public_id": "chat_app/profile/image123"
}
```

Response:

```json
{
  "success": true,
  "message": "Image deleted successfully"
}
```

## Implementation Details

This integration uses:

1. Cloudinary Node.js SDK for image management
2. Express middlewares for validation
3. Proper error handling and reporting
4. Secure API endpoints with authentication

## Troubleshooting

- Make sure your Cloudinary credentials are correct
- Check that your base64 image string is valid
- Ensure the API routes are properly authenticated
- Verify that the Cloudinary package is installed 