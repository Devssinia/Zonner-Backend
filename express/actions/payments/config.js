const dotenv = require('dotenv');
dotenv.config();
module.exports = {
    consumerKey: process.env.CONSUMER_KEYY,
    secret: process.env.CONSUMER_SECRETE,
    passkey: process.env.PASS_KEY,
    shortcode: process.env.SHORT_CODE,
};