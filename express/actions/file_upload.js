import cloudinary from '../configuration/cloudinary.js';
import fs from 'fs/promises'; // Use fs.promises for Promise-based file operations

const file_upload = async (req, res) => {
  const imagePath = req.body.name;
  try {
    // Read the image file asynchronously
    const data = await fs.readFile(imagePath);

    // Convert the image data to base64
    const base64str = data.toString('base64');

    // Upload the image to Cloudinary
    const result = await cloudinary.uploader.upload(`data:image/jpeg;base64,${base64str}`);

    return res.json({
      image_url: result.url
    });
  } catch (e) {
    console.error(e);
    return res.status(400).json({
      message: e.message || 'An error occurred'
    });
  }
};

export { file_upload };
