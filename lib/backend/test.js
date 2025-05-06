import mongoose from 'mongoose';
import { User } from './models/user_model.js';
import { Chat } from './models/chat_model.js';
import { Message } from './models/message_model.js';
import { faker } from '@faker-js/faker';
import bcryptjs from 'bcryptjs';

// Connect to your test database
mongoose.connect('mongodb://localhost:27017/chat_app_test', {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

// Clear existing test data
const clearDatabase = async () => {
    await User.deleteMany({});
    await Chat.deleteMany({});
    await Message.deleteMany({});
};

// Generate random users
const generateUsers = async (count = 10) => {
    const users = [];
    for (let i = 0; i < count; i++) {
        const user = new User({
            username: faker.internet.displayName(),
            email: faker.internet.email(),
            password: await bcryptjs.hash(faker.internet.password(), 10),
            phone: faker.phone.number(),
            gender: faker.helpers.arrayElement(['male', 'female', 'unknown']),
            profilePic: faker.image.avatar(),
            profileUrl: faker.internet.url(),
            isVerified: true,
            lastLogin: faker.date.recent()
        });
        users.push(await user.save());
    }
    return users;
};

// Generate random chats between users
const generateChats = async (users, count = 15) => {
    const chats = [];
    for (let i = 0; i < count; i++) {
        const [user1, user2] = faker.helpers.arrayElements(users, 2);
        const chat = new Chat({
            participantOneId: user1._id,
            participantTwoId: user2._id,
            createdAt: faker.date.past()
        });
        chats.push(await chat.save());
    }
    return chats;
};

// Generate random messages for chats
const generateMessages = async (users, chats, count = 100) => {
    const messages = [];
    for (let i = 0; i < count; i++) {
        const chat = faker.helpers.arrayElement(chats);
        const sender = faker.helpers.arrayElement([
            chat.participantOneId,
            chat.participantTwoId
        ]);

        const message = new Message({
            chatId: chat._id,
            senderId: sender,
            content: faker.lorem.sentence(),
            type: faker.helpers.arrayElement(['text', 'image', 'audio']),
            isRead: faker.datatype.boolean(),
            mediaUrl: Math.random() > 0.7 ? faker.image.url() : undefined,
            createdAt: faker.date.between({
                from: chat.createdAt,
                to: new Date()
            })
        });
        messages.push(await message.save());
    }
    return messages;
};

// Main function to generate all test data
const generateTestData = async () => {
    try {
        await clearDatabase();
        console.log('Cleared existing test data');

        const users = await generateUsers();
        console.log(`Generated ${users.length} users`);

        const chats = await generateChats(users);
        console.log(`Generated ${chats.length} chats`);

        const messages = await generateMessages(users, chats);
        console.log(`Generated ${messages.length} messages`);

        console.log('Test data generation complete!');
        process.exit(0);
    } catch (error) {
        console.error('Error generating test data:', error);
        process.exit(1);
    }
};

generateTestData();