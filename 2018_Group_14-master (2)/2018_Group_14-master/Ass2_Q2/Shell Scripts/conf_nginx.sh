#! /bin/bash

sudo apt-get update
sudo apt-get -y install nginx

sudo vi /etc/nginx/nginx.conf

# ----------------------------------------
# put the following lines in the http section of nginx.conf

upstream mysite {
    server %actual_ip%:80 weight=1;
    server %actual_ip%:80 weight=1;
    server %actual_ip%:80 backup;
}

server {
    listen 80;
    server_name %nginx_ip%;
    location / {
        root html;
        index index.html;
        proxy_pass http://mysite;
    }
}

# ----------------------------------------

cd /usr/sbin/
sudo ./nginx -s reload