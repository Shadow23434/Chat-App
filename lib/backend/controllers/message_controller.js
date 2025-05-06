import { Message } from '../models/message_model.js';
import { Types } from 'mongoose';

export const fetchAllMessagesByChatId = async (req, res) => {
    const { chatId } = req.params;
    const userId = req.userId;

    try {
        if (!chatId || !Types.ObjectId.isValid(chatId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid chat ID'
            });
        }
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const messages = await Message.find({ chatId })
            .sort({ createdAt: 1 });

        if (messages.length > 0) {
            const updateResult = await Message.updateMany(
                {
                    chatId,
                    senderId: { $ne: userId },
                    isRead: false
                },
                { $set: { isRead: true } }
            );
        }

        res.status(200).json({
            success: true,
            messages: messages
        });
    } catch (error) {
        console.error('Error in fetchAllMessagesByChatId:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch messages',
        });
    }
};

export const saveMessage = async (req, res) => {
    const { chatId, content, type, mediaUrl } = req.body;
    const userId = req.userId;
    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const newMessage = new Message({
            chatId,
            senderId: userId,
            type: type || 'text',
            content,
            mediaUrl,
            createdAt: new Date(),
            isRead: false
        });
        await newMessage.save();
        res.status(201).json(newMessage);
    } catch (error) {
        res.status(500).json({ error: 'Failed to save message' });
    }
};

export const deleteMessage = async (req, res) => {
    const { messageId } = req.params;
    const userId = req.userId;
    try {
        if (!userId || !Types.ObjectId.isValid(userId)) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized: Invalid user ID'
            });
        }

        const message = await Message.findById(messageId);
        if (message.senderId.toString() !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized: You can only delete your own message'
            });
        }

        await Message.deleteOne({ _id: messageId });

        res.status(200).json({ message: 'Message deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete message' });
    }
};
