/**
 * Middleware to validate image upload request
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
export const validateImageUpload = (req, res, next) => {
    // Check if image exists in the request body
    if (!req.body.image) {
        return res.status(400).json({
            success: false,
            message: 'No image provided'
        });
    }

    // Check if image is a valid base64 string or URL
    const isBase64 = /^data:image\/(png|jpg|jpeg|gif);base64,/.test(req.body.image);
    const isUrl = /^https?:\/\/.+/.test(req.body.image);

    if (!isBase64 && !isUrl) {
        return res.status(400).json({
            success: false,
            message: 'Invalid image format. Must be a base64 string or URL'
        });
    }

    // Check if image size is within limits (if it's a base64 string)
    if (isBase64) {
        // Base64 string length ÷ 4 * 3 gives the approximate file size in bytes
        const base64Data = req.body.image.split(',')[1];
        const fileSizeInBytes = Math.ceil((base64Data.length / 4) * 3);
        const fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        // Maximum file size (10MB)
        const maxSizeInMB = 10;

        if (fileSizeInMB > maxSizeInMB) {
            return res.status(400).json({
                success: false,
                message: `Image too large. Maximum allowed size is ${maxSizeInMB}MB`
            });
        }
    }

    // If all checks pass, continue
    next();
};

/**
 * Middleware to validate image deletion request
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
export const validateImageDeletion = (req, res, next) => {
    if (!req.body.public_id) {
        return res.status(400).json({
            success: false,
            message: 'Image public_id is required'
        });
    }

    next();
}; 