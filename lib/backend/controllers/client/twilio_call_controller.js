const twilio = require('twilio');
const AccessToken = twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;

exports.getTwilioToken = (req, res) => {
    const { identity, room } = req.body;
    const token = new AccessToken(
        process.env.TWILIO_ACCOUNT_SID,
        process.env.TWILIO_API_KEY,
        process.env.TWILIO_API_SECRET
    );
    token.identity = identity;
    const videoGrant = new VideoGrant({ room });
    token.addGrant(videoGrant);
    res.json({ token: token.toJwt() });
};
