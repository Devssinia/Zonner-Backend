import express from 'express'
import dotenv from 'dotenv'
import bodyParser from 'body-parser'
dotenv.config()
const app = express()
app.use(bodyParser.json({ limit: '200mb' }))
app.use(bodyParser.urlencoded({ extended: true }))
app.use(express.json({ limit: '200mb' }))
app.post('/:route', async (req, res) => {
  try {
    console.log('from here' )
    const handler = require(`./express/actions/${req.params.route}`)
    console.log(handler)
    if (!handler) {
      return res.status(400).json({
        message: 'path not found',
      })
    }
    handler(req, res)
  } catch (e) {
    console.log(e)
    return res.status(400).json({
      message: 'unexpected error occurred' + e,
    })
  }
})
app.post('/event/:route', (req, res) => {
  try {
    console.log('from here')
    const handler = require(`./express/events/${req.params.route}`)
    if (!handler) {
      return res.status(400).json({
        message: 'path not found',
      })
    }
    handler(req, res)
  } catch (e) {
    console.log(e)
    return res.status(400).json({
      message: 'unexpected error occurred',
    })
  }
})
const port = process.env.EXPRESS_PORT;

app.listen(port, () => {
  console.log('on the moon')
})
