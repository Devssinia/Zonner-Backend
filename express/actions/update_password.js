import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { update_password } from '../utilities/authentication'
dotenvConfig()
const reset_password = async (req, res) => {
    try {
        const { phone_no, new_password } = req.body.input

        if (!phone_no || !new_password) {
            return res.status(400).json({
                message: 'Please provide all the details',
            })
        }
        const salt = await bcrypt.genSalt(10)
        const hashed_password = await bcrypt.hash(new_password, salt)
        const password = hashed_password


        const updated_password = await update_password({ phone_no, password })

        console.log("new Password is", updated_password)
        if (updated_password==0) {
            res.status(400).json({
                message: 'Password Reset Failed try again',
            })

        }
        else {
            return res.status(200).json({
                message: 'Password Reseted Successfully',
            })
        }

    } catch (error) {
        return res.status(400).json({
            message: error,
        })
    }
}

export { reset_password }
