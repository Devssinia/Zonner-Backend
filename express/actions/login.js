import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { User, update_last_seen } from '../utilities/user'

/**
 * Log in the user with the provided phone number and password.
 *
 * @param {Object} req - The request object containing the user input.
 * @param {Object} req.body - The request body object.
 *    @param {string} req.body.input.phone_no - The user's phone number.
 *     @param {string} req.body.input.password - The user's password.
 * @param {Object} res - The response object.
 * @return {Object} The access token upon successful login.
 *   @property {string} access_token - The JWT access token.
 */

const login = async (req, res) => {
  try {
    const { phone_no, password } = req.body.input
    if (!phone_no || !password) {
      return res
        .status(400)
        .json({ message: 'Please provide Both Phone Number and Password' })
    }

    const user = await User({ phone_no })
    console.log(user)
    
    if (!user || !user.password || !user.role) {
      return res.status(400).json({ message: 'Incorrect Credentials' })
    }

    const is_valid_password = await bcrypt.compare(password, user.password)
    if (!is_valid_password) {
      return res.status(400).json({ message: 'Incorrect Credentials' })
    }
      
    const token_payload = {
      'https://hasura.io/jwt/claims': {
        'x-hasura-allowed-roles': ['zadmin', 'rider', 'customer', 'vendor'],
        'x-hasura-default-role': user.role.role_name,
        [`x-hasura-${user.role.role_name}-id`]: `${user.user_id}`,
      },
    }
const expirationInSeconds = 1800; // 30 minute
const token = jwt.sign(token_payload, process.env.HASURA_GRAPHQL_JWT_SECRET,{
expiresIn: expirationInSeconds
}); 
const last_seen=await update_last_seen({phone_no})

 console.log(`the returned time stamp is ${last_seen}`)
return res.status(200).json({ access_token: token })
  } catch (error) {
    console.log(error)
    return res.status(400).json({ message: 'Something went wrong' })
  }
}

export { login }
