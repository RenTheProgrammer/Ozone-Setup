#!/bin/bash

echo "Creating ozone directory structure..."
cd / && mkdir /ozone

echo "Changing to ozone directory..."
cd /ozone

echo "Creating subdirectories..."
mkdir --parent /caddy/etc/caddy
mkdir --parent /caddy/data

echo "Creating environment files..."
touch .env 
echo ".env Created"
touch postgres.env
echo "postgres.env Created"
touch ozone.env
echo "ozone.env Created"


echo "Downloading compose.yml..."
curl -o compose.yml https://raw.githubusercontent.com/RenTheProgrammer/Ozone-Setup/main/compose.yml

echo "Setup complete."