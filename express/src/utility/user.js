import client from '../configuration/hasura_client'
const QUERY_USER_BY_PHONE = `
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
const user = async (variables) => {
  const data = await client.request(QUERY_USER_BY_PHONE, variables)
  return data['authentications'][0]
}

export { user }
