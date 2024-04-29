import client from '../../configuration/hasura_client'
const INSERT_TRANSACTION=`
mutation MyMutation($amount:String!,$checkout_url:String!,$currency:String!,$customer_id:uuid!,$order_id:uuid!,$tx_ref:String!,$status:transaction_status!){
  insert_transactions_one(object:{amount: $amount, checkout_url: $checkout_url, currency: $currency, customer_id: $customer_id, order_id: $order_id, tx_ref: $tx_ref,status:$status}) {
    tx_ref
    status
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
const chapa_insert_transaction = async (variables) => {
  const data = await client.request(INSERT_TRANSACTION,variables)
  console.log("inserted transaction is",data['insert_transactions_one']['transaction_id'])
  return data['insert_transactions_one']['transaction_id']
}
const chapa_update_transaction = async (variables) => {
    const data = await client.request(UPDATE_TRANSACTION, variables);
    console.log("Data:", data);
    const transaction_status = data?.['update_transactions_by_pk']?.['status'];
    console.log("Customer ID:", transaction_status);
    
    return transaction_status;
}
export { chapa_insert_transaction,chapa_update_transaction }
