#!/usr/bin/env bash

set -e

# Validate working directory
if [ "$(ls -A | wc -l)" -gt 1 ]; then
   echo "Error: working directory is not empty." >&2
   exit 1
fi

# Validate dependencies
if [ ! -x "$(command -v docker)" ]; then
  echo "Error: docker is not installed." >&2
  exit 1
fi

if [ ! -x "$(command -v curl)" ]; then
  echo "Error: curl is not installed." >&2
  exit 1
fi

echo "Starting auto setup..."

# Proceed setup
curl -L https://github.com/timoshka-lab/docker-dev-wordpress/archive/main.tar.gz | tar xvz -C ./ --strip-components=1
cp .env.example .env

read -p "Edit the '.env' file, and press enter key to continue:"

docker compose build
docker compose up -d
docker compose exec app /setup.sh

if [ -x "$(command -v security)" ]; then
  echo "Installing ssl certificate into keychain..."
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$(pwd)/docker/nginx/certs/server.crt"
else
  echo "Warning: you have to add ssl certificate to your keychain manually."
fi

echo -e "\e[32mAuto setup is now Done!\e[0m"