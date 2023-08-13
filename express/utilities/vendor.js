import client from '../configuration/hasura_client'

const INSERT_VENDOR =`
mutation MyMutation($email: String = "", $full_name: String = "", $phone_no: String = "") {
    insert_vendors_one(object: {email: $email, full_name: $full_name, phone_no: $phone_no}) {
      vendor_id
    }
  } 
  `


const FIND_RIDER=`
query MyQuery($email: String = "") {
    vendors(where: {email: {_eq: $email}}) {
      vendor_id
    }
  }
 `  

const insert_vendor = async (variables) => {
  const data = await client.request(INSERT_VENDOR, variables)
  return data['insert_vendors_one']['vendor_id']
}


const find_vendor = async (variables) => {   
    const data = await client.request(FIND_RIDER, variables)  
    console.log(data);       
    return data?.['vendors'][0]?.['vendor_id']        
    }


export { insert_vendor,find_vendor }
