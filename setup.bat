#!/bin/bash

echo "Creating ozone directory structure..."
cd / && mkdir /ozone

echo "Changing to ozone directory..."
cd /ozone

echo "Creating subdirectories..."
mkdir --parent /caddy/etc/caddy
mkdir --parent /caddy/data

echo "Creating Caddyfile"
cd /caddy/etc/caddy
curl -o Caddyfile https://raw.githubusercontent.com/RenTheProgrammer/Ozone-Setup/main/Caddyfile

#Prompt user for domain name
read -p "Enter your domain name without 'https' (e.g., example.com): " DOMAIN_NAME
#Replace placeholder in Caddyfile with user input
sed -i "s/{DOMAIN}/$DOMAIN_NAME/g" Caddyfile

cd /ozone

echo "Creating environment files..."
touch .env 
echo ".env Created"
touch postgres.env
echo "postgres.env Created"
touch ozone.env
echo "ozone.env Created"

echo "Populating environment files..."
POSTGRES_PASSWORD="$(openssl rand --hex 16)"

cat <<POSTGRES_CONFIG | sudo tee /ozone/postgres.env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=ozone
POSTGRES_CONFIG


echo "Postgres environment file populated."

read -p "Enter your service account hanlde (eg. mylabeler.bsky.social): " SERVICE_ACCOUNT_HANDLE


OZONE_HOSTNAME=$DOMAIN_NAME
OZONE_SERVICE_ACCOUNT_HANDLE=$SERVICE_ACCOUNT_HANDLE
OZONE_SERVER_DID="$(curl --fail --silent --show-error "https://api.bsky.app/xrpc/com.atproto.identity.resolveHandle?handle=${OZONE_SERVICE_ACCOUNT_HANDLE}" | jq --raw-output .did)"
OZONE_ADMIN_PASSWORD="$(openssl rand --hex 16)"
OZONE_SIGNING_KEY_HEX="$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)"

cat <<OZONE_CONFIG | sudo tee /ozone/ozone.env
OZONE_SERVER_DID=${OZONE_SERVER_DID}
OZONE_PUBLIC_URL=https://${OZONE_HOSTNAME}
OZONE_ADMIN_DIDS=${OZONE_SERVER_DID}
OZONE_ADMIN_PASSWORD=${OZONE_ADMIN_PASSWORD}
OZONE_SIGNING_KEY_HEX=${OZONE_SIGNING_KEY_HEX}
OZONE_DB_POSTGRES_URL=postgresql://postgres:${POSTGRES_PASSWORD}@localhost:5432/ozone
OZONE_DB_MIGRATE=1
OZONE_DID_PLC_URL=https://plc.directory
OZONE_APPVIEW_URL=https://api.bsky.app
OZONE_APPVIEW_DID=did:web:api.bsky.app
LOG_ENABLED=1
OZONE_DEV_MODE=true
OZONE_CONFIG
echo "Ozone environment file populated."

read -p "Enter Cloudflare token with Zone.Read: " CF_TOKEN

cat <<CLOUDFLARE_CONFIG | sudo tee -a /ozone/.env
CF_API_TOKEN=$CF_TOKEN
CLOUDFLARE_CONFIG

echo ".env file populated."


echo "Downloading compose.yml..."
curl -o compose.yml https://raw.githubusercontent.com/RenTheProgrammer/Ozone-Setup/main/compose.yml

echo "Setup complete."
echo "cd into /ozone and run 'docker-compose up' to start Ozone."
