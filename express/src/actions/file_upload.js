import cloudinary from '../configuration/cloudinary.js';
const handler = async (req, res) => {
    try {
      const { name,type,base64str } = req.body.input
      const result = await cloudinary.uploader.upload(`data:image/jepg;base64,${base64str}`)
      return res.json({
        image_url: result.url
      })
    }
    catch (e) {
      console.log(e);
      return res.status(400).json({
        message: e
      })
    }
  }
  module.exports = handler