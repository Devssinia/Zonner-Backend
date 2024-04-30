import { Chapa } from 'chapa-nodejs';
import dotenv from 'dotenv';
import { chapa_insert_transaction,update_transaction } from '../../../utilities/chapa/chapa_transaction.js';

dotenv.config();
const chapa = new Chapa({
  secretKey: process.env.CHAPA_SECRETE_KEY,
});
let tx_ref;
const chapa_callback=process.env.CHPA_CALLBACK_URL
const accept_chapa_payment = async (req, res) => {
  tx_ref = await chapa.generateTransactionReference();
//   const money=req.body.input.amount
//   const order_id=req.body.input.order_id;
//   const customer_id=req.body.input.customer_id;
  const money=req.body.input.amount
  const order_id=req.body.input.order_id;
  const customer_id=req.body.input.customer_id;
  try {
    const response = await chapa.mobileInitialize({
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@gmail.com',
    currency: 'ETB',
    amount: money,
    tx_ref: tx_ref,
    callback_url: `${chapa_callback}/verify_chapa_payment`,
    return_url: `${chapa_callback}/verify_chapa_payment`,
    customization: {
      title: 'Zonner Payment',
      description: 'We are Zonners',
    },
  });
 

  const transaction= await  chapa_insert_transaction({amount: money,status:"success",order_id:order_id,customer_id: customer_id,currency:"ETB",tx_ref:tx_ref,checkout_url:response.data["checkout_url"]})
  console.log( "the checkout url is ",response.data["checkout_url"]);
  return res.json({
    "message":"payment request successfull",
    "checkoutUrl":`${response.data["checkout_url"]}`,
    "tx_ref":`${tx_ref}`,
  })
  } catch (error) {
   console.error('Error:', error)
   return res.json({
    "message":"payment request failed",
  })
  }
};

const verify_chapa_payment= async (req,res)=>{
  try{
  const response = await chapa.verify({
      tx_ref: tx_ref,
    });
  console.log("the response afte verify is",response);
  }
catch(error){
  console.error('Error:',)
}
  
}
export {accept_chapa_payment,verify_chapa_payment}