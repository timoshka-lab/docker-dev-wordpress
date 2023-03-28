#!/bin/bash
set -e

CERTS_DIR=/etc/nginx/certs
NGINX_INC_DIR=/etc/nginx/includes

function get_host_names() {
  local -n hostnames=$1
  local delimiter="${2:-,}"
  readarray -td"$delimiter" hostnames <<<"$NGINX_SERVER_NAME"
}

function export_servers() {
    local servers=()
    get_host_names servers
    WP_SERVERS="$(IFS=" "; echo "${servers[*]}")"
    DB_SERVERS="db.${servers[0]}"
    export WP_SERVERS
    export DB_SERVERS
}

function main() {
  echo "Removing default nginx config..."
  rm -f /etc/nginx/conf.d/default.conf

  if [ "$NGINX_ENABLE_SSL" = true ]; then
    echo "Enabling SSL..."

    if [ ! -f "$CERTS_DIR/server.crt" ]; then
      echo "Cleaning up old certs..."
      rm -f "$CERTS_DIR/*"

      hostnames=()
      get_host_names hostnames
      cert_dns_list=()

      for domain in "${hostnames[@]}"; do
        cert_dns_list+=("DNS:${domain}")
      done

      CERTS_DNS="$(IFS=,; echo "${cert_dns_list[*]}")"

      echo "Generating new certs..."
      echo "subjectAltName = ${CERTS_DNS}, IP:127.0.0.1" > "$CERTS_DIR/subjectnames.txt"
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

  echo "Mapping server names..."
  export_servers
  /usr/local/bin/ep -v /etc/nginx/conf.d/*.conf
  /usr/local/bin/ep -v /etc/nginx/includes/*.conf

  echo "-----------------------------------------------------------"
  echo "Dont forget to add the following to your '/etc/hosts' file:"
  echo "127.0.0.1 ${WP_SERVERS}"
  echo "127.0.0.1 ${DB_SERVERS}"
  echo "-----------------------------------------------------------"

  echo "Starting nginx..."
  exec nginx -g 'daemon off;'
}

main