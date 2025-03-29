import { mailtrapClient, sender } from "./mailtrap_config.js";
import { VERIFICATION_EMAIL_TEMPLATE, PASSWORD_RESET_REQUEST_TEMPLATE, PASSWORD_RESET_SUCCESS_TEMPLATE } from './emailTemplates.js'

export const sendVerificationEmail = async (email, verificationToken) => {
    const recipient = [{ email }];
    try {
        const response = await mailtrapClient.send({
            from: sender,
            to: recipient,
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
    const recipient = [{ email }];

    try {
        const response = await mailtrapClient.send({
            from: sender,
            to: recipient,
            template_uuid: 'b13a4d2f-7da0-488f-97d8-781525bbfb83',
            template_variables: {
                'company_info_name': 'Chat App',
                'name': username,
            }
        });

        console.log('Welcome email sent successfully', response);
    } catch (error) {
        console.log(`Error sending welcome email`, error);
        throw new Error(`Error sending welcome email: ${error}`);
    }
}

export const sendPasswordResetEmail = async (email, resetUrl) => {
    const recipient = [{ email }];

    try {
        const response = await mailtrapClient.send({
            from: sender,
            to: recipient,
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
    const recipient = [{ email }];

    try {
        const response = await mailtrapClient.send({
            from: sender,
            to: recipient,
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
