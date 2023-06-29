import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { User } from '../utility/user'

const login = async (req, res) => {
  try {
    console.log('login');
    
    const { phone_no, password } = req.body.input;
    if (!phone_no || !password) {
      return res.status(400).json({ message: 'Please provide Both Phone Number and Password' });
    }
    
    const user = await User({ phone_no });
    console.log(user);
    
    if (!user || !user.password || !user.role) {
      return res.status(400).json({ message: 'Incorrect Credentials' });
    }
    
    const is_valid_password = await bcrypt.compare(password, user.password);
    if (!is_valid_password) {
      return res.status(400).json({ message: 'Incorrect Credentials' });
    }
    
    const token_payload = {
      'https://hasura.io/jwt/claims': {
        'x-hasura-allowed-roles': ['zadmin', 'rider', 'customer', 'vendor'],
        'x-hasura-default-role': user.role.role_name,
        [`x-hasura-${user.role.role_name}-id`]: `${user.user_id}`,
      },
    };
    const token = jwt.sign(token_payload, process.env.HASURA_GRAPHQL_JWT_SECRET);
    
    return res.status(200).json({ access_token: token });
  } catch (error) {
    console.log(error);
    return res.status(400).json({ message: 'Something went wrong' });
  }
};

export { login }
