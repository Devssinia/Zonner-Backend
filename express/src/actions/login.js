import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import jwt from 'jsonwebtoken'
// import { User } from '../utility/user'  
dotenvConfig()

const handler = async (req, res) => {
    console.log(req.body)
    return res.status(200).json({     
        access_token: 'hello world'     
    })
    // the login function looks like below
//   const { phone, password } = req.body.input.inputs
//   console.log(phone, password)
//   if(!phone || !password){ 
//     return res.status(400).json({ 
//       message: 'please enter Phone Number and Password'       
//     })
//   }
//   const user = await User({ phone }, USER_QUERY_BY_ID)
//   console.log(user)
//   if (!user) {
//     return res.status(400).json({
//       message: 'Incorrect Phone Number or Password please enter again',
//     })
//   } else {
//     if (user.password === null) {
//       return res.status(400).json({
//         message: 'Please Contact Admin to set Your Password',
//       })
//     }
//     const value = await bcrypt.compare(password, user.password)
//     console.log(value)
//     if (!value) {
//       return res.status(400).json({
//         message: 'Incorrect Password',
//       })
//     }
//     console.log(user.user_roles)
//     let roles = []
//     user.user_roles.forEach((role) => {
//       roles.push(role.role.name)
//     })
//     let token
//     if (roles[0] === 'operator') {
//       token = jwt.sign(
//         {
//           'https://hasura.io/jwt/claims': {
//             'x-hasura-allowed-roles': ['admins', 'operator', 'technician'],
//             'x-hasura-default-role': roles[0],
//             'x-hasura-operator-id': `${user.id}`,
//           },
//         },
//         process.env.HASURA_GRAPHQL_JWT_SECRET,
//       )
//     } else if (roles[0] === 'technician') {
//       token = jwt.sign(
//         {
//           'https://hasura.io/jwt/claims': {
//             'x-hasura-allowed-roles': ['admins', 'operator', 'technician'],
//             'x-hasura-default-role': roles[0],
//             'x-hasura-technician-id': `${user.id}`,
//           },
//         },
//         //X-Hasura-Technician-Id
//         process.env.HASURA_GRAPHQL_JWT_SECRET,
//       )
//     } else if (roles[0] === 'admins') {
//       token = jwt.sign(
//         {
//           'https://hasura.io/jwt/claims': {
//             'x-hasura-allowed-roles': ['admins', 'operator', 'technician'],
//             'x-hasura-default-role': roles[0],
//             'x-hasura-admin-id': `${user.id}`,
//           },
//         },
//         process.env.HASURA_GRAPHQL_JWT_SECRET,
//       )
//     }

//     return res.json({
//       accestoken: token,
//       id: user.id,
//     })
//   }
}

module.exports = handler
