const sendSms = async (req, res) => {
    try {
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const twilioPhone = process.env.TWILIO_PHONE_NUMBER;
         
        const phone = req.body.input.phone;
        const message = req.body.input.message;

        console.log(`Twilio account info: ${twilioPhone}`);

        const client = require('twilio')(accountSid, authToken);

        await client.messages.create({
            body:message,
            from: twilioPhone,
            to: phone
        });

        return res.json({
            message: "Order message sent successfully"
        });
    } catch (error) {
        console.error("Error sending SMS:", error);
        return res.json({ message: "Failed to send SMS" });
    }
}

module.exports = { sendSms };
