import client from '../configuration/hasura_client'
const INSERT_CUSTOMER = `
mutation MyMutation($email: String = "", $full_name: String = "", $phone_no: String = "") {
    insert_riders_one(object: {email: $email, full_name:$full_name, phone_no: $phone_no}) {
    }
  } 

  `
const FIND_CUSTOMER = `
query MyQuery($email: String = "") {
    customers(where: {email: {_eq: $email}}) {
customer_id
email
full_name
    }
  }
 `  
const insert_customer = async (variables) => {
  const data = await client.request(INSERT_CUSTOMER, variables)
  return data['insert_customers_one']['customer_id']
}

const find_customer = async (variables) => {   
    const data = await client.request(FIND_CUSTOMER, variables)  
    console.log(data);       
    return data?.['customers']?.[0]?.['customer_id']        
  }

export {insert_customer,find_customer }  
