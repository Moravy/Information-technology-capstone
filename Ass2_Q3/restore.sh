#!/bin/bash

# Create the PostGIS Instance
export PGPASSWORD=postgres_007%
HOSTNAME=$1
psql -U postgres -h $HOSTNAME -c "CREATE DATABASE gis ENCODING 'UTF-8' LC_COLLATE 'en_GB.utf8' LC_CTYPE 'en_GB.utf8' TEMPLATE template0"

# Create the postgis and hstore extensions
psql -U postgres -h $HOSTNAME -c "\connect gis"
psql -U postgres -h $HOSTNAME -d gis -c "CREATE EXTENSION postgis"
psql -U postgres -h $HOSTNAME -d gis -c "CREATE EXTENSION hstore"

# Add a user and grant access to gis DB
psql -U postgres -c "create user ubuntu;grant all privileges on database gis to ubuntu;"

# Enabling remote access to PostgreSQL
sudo sed -i "10i\host all all 0.0.0.0/0 trust" /etc/postgresql/10/main/pg_hba.conf
sudo sed -i "58i\listen_addresses = '*'" /etc/postgresql/10/main/postgresql.conf
sudo /etc/init.d/postgresql restart

# Tuning the database
sudo echo 'shared_buffers = 128MB' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'min_wal_size = 80MB' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'max_wal_size = 1GB' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'work_mem = 4MB' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'maintenance_work_mem= 64MB' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'autovacuum = off' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo echo 'fsync = off' | sudo tee -a /etc/postgresql/10/main/postgresql.conf
sudo /etc/init.d/postgresql stop
sudo /etc/init.d/postgresql start

# Restore
pg_dump -F c -f ~/backup/gis_backup.dmp  -C -E  UTF8 -h $1 -p 5432 -U postgres gis
