import client from '../configuration/hasura_client'
const INSERT_TRANSACTION=`
mutation MyMutation($phone_number: String, $amount: String, $transaction_date: String, $mpesa_transaction_id: String, $status:transaction_status!, $order_id: uuid!) {
  insert_transactions_one(object: {amount: $amount, mpesa_transaction_id: $mpesa_transaction_id, phone_number: $phone_number, order_id: $order_id, status: $status, transaction_date: $transaction_date}) {
    amount
    mpesa_transaction_id
    phone_number
    order_id
    status
    transaction_date
    transaction_id
  }
}
`
const UPDATE_TRANSACTION = `
mutation UpdateTransaction ($transaction_id:uuid!,$status:transaction_status!) {
  update_transactions_by_pk(pk_columns: {transaction_id: $transaction_id}, _set: {status:$status}) {
    amount
    mpesa_transaction_id
    phone_number
    status
    transaction_date
    transaction_id
  }
}
 `  
const insert_transaction = async (variables) => {
  const data = await client.request(INSERT_TRANSACTION,variables)
  return data['insert_transactions_one']['transaction_id']
}
const update_transaction = async (variables) => {
    const data = await client.request(UPDATE_TRANSACTION, variables);
    console.log("Data:", data);
    const transaction_status = data?.['update_transactions_by_pk']?.['status'];
    console.log("Customer ID:", transaction_status);
    
    return transaction_status;
}
export { insert_transaction,update_transaction }
