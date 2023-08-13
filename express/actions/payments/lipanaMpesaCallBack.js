export const myCallBack = async (req, res) => {
    let body = req.body;
    let { ResultCode, ResultDesc } = body.Body.stkCallback;
    let receipt, amount, phone, date = "";
  
    if (ResultCode != 0) {
      console.log(ResultCode, ResultDesc);
      return res.status(400).json({ message: `${ResultDesc}` });
    }
    let list = body.Body.stkCallback.CallbackMetadata.Item;
    list.forEach(item => {
      if (item.Name === "MpesaReceiptNumber") {
        receipt = item.Value;
      }
      if (item.Name === "TransactionDate") {
        date = item.Value;
      }
      if (item.Name === "PhoneNumber") {
        phone = item.Value;
      }
      if (item.Name === "Amount") {
        amount = item.Value;
      }
    });
    try {
      console.log(ResultDesc, newTransaction);
      return res.status(201).json({ message: `${ResultDesc}`, newTransaction });
    } catch (error) {
      console.log(error.message);
      return res.send({
        success: false,
        message: error.message
      });
    }
  };
  