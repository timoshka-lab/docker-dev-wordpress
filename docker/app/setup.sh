#!/bin/bash

set -e

args=()
SKIP_WP=false

for OPT in "$@"
do
  case $OPT in
    --version)
      args+=("--version")
      args+=("$2")
      shift 2
      ;;
    --skip-wp)
      SKIP_WP=true
      shift 1
      ;;
  esac
done

WORDPRESS_DIR=/var/www/html/wordpress/public
PHPMYADMIN_DIR=/var/www/html/phpmyadmin/public

if [ "$SKIP_WP" = false ]; then
  if [ -f "$WORDPRESS_DIR/index.php" ]; then
    echo "WordPress is already installed. Skipping..."
  else
    WP_USER=""
    WP_TITLE=""

    while [ -z "$WP_USER" ]; do read -r -p "Username: " WP_USER; done
    while [ -z "$WP_TITLE" ]; do read -r -p "Website Title: " WP_TITLE; done

    echo "Downloading WordPress..."
    wp core download --path=$WORDPRESS_DIR --locale=ja --allow-root "${args[@]}"

    echo "Installing WordPress..."
    wp core install --path=$WORDPRESS_DIR --allow-root --skip-email --url="$WP_SITE_URL" --title="$WP_TITLE" --admin_user="$WP_USER" --admin_email="$WP_EMAIL"

    echo "Installing SMTP plugin..."
    wp plugin install --path=$WORDPRESS_DIR --allow-root http://github.com/timoshka-lab/wp-dev-smtp/archive/main.zip
  fi
else
  echo "Skipping WordPress installation..."
fi

if [ -f "$PHPMYADMIN_DIR/index.php" ]; then
  echo "phpMyAdmin is already installed. Skipping..."
else
  echo "Downloading phpMyAdmin..."
  wget -qO- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz  | tar xz -C $PHPMYADMIN_DIR --strip-components=1
fi

echo -e "\e[32mDone!\e[0m"
