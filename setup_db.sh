#!/bin/bash

# Load variables from .env file
source ~/Zonner-Backend/.env

# Use a Here Document (<<) to pass the commands to psql with the correct environment variables
sudo -u postgres psql << EOF

ALTER USER postgres WITH PASSWORD '$DB_ROOT_PASWORD';
CREATE USER zonner_db_admin WITH PASSWORD '$DB_ZONNER_ADMIN_PASSWORD';
CREATE DATABASE zonner_db;
GRANT ALL PRIVILEGES ON DATABASE zonner_db TO zonner_db_admin;

EOF


