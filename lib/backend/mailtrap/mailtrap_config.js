import dotenv from 'dotenv';
// import { MailtrapClient } from "mailtrap";

import nodemailers from 'nodemailer';

dotenv.config();

// export const mailtrapClient = new MailtrapClient({
//     token: process.env.MAILTRAP_TOKEN,
// });

// export const sender = {
//     email: "hello@chat-app.com",
//     name: "Chat App",
// };

export const transporter = nodemailers.createTransport({
    host: process.env.GMAIL_HOST,
    port: 587,
    secure: false,
    auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS,
    }
});

export const mailOptions = {
    from: '"Chat App" <contact@chatapp.com>',
};
