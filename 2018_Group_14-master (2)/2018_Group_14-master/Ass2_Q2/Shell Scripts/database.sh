# ---------------- 1 -----------------

# Update Ubuntu & Install essential tools
sudo apt-get update

# Set the en_GB locale
sudo locale-gen en_GB en_GB.UTF-8
sudo update-locale LANG='en_GB.UTF-8'
sudo update-locale LANGUAGE='en_GB.UTF-8'
sudo update-locale LC_ALL='en_GB.UTF-8'
. /etc/default/locale

#Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgis pgadmin3 postgresql-contrib

# Set the password for the postgres user
cd ~/
echo 'localhost:5432:*:postgres:postgres_007%'>.pgpass
chmod 600 .pgpass
sudo sed -i 's|peer|trust|' /etc/postgresql/10/main/pg_hba.conf
sudo sed -i 's|md5|trust|' /etc/postgresql/10/main/pg_hba.conf
sudo service postgresql restart

#Create the PostGIS Instance
export PGPASSWORD=postgres_007%
HOSTNAME=localhost
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

# ---------------- 2 -----------------

# Create indexes and grant users
wget https://raw.githubusercontent.com/openstreetmap/osm2pgsql/master/install-postgis-osm-user.sh
chmod a+x ./install-postgis-osm-user.sh
sudo ./install-postgis-osm-user.sh gis ubuntu