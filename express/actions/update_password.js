import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { update_password } from '../utilities/authentication'
dotenvConfig()
const reset_password = async (req, res) => {
  try {
    const {phone_no,new_password}= req.body.input
    
    if (!phone_no|| !new_password) {
      return res.status(400).json({
        message: 'Please provide all the details',
      })
    }
   const salt = await bcrypt.genSalt(10)
   const hashed_password = await bcrypt.hash(new_password, salt)
    const  password=hashed_password
    console.log("good untill this")

    const authentication = await update_password({phone_no,password })
    console.log(authentication)
    return res.json({
      success: 'Password Reseted Successfully',
    })
  } catch (error) {
    return res.status(400).json({
      message: error,
    })
  }
}

export {reset_password }
