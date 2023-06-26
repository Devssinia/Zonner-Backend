import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { User } from '../utility/user'

const login = async (req, res) => {
  try {
    console.log('login')
    const { phone_no, password } = req.body.input
    if (!phone_no || !password) {
      return res.status(400).json({
        message: 'Please provide Both Phone Number and Password',
      })
    }
    const user = await User({ phone_no })
    console.log(user)
    if (!user) {
      return res.status(400).json({
        message: 'Incorrect Credentials',
      })
    } else {
      if (user.password === null) {
        return res.status(400).json({
          message: 'Incorrect Credentials',
        })
      }
      const value = await bcrypt.compare(password, user.password)
      if (!value) {
        return res.status(400).json({
          message: 'Incorrect Credentials',
        })
      }
      if (user.role === null) {
        return res.status(400).json({
          message: 'Incorrect Credentials',
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
        process.env.HASURA_GRAPHQL_JWT_SECRET,
      )
      return res.status(200).json({
        access_token: token,
      })
    }
  } catch (error) {
    console.log(error)
    return res.status(400).json({
      message: 'Something went wrong',
    })
  }
}

export { login }
