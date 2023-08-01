#!/bin/bash

# Load variables from .env file

source ~/Zonner-Backend/.env
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$DB_ROOT_PASWORD';"

sudo -u postgres psql -c "CREATE USER zonner_db_admin WITH PASSWORD '$DB_ZONNER_ADMIN_PASSWORD';"

sudo -u postgres psql -c "CREATE DATABASE zonner_db;"

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE zonner_db TO zonner_db_admin;"

exit
