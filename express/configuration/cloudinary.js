import {v2 as cloudinary} from 'cloudinary';

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME ||'dwfyzwrtw',
  api_key: process.env.CLOUDINARY_API_KEY ||'241233934443616',
  api_secret: process.env.CLOUDINARY_API_SECRET ||'oj453qJq-iyL-L7ibMWmfEhT6c4',
  secure:true
});
module.exports = cloudinary;
