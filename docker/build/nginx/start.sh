#!/bin/bash
set -e

CERTS_DIR=/etc/nginx/certs
NGINX_INC_DIR=/etc/nginx/includes

function get_host_names() {
  local -n hostnames=$1
  local delimiter="${2:-,}"
  # shellcheck disable=SC2034
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

      if [ "$REVIEW_MODE" = true ]; then
        domains=()
        get_host_names domains

        args=()
        for domain in "${domains[@]}"; do
            args+=("-d $domain")
        done

        echo "Generating certificates for ${domains[*]}..."
        certbot certonly --standalone "${args[@]}" --non-interactive --agree-tos --register-unsafely-without-email --rsa-key-size 4096

        echo "Copying certs to nginx directory..."
        cp -L /etc/letsencrypt/live/"$(printf "%s" "${domains[0]}")"/fullchain.pem "$CERTS_DIR/server.crt"
        cp -L /etc/letsencrypt/live/"$(printf "%s" "${domains[0]}")"/privkey.pem "$CERTS_DIR/server.key"
      else
        domains=()
        get_host_names domains
        cert_dns_list=()

        for domain in "${domains[@]}"; do
          cert_dns_list+=("DNS:${domain}")
        done

        CERTS_DNS="$(IFS=,; echo "${cert_dns_list[*]}")"

        echo "Generating new certs..."
        echo "subjectAltName = ${CERTS_DNS}, IP:127.0.0.1" > "$CERTS_DIR/subjectnames.txt"
        openssl genrsa 2048 > "$CERTS_DIR/server.key"
        openssl req -new -key "$CERTS_DIR/server.key" -subj "/C=JP/CN=$NGINX_SERVER_NAME" > "$CERTS_DIR/server.csr"
        openssl x509 -days 3650 -req -extfile "$CERTS_DIR/subjectnames.txt" -signkey "$CERTS_DIR/server.key" < "$CERTS_DIR/server.csr" > "$CERTS_DIR/server.crt"
      fi
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

  if [ -n "$WP_BASIC_AUTH_USER" ] && [ -n "$WP_BASIC_AUTH_PASSWORD" ]; then
    echo "Basic auth is enabled."
    htpasswd -b -c /etc/nginx/.htpasswd.wordpress "$WP_BASIC_AUTH_USER" "$WP_BASIC_AUTH_PASSWORD"
  else
    echo "Basic auth is disabled."
    echo "" > "$NGINX_INC_DIR/wordpress_basic_auth.conf"
  fi

  if [ "$REVIEW_MODE" = true ]; then
    echo "Disabling phpmyadmin configuration..."
    rm -f /etc/nginx/conf.d/db.wordpress.conf
  fi

  echo "Mapping server names..."
  export_servers
  /usr/local/bin/ep -v /etc/nginx/conf.d/*.conf
  /usr/local/bin/ep -v /etc/nginx/includes/*.conf

  if [ "$REVIEW_MODE" = false ]; then
    echo "-----------------------------------------------------------"
    echo "Dont forget to add the following to your '/etc/hosts' file:"
    echo "127.0.0.1 ${WP_SERVERS}"
    echo "127.0.0.1 ${DB_SERVERS}"
    echo "-----------------------------------------------------------"
  fi

  echo "Starting nginx..."
  exec nginx -g 'daemon off;'
}

main