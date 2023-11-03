import express from 'express'
import { config as dotenvConfig } from 'dotenv'
import { customer_signup } from '../actions/customer_signup.js'
import { rider_signup } from '../actions/rider_signup.js'
import { vendor_signup } from '../actions/vendor_sign_up.js'
import { file_upload } from   '../actions/file_upload.js'
import { login } from   '../actions/login.js'
import { testEvent } from '../actions/test_event'
import {getOAuthToken} from '../actions/payments/generateToken.js'
import * as transaction from '../actions/payments/c_to_b_payment'
import { buisnessToCustomer } from '../actions/payments/b_to_c_payment.js'
import { reset_password } from '../actions/update_password.js'
const router = express.Router();
dotenvConfig()
router.post('/login', (req, res) => {login(req, res)})
router.post('/test', (req, res) => {testEvent(req, res)})
router.post('/customer_signup', (req, res) => {customer_signup(req, res)})
router.post('/rider_signup', (req, res) => { rider_signup(req, res)})
router.post('/reset_password', (req, res) => {reset_password(req, res)})
router.post('/vendor_signup', (req, res) => {vendor_signup(req, res)})
router.post('/file_upload', (req, res) => {file_upload(req, res)})
router.post("/stk",getOAuthToken,transaction.payAmount)
router.post("/callback",getOAuthToken,transaction.mpessaCallBack)
router.post("btoc",getOAuthToken,buisnessToCustomer)
router.post('/timeout_url', (req, res) => {
    console.log("--------------------Timeout -----------------")
    console.log(req.body)
})

router.post('/b2c_result_url', (req, res) => {
    consosle.log("-------------------- B2C Result -----------------")
    console.log(JSON.stringify(req.body.Result))
})
export default router
