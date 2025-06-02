import express from 'express';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import http from 'http';
import path from 'path';
import { Server } from 'socket.io';
import { connectDB } from './db/connect.js';
import routes from './routes/index.js';
import { saveMessage } from './controllers/client/message_controller.js';
import { User } from './models/user_model.js';
import { cleanupExpiredStories } from './controllers/admin/story_controller.js';

// Load environment variables FIRST with explicit path
const envPath = path.join(process.cwd(), '.env');

dotenv.config({ path: envPath });

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
        credentials: true
    }
});

// Middleware
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Credentials', 'true');
    res.header('Access-Control-Max-Age', '86400'); // 24 hours

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    next();
});

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        env: process.env.NODE_ENV || 'development'
    });
});

// Debug endpoint to check env variables (REMOVE IN PRODUCTION)
app.get('/debug/env', (req, res) => {
    const safeEnvVars = {};
    for (const [key, value] of Object.entries(process.env)) {
        // Don't expose sensitive information
        if (!key.includes('PASSWORD') && !key.includes('SECRET') && !key.includes('KEY')) {
            safeEnvVars[key] = value;
        }
    }
    res.json(safeEnvVars);
});

// Debug endpoint to check MongoDB connection
app.get('/debug/db', async (req, res) => {
    try {
        const { checkConnection } = await import('./db/connect.js');
        const connectionInfo = checkConnection();
        res.json({
            connection: connectionInfo,
            mongoUri: process.env.MONGODB_URI ? 'Set' : 'Not set'
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Use routes
app.use('/', routes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        error: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : err.message
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Socket.io setup
io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('joinChat', (chatId) => {
        if (!chatId) {
            console.error('Invalid chatId provided');
            return;
        }
        socket.join(chatId);
        console.log(`User ${socket.id} joined chat: ${chatId}`);
    });

    socket.on('sendMessage', async (message) => {
        try {
            const { chatId, senderId, content, type, mediaUrl } = message;

            // Validate required fields
            if (!chatId || !senderId || !content) {
                console.error('Missing required message fields');
                socket.emit('messageError', { error: 'Missing required fields' });
                return;
            }

            const savedMessage = await saveMessage(chatId, senderId, content, type, mediaUrl);
            console.log('Message saved:', savedMessage);

            // Emit to all users in the chat room
            io.to(chatId).emit('newMessage', savedMessage);
        } catch (error) {
            console.error('Failed to save message:', error);
            socket.emit('messageError', { error: 'Failed to save message' });
        }
    });

    socket.on('disconnect', (reason) => {
        console.log(`User disconnected: ${socket.id}, reason: ${reason}`);
    });

    socket.on('error', (error) => {
        console.error('Socket error:', error);
    });
});

// Admin namespace for admin-specific functionality
const adminNamespace = io.of('/admin');
adminNamespace.on('connection', (socket) => {
    console.log('Admin connected:', socket.id);

    socket.on('joinAdminRoom', (adminId) => {
        if (!adminId) {
            console.error('Invalid adminId provided');
            return;
        }
        const roomName = `admin:${adminId}`;
        socket.join(roomName);
        console.log(`Admin ${socket.id} joined room: ${roomName}`);
    });

    socket.on('disconnect', (reason) => {
        console.log(`Admin disconnected: ${socket.id}, reason: ${reason}`);
    });

    socket.on('error', (error) => {
        console.error('Admin socket error:', error);
    });
});

// Function to create default admin accounts
async function createDefaultAdmins() {
    try {
        // Check and create super admin
        const superAdminExists = await User.findOne({ role: 'super_admin' });
        if (!superAdminExists) {
            await User.create({
                username: process.env.SUPER_ADMIN_USERNAME || 'super_admin',
                email: process.env.SUPER_ADMIN_EMAIL || 'super_admin@chatapp.com',
                password: process.env.SUPER_ADMIN_PASSWORD || 'SuperAdmin@123',
                role: 'super_admin',
                isVerified: true
            });
            console.log('Default super admin account created successfully');
        }

        // Check and create regular admin
        const adminExists = await User.findOne({ role: 'admin' });
        if (!adminExists) {
            await User.create({
                username: process.env.ADMIN_USERNAME || 'admin',
                email: process.env.ADMIN_EMAIL || 'admin@chatapp.com',
                password: process.env.ADMIN_PASSWORD || 'Admin@123',
                role: 'admin',
                isVerified: true
            });
            console.log('Default admin account created successfully');
        }
    } catch (error) {
        console.error('Error creating default admin accounts:', error.message);
    }
}

// Start server
const PORT = process.env.PORT || 5000;

async function startServer() {
    try {
        // Connect to database
        await connectDB();

        // Create default admin accounts
        await createDefaultAdmins();

        // Start server with Socket.IO support
        server.listen(PORT, '0.0.0.0', () => {
            console.log(`HTTP: http://0.0.0.0:${PORT}`);
            console.log(`Socket.IO enabled`);
        });

        // Schedule daily cleanup of expired stories
        setInterval(async () => {
            console.log('Running scheduled cleanup of expired stories...');
            await cleanupExpiredStories();
        }, 24 * 60 * 60 * 1000); // Run every 24 hours

        // Run initial cleanup
        await cleanupExpiredStories();

    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully');
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
});

// Start the server
startServer();