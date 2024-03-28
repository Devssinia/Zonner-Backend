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
    const { phone_no, password,role_name} = req.body.input
    if (!phone_no || !password ||role_name) {
      return res
        .status(400)
        .json({ message: 'Please provide Both Phone Number and Password' })
    }
      
      let role_id;
      if(role_name=="customer"){
        role_id="d6895ae5-c665-420a-ae0a-6efd81ee7506"
       }
      else if(role_name=="vendor"){
        role_id="9268abe4-21b8-4839-8e1e-12c4322a63cd"
      }
      else if(role_name=="rider"){
         role_id="56a6ed6a-f320-4a46-bb5f-10c7ece29c7c"
      }
      else {

      }
    const user = await User({ phone_no,role_id })
    
    if (!user || !user.password || !user.role) {
      return res.status(400).json({ message: 'Incorrect Credentials' })
    }
    
    console.log("the current user is",user)
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
