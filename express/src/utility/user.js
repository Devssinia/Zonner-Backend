import client from "../configuration/apollo.config";
const QUERY_BY = `
query MyQuery($adress_id: uuid = "") {
    addresses_by_pk(adress_id: $adress_id) {
      address_line_one
    }
  }
  `
  User({
    adress_id: 1
})
const User = async (variables) => {
    const data = await client.request(QUERY_BY, variables);
    return data['addresses_by_pk']['address_line_one'];
    }


    

export { User}