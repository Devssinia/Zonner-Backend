import bcrypt from 'bcrypt'
import { config as dotenvConfig } from 'dotenv'
import { User } from '../utilities/user'
import { insert_vendor, find_vendor } from '../utilities/vendor'
import { insert_password as Insert_password } from '../utilities/user'
dotenvConfig()
const vendor_signup = async (req, res) => {
  try {
    const { first_name, last_name, email, phone_no, password } = req.body.input;
    if (!phone_no || !password || !first_name || !last_name || !email) {
      return res.status(400).json({ message: 'Please provide ALL the details' });
    }
    const salt = await bcrypt.genSalt(10);
    const hashed_password = await bcrypt.hash(password, salt);
    const user = await User({ phone_no });

    if (user) {
      return res.status(400).json({ message: 'User Already Exists' });
    }

    const vendor_email = await find_vendor({ email });

    if (vendor_email) {
      return res.status(400).json({ message: 'Your Email is Already Registered' });
    }

    const vendor = await insert_vendor({ phone_no, first_name, last_name, email });

    if (!vendor) {
      return res.status(400).json({ message: 'Something went wrong' });
    }

    const insert_password = await Insert_password({
      password: hashed_password,
      user_id: vendor,
    });

    if (!insert_password) {
      return res.status(400).json({ message: 'Something went wrong' });
    }

    return res.json({ success: 'Vendor Created Successfully' });
  } catch (error) {
    console.log(error)
    return res.status(400).json({ message: error.message });
  }
};

export { vendor_signup }
