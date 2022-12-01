#!/bin/bash
set -e

/usr/local/bin/ep -v /etc/nginx/conf.d/*.conf
/usr/local/bin/ep -v /etc/nginx/includes/*.conf

CERTS_DIR=/etc/nginx/certs
NGINX_INC_DIR=/etc/nginx/includes

echo "Removing default nginx config..."
rm -f /etc/nginx/conf.d/default.conf

if [ "$NGINX_ENABLE_SSL" = true ]; then
  echo "Enabling SSL..."

  if [ ! -f "$CERTS_DIR/server.crt" ]; then
    echo "Cleaning up old certs..."
    rm -f "$CERTS_DIR/*"

    echo "Generating new certs..."
    echo "subjectAltName = DNS:${NGINX_SERVER_NAME}, IP:127.0.0.1" > "$CERTS_DIR/subjectnames.txt"
    openssl genrsa 2048 > "$CERTS_DIR/server.key"
    openssl req -new -key "$CERTS_DIR/server.key" -subj "/C=JP/CN=$NGINX_SERVER_NAME" > "$CERTS_DIR/server.csr"
    openssl x509 -days 3650 -req -extfile "$CERTS_DIR/subjectnames.txt" -signkey "$CERTS_DIR/server.key" < "$CERTS_DIR/server.csr" > "$CERTS_DIR/server.crt"
  fi

  echo "Generating nginx configuration for ssl..."

  if [ "$NGINX_FORCE_HTTPS" = true ]; then
    echo "Forcing HTTPS..."
    cat "$NGINX_INC_DIR/wordpress_force_https.conf" > "$NGINX_INC_DIR/wordpress_http_context.conf"
  else
    cat "$NGINX_INC_DIR/wordpress_locations.conf" > "$NGINX_INC_DIR/wordpress_http_context.conf"
  fi
else
  echo "Generating nginx configuration for http..."
  cat "$NGINX_INC_DIR/wordpress_locations.conf" > "$NGINX_INC_DIR/wordpress_http_context.conf"
  echo "" > "$NGINX_INC_DIR/wordpress_https_server.conf"
fi

echo "-----------------------------------------------------------"
echo "Dont forget to add the following to your '/etc/hosts' file:"
echo "127.0.0.1 ${NGINX_SERVER_NAME}"
echo "127.0.0.1 db.${NGINX_SERVER_NAME}"
echo "-----------------------------------------------------------"

echo "Starting nginx..."
exec nginx -g 'daemon off;'