import { transporter, mailOptions } from "./mailtrap_config.js";
import {
    VERIFICATION_EMAIL_TEMPLATE,
    PASSWORD_RESET_REQUEST_TEMPLATE,
    PASSWORD_RESET_SUCCESS_TEMPLATE,
    WELCOME_EMAIL_TEMPLATE
} from './emailTemplates.js'

export const sendVerificationEmail = async (email, verificationToken) => {
    try {
        const response = await transporter.sendMail({
            ...mailOptions,
            to: email,
            subject: 'Verify your email',
            html: VERIFICATION_EMAIL_TEMPLATE.replace('{verificationCode}', verificationToken),
            category: 'Email Verification'
        });

        console.log('Email sent successfully', response);
    } catch (error) {
        console.error(`Error sending verification`, error);
        throw new Error(`Error sending verification email: ${error}`);
    }
}

export const sendWelcomeEmail = async (email, username) => {
    try {
        const response = await transporter.sendMail({
            ...mailOptions,
            to: email,
            subject: 'Welcome to Chat App',
            html: WELCOME_EMAIL_TEMPLATE.replace('{username}', username),
            category: 'Welcome Email',
        });

        console.log('Welcome email sent successfully', response);
    } catch (error) {
        console.log(`Error sending welcome email`, error);
        throw new Error(`Error sending welcome email: ${error}`);
    }
}

export const sendPasswordResetEmail = async (email, resetUrl) => {
    try {
        const response = await transporter.sendMail({
            ...mailOptions,
            to: email,
            subject: 'Reset your Password',
            html: PASSWORD_RESET_REQUEST_TEMPLATE.replace('{resetURL}', resetUrl),
            category: 'Password Reset',
        });

        console.log('Password reset email sent successfully', response);
    } catch (error) {
        console.log(`Error sending password reset email`, error);
        throw new Error(`Error sending password reset email: ${error}`);
    }
}

export const sendResetSuccessEmail = async (email) => {
    try {
        const response = await transporter.sendMail({
            ...mailOptions,
            to: email,
            subject: 'Reset Password Successful',
            html: PASSWORD_RESET_SUCCESS_TEMPLATE,
            category: 'Password Reset',
        });
        console.log('Reset Success email sent successfully', response);
    } catch (error) {
        console.log(`Error sending reset success email`, error);
        throw new Error(`Error sending reset success email: ${error}`);
    }
}
