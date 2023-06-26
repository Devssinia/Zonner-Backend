import cloudinary from '../configuration/cloudinary.js';
<<<<<<< HEAD:express/src/actions/file_upload.js
const handler = async (req, res) => {
=======

const file_upload = async (req, res) => {
    
>>>>>>> refs/remotes/origin/main:express/actions/file_upload.js
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

export { file_upload }       