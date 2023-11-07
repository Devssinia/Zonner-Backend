import client from '../configuration/hasura_client'
const UPDATE_PASSWORD=`
mutation UpdatePassword($phone_no: String!, $password: String!) {
  update_authentications(where: {phone_no: {_eq: $phone_no}}, _set: {password: $password}) {
    affected_rows
    returning {
      last_seen
      password
      phone_no
    }
  }
}
`
const update_password = async (variables) => {
    try {
        console.log("still called")
        const data = await client.request(UPDATE_PASSWORD, variables);
        console.log("Data:", data);
        const password = data?.['update_authentications']?.['returning'][0]?.["password"];
        console.log("password:", password);
        return password;
    } catch (error) {
      
    console.log("error detected")
    }

}

export { update_password }
