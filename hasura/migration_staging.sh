hasura migrate apply --envfile  .env.staging
hasura metadata apply --envfile  .env.staging
hasura metadata reload --envfile  .env.staging