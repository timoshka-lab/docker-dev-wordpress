#!/bin/bash

set -e

args=()

for OPT in "$@"
do
  case $OPT in
    --version)
      args+=("--version")
      args+=("$2")
      shift 2
      ;;
  esac
done

WORDPRESS_DIR=/var/www/html/wordpress/public
PHPMYADMIN_DIR=/var/www/html/phpmyadmin/public

if [ -f "$WORDPRESS_DIR/index.php" ]; then
  echo "WordPress is already installed. Skipping..."
else
  echo "Downloading WordPress..."
  /usr/local/bin/wp core download --path=$WORDPRESS_DIR --locale=ja --allow-root "${args[@]}"
fi

if [ -f "$PHPMYADMIN_DIR/index.php" ]; then
  echo "phpMyAdmin is already installed. Skipping..."
else
  echo "Downloading phpMyAdmin..."
  wget -qO- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz  | tar xz -C $PHPMYADMIN_DIR --strip-components=1
fi

