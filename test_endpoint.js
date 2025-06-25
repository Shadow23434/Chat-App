const http = require('http');

// Test the debug endpoint
const testData = {
    chatId: "683328469a3b94a8153e070f",
    userId: "683328469a3b94a8153e05e2"
};

const postData = JSON.stringify(testData);

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/debug/trigger-chat-update',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'Authorization': 'Bearer YOUR_TOKEN_HERE' // Replace with actual token
    }
};

const req = http.request(options, (res) => {
    console.log(`Status: ${res.statusCode}`);
    console.log(`Headers: ${JSON.stringify(res.headers)}`);

    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        console.log('Response:', data);
    });
});

req.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
});

req.write(postData);
req.end(); 