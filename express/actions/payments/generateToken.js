const axios=require('axios')
 const config = require('./config');
const getOAuthToken=async(req,res,next)=>{
const url="https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
const consumer_key = config.consumerKey;
const consumer_secret = config.secret;
  console.log("consumer key is ",consumer_key)
  console.log("consumer secrete",consumer_secret)
    let auth =Buffer.from(`${consumer_key}:${consumer_secret}`).toString('base64');
    try{
        let {data} =  await axios.get(url,{
            headers:{
               "Authorization":`Basic ${auth}`
            }
        });

        req.token = data['access_token'];
        console.log("the token is ",req.token)
        return next();

    }catch(err){
     console.log("the error is",err)
        return res.send({
            success:false,
            message:err.message
        });
    } 
};
module.exports={
    getOAuthToken
}