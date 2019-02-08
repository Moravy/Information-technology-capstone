#!/bin/bash

# Update Ubuntu & Install essential tools
sudo apt-get update

# Set the en_GB locale
sudo locale-gen en_GB en_GB.UTF-8
sudo update-locale LANG='en_GB.UTF-8'
sudo update-locale LANGUAGE='en_GB.UTF-8'
sudo update-locale LC_ALL='en_GB.UTF-8'
. /etc/default/locale

# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgis pgadmin3 postgresql-contrib

# Set the password for the postgres user
cd ~/
echo 'localhost:5432:*:postgres:postgres_007%'>.pgpass
chmod 600 .pgpass
sudo sed -i 's|peer|trust|' /etc/postgresql/10/main/pg_hba.conf
sudo sed -i 's|md5|trust|' /etc/postgresql/10/main/pg_hba.conf
sudo service postgresql restart

# ------------------ backup -------------------
mkdir backup
echo 'logs'>backup_log

echo "#!/bin/bash
pg_dump -F c -f /home/ubuntu/backup/gis_backup.dmp  -C -E  UTF8 -h $1 -p 5432 -U postgres gis
echo "backup finished" >> /home/ubuntu/backup_log">auto_back.sh

# backup every 15 minutes
echo '*/15 * * * * ubuntu bash /home/ubuntu/auto_back.sh' | sudo tee -a /etc/crontab


