export const VERIFICATION_EMAIL_TEMPLATE = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Email</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background: linear-gradient(to right, #3B76F6, #3B76F6); padding: 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">Verify Your Email</h1>
  </div>
  <div style="background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
    <p>Hello,</p>
    <p>Thank you for signing up! Your verification code is:</p>
    <div style="text-align: center; margin: 30px 0;">
      <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #3B76F6;">{verificationCode}</span>
    </div>
    <p>Enter this code on the verification page to complete your registration.</p>
    <p>This code will expire in 15 minutes for security reasons.</p>
    <p>If you didn't create an account with us, please ignore this email.</p>
    <p>Best regards,<br>Chat App Team</p>
  </div>
  <div style="text-align: center; margin-top: 20px; color: #888; font-size: 0.8em;">
    <p>This is an automated message, please do not reply to this email.</p>
  </div>
</body>
</html>
`;

export const WELCOME_EMAIL_TEMPLATE = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Welcome to Chat App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
        }
        .header {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
            align-items: center;
        }
        .logo {
            margin-bottom: 20px;
        }
        .logo img {
            max-width: 150px;
            height: auto;
            display: block;
            margin: 0 auto;
        }
        .content {
            background-color: #f9f9f9;
            padding: 25px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .button {
            display: inline-block;
            background-color: #3B76F6;
            padding: 12px 25px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            margin: 15px 0;
        }
        .guide-container {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 10px;
        }
        .guide-container a {
            color: #3B76F6;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            font-size: 16px;
        }
        .guide-icon {
            width: 50px;  
            height: 50px; 
            margin-right: 12px;  
            vertical-align: middle;
        }
        .footer {
            font-size: 14px;
            color: #7f8c8d;
            align-items: center;
        }
    </style>
</head>
<body>
    <div class="header">Chat App</div>
    
    <div class="logo">
        <img src="https://media-hosting.imagekit.io/454ca4aaa0f8469e/app_logo.png?Expires=1837870869&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=HCxpBxGI2jIG5C8VvZMq9GpOEO-ZCVDsmU4owZFkbs70Hl-ZX76uysFPoxY3zvcHk2nmO3Ecqf6Yjdk3-0vL5bGVSHmG6f3F8~mSfbwtQfOIxS5TWODUVsh9I9dxKuDj05K~lGRkqO19~DqK9MUmgBiv~cfu6iL~MA-WBKJ7HUMOOtXk0utIWnK3Pl~Pu0qh-OANXdwrY3RfZrjSW-7HcIGqVvZltK~VJvPMf5CwwientfaxXGygqAb2Jaxn7PuvhsnKzWXgVXdzenzxVhiXdVJ8RR8vJhsNFFFdFVyKF985ueVfWhIgcQm-GPRn4qeDyY0tX2Jz43IvoSiBBSPhxw__" alt="Chat App Logo" style="display: block; max-width: 150px;">
    </div>
    
    <div class="content">
        <p>Welcome, <strong>{username}</strong></p>
        <p>Thanks for choosing Chat App! We are happy to see you on board.</p>
        
        <p>To get started, do this next step:</p>
        
    <div style="text-align: center; margin: 30px 0;">
      <a href="#" style="background-color: #3B76F6; color: white; padding: 12px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;">Next Step</a>
    </div>
        
        <div class="guide-container">
            <a href="#">
                <img src="https://media-hosting.imagekit.io/acecf163b6224670/start_guild.png?Expires=1837870940&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=E9qK7aQ14ADthiJA5WDmny2Y0QERoVdwgWEg6V5pucH1hh48jT~9XIWZjFmqQfACYD7RfG5FxyUAOHC6C2Dsholj0LuCeqhPJ5JoNDh93C5I7GOtKxdixufui~0Xq51NMxF~1JIOiNZt2gZH-xyf9sW~oZWjSCIk-667auphJDBpOEgSKkfgnWFtMlUpCj6xkXbV-gEW-ZAIQhvFAM~tHhyCh5ajpJherlCNu9DKgo50vqaafFXRhHLAsgpUalVXws0rQAI9jYK9svj4CtVQADE9KxkciQfzo7NQ1dQs8v7RAju2kpeWmYaGioQOIMnppOAyhXXdYxBnJiB8nx1D6g__" class="guide-icon" alt="Guide icon" style="width:80px; height:50px;">
                Get Started Guide
            </a>
        </div>
    </div>
    
    <div class="footer">
        <p>We hope you enjoy this journey as much as we enjoy creating it for you.</p>
    </div>
</body>
</html>
`;

export const PASSWORD_RESET_SUCCESS_TEMPLATE = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Password Reset Successful</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background: linear-gradient(to right, #3B76F6, #3B76F6); padding: 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">Password Reset Successful</h1>
  </div>
  <div style="background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
    <p>Hello,</p>
    <p>We're writing to confirm that your password has been successfully reset.</p>
    <div style="text-align: center; margin: 30px 0;">
      <div style="background-color: #3B76F6; color: white; width: 50px; height: 50px; line-height: 50px; border-radius: 50%; display: inline-block; font-size: 30px;">
        ✓
      </div>
    </div>
    <p>If you did not initiate this password reset, please contact our support team immediately.</p>
    <p>For security reasons, we recommend that you:</p>
    <ul>
      <li>Use a strong, unique password</li>
      <li>Enable two-factor authentication if available</li>
      <li>Avoid using the same password across multiple sites</li>
    </ul>
    <p>Thank you for helping us keep your account secure.</p>
    <p>Best regards,<br>Chat App Team</p>
  </div>
  <div style="text-align: center; margin-top: 20px; color: #888; font-size: 0.8em;">
    <p>This is an automated message, please do not reply to this email.</p>
  </div>
</body>
</html>
`;

export const PASSWORD_RESET_REQUEST_TEMPLATE = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Your Password</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background: linear-gradient(to right, #3B76F6, #3B76F6); padding: 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">Password Reset</h1>
  </div>
  <div style="background-color: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
    <p>Hello,</p>
    <p>We received a request to reset your password. If you didn't make this request, please ignore this email.</p>
    <p>To reset your password, click the button below:</p>
    <div style="text-align: center; margin: 30px 0;">
      <a href="{resetURL}" style="background-color: #3B76F6; color: white; padding: 12px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;">Reset Password</a>
    </div>
    <p>This link will expire in 1 hour for security reasons.</p>
    <p>Best regards,<br>Chat App Team</p>
  </div>
  <div style="text-align: center; margin-top: 20px; color: #888; font-size: 0.8em;">
    <p>This is an automated message, please do not reply to this email.</p>
  </div>
</body>
</html>
`;
