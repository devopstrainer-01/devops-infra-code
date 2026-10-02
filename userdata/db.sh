#!/bin/bash
apt update
apt upgrade -y
# sudo apt install mysql-server -y 
# sudo systemctl enable --now  mysql.service
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable --now postgresql.service