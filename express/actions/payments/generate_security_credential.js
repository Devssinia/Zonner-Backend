const crypto = require('crypto');
function generateSecurityCredential(passkey) {
  // Create a sha256 hash of the Lipa Na M-Pesa Online Passkey
  const hash = crypto.createHash('sha256');
  const data = passkey;
  // Update the hash object with the data to be hashed
  hash.update(data);
  // Get the hexadecimal representation of the hash
  const securityCredential = hash.digest('hex').toUpperCase();
  return securityCredential;
}
export {generateSecurityCredential}