import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { user as User } from '../utility/user'
import { insert_rider as Rider, find_rider } from '../utility/rider'
import { insert_password as Insert_password } from '../utility/user'

dotenvConfig()

const vendor_signup = async (req, res) => {
  const { first_name, last_name, email, phone_no, password } = req.body.input
  if (!phone_no || !password || !first_name || !last_name || !email) {
    return res.status(400).json({
      message: 'Please provide ALL the details',
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
  let rider_email = await find_rider({ email })
  console.log(rider_email);
  if (rider_email) {
    return res.status(400).json({
      message: 'Your Email is Already Registered',
    })
  }
  const rider = await Rider({ phone_no, first_name, last_name, email })
  if (!rider) {
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
    success: 'Rider Created Successfully',
  })
}


export { vendor_signup }   