#!/bin/bash

set -e

# 　wp-cliをphp8.1環境で実行した際に、Deprecatedエラーが出るので、一時的な対応としてphp-cliからwp-cliを実行するようにしています。
# 参照： https://github.com/wp-cli/wp-cli/issues/5623
# TODO: wp-cliのバグが修正されてから、wp-cliを直接実行する仕様に変更すること。

function wp_cmd() {
  # /usr/local/bin/wp "$@"
  /usr/local/bin/php -d error_reporting='E_ALL ^ E_DEPRECATED' /usr/local/bin/wp "$@"
}

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

echo "Starting application setup..."

if [ "$SKIP_WP" = false ]; then
  if [ -f "$WORDPRESS_DIR/wp-includes/version.php" ]; then
    echo "WordPress is already installed. Skipping..."
  else
    WP_USER=""
    WP_TITLE=""

    while [ -z "$WP_USER" ]; do read -r -p "WordPress Username: " WP_USER; done
    while [ -z "$WP_TITLE" ]; do read -r -p "WordPress Title: " WP_TITLE; done

    echo "Downloading WordPress..."
    wp_cmd core download --path="$WORDPRESS_DIR" --locale=ja --allow-root "${args[@]}"

    echo "Installing WordPress..."
    wp_cmd core install --path="$WORDPRESS_DIR" --allow-root --skip-email --url="$WP_SITE_URL" --title="$WP_TITLE" --admin_user="$WP_USER" --admin_email="$WP_EMAIL"

    echo "Installing SMTP plugin..."
    wp_cmd plugin install --path="$WORDPRESS_DIR" --allow-root --activate http://github.com/timoshka-lab/wp-dev-smtp/archive/main.zip

    echo "Fixing WordPress permissions..."
    chown -R www-data:www-data $WORDPRESS_DIR
  fi
else
  echo "Skipping WordPress installation..."
fi

if [ -f "$PHPMYADMIN_DIR/libraries/classes/Version.php" ]; then
  echo "phpMyAdmin is already installed. Skipping..."
else
  echo "Downloading phpMyAdmin..."
  wget -qO- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz  | tar xz -C $PHPMYADMIN_DIR --strip-components=1
fi

echo -e "\e[32mApplication setup is now Done!\e[0m"
