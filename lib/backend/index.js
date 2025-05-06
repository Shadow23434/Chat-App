import express from 'express';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import http from 'http';
import { Server } from 'socket.io'
import { connectDB } from './db/connect.js';
import authRoutes from './routes/auth_route.js';
import chatRoutes from './routes/chat_route.js';
import messageRoutes from './routes/message_route.js';
import contactRoutes from './routes/contact_route.js';
import profileRoutes from './routes/profile_route.js';
import callRoutes from './routes/call_route.js';
import storyRoutes from './routes/story_route.js';
import commentRoutes from './routes/comment_route.js';
import { saveMessage } from './controllers/message_controller.js';

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*'
    }
});

//  route config for web
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});
app.use(express.json());
app.use(cookieParser());
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/message', messageRoutes);
app.use('/api/contact', contactRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/call', callRoutes);
app.use('/api/story', storyRoutes);
app.use('/api/comment', commentRoutes);

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('joinChat', (chatId) => {
        socket.join(chatId);
        console.log('User joined chat: ' + chatId);
    });

    socket.on('sendMessage', async (message) => {
        const { chatId, senderId, content, type, mediaUrl } = message;
        try {
            const savedMessage = await saveMessage(chatId, senderId, content, type, mediaUrl);
            console.log('sendMessage: ');
            console.log(saveMessage);
            io.to(chatId).emit('newMessage', saveMessage);
        } catch (error) {
            console.error('Failed to save messaage:', error);
        }
    });

    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    })
})

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    connectDB();
    console.log(`Server is running on port ${PORT}: http://localhost:${PORT}`);
});
