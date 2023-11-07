const axios = require('axios');
const config = require('./config');
const uuid = require('uuid');
import { generateSecurityCredential } from './generate_security_credential.js';
import { insert_transaction, update_transaction } from '../../utilities/transactions';
exports.buisnessToCustomer = async (req, res) => {
    console.log("the request token is ", req.token)
    const url = 'https://sandbox.safaricom.co.ke/mpesa/b2c/v3/paymentrequest';
    const phone = req.body.phone.substring(1);
    const money = req.body.amount;
    const shortcode = config.shortcode;
    const que = config.b2cQue;
    const passKey = config.passkey
    const resultUrl = config.b2cResultUrl
    const initiatorName=config.initiatorName
    const securityCredential = generateSecurityCredential(passKey)
     console.log("initiator name is",initiatorName)
    console.log("generated security credential is", securityCredential)
    const originatorConversationID = uuid.v4(); // You need to implement a function to generate a unique ID
    const auth = `Bearer ${req.token}`
    try {
        console.log("it is excuted succssfully")
        let { data } = await axios.post(url, {
            "OriginatorConversationID": originatorConversationID,
            "InitiatorName": initiatorName,
            "SecurityCredential": securityCredential,
            "CommandID": "BusinessPayment",
            "Amount": money,
            "PartyA": shortcode,
            "PartyB": phone,
            "Remarks": "please pay",
            "QueueTimeOutURL": que,
            "ResultURL": resultUrl,
            "Occasion": "endmonth"
        }, {
            "headers": {
                "Authorization": auth
            }
        })
        console.log(data)
        return res.status(200).json({
            "transaction_id": "successfully sent",
        })
    } catch (err) {
        console.log(err);
        return res.send({
            success: false,
            message: err.message
        });
    }
}
