import cloudinary from '../configuration/cloudinary.js';

const file_upload = async (req, res) => {
  try {
    const {file_type,base64str}=req.body;
    // Upload the base64-encoded file content to Cloudinary
    const result = await cloudinary.uploader.upload(`data:${file_type};base64,${base64str}`);
    // const result = await cloudinary.uploader.upload(base64str);
    return res.json({
      file_url: result.url
    });
  } catch (e){
    console.log(e);
    return res.status(400).json({
      message: e
    });
  }
};
export { file_upload };
