import { Chat } from '../../models/chat_model.js';
import { Message } from '../../models/message_model.js';
import { User } from '../../models/user_model.js';
import { v2 as cloudinary } from 'cloudinary';

// Configure Cloudinary (replace with your actual Cloudinary configuration)
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Helper function to extract public ID from Cloudinary URL and delete the image
const deleteImageFromCloudinary = async (mediaUrl) => {
    try {
        if (!mediaUrl) {
            console.warn('No media URL provided for Cloudinary deletion.');
            return;
        }

        // Extract public ID from Cloudinary URL
        // Assumes URL format like: .../v<version>/<public_id>.<extension>
        const urlParts = mediaUrl.split('/');
        const uploadIndex = urlParts.indexOf('upload');
        if (uploadIndex === -1 || uploadIndex + 2 >= urlParts.length) {
            console.error(`Could not extract public ID from URL: ${mediaUrl}`);
            return; // Cannot extract public ID, cannot delete
        }

        // The public ID is typically after 'upload' and may include folders
        const publicIdWithExtension = urlParts.slice(uploadIndex + 2).join('/');
        const publicId = publicIdWithExtension.split('.')[0]; // Remove file extension

        console.log(`Attempting to delete image with public ID: ${publicId}`);

        // Delete the image from Cloudinary
        const result = await cloudinary.uploader.destroy(publicId);
        console.log('Cloudinary deletion result:', result);

        if (result.result !== 'ok') {
            console.error(`Failed to delete image ${publicId} from Cloudinary: ${result.result}`);
        }

    } catch (error) {
        console.error('Error deleting image from Cloudinary:', error);
        // Log the error but don't throw, so database deletion can proceed
    }
};

export const getChats = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        const sort = req.query.sort || 'desc';
        const search = req.query.search || '';

        let pipeline = [];
        pipeline.push({
            $lookup: {
                from: 'users',
                let: { participantOneId: '$participantOneId' },
                pipeline: [
                    {
                        $match: {
                            $expr: { $eq: ['$_id', '$$participantOneId'] }
                        }
                    }
                ],
                as: 'participantOne'
            }
        });
        pipeline.push({
            $lookup: {
                from: 'users',
                let: { participantTwoId: '$participantTwoId' },
                pipeline: [
                    {
                        $match: {
                            $expr: { $eq: ['$_id', '$$participantTwoId'] }
                        }
                    }
                ],
                as: 'participantTwo'
            }
        });

        pipeline.push({
            $project: {
                _id: 1,
                createdAt: 1,
                participantOneId: { // Project participant data structure
                    $cond: {
                        if: { $and: [{ $isArray: '$participantOne' }, { $gt: [{ $size: '$participantOne' }, 0] }] },
                        then: { _id: { $arrayElemAt: ['$participantOne._id', 0] }, username: { $arrayElemAt: ['$participantOne.username', 0] }, email: { $arrayElemAt: ['$participantOne.email', 0] }, profilePic: { $arrayElemAt: ['$participantOne.profilePic', 0] } },
                        else: null
                    }
                },
                participantTwoId: { // Project participant data structure
                    $cond: {
                        if: { $and: [{ $isArray: '$participantTwo' }, { $gt: [{ $size: '$participantTwo' }, 0] }] },
                        then: { _id: { $arrayElemAt: ['$participantTwo._id', 0] }, username: { $arrayElemAt: ['$participantTwo.username', 0] }, email: { $arrayElemAt: ['$participantTwo.email', 0] }, profilePic: { $arrayElemAt: ['$participantTwo.profilePic', 0] } },
                        else: null
                    }
                },
            }
        });

        pipeline.push({
            $match: {
                $and: [
                    { 'participantOneId': { $ne: null } },
                    { 'participantTwoId': { $ne: null } }
                ]
            }
        });

        if (search) {
            const searchRegex = new RegExp(search, 'i');
            pipeline.push({
                $match: {
                    $or: [
                        { 'participantOneId.username': { $exists: true, $regex: searchRegex } },
                        { 'participantOneId.email': { $exists: true, $regex: searchRegex } },
                        { 'participantTwoId.username': { $exists: true, $regex: searchRegex } },
                        { 'participantTwoId.email': { $exists: true, $regex: searchRegex } }
                    ]
                }
            });
        }

        pipeline.push({
            $lookup: {
                from: 'messages',
                let: { chatId: '$_id' },
                pipeline: [
                    { $match: { $expr: { $eq: ['$chatId', '$$chatId'] } } },
                    { $sort: { createdAt: -1 } },
                    { $limit: 1 },
                    { $project: { createdAt: 1 } }
                ],
                as: 'lastMessage'
            }
        });

        pipeline.push({
            $addFields: {
                lastMessageAt: {
                    $ifNull: [
                        {
                            $dateToString: {
                                date: { $arrayElemAt: ['$lastMessage.createdAt', 0] },
                                format: "%Y-%m-%dT%H:%M:%S.%LZ"
                            }
                        },
                        {
                            $dateToString: {
                                date: '$createdAt',
                                format: "%Y-%m-%dT%H:%M:%S.%LZ"
                            }
                        }
                    ]
                }
            }
        });

        pipeline.push({
            $sort: { lastMessageAt: sort === 'desc' ? -1 : 1 }
        });

        pipeline.push(
            { $skip: skip },
            { $limit: limit }
        );

        // Execute the aggregation
        const chats = await Chat.aggregate(pipeline);

        let countMatch = {
            $and: [
                { 'participantOneId': { $ne: null } }, // Match out chats with null participants
                { 'participantTwoId': { $ne: null } }
            ]
        };

        if (search) {
            countMatch = {
                ...countMatch, $or: [
                    { 'participantOne.username': { $regex: search, $options: 'i' } },
                    { 'participantOne.email': { $regex: search, $options: 'i' } },
                    { 'participantTwo.username': { $regex: search, $options: 'i' } },
                    { 'participantTwo.email': { $regex: search, $options: 'i' } }
                ]
            };
        }

        const total = await Chat.countDocuments(
            search ? {
                $or: [
                    // Assuming search applies to original participant fields before complex projection
                    { 'participantOneId': { $in: await User.find({ $or: [{ username: { $regex: search, $options: 'i' } }, { email: { $regex: search, $options: 'i' } }] }).distinct('_id') } },
                    { 'participantTwoId': { $in: await User.find({ $or: [{ username: { $regex: search, $options: 'i' } }, { email: { $regex: search, $options: 'i' } }] }).distinct('_id') } },
                ]
            } : {}
        );

        const totalCountPipeline = [];
        totalCountPipeline.push({ $count: 'total' });

        const totalResult = await Chat.aggregate(totalCountPipeline);
        const totalChat = totalResult.length > 0 ? totalResult[0].total : 0;

        const transformedChats = await Promise.all(chats.map(async chat => {
            try {
                const messageCount = await Message.countDocuments({ chatId: chat._id });

                return {
                    _id: chat._id,
                    createdAt: chat.createdAt,
                    participantOneId: chat.participantOneId,
                    participantTwoId: chat.participantTwoId,
                    lastMessageAt: chat.lastMessageAt,
                    messageCount,
                };
            } catch (error) {
                console.error('Error processing chat for message count:', chat._id, error);
                return null;
            }
        }));

        const validChats = transformedChats.filter(chat => chat !== null);

        const finalChats = validChats.map(chat => ({
            _id: chat._id,
            participantOneId: chat.participantOneId,
            participantTwoId: chat.participantTwoId,
            messageCount: chat.messageCount,
            lastMessageAt: chat.lastMessageAt,
        }));


        // Calculate total statistics (keep this as it's global stats)
        const totalStats = await Message.aggregate([
            { $group: { _id: null, totalMessages: { $sum: 1 }, totalTextMessages: { $sum: { $cond: [{ $eq: ['$type', 'text'] }, 1, 0] } }, totalImageMessages: { $sum: { $cond: [{ $eq: ['$type', 'image'] }, 1, 0] } }, totalReadMessages: { $sum: { $cond: [{ $eq: ['$isRead', true] }, 1, 0] } } } }
        ]);

        res.status(200).json({
            chats: finalChats,
            stats: {
                totalMessages: totalStats[0]?.totalMessages || 0,
                textCount: totalStats[0]?.totalTextMessages || 0,
                imageCount: totalStats[0]?.totalImageMessages || 0,
                readCount: totalStats[0]?.totalReadMessages || 0
            },
            pagination: {
                totalChat,
                page,
                pages: Math.ceil(totalChat / limit)
            }
        });
    } catch (error) {
        console.error('Get chats error:', error);
        console.error('Error stack:', error.stack);
        res.status(500).json({
            message: 'Internal server error',
            error: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
};

export const getChatDetails = async (req, res) => {
    try {
        const { chatId } = req.params;

        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const messages = await Message.find({ chatId })
            .populate('senderId', 'username email profilePic')
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });

        const total = await Message.countDocuments({ chatId });

        res.status(200).json({
            chat: {
                id: chatId
            },
            messages,
            pagination: {
                total,
                page,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        console.error('Get chat details error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

export const deleteChat = async (req, res) => {
    try {
        const { chatId } = req.params;
        // Find all messages for the chat first to get media URLs
        const messagesToDelete = await Message.find({ chatId });

        // Delete images from Cloudinary for image messages
        for (const message of messagesToDelete) {
            if (message.type === 'image' && message.mediaUrl) {
                await deleteImageFromCloudinary(message.mediaUrl);
            }
        }

        // Delete all messages associated with the chat
        const deleteMessagesResult = await Message.deleteMany({ chatId });

        // Delete the chat itself
        const deletedChat = await Chat.findByIdAndDelete(chatId);

        if (!deletedChat) {
            // If chat was not found, return 404
            return res.status(404).json({
                message: 'Chat not found'
            });
        }

        res.status(200).json({
            message: 'Chat and associated messages deleted successfully',
            deletedChatId: deletedChat._id,
            deletedMessagesCount: deleteMessagesResult.deletedCount
        });

    } catch (error) {
        console.error('Delete chat error:', error);
        res.status(500).json({
            message: 'Internal server error',
            error: error.message
        });
    }
};

export const deleteMessage = async (req, res) => {
    try {
        const { messageId } = req.params;

        // Find the message before deleting to check its type and mediaUrl
        const messageToDelete = await Message.findById(messageId);

        if (!messageToDelete) {
            return res.status(404).json({
                message: 'Message not found'
            });
        }

        // If it's an image message, delete the image from Cloudinary
        if (messageToDelete.type === 'image' && messageToDelete.mediaUrl) {
            await deleteImageFromCloudinary(messageToDelete.mediaUrl);
        }

        // Delete the message from the database
        const deletedMessage = await Message.findByIdAndDelete(messageId);

        // We already checked if messageToDelete exists, so deletedMessage should also exist,
        // but checking again is safer in case of race conditions or unexpected issues.
        if (!deletedMessage) {
            // This case should ideally not be hit if messageToDelete was found
            console.error('Message found initially but failed to delete from DB:', messageId);
            return res.status(500).json({
                message: 'Internal server error: Failed to delete message from DB after Cloudinary',
                error: 'DB deletion failed'
            });
        }


        res.status(200).json({
            message: 'Message deleted successfully',
            deletedMessage
        });
    } catch (error) {
        console.error('Delete message error:', error);
        res.status(500).json({
            message: 'Internal server error',
            error: error.message
        });
    }
};

export const downloadChat = async (req, res) => {
    try {
        const { chatId } = req.params;

        // Get chat details
        const chat = await Chat.findById(chatId)
            .populate('participantOneId', 'username email')
            .populate('participantTwoId', 'username email');

        if (!chat) {
            return res.status(404).json({ message: 'Chat not found' });
        }

        // Get all messages for this chat
        const messages = await Message.find({ chatId })
            .populate('senderId', 'username email')
            .sort({ createdAt: 1 });

        // Create CSV header
        const csvHeader = [
            'Message ID',
            'Sender',
            'Sender Email',
            'Message Type',
            'Content',
            'Is Read',
            'Created At'
        ].join(',');

        // Create CSV rows
        const csvRows = messages.map(message => {
            return [
                message._id,
                message.senderId?.username || 'Unknown',
                message.senderId?.email || 'Unknown',
                message.type,
                message.content?.replace(/,/g, ';'), // Replace commas in content to avoid CSV formatting issues
                message.isRead,
                message.createdAt
            ].join(',');
        });

        // Combine header and rows
        const csvContent = [csvHeader, ...csvRows].join('\n');

        // Set headers for file download
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=chat-${chatId}-${new Date().toISOString()}.csv`);

        // Send the CSV file
        res.status(200).send(csvContent);
    } catch (error) {
        console.error('Download chat error:', error);
        res.status(500).json({
            message: 'Internal server error',
            error: error.message
        });
    }
};

export const downloadAllChats = async (req, res) => {
    try {
        // Get all chats with participant details
        const chats = await Chat.find()
            .populate('participantOneId', 'username email')
            .populate('participantTwoId', 'username email');

        if (!chats || chats.length === 0) {
            return res.status(404).json({
                message: 'No chats found'
            });
        }

        // Create CSV header
        const csvHeader = [
            'Chat ID',
            'Participant 1',
            'Participant 1 Email',
            'Participant 2',
            'Participant 2 Email',
            'Message ID',
            'Sender',
            'Sender Email',
            'Message Type',
            'Content',
            'Is Read',
            'Created At'
        ].join(',');

        // Process all chats and their messages
        const csvRows = [];

        for (const chat of chats) {
            try {
                // Get all messages for this chat
                const messages = await Message.find({ chatId: chat._id })
                    .populate('senderId', 'username email')
                    .sort({ createdAt: 1 });

                // Add a row for each message
                messages.forEach(message => {
                    const row = [
                        chat._id,
                        chat.participantOneId?.username || 'Unknown',
                        chat.participantOneId?.email || 'Unknown',
                        chat.participantTwoId?.username || 'Unknown',
                        chat.participantTwoId?.email || 'Unknown',
                        message._id,
                        message.senderId?.username || 'Unknown',
                        message.senderId?.email || 'Unknown',
                        message.type,
                        message.content?.replace(/,/g, ';').replace(/\n/g, ' '), // Replace commas and newlines
                        message.isRead,
                        message.createdAt
                    ].map(field => `"${field}"`).join(','); // Wrap fields in quotes to handle special characters

                    csvRows.push(row);
                });

                // If chat has no messages, add a row with just chat info
                if (messages.length === 0) {
                    const row = [
                        chat._id,
                        chat.participantOneId?.username || 'Unknown',
                        chat.participantOneId?.email || 'Unknown',
                        chat.participantTwoId?.username || 'Unknown',
                        chat.participantTwoId?.email || 'Unknown',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        chat.createdAt
                    ].map(field => `"${field}"`).join(',');

                    csvRows.push(row);
                }
            } catch (error) {
                console.error(`Error processing chat ${chat._id}:`, error);
                // Continue with next chat even if one fails
                continue;
            }
        }

        if (csvRows.length === 0) {
            return res.status(404).json({
                message: 'No data available to export'
            });
        }

        // Combine header and rows
        const csvContent = [csvHeader, ...csvRows].join('\n');

        // Set headers for file download
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename=all-chats-${new Date().toISOString()}.csv`);

        // Send the CSV file
        res.status(200).send(csvContent);
    } catch (error) {
        console.error('Download all chats error:', error);
        res.status(500).json({
            message: 'Internal server error',
            error: error.message
        });
    }
};
