import cloudinary from '../configuration/cloudinary.js';
import { createReadStream } from 'fs'; // Import createReadStream directly from 'fs' module

const file_upload = async (req, res) => {
  const filePath = req.body.path;
  console.log(`the path of the file is ${filePath}`);

  try {
    // Read the file asynchronously using streams
    const readStream = createReadStream(filePath); // Use createReadStream directly

    // Upload the file to Cloudinary
    const uploadOptions = {
      resource_type: 'auto',
      public_id: 'zonner-files',
    };

    const uploadResult = await cloudinary.uploader.upload_stream(
      uploadOptions,
      (error, result) => {
        if (error) {
          console.error(error);
          return res.status(400).json({
            message: error.message || 'An error occurred during upload',
          });
        }

        return res.json({
          file_url: result.url,
        });
      }
    );

    // Pipe the file data to the Cloudinary uploader
    readStream.pipe(uploadResult);
  } catch (e) {
    console.error(e);
    return res.status(400).json({
      message: e.message || 'An error occurred',
    });
  }
};

export { file_upload };
