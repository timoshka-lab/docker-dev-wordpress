#!/bin/bash

set -eu

function wp_cmd() {
  # /usr/local/bin/wp "$@"
  /usr/local/bin/php -d error_reporting='E_ALL ^ E_DEPRECATED' /usr/local/bin/wp "$@"
}

SKIP_PASS_RESET=false
DEFAULT_PASSWORD=develop

for OPT in "$@"
do
  case $OPT in
    --pass)
      DEFAULT_PASSWORD=$2
      shift 2
      ;;
    --skip-pass-reset)
      SKIP_PASS_RESET=true
      shift 1
      ;;
  esac
done

WORDPRESS_DIR=/var/www/html/wordpress/public
MYSQL_INIT_FILE=/initdb.d/001-mysql-init.sql

if [ "$SKIP_PASS_RESET" = false ]; then
  echo "Resetting users password to: $DEFAULT_PASSWORD"
  wp_cmd user list --path="$WORDPRESS_DIR" --allow-root --field=ID | while read id; do
    wp_cmd user update "$id" --path="$WORDPRESS_DIR" --user_pass="$DEFAULT_PASSWORD" --allow-root --skip-email
  done
fi

echo "Exporting database..."
wp_cmd db export --path="$WORDPRESS_DIR" --add-drop-table --allow-root "$MYSQL_INIT_FILE"