import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import jwt from 'jsonwebtoken'
import { user  as User } from '../utility/user'  
dotenvConfig()

const handler = async (req, res) => {
    const { phone_no, password } = req.body.input    
    console.log(phone_no, password);
    
  if(!phone_no || !password){ 
    return res.status(400).json({ 
      message: 'please enter Phone Number and Password'       
    })
  }
  const user = await User({ phone_no })
  console.log(user)
  if (!user) {
    return res.status(400).json({
      message: 'Incorrect Phone Number or Password please enter again',
    })
  } else {
    if (user.password === null) {
      return res.status(400).json({
        message: 'Please Contact Admin to set Your Password',
      })
    }
    const value = await bcrypt.compare(password, user.password)
    if (!value) {
      return res.status(400).json({
        message: 'Incorrect Password',
      })
    }

    let token = jwt.sign(
        {
          'https://hasura.io/jwt/claims': {
            'x-hasura-allowed-roles': ['zadmin', 'rider', 'customer', 'vendor'],
            'x-hasura-default-role': user.role.role_name,
            [`x-hasura-${user.role.role_name}-id`]: `${user.user_id}`,
          },
        },
        process.env.HASURA_GRAPHQL_JWT_SECRET
      );
      
    

    return res.json({
        access_token: token,
    })
  }
}

module.exports = handler
