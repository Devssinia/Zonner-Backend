import axios from 'axios'

import dotenv from 'dotenv'
dotenv.config()
const getOAuthToken = async (req, res, next) => {
  let consumer_key = process.env.CONSUMER_KEY
  let consumer_secret = process.env.CONSUMER_SECRET

  let url = process.env.OAUTH_TOKEN_URL
  // console.log({
  //   consumer_key:consumer_key,
  //   consumer_secret:consumer_secret,
  //   url:url
  // })
  let auth = new Buffer.from(`${consumer_key}:${consumer_secret}`).toString(
    'base64',
  )
  console.log("Authed",auth)
  try {
    let { data } = await axios.get(url, {
      headers: {
        Authorization: `Basic ${auth}`,
      },
    })

    req.token = data['access_token']
    console.log(data)

    return next()
  } catch (err) {
    console.log(err.message)
    return res.send({
      success: false,
      message: err.message,
    })
  }
}

export { getOAuthToken }
