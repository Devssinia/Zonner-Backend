import axios from 'axios';
import { config as dotenvConfig } from 'dotenv'

dotenvConfig()

export const c2b_payment = async (req, res) => {
  const phone = req.body.phone;
  const money = req.body.amount;
  const order_id = req.body
  if (!phone) return res.status(400).json({ message: "Phone Number is required" });
  if (!money) return res.status(400).json({ message: "Amount is required" });

  const date = new Date();
  const timestamp =
    date.getFullYear() +
    ("0" + (date.getMonth() + 1)).slice(-2) +
    ("0" + date.getDate()).slice(-2) +
    ("0" + date.getHours()).slice(-2) +
    ("0" + date.getMinutes()).slice(-2) +
    ("0" + date.getSeconds()).slice(-2);
  let token = req.token;
  let auth = `Bearer ${token}`;
  console.log(auth);
  let url = process.env.lipa_na_mpesa_url;
  let bs_short_code = process.env.lipa_na_mpesa_shortcode;
  let passkey = process.env.lipa_na_mpesa_passkey;
  let officialPhoneNo = phone.substring(1);

  let password = Buffer.from(`${bs_short_code}${passkey}${timestamp}`).toString('base64');
  let transcation_type = "CustomerPayBillOnline";
  let amount = `${money}`; //you can enter any amount
  let partyA = `254${officialPhoneNo}`; //should follow the format:2547xxxxxxxx
  let partyB = bs_short_code;
  let phoneNumber = `254${officialPhoneNo}`; //should follow the format:2547xxxxxxxx
  let callBackUrl = "https://8efc-197-237-246-189.ngrok.io/api/myCallBackUrl";
  let accountReference = `MpesaApiTest`;
  let transaction_desc = "Testing";

  try {
    let { data } = await axios.post(url, {
      "BusinessShortCode": bs_short_code,
      "Password": password,
      "Timestamp": timestamp,
      "TransactionType": transcation_type,
      "Amount": amount,
      "PartyA": partyA,
      "PartyB": partyB,
      "PhoneNumber": phoneNumber,
      "CallBackURL": callBackUrl,
      "AccountReference": accountReference,
      "TransactionDesc": transaction_desc
    }, {
      "headers": {
        "Authorization": auth
      }
    });
    console.log(data);
    return res.status(200).json(data);
  } catch (err) {
    return res.send({
      success: false,
      message: err.message
    });
  }
};

