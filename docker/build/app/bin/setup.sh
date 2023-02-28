#!/bin/bash

set -eu

# 　wp-cliをphp8.1環境で実行した際に、Deprecatedエラーが出るので、一時的な対応としてphp-cliからwp-cliを実行するようにしています。
# 参照： https://github.com/wp-cli/wp-cli/issues/5623
# TODO: wp-cliのバグが修正されてから、wp-cliを直接実行する仕様に変更すること。

function wp_cmd() {
  # /usr/local/bin/wp "$@"
  /usr/local/bin/php -d error_reporting='E_ALL ^ E_DEPRECATED' /usr/local/bin/wp "$@"
}

SKIP_WP=false
WP_VERSION=

for OPT in "$@"
do
  case $OPT in
    --version)
      WP_VERSION=$2

      shift 2
      ;;
    --skip-wp)
      SKIP_WP=true
      shift 1
      ;;
  esac
done

WORDPRESS_ADMIN_PASSWORD=develop
WORDPRESS_DIR=/var/www/html/wordpress/public
PHPMYADMIN_DIR=/var/www/html/phpmyadmin/public
MYSQL_INIT_FILE=/initdb.d/001-mysql-init.sql
EXTRA_SETUP_BIN_DIR=/setup.d

until mysqladmin ping -h "$MYSQL_HOST" --silent; do
  echo 'Waiting for mysql server connection...'
  sleep 2
done

echo "Starting application setup..."

if [ "$SKIP_WP" = false ]; then
  if [ -f "$WORDPRESS_DIR/wp-includes/version.php" ]; then
    echo "WordPress is already downloaded. Skipping..."
  else
    args=()

    if [ -z "$WP_VERSION" ] && [ -n "${WP_DEFAULT_VERSION:-}" ] ; then
      args+=("--version")
      args+=("$WP_DEFAULT_VERSION")
    fi

    if [ -d "$WORDPRESS_DIR/wp-content" ]; then
      echo "Downloading WordPress without default content..."
      wp_cmd core download --path="$WORDPRESS_DIR" --locale=ja --allow-root --skip-content "${args[@]}"
    else
      echo "Downloading WordPress..."
      wp_cmd core download --path="$WORDPRESS_DIR" --locale=ja --allow-root "${args[@]}"
    fi
  fi

  if [ -f "$MYSQL_INIT_FILE" ]; then
    echo "Restoring database..."
    wp_cmd db import --path="$WORDPRESS_DIR" --allow-root "$MYSQL_INIT_FILE"
  else
    if wp_cmd core is-installed --path="$WORDPRESS_DIR" --allow-root; then
      echo "Skipping WordPress installation..."
    else
      WP_USER=""
      WP_TITLE=""

      while [ -z "$WP_USER" ]; do read -r -p "WordPress Username: " WP_USER; done
      while [ -z "$WP_TITLE" ]; do read -r -p "WordPress Title: " WP_TITLE; done

      echo "Installing WordPress..."
      wp_cmd core install --path="$WORDPRESS_DIR" --allow-root --skip-email --url="$WP_SITE_URL" --title="$WP_TITLE" --admin_user="$WP_USER" --admin_email="$WP_EMAIL" --admin_password="$WORDPRESS_ADMIN_PASSWORD"

      echo "Installing SMTP plugin..."
      wp_cmd plugin install --path="$WORDPRESS_DIR" --allow-root --activate https://github.com/timoshka-lab/wp-dev-smtp/archive/main.zip

      echo "Exporting database..."
      wp_cmd db export --path="$WORDPRESS_DIR" --add-drop-table --allow-root "$MYSQL_INIT_FILE"
    fi
  fi

  echo "Fixing WordPress permissions..."
  chown -R www-data:www-data $WORDPRESS_DIR
else
  echo "Skipping WordPress installation..."
fi

if [ -f "$PHPMYADMIN_DIR/libraries/classes/Version.php" ]; then
  echo "phpMyAdmin is already installed. Skipping..."
else
  echo "Downloading phpMyAdmin..."
  wget -qO- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz  | tar xz -C $PHPMYADMIN_DIR --strip-components=1
fi

if [ -n "$(ls "$EXTRA_SETUP_BIN_DIR")" ]; then
  echo "Starting extra setup scripts..."
  for file in "$EXTRA_SETUP_BIN_DIR"/*.sh; do
    echo "Running $file..."
    bash "$file"
  done
fi

echo -e "\e[32mApplication setup is now Done!\e[0m"
