const axios = require('axios');
const config = require('./config');
exports.payAmount=async(req,res)=>{
    const phone=req.body.phone
    const money=req.body.amount
    if(!phone) return res.status(400).json({message:"Phone Number is required"})
    if(!money) return res.status(400).json({message:"Amount is required"})
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
    let url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";
    let bs_short_code = config.shortcode;
    let passkey = config.passkey;
    let officialPhoneNo=phone.substring(1)
    let password = new Buffer.from(`${bs_short_code}${passkey}${timestamp}`).toString('base64');
    let transcation_type = "CustomerPayBillOnline";
    let amount = `${money}`; 
    let partyA = `${officialPhoneNo}`; 
    let partyB = bs_short_code;
    let phoneNumber = `${officialPhoneNo}`;
    let callBackUrl = "https://a5b2-196-191-61-103.ngrok-free.app/callback";
    let accountReference = `FredZonner`;
    let transaction_desc = "Testing"
    try {
    console.log("it is excuted succssfully")
    console.log(`the phone number passed is ${officialPhoneNo}`)
        let {data} = await axios.post(url,{
            "BusinessShortCode":bs_short_code,
            "Password":password,
            "Timestamp":timestamp,
            "TransactionType": transcation_type,
            "Amount": amount,
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
     return  res.status(200).json({
       "message":"successfully sent"})
    }catch(err){
        console.log(err);
        return res.send({
            success:false,
            message:err.message
        });
    }
}
exports.mpessaCallBack=async(req,res)=>{
    let body=req.body
    let {ResultCode,ResultDesc}=body.Body.stkCallback;
    let receipt,amount,phone,date=""    
    if(ResultCode != 0){
        console.log(ResultCode,ResultDesc) 
        return res.status(400).json({message:`${ResultDesc}`})
    } 
    let list=body.Body.stkCallback.CallbackMetadata.Item;
    list.forEach(item => {

        if (item.Name === "MpesaReceiptNumber") {
        //    unique identifier for transaction
        receipt = item.Value
         console.log(`the recipt is ${receipt}`)
        }
        if (item.Name === "TransactionDate") {
           //stores date of transaction
          date = item.Value
        console.log(`the date here is ${date}`)
        }
        if (item.Name === "PhoneNumber") {
            //stores the transaction phone
           phone= item.Value
           console.log(`the phone is ${phone}`)

        }
        if (item.Name === "Amount") {
           //stores transaction amount
            amount = item.Value
            console.log(`the amount is ${amount}`)
        }
    });
    try {

    console.log(ResultDesc)
      return  res.status(201).json({message:`${ResultDesc}`})
    } catch (error) {
        console.log(error.message)
        return res.send({
            success:false,
            message:error.message
        });
    }
}
