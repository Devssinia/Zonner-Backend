import client from '../configuration/hasura_client'
const INSERT_TRANSACTION=`
mutation MyMutation($phone_number: String, $amount: String, $transaction_date: timestamptz, $mpesa_transaction_id: String, $status: transaction_status!, $order_id: uuid!, $customer_id: uuid!) {
  insert_transactions_one(object: {amount: $amount, mpesa_transaction_id: $mpesa_transaction_id, phone_number: $phone_number, order_id: $order_id, status: $status, transaction_date: $transaction_date, customer_id:$customer_id}) {
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
 const UPDATE_MPESA_TRANSACTION=`
 mutation UpdateTransaction($mpesa_transaction_id: String!, $status: transaction_status!) {
  update_transactions(where: {mpesa_transaction_id: {_eq:$mpesa_transaction_id}}, _set: {status: $status}) {
    returning {
    amount
    mpesa_transaction_id
    phone_number
    status
    transaction_date
    transaction_id
    }
  }
}
 `
const UPDATE_ORDER=`
mutation MyMutation2($order_id:uuid!,$transaction_status:transaction_status!) {
  update_orders_by_pk(pk_columns: {order_id: $order_id}, _set: {transaction_status: $transaction_status}) {
    order_id
    order_status
    transaction_status
    customer_id
  }
}

`

const insert_transaction = async (variables) => {
  const data = await client.request(INSERT_TRANSACTION,variables)
  console.log("inserted transaction is",data['insert_transactions_one']['transaction_id'])
  return data['insert_transactions_one']['transaction_id']
}
const update_transaction = async (variables) => {
    const data = await client.request(UPDATE_TRANSACTION, variables);
    console.log("Data:", data);
    const transaction_status = data?.['update_transactions_by_pk']?.['status'];
    console.log("Customer ID:", transaction_status);
    
    return transaction_status;
}
const update_order = async (variables) => {
  const data = await client.request(UPDATE_ORDER, variables);
  console.log("Data:", data);
  const order_status = data?.['update_orders_by_pk']?.['transaction_status'];
  console.log("Customer ID:", order_status);
  
  return order_status;
}



const update_mpsesa_transaction = async (variables) => {
  const data = await client.request(UPDATE_MPESA_TRANSACTION, variables);
  console.log("Data:", data);
  const transaction_status = data?.['update_transactions']?.['returning'][0]?.["status"];
  console.log("Customer ID:", transaction_status);
  
  return transaction_status;
}

export { insert_transaction,update_transaction,update_mpsesa_transaction,update_order}
