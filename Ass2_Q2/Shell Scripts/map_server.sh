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
sudo apt-get install -y git autoconf libtool libxml2-dev libbz2-dev \
  libgeos-dev libgeos++-dev libproj-dev gdal-bin libgdal-dev g++ \
  libmapnik-dev mapnik-utils python-mapnik

# Install Apache HTTP Server
sudo apt-get install -y apache2 apache2-dev

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
sudo sed -i 's|<Datasource>|<Datasource><Parameter name="type">postgis</Parameter><Parameter name="host">%actual_ip%</Parameter><Parameter name="dbname">gis</Parameter><Parameter name="user">postgres</Parameter><Parameter name="password">postgres_007%</Parameter>|' ~/src/openstreetmap-carto/style.xml
ls -l style.xml

# Set the password for the postgres user
cd ~/
echo '%actual_ip%:5432:*:postgres:postgres_007%'>.pgpass
chmod 600 .pgpass

# Configure renderd
sudo sed -i "2i\socketname=/var/run/renderd/renderd.sock" /usr/local/etc/renderd.conf
sudo sed -i -e '/plugins_dir/ s~=.*~=/usr/lib/mapnik/3.0/input~' /usr/local/etc/renderd.conf
sudo sed -i -e '/font_dir=/ s~=.*~=/usr/share/fonts~' /usr/local/etc/renderd.conf
sudo sed -i -e '/font_dir_recurse=/ s~=.*~=true~' /usr/local/etc/renderd.conf
sudo sed -i -e '/URI=/ s~=.*~=/osm_tiles/~' /usr/local/etc/renderd.conf
sudo sed -i -e '/XML=/ s~=.*~=/home/ubuntu/src/openstreetmap-carto/style.xml~' /usr/local/etc/renderd.conf
sudo sed -i -e '/HOST=/ s~=.*~=%actual_ip%~' /usr/local/etc/renderd.conf

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