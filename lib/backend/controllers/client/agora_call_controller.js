import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg;

export const getAgoraToken = (req, res) => {
    console.log('=== AGORA TOKEN REQUEST DEBUG ===');
    console.log('Headers:', req.headers);
    console.log('Method:', req.method);
    console.log('URL:', req.url);
    console.log('Body:', req.body);
    console.log('Content-Type:', req.get('Content-Type'));
    console.log('Authorization:', req.get('Authorization') ? 'Present' : 'Missing');
    console.log('================================');

    const { channelName, uid, role, expireTime } = req.body;

    console.log('Parsed body values:');
    console.log('- channelName:', channelName);
    console.log('- uid:', uid);
    console.log('- role:', role);
    console.log('- expireTime:', expireTime);

    const appID = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;

    // Debug logs
    console.log('AGORA_APP_ID:', appID ? 'Set' : 'Not set');
    console.log('AGORA_APP_CERTIFICATE:', appCertificate ? 'Set' : 'Not set');

    if (!appID) {
        return res.status(500).json({
            error: 'AGORA_APP_ID not set in environment variables',
            details: 'Please add AGORA_APP_ID to your .env file'
        });
    }

    if (!appCertificate) {
        return res.status(500).json({
            error: 'AGORA_APP_CERTIFICATE not set in environment variables',
            details: 'Please add AGORA_APP_CERTIFICATE to your .env file'
        });
    }

    // Validate required fields
    if (!channelName) {
        return res.status(400).json({
            error: 'channelName is required',
            received: req.body
        });
    }

    if (uid === undefined || uid === null) {
        return res.status(400).json({
            error: 'uid is required',
            received: req.body
        });
    }

    // Set user role
    let agoraRole = RtcRole.SUBSCRIBER;
    if (role === 'publisher') {
        agoraRole = RtcRole.PUBLISHER;
    }

    // Set token expiration time
    const expirationTimeInSeconds = expireTime || 3600;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    try {
        console.log('Building token with:');
        console.log('- appID:', appID);
        console.log('- appCertificate length:', appCertificate.length);
        console.log('- channelName:', channelName);
        console.log('- uid:', uid);
        console.log('- agoraRole:', agoraRole);
        console.log('- privilegeExpiredTs:', privilegeExpiredTs);

        // Build token
        const token = RtcTokenBuilder.buildTokenWithUid(
            appID, appCertificate, channelName, uid, agoraRole, privilegeExpiredTs
        );

        console.log('Token generated successfully for channel:', channelName);
        res.json({ token });
    } catch (error) {
        console.error('Error generating token:', error);
        res.status(500).json({
            error: 'Failed to generate token',
            details: error.message
        });
    }
};
