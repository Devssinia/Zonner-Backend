import express from 'express'
import { config as dotenvConfig } from 'dotenv'
import { customer_signup } from '../actions/customer_signup.js'
import { rider_signup } from '../actions/rider_signup.js'
import { vendor_sign_up } from '../actions/vendor_sign_up.js'
import { file_upload } from '../actions/file_upload.js'
import { login } from '../actions/login.js'
import {testEvent} from '../actions/test_event'
const router = express.Router()

dotenvConfig()

router.post('/login', (req, res) => {
  login(req, res)
})
router.post('/test', (req, res) => {
  testEvent(req, res)
})
router.post('/customer_signup', (req, res) => {
  customer_signup(req, res)
})
router.post('/rider_signup', (req, res) => {
  rider_signup(req, res)
})
router.post('/vendor_signup', (req, res) => {
  vendor_sign_up(req, res)
})
router.post('/file_upload', (req, res) => {
  file_upload(req, res)
})

export default router
