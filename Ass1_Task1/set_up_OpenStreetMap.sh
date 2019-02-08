#! /bin/bash

# set_up_OpenStreetMap.sh
#
# Authors: Daming Li 	 (Massey ID: 15398736, Email: ldm2264@gmail.com, @Damming github.com)
#          Moravy Oum	 (Massey ID: 16859528 , Email: moravy22@gmail.com , @Moravy github.com)
#          Yaozu zhang	 (Massey ID: 15398302, Email: 1264453650@qq.com, @shadoade github.com)
#          Simon Freeman (Massey ID: 13036748, Email: freeman.simon@rocketmail.com, @Simon3man github.com)
#
# Create time: 01/Aug./2018
#
# Homepage: https://github.com/Damming/2018_Group_14
# License: https://raw.githubusercontent.com/Damming/2018_Group_14/master/License.txt?token=AZvMHA8ak_65kW9KyjSlAd5-8o7vGDw_ks5bg8pGwA%3D%3D
#
# Description: Install all required libraries and turn a blanck Ubuntu Server to an OpenStreetMap Server
# 
# System required: Ubuntu Server 18.04



# beginning of the script


# Update Ubuntu & Install essential tools
sudo apt-get update
# sudo apt-get -y upgrade
sudo apt-get -y install ca-certificates curl unzip gdal-bin tar wget bzip2 build-essential clang

# Configure a swap (500M)
sudo fallocate -l 500M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Set the en_GB locale
sudo locale-gen en_GB en_GB.UTF-8
sudo update-locale LANG='en_GB.UTF-8'
sudo update-locale LANGUAGE='en_GB.UTF-8'
sudo update-locale LC_ALL='en_GB.UTF-8'
. /etc/default/locale

# Install Git
sudo apt-get install -y git

# Update Freetype6
sudo add-apt-repository -y ppa:no1wantdthisname/ppa
sudo apt-get update 
sudo apt-get install -y libfreetype6 libfreetype6-dev

# Install Mapnik from the standard Ubuntu repository
# sudo add-apt-repository -y ppa:talaj/osm-mapnik
# sudo apt-get update
sudo apt-get install -y git autoconf libtool libxml2-dev libbz2-dev \
  libgeos-dev libgeos++-dev libproj-dev gdal-bin libgdal-dev g++ \
  libmapnik-dev mapnik-utils python-mapnik

# Install Apache HTTP Server
sudo apt-get install -y apache2 apache2-dev

# Install Mod_tile from package
# sudo apt-get install -y libapache2-mod-tile

# Install Mod_tile from source
sudo apt-get install -y autoconf autogen libmapnik3.0
mkdir -p ~/src
cd ~/src
git clone https://github.com/openstreetmap/mod_tile.git
cd mod_tile
./autogen.sh
./configure
make
sudo make install
sudo make install-mod_tile
sudo ldconfig
cd ~/

# Install Yaml and Package Manager for Python
sudo apt-get install -y python-yaml
sudo apt-get install -y python-pip

# Install Mapnik Utilities
sudo apt-get install -y mapnik-utils

# Install openstreetmap-carto
cd ~/src
git clone https://github.com/gravitystorm/openstreetmap-carto.git
cd openstreetmap-carto

# Install the fonts needed by openstreetmap-carto
sudo apt-get install -y fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted fonts-hanazono ttf-unifont
cd ~/src
git clone https://github.com/googlei18n/noto-emoji.git
git clone https://github.com/googlei18n/noto-fonts.git
sudo cp noto-emoji/fonts/NotoColorEmoji.ttf /usr/share/fonts/truetype/noto
sudo cp noto-emoji/fonts/NotoEmoji-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansArabicUI-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoNaskhArabicUI-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansArabicUI-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoNaskhArabicUI-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansAdlam-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansAdlamUnjoined-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansChakma-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansOsage-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansSinhalaUI-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansArabicUI-Regular.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansCherokee-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansSinhalaUI-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansSymbols-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/hinted/NotoSansArabicUI-Bold.ttf /usr/share/fonts/truetype/noto
sudo cp noto-fonts/unhinted/NotoSansSymbols2-Regular.ttf /usr/share/fonts/truetype/noto
sudo fc-cache -fv
sudo apt install fontconfig
fc-list
fc-list | grep Emoji

# Install old unifont Medium font (just removes the warning)
cd ~/src
mkdir OldUnifont
cd OldUnifont
wget http://http.debian.net/debian/pool/main/u/unifont/unifont_5.1.20080914.orig.tar.gz
tar xvfz unifont_5.1.20080914.orig.tar.gz unifont-5.1.20080914/font/precompiled/unifont.ttf
sudo cp unifont-5.1.20080914/font/precompiled/unifont.ttf /usr/share/fonts/truetype/unifont/OldUnifont.ttf
sudo fc-cache -fv
fc-list | grep -i unifont

#Create the data folder
cd ~/src
cd openstreetmap-carto
scripts/get-shapefiles.py

# installing Node.js v6.x
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && sudo apt-get install -y nodejs
sudo apt-get install -y npm

#install the latest version 0 of carto
sudo npm install -g carto@0

#install mapnik-reference
npm install mapnik-reference
node -e "console.log(require('mapnik-reference'))"

# Test carto and produce style.xml from the openstreetmap-carto style
cd ~/src
cd openstreetmap-carto
carto -a "3.0.20" project.mml > style.xml
ls -l style.xml

#Set the environment variables
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=postgres_007%

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

# Install Osm2pgsql
# sudo apt-get install -y osm2pgsql
sudo add-apt-repository -y ppa:osmadmins/ppa
apt-key adv --keyserver keyserver.ubuntu.com --recv A438A16C88C6BE41CB1616B8D57F48750AC4F2CB
sudo apt-get update
sudo apt-get install -y osm2pgsql

# Get an OpenStreetMap data extract
cd ~/src/openstreetmap-carto
# wget -c https://download.bbbike.org/osm/bbbike/Auckland/Auckland.osm.pbf
wget -c https://raw.githubusercontent.com/Damming/MapData/master/Auckland.osm.pbf

# Load data to PostGIS
sudo sysctl -w vm.overcommit_memory=1
HOSTNAME=localhost
osm2pgsql -s -C 300 -c -G --hstore --style openstreetmap-carto.style --tag-transform-script openstreetmap-carto.lua -d gis -H $HOSTNAME -U postgres Auckland.osm.pbf

# Create indexes and grant users
HOSTNAME=localhost
scripts/indexes.py | psql -U postgres -h $HOSTNAME -d gis
wget https://raw.githubusercontent.com/openstreetmap/osm2pgsql/master/install-postgis-osm-user.sh
chmod a+x ./install-postgis-osm-user.sh
sudo ./install-postgis-osm-user.sh gis ubuntu

# Configure renderd
sudo sed -i "2i\socketname=/var/run/renderd/renderd.sock" /usr/local/etc/renderd.conf
sudo sed -i -e '/plugins_dir/ s~=.*~=/usr/lib/mapnik/3.0/input~' /usr/local/etc/renderd.conf
sudo sed -i -e '/font_dir=/ s~=.*~=/usr/share/fonts~' /usr/local/etc/renderd.conf
sudo sed -i -e '/font_dir_recurse=/ s~=.*~=true~' /usr/local/etc/renderd.conf
sudo sed -i -e '/URI=/ s~=.*~=/osm_tiles/~' /usr/local/etc/renderd.conf
sudo sed -i -e '/XML=/ s~=.*~=/home/ubuntu/src/openstreetmap-carto/style.xml~' /usr/local/etc/renderd.conf
sudo sed -i -e '/HOST=/ s~=.*~=localhost~' /usr/local/etc/renderd.conf
# sudo sed -i '30i\TILEDIR=/var/lib/mod_tile' /usr/local/etc/renderd.conf
# sudo sed -i '31i\TILESIZE=256' /usr/local/etc/renderd.conf

# Install renderd init script by copying the sample init script included in its package
sudo cp ~/src/mod_tile/debian/renderd.init /etc/init.d/renderd
sudo chmod a+x /etc/init.d/renderd

# Edit the init script file
sudo sed -i -e '/DAEMON=/ s~=.*~= /usr/local/bin/$NAME~' /etc/init.d/renderd
sudo sed -i -e '/DAEMON_ARGS=/ s~=.*~= "-c /usr/local/etc/renderd.conf"~' /etc/init.d/renderd
sudo sed -i -e '/RUNASUSER=/ s~=.*~=ubuntu~' /etc/init.d/renderd

sudo mkdir /var/run/renderd
sudo chown ubuntu:ubuntu /var/run/renderd

sudo mkdir -p /var/lib/mod_tile
sudo chown ubuntu:ubuntu /var/lib/mod_tile

sudo systemctl daemon-reload
sudo systemctl start renderd
sudo systemctl enable renderd

# Configure Apache
echo 'LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so' | sudo tee -a /etc/apache2/mods-available/mod_tile.load
sudo ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/

# Edit the default virtual host file
sudo sed -i "2i\        LoadTileConfigFile /usr/local/etc/renderd.conf" /etc/apache2/sites-enabled/000-default.conf
sudo sed -i '3i\        ModTileRenderdSocketName /var/run/renderd/renderd.sock' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i '4i\        ModTileRequestTimeout 3' /etc/apache2/sites-enabled/000-default.conf
sudo sed -i '5i\        ModTileMissingRequestTimeout 60' /etc/apache2/sites-enabled/000-default.conf
sudo systemctl restart apache2

# OpenLayers
cd /var/www/html/
sudo wget -c https://raw.githubusercontent.com/Damming/MapData/master/ol.html

# Leaflet
sudo wget -c https://raw.githubusercontent.com/Damming/MapData/master/lf.html

# Start renderd
cd ~
renderd -f -c /usr/local/etc/renderd.conf