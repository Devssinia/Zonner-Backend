const axios = require('axios');
const config = require('./config');

const url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
const consumer_key = config.consumerKey;
const consumer_secret = config.secret;
const passkey = config.passkey;
const shortcode = config.shortcode;
const prettyJsonOptions = {
    noColor: true
};

let oauth_token=null;

async function getOauthToken() {
    try {
        const auth = "Basic " + Buffer.from(`${consumer_key}:${consumer_secret}`).toString("base64");
        const response = await axios.get(url, {
            headers: {
                "Authorization": auth
            }
        });
        oauth_token = response.data.access_token;
        console.log("Token:", oauth_token);
    } catch (error) {
        console.error("Auth Error:", error.message);
    }
}

async function stk_push(req, res) {
    try {
        if (!oauth_token) {
            await getOauthToken();
        }

        const phone = req.body.phone;
        const amount = req.body.amount;

        if (!phone || !amount) {
            return res.status(400).json({ message: "Phone Number and Amount are required" });
        }

        const timestamp = formatDate();
        const password = Buffer.from(shortcode + passkey + timestamp).toString("base64");
        const auth = "Bearer " + oauth_token;
        console.log(auth)
        console.log(`excute ${consumer_key}`)
        const pay_url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";
        const response = await axios.post(pay_url, {
            "BusinessShortCode": shortcode,
            "Password": password,
            "Timestamp": timestamp,
            "TransactionType":"CustomerPayBillOnline",
            "Amount": amount,
            "PartyA": phone,
            "PartyB": shortcode,
            "PhoneNumber": phone,
            "CallBackURL":"https://9ee9-196-191-61-185.ngrok-free.app/mpesa-callback",
            "AccountReference": "Zonner App",
            "TransactionDesc": "Testing mpesa"
        }, {
            headers: {
                "Authorization": auth
            }
        });
        res.status(200).send('STK push sent to phone');
        console.log("Response:", response.data);
    } catch (error) {
        res.status(500).send('There was an error');
        console.error("LNMO error:", error);
    }
}

function formatDate() {
    const date = new Date();
    const correctDate =
        date.getFullYear().toString() +
        pad2(date.getMonth() + 1) +
        pad2(date.getDate()) +
        pad2(date.getHours()) +
        pad2(date.getMinutes()) +
        pad2(date.getSeconds());
    return correctDate;
}

function pad2(n) {
    return n < 10 ? '0' + n : n;
}

module.exports = {
    stk_push
};
