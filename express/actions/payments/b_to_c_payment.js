const axios = require('axios');
const config = require('./config');
import { insert_transaction,update_transaction } from '../../utilities/transactions';
exports.buisnessToCustomer=async(req,res)=>{  
    const url = 'https://sandbox.safaricom.co.ke/mpesa/b2c/v3/paymentrequest';
    const phone=req.body.phone;
    const money=req.body.amount;
    const shortcode=config.shortcode;
     auth = 'Bearer ' + req.token
   try {
 console.log("it is excuted succssfully")
    console.log(`the phone number passed is ${officialPhoneNo}`)
        let {data} = await axios.post(url,{
            "InitiatorName": "apitest342",
            "SecurityCredential": "Q9KEnwDV/V1LmUrZHNunN40AwAw30jHMfpdTACiV9j+JofwZu0G5qrcPzxul+6nocE++U6ghFEL0E/5z/JNTWZ/pD9oAxCxOik/98IYPp+elSMMO/c/370Joh2XwkYCO5Za9dytVmlapmha5JzanJrqtFX8Vez5nDBC4LEjmgwa/+5MvL+WEBzjV4I6GNeP6hz23J+H43TjTTboeyg8JluL9myaGz68dWM7dCyd5/1QY0BqEiQSQF/W6UrXbOcK9Ac65V0+1+ptQJvreQznAosCjyUjACj35e890toDeq37RFeinM3++VFJqeD5bf5mx5FoJI/Ps0MlydwEeMo/InA==",
            "CommandID": "BusinessPayment",
            "Amount": money,
            "PartyA": shortcode,
            "PartyB": phone,
            "Remarks": "please pay",
            "QueueTimeOutURL":"http://197.248.86.122:801/timeout_url",
            "ResultURL":"http://197.248.86.122:801/b2c_result_url",
            "Occasion": "endmonth"
        },{
            "headers":{
                "Authorization":auth
            }
        })
     console.log(data)
     return  res.status(200).json({
       "transaction_id":"successfully sent",})
    }catch(err){
        console.log(err);
        return res.send({
            success:false,
            message:err.message
        });
    }
   }
