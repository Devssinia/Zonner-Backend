import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { insert_rider, find_rider } from '../utilities/rider'
import { User,insert_password as Insert_password } from '../utilities/user'
dotenvConfig()
/**
 * Creates a new rider account with the provided information.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @return {Promise} A promise that resolves to the response object.
 */
const rider_signup = async (req, res) => {
  try {
    const { first_name, last_name, email, phone_no, password } = req.body.input
    if (!phone_no || !password || !first_name || !last_name || !email) {
      return res.status(400).json({
        message: 'Please provide ALL the details',
      })
    }
    const salt = await bcrypt.genSalt(10)
    const hashed_password = await bcrypt.hash(password, salt)
    const user = await User({ phone_no })
    console.log(user)
    if (user) {
      return res.status(400).json({
        message: 'User Already Exists',
      })
    }
    let rider_email = await find_rider({ email })
    console.log(rider_email)
    if (rider_email) {
      return res.status(400).json({
        message: 'Your Email is Already Registered',
      })
    }
    const rider = await insert_rider({ phone_no, first_name, last_name, email })
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
  } catch (error) {
    return res.status(400).json({
      message: error,
    })
  }
}

export { rider_signup }
