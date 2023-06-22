import { GraphQLClient } from 'graphql-request'
// eslint-disable-next-line no-unused-vars
import * as dotenv from 'dotenv'

dotenv.config()
const client = new GraphQLClient(process.env.HASURA_END_POINT || "Hasura URL", {
  headers: {
    'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET || "secret",
  },
})
export default client
