const axios = require('axios');
const config = require('./config');
import { insert_transaction, update_mpsesa_transaction } from '../../utilities/transactions';
import { generateSecurityCredential } from './generate_security_credential';



const checkStatus = async (checkout_request_id) => {
    const authUrl = config.authUrl;
    const statusUrl=config.checkStatusUrl;
    const consumer_key = config.consumerKey;
    const consumer_secret = config.secret;
    let auth = Buffer.from(`${consumer_key}:${consumer_secret}`).toString('base64');

    try {
        let tokenResponse = await axios.get(authUrl, {
            headers: {
                "Authorization": `Basic ${auth}`
            }
        });
        let token = tokenResponse.data['access_token'];
        const authHeader = `Bearer ${token}`;
        const date=new Date()
        const timestamp=
             date.getFullYear() +
             ("0" + (date.getMonth() + 1)).slice(-2) +
             ("0" + date.getDate()).slice(-2) +
             ("0" + date.getHours()).slice(-2) +
             ("0" + date.getMinutes()).slice(-2) +
             ("0" + date.getSeconds()).slice(-2) 
        const bs_short_code = config.shortcode;
        const passkey = config.passkey;
        const password = new Buffer.from(bs_short_code + passkey + timestamp).toString("base64");

        const { data } = await axios.post(statusUrl, {
            "BusinessShortCode": bs_short_code,
            "Password": password,
            "Timestamp": timestamp,
            "CheckoutRequestID": checkout_request_id,
        }, {
            "headers": {
                "Authorization": authHeader
            }
        });

        const ResultCode = data.ResultCode;
        if (ResultCode != 0) {
            await update_mpsesa_transaction({
                mpesa_transaction_id: checkout_request_id,
                status: "unpaid"
            });
            console.log("Transaction failed");
            return "unpaid"
        } else {
            await update_mpsesa_transaction({
                mpesa_transaction_id: checkout_request_id,
                status: "paid"
            });
            console.log("Payment successful");
            return "paid"
        }
    } catch (err) {
        console.error('Error checking status:', err);
         return "pending"
    }
};

module.exports = {
    checkStatus
};