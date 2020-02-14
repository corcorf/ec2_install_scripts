#!/usr/bin/env bash

: '
shell script to get a metabase dashboard up and running 
from scratch on an AWS EC2 machine
'

# install python and git
sudo yum install -y python3
sudo yum install -y git
pip3 install numpy pandas sqlalchemy country_converter
git clone https://github.com/corcorf/ec2_install_scripts.git

# install java developer kit
wget http://downloads.metabase.com/v0.34.2/metabase.jar
wget --no-check-certificate --no-cookies --header \
"Cookie:oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u141-b15/\
336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm
sudo yum install -y jdk-8u141-linux-x64.rpm

# install nginx for redirecting metabase traffic
sudo amazon-linux-extras install -y nginx1.12
# replace nginx config file
export NGINXCONF="/etc/nginx/nginx.conf"
sudo cp ./ec2_install_scripts/install_metabase/nginx.conf $NGINXCONF

sudo service nginx restart

screen java -jar metabase.jar &


sudo echo "java -jar ~/metabase.jar &" >> /etc/rc.local
sudo chmod +x /etc/rc.d/rc.local
