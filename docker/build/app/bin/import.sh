#!/bin/bash

set -eu

function wp_cmd() {
  # /usr/local/bin/wp "$@"
  /usr/local/bin/php -d error_reporting='E_ALL ^ E_DEPRECATED' /usr/local/bin/wp "$@"
}

WORDPRESS_DIR=/var/www/html/wordpress/public
MYSQL_INIT_FILE=/initdb.d/001-mysql-init.sql

if [ -f $MYSQL_INIT_FILE ]; then
  echo "Importing database..."
  wp_cmd db import --path="$WORDPRESS_DIR" --allow-root "$MYSQL_INIT_FILE"
else
  echo "No database to import."
fi