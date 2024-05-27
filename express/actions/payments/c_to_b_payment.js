const axios = require('axios');
const config = require('./config');

import { insert_transaction,update_mpsesa_transaction,update_order} from '../../utilities/transactions';
import {checkStatus} from './check_status.js'
exports.payAmount=async(req,res)=>{
    const phone=req.body.input.phone
    const money=req.body.input.amount
    const order_id=req.body.input.order_id
    const customer_id=req.body.input.customer_id
    if(!phone) return res.status(400).json({message:"Phone Number is required"})
    if(!money) return res.status(400).json({message:"Amount is required"})
    if(!order_id) return res.status(400).json({message:"Order Id is required"})
    if(!customer_id) return res.status(400).json({message:"Customer Id is required"})
  
    const date=new Date()
    const timestamp=
         date.getFullYear() +
         ("0" + (date.getMonth() + 1)).slice(-2) +
         ("0" + date.getDate()).slice(-2) +
         ("0" + date.getHours()).slice(-2) +
         ("0" + date.getMinutes()).slice(-2) +
         ("0" + date.getSeconds()).slice(-2) 
    let token = req.token;
    console.log("token",req.token)
    let auth = `Bearer ${token}`;
    console.log(auth)
    let url = config.c2bUrl;
    console.log(`this is for production ${url}`)
    let bs_short_code = config.shortcode;
    let passkey =config.passkey;
    let callBackUrl=config.c2bCallback
    let officialPhoneNo=phone.substring(1)//left the first digit +
    const password = new Buffer.from(bs_short_code + passkey + timestamp).toString("base64");
    let transcation_type = "CustomerPayBillOnline";
    let amount = `${money}`; 
    let partyA = `${officialPhoneNo}`; 
    let partyB = bs_short_code;
    let phoneNumber = `${officialPhoneNo}`;
    let accountReference = `FredZonner`;
    let transaction_desc = "Testing"
    console.log(`printing partyA:${partyA} partyB: ${partyB} phoneNumber :${phoneNumber}`)

    try {
    console.log("it is excuted succssfully")
        let {data} = await axios.post(url,{
            "BusinessShortCode":bs_short_code,
            "Password":password,
            "Timestamp":timestamp,
            "TransactionType": transcation_type,
            "Amount":amount,
            "PartyA": partyA,
            "PartyB": partyB,
            "PhoneNumber":phoneNumber,
            "CallBackURL":callBackUrl,
            "AccountReference":accountReference,
            "TransactionDesc":transaction_desc
        },{
            "headers":{
                "Authorization":auth
            }
        })
      console.log(data)
      const date = new Date();
      const isoDateWithOffset = date.toISOString();
      const transaction= await  insert_transaction({phone_number:phoneNumber,amount: amount,transaction_date:isoDateWithOffset,mpesa_transaction_id:data["CheckoutRequestID"], status:"pending",order_id:order_id,customer_id:customer_id})
      
      await new Promise((resolve) => setTimeout(resolve, 30000));
        console.log("now Before calling");
        const status=await checkStatus(data["CheckoutRequestID"]);
         await update_order({order_id:order_id,transaction_status:status})
         console.log("now after calling");
        return res.status(200).json({
            "success": true,
            "message":`${status}`
        });
       
    }catch(err){
        console.log(err);
        return res.send({
            success:false,
            message:err
        });
    }
}

// this code is no more important for integration of mpesa in this code
exports.mpesaCallBack = async (req, res) => {
    console.log("Callback received");
    let body = req.body;
    let { ResultCode, ResultDesc } = body.Body.stkCallback;
    let receipt, amount, phone, date = "";

    if (ResultCode != 0) {
        console.log("function inside result description")
        // Transaction failed
        console.log(ResultCode, ResultDesc);
        try {
            await update_mpsesa_transaction({
                mpesa_transaction_id: body.Body.stkCallback.CheckoutRequestID,
                status: "pending"
            });
            return res.status(400).json({ message: `${ResultDesc}` });
        } catch (error) {
            console.log(error.message);
            return res.status(500).json({ success: false, message: error.message });
        }
    }



    // Transaction successful
    let list = body.Body.stkCallback.CallbackMetadata.Item;
    list.forEach(item => {
        if (item.Name === "MpesaReceiptNumber") {
            receipt = item.Value;
        }
        if (item.Name === "TransactionDate") {
            date = item.Value;
        }
        if (item.Name === "PhoneNumber") {
            phone = item.Value;
        }
        if (item.Name === "Amount") {
            amount = item.Value;
        }
    });

    try {
        await update_mpsesa_transaction({
            mpesa_transaction_id: receipt,
            status: "paid"
        });

        console.log("Transaction updated successfully");
        return res.status(200).json({ message: `Payment successful: ${ResultDesc}` });

    } catch (error) {
        console.log(error.message);
        return res.status(500).json({ success: false, message: error.message });
    }
};

// autoB2B=async(req,res)=>{
//   console.log("this will be excutes after trabsaction is successful and updated")

// }