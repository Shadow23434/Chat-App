import express from 'express';
import dotenv from 'dotenv';
import { connectDB } from './db/connect.js';
import authRoutes from './routes/auth_route.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
    connectDB();
    console.log(`Server is running on port ${PORT}: http://localhost:${PORT}`);
});
