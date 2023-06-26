import client from '../configuration/hasura_client'
const INSERT_RIDER = `
mutation MyMutation($email: String = "", $first_name: String = "", $last_name: String = "", $phone_no: String = "") {
    insert_riders_one(object: {email: $email, first_name: $first_name, last_name: $last_name, phone_no: $phone_no}) {
      rider_id
    }
  } 

  `

const FIND_RIDER = `
query MyQuery($email: String = "") {
    riders(where: {email: {_eq: $email}}) {
      rider_id
    }
  }
 `  
const insert_rider = async (variables) => {
  const data = await client.request(INSERT_RIDER, variables)
  return data['insert_riders_one']['rider_id']
}

const find_rider = async (variables) => {   
    const data = await client.request(FIND_RIDER, variables)  
    console.log(data);       
    return data?.['riders'][0]?.['rider_id'] ?? null        
    }


export { insert_rider,find_rider }
