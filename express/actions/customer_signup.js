import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { user as User } from '../utility/user'
import { insert_customer, find_customer } from '../utility/customer'
import { insert_password as Insert_password } from '../utility/user'

dotenvConfig()

const  customer_signup= async (req,res) => {
  const { full_name, email, phone_no, password } = req.body.input
  if (!phone_no || !password ||!full_name || !email) {
    return res.status(400).json({
      message: 'Please provide all the details',
    })
  }
  const salt = await bcrypt.genSalt(10)
  const hashed_password = await bcrypt.hash(password, salt)
  const user = await User({ phone_no })
  if (user) {
    return res.status(400).json({
      message: 'User Already Exists',
    })
  }
  let customer_email = await find_customer({ email })
  console.log(customer_email)
  if (customer_email) {
    return res.status(400).json({
      message: 'Your Email is Already Registered',
    })
  }
  const customer = await insert_customer({phone_no,full_name, email })
  if (!customer) {
    return res.status(400).json({
      message: 'Something went wrong ',
    })
  }
  const insert_password = await Insert_password({
    password: hashed_password,
    user_id: rider,
  })
  if (!insert_password) {
    return res.status(400).json({
      message: 'Something went wrong',
    })
  }
  return res.json({
    success: 'Customer Created Successfully',
  })
}
export {customer_signup }