#!/usr/bin/env bash

: '
shell script to get a metabase dashboard up and running 
from scratch on an AWS EC2 machine
'

# install python and git
sudo yum install -y python3
sudo yum install -y git
pip3 install -y numpy pandas sqlalchemy country_converter

# install java developer kit
wget http://downloads.metabase.com/v0.34.2/metabase.jar
wget --no-check-certificate --no-cookies --header \
"Cookie:oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u141-b15/\
336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm
sudo yum install -y jdk-8u141-linux-x64.rpm

# install nginx for redirecting metabase traffic
sudo amazon-linux-extras install -y nginx1.12
# replace lines in the nginx config file
export S1="[[:blank:]]root[[:blank:]]*/usr/share/nginx/html;"
export R1="#        root    /usr/share/nginx/html;"
export S2="[[:blank:]]include /etc/nginx/default.d/*.conf;"
export R2="#        include /etc/nginx/default.d/*.conf;"
export S3="[[:blank:]]location / {"
export R3="        location / {proxy_pass http://127.0.0.1:3000/;"
export NGINCONF="/etc/nginx/nginx.conf"
sudo sed -i -e "s%$S1%$R1%" -e "s%$S2%$R2%" -e "s%$S3%$R3%" $NGINCONF

sudo service nginx restart

screen java -jar metabase.jar &

