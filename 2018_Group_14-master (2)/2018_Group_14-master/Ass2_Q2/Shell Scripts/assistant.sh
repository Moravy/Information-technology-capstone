# Update Ubuntu & Install essential tools
sudo apt-get update
# sudo apt-get -y upgrade
sudo apt-get -y install ca-certificates curl unzip gdal-bin tar wget bzip2 build-essential clang

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
sudo apt-get install -y git autoconf libtool libxml2-dev libbz2-dev \
  libgeos-dev libgeos++-dev libproj-dev gdal-bin libgdal-dev g++ \
  libmapnik-dev mapnik-utils python-mapnik

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
sudo sed -i 's|<Datasource>|<Datasource><Parameter name="type">postgis</Parameter><Parameter name="host">%actual_ip%</Parameter><Parameter name="dbname">gis</Parameter><Parameter name="user">postgres</Parameter><Parameter name="password">postgres_007%</Parameter>|' ~/src/openstreetmap-carto/style.xml
ls -l style.xml

# Set the password for the postgres user
cd ~/
echo '%actual_ip%:5432:*:postgres:postgres_007%'>.pgpass
chmod 600 .pgpass

# Install Osm2pgsql
sudo add-apt-repository -y ppa:osmadmins/ppa
apt-key adv --keyserver keyserver.ubuntu.com --recv A438A16C88C6BE41CB1616B8D57F48750AC4F2CB
sudo apt-get update
sudo apt-get install -y osm2pgsql

# Get an OpenStreetMap data extract
cd ~/src/openstreetmap-carto
wget -c https://raw.githubusercontent.com/Damming/MapData/master/Auckland.osm.pbf

# Load data to PostGIS
sudo sysctl -w vm.overcommit_memory=1
HOSTNAME=%actual_ip%
osm2pgsql -s -C 300 -c -G --hstore --style openstreetmap-carto.style --tag-transform-script openstreetmap-carto.lua -d gis -H $HOSTNAME -U postgres Auckland.osm.pbf

# Create indexes and grant users
HOSTNAME=%actual_ip%
scripts/indexes.py | psql -U postgres -h $HOSTNAME -d gis