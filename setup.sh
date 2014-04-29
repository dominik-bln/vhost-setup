#!/bin/bash

#
# This file contains basic setup steps for my vHost server
# (currently Ubuntu 12.04) as a small reminder for myself.
#

echo "Starting server setup.."

echo "Trying to setup default locale.."
#setup locale because it always produces strange errors during installations and other stuff
sudo locale-gen en_US.UTF-8
sudo update-locale LANG="en_US.UTF-8" LC_MESSAGES="POSIX"
sudo dpkg-reconfigure locales

echo "Creating user account.."
#create my own user to avoid usage of root later
sudo useradd dominik
sudo passwd dominik
sudo adduser dominik sudo
su dominik
bash

echo "Updating system.."
#make sure everything is up-to-date
sudo apt-get update
sudo apt-get upgrade

#enable autostarting of mysql for host-europe
echo "Enabling MySQL and setting root password.."
sudo rm /etc/init/mysql.override
sudo service mysql start
read -s -p "Please enter a password for the MySQL root user:" password && echo ""
read -s -p "Repeat:" passwordRepeat && echo ""

if($password == $passwordRepeat){
  sudo mysqladmin -u root $password
} else {
  echo "Couldn't set the MySQL root password"
  exit 1
}

echo "Installing some useful packages.."
#install important packages
sudo apt-get install -y -qq redmine-mysql
sudo apt-get install -y -qq redmine
sudo apt-get install -y -qq phpmyadmin

#apache configuration
sudo a2enmod ssl
sudo a2enmod rewrite

sudo cp ./resources/dominik.berlin /etc/apache2/sites-available/dominik.berlin
sudo a2ensite dominik.berlin

sudo cp ./resources/pma.dominik.berlin /etc/apache2/sites-available/pma.dominik.berlin
sudo a2ensite pma.dominik.berlin

sudo cp ./resources/talesofjade.de /etc/apache2/sites-available/talesofjade.de
sudo a2ensite talesofjade.de

#create basic ssl certificate
sudo mkdir /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

echo "Finished server setup successfully!"

