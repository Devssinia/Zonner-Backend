import client from "../configuration/apollo.config";
const QUERY_BY = ``
const User = async (variables) => {
    const data = await client.request(QUERY_BY, variables);
    return data['users_by_pk'];
    }
export { User}