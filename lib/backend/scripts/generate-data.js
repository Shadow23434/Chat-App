import { faker } from '@faker-js/faker';
import { ObjectId } from 'mongodb';
import pkg from 'lodash';
const { sample } = pkg;
import fs from 'fs';

// Cấu hình
const DATA = {
    users: 100,
    messages: 200,
    stories: 50,
    contacts: 50,
    comments: 100,
    chats: 50,
    calls: 150,
};

// Tạo users trước (vì các dữ liệu khác phụ thuộc vào user IDs)
// Hàm tạo permissions dựa trên role
const getPermissionsByRole = (role) => {
    const basePermissions = {
        'user:profile:read': true,
        'user:profile:edit': true,
        'chat:read': true,
        'chat:write': true,
        'story:read': true,
        'story:write': true,
        'call:create': true,
        'contact:manage': true,
        'admin:users:read': false,
        'admin:users:write': false,
        'admin:stats:read': false,
        'admin:chats:read': false,
        'admin:stories:read': false,
        'admin:calls:read': false,
        'admin:support:read': false,
        'admin:support:write': false
    };

    if (role === 'admin') {
        return {
            ...basePermissions,
            'admin:users:read': true,
            'admin:stats:read': true,
            'admin:chats:read': true,
            'admin:stories:read': true,
            'admin:calls:read': true,
            'admin:support:read': true,
            'admin:support:write': true
        };
    } else if (role === 'super_admin') {
        return {
            ...basePermissions,
            'admin:users:read': true,
            'admin:users:write': true,
            'admin:stats:read': true,
            'admin:chats:read': true,
            'admin:stories:read': true,
            'admin:calls:read': true,
            'admin:support:read': true,
            'admin:support:write': true
        };
    }

    return basePermissions;
};

const generateUsers = () => {
    return Array.from({ length: DATA.users }, (_, i) => {
        // Tạo role: 98 user, 1 admin, 1 super_admin
        let role;
        if (i === 0) {
            role = 'admin';
        } else if (i === 1) {
            role = 'super_admin';
        } else {
            role = 'user';
        }

        const permissions = getPermissionsByRole(role);

        return {
            _id: { $oid: new ObjectId().toString() },
            username: faker.internet.username(),
            email: faker.internet.email(),
            password: "$2b$10$FakeHashForDemoPurposeOnly1234",
            phoneNumber: faker.phone.number(),
            gender: sample(["male", "female", "unknown"]),
            profilePic: faker.image.avatar(),
            role: role,
            permissions: permissions,
            isVerified: true,
            lastLogin: { $date: faker.date.recent().toISOString() },
            createdAt: { $date: faker.date.past().toISOString() },
            updatedAt: { $date: faker.date.recent().toISOString() },
            // Không tạo resetPasswordToken và verificationToken vì đây là dữ liệu demo
        };
    });
};

// Tạo stories (with unique userId)
const generateStories = (userIds) => {
    const usedUserIds = new Set();
    return Array.from({ length: DATA.stories }, () => {
        const availableUserIds = userIds.filter(id => !usedUserIds.has(id));
        if (availableUserIds.length === 0) {
            throw new Error("Not enough unique userIds for stories");
        }
        const selectedUserId = sample(availableUserIds);
        usedUserIds.add(selectedUserId);
        const storyType = sample(["image", "audio"]); // Randomly select type
        return {
            _id: { $oid: new ObjectId().toString() },
            caption: faker.lorem.sentence(),
            type: storyType,
            createdAt: { $date: faker.date.recent().toISOString() },
            expiresAt: { $date: faker.date.future().toISOString() },
            mediaUrl: storyType === "audio" ? faker.internet.url() : "", // Audio: URL, Image: empty
            mediaName: storyType === "audio" ? faker.system.fileName() : "", // Audio: file name, Image: empty
            backgroundUrl: faker.image.url(), // Always include background URL
            userId: { $oid: selectedUserId },
            likes: faker.number.int({ min: 0, max: 100 }),
        };
    });
};

// Tạo contacts
const generateContacts = (userIds) => {
    const uniquePairs = new Set();
    return Array.from({ length: DATA.contacts }, () => {
        let userId1, userId2;
        do {
            userId1 = sample(userIds);
            userId2 = sample(userIds.filter(id => id !== userId1));
        } while (uniquePairs.has(`${userId1}-${userId2}`));

        uniquePairs.add(`${userId1}-${userId2}`);
        return {
            _id: { $oid: new ObjectId().toString() },
            userId1: { $oid: userId1 },
            userId2: { $oid: userId2 },
            status: sample(["accepted", "pending"]),
        };
    });
};

// Tạo comments
const generateComments = (userIds, storyIds) => {
    const comments = [];
    const commentsByStoryId = new Map(); // Track comments per story for replies

    for (let i = 0; i < DATA.comments; i++) {
        const storyId = sample(storyIds);
        const createdAt = faker.date.recent({ days: 7 }); // Recent dates within 7 days
        const comment = {
            _id: { $oid: new ObjectId().toString() },
            storyId: { $oid: storyId },
            content: faker.lorem.sentence(),
            userId: { $oid: sample(userIds) },
            likes: faker.number.int({ min: 0, max: 50 }),
            createdAt: { $date: createdAt.toISOString() },
            parentCommentId: null, // Default to null (top-level)
        };

        // Initialize commentsByStoryId for this storyId if not already
        if (!commentsByStoryId.has(storyId)) {
            commentsByStoryId.set(storyId, []);
        }

        // Decide if this comment is a reply (e.g., 50% chance if possible)
        const existingComments = commentsByStoryId.get(storyId);
        if (existingComments.length > 0 && Math.random() < 0.5) {
            // Select a parent comment from the same story
            const potentialParents = existingComments.filter(
                (c) => new Date(c.createdAt.$date) < createdAt
            );
            if (potentialParents.length > 0) {
                const parentComment = sample(potentialParents);
                comment.parentCommentId = { $oid: parentComment._id.$oid };
            }
        }

        // Add comment to the list and to commentsByStoryId
        comments.push(comment);
        commentsByStoryId.get(storyId).push(comment);
    }

    return comments;
};

// Tạo chats
const generateChats = (userIds) => {
    const uniquePairs = new Set();
    return Array.from({ length: DATA.chats }, () => {
        let participantOneId, participantTwoId;
        do {
            participantOneId = sample(userIds);
            participantTwoId = sample(userIds.filter(id => id !== participantOneId));
        } while (uniquePairs.has(`${participantOneId}-${participantTwoId}`));

        uniquePairs.add(`${participantOneId}-${participantTwoId}`);
        return {
            _id: { $oid: new ObjectId().toString() },
            participantOneId: { $oid: participantOneId },
            participantTwoId: { $oid: participantTwoId },
            createdAt: { $date: faker.date.past().toISOString() },
        };
    });
};

// Tạo messages - FIXED VERSION
const generateMessages = (userIds, chats) => {
    return Array.from({ length: DATA.messages }, () => {
        // Chọn một chat ngẫu nhiên
        const selectedChat = sample(chats);
        // Chỉ chọn senderId từ 2 người tham gia chat này
        const participants = [selectedChat.participantOneId.$oid, selectedChat.participantTwoId.$oid];
        const senderId = sample(participants);

        return {
            _id: { $oid: new ObjectId().toString() },
            chatId: { $oid: selectedChat._id.$oid },
            senderId: { $oid: senderId },
            content: faker.lorem.sentence(),
            type: sample(["text", "image", "audio"]),
            isRead: faker.datatype.boolean(),
            createdAt: { $date: faker.date.recent().toISOString() },
            mediaUrl: sample([faker.image.url(), ""]),
        };
    });
};

// Tạo calls
const generateCalls = (userIds) => {
    return Array.from({ length: DATA.calls }, () => {
        const callerId = sample(userIds);
        const receiverId = sample(userIds.filter(id => id !== callerId));
        const isMissed = Math.random() < 0.5; // 50% chance of missed call
        const duration = isMissed ? 0 : faker.number.int({ min: 1, max: 600 });
        return {
            _id: { $oid: new ObjectId().toString() },
            callerId: { $oid: callerId },
            receiverId: { $oid: receiverId },
            status: isMissed ? "missed" : "received",
            duration: duration,
            startedAt: { $date: faker.date.recent().toISOString() },
            endedAt: { $date: faker.date.recent().toISOString() },
        };
    });
};

// Main function
const generateData = () => {
    // 1. Generate users
    const users = generateUsers();
    const userIds = users.map(user => user._id.$oid);
    fs.writeFileSync("users.json", JSON.stringify(users, null, 2));

    // 2. Generate stories
    const stories = generateStories(userIds);
    const storyIds = stories.map(story => story._id.$oid);
    fs.writeFileSync("stories.json", JSON.stringify(stories, null, 2));

    // 3. Generate contacts
    const contacts = generateContacts(userIds);
    fs.writeFileSync("contacts.json", JSON.stringify(contacts, null, 2));

    // 4. Generate comments
    const comments = generateComments(userIds, storyIds);
    fs.writeFileSync("comments.json", JSON.stringify(comments, null, 2));

    // 5. Generate chats
    const chats = generateChats(userIds);
    fs.writeFileSync("chats.json", JSON.stringify(chats, null, 2));

    // 6. Generate messages - Pass chats instead of chatIds
    const messages = generateMessages(userIds, chats);
    fs.writeFileSync("messages.json", JSON.stringify(messages, null, 2));

    // 7. Generate calls
    const calls = generateCalls(userIds);
    fs.writeFileSync("calls.json", JSON.stringify(calls, null, 2));

    console.log("✅ Dữ liệu đã được sinh thành công!");
};

generateData();