#!/bin/sh
set -e

#install mongodb
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
cat <<EOF > /etc/apt/sources.list.d/mongodb-org-3.2.list
deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
EOF
apt update
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod
