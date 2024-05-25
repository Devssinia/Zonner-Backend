const dotenv = require('dotenv');
dotenv.config();
module.exports = {
    consumerKey: process.env.CONSUMER_KEYY,
    secret: process.env.CONSUMER_SECRETE,
    passkey: process.env.PASS_KEY,
    shortcode: process.env.SHORT_CODE,
    c2bCallback:process.env.C2B_CALLBACK_URL,
    b2cResultUrl:process.env.B2C_RESULT_URL,
    b2cQue:process.env.QUEUE_TIMEOUT_URL,
    initiatorName:process.env.INITIATOR_NAME,
    authUrl:process.env.AUTH_URL,
    c2bUrl:process.env.C2B_URL,
    checkStatusUrl:process.env.CHECK_STATUS_URL
};