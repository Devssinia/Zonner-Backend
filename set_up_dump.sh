#!/bin/bash

# Load variables from .env file
source ~/Zonner-Backend/.env

# Execute the dumped.sql file with the password from the password file
PGPASSWORD="$DB_ZONNER_ADMIN_PASSWORD" psql "dbname=zonner_db user=zonner_db_admin" -f ~/Zonner-Backend/dumped.sql
