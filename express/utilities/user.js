import client from '../configuration/hasura_client'
const QUERY_USER_BY_PHONE =`
query MyQuery($phone_no: String = "") {
  authentications(where: {phone_no: {_eq: $phone_no}}) {
    password
    phone_no
    user_id
    status
    role {
      role_name
      role_id
    }
  }
}
  `


const INSERT_USER_PASSWORD =`
mutation MyMutation($password: String = "", $user_id: uuid = "") {
  update_authentications_by_pk(pk_columns: {user_id: $user_id}, _set: {password: $password}) {
    user_id
  }
}
`
const UPDATE_LAST_SEEN =`
mutation MyMutation($phone_no:String!){
  update_authentications(where: {phone_no: {_eq: $phone_no}}, _set: {last_seen: "now()"}) {
    affected_rows
    returning {
      last_seen
      password
      phone_no
      role_id
      user_id
    }
  }
}
`



const User = async (variables) => {
  const data = await client.request(QUERY_USER_BY_PHONE, variables)
  return data['authentications'][0]
}

const update_last_seen = async (variables) => {  
  const data = await client.request(UPDATE_LAST_SEEN, variables)            
  return data?.['update_authentications_by_pk']?.['last_seen']         
}
const insert_password = async (variables) => {  
  const data = await client.request(INSERT_USER_PASSWORD, variables)            
  return data?.['update_authentications_by_pk']?.['user_id']         
}

export { User,insert_password,update_last_seen}
