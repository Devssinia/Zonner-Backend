import express from 'express'
import dotenv from 'dotenv'
import bodyParser from 'body-parser'
import cors from 'cors'    
import routes from './express/routes/index.js'
dotenv.config()
const app = express()
app.use(bodyParser.json({ limit: '200mb' }))
app.use(bodyParser.urlencoded({ extended: true }))
app.use(express.json({ limit: '200mb' }))
app.use(cors())
app.use('/', routes) 

const port = process.env.EXPRESS_PORT;
app.listen( port||3000, () => {
  console.log('on the moddddon')
})
