#!/bin/bash
sudo -i
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
apt install unzip
wget https://www.tooplate.com/zip-templates/2133_moso_interior.zip
unzip 2133_moso_interior.zip
mv 2133_moso_interior/* /var/www/html
systemctl restart apache2