ARG NGINX_VERSION=1.18
FROM nginx:${NGINX_VERSION}-alpine

ARG ENVPLATE_VERSION=1.0.2

RUN set -ex && \
    apk add --no-cache wget bash sudo openssl certbot apache2-utils && \
    ENVPLATE_ARCH=$(uname -m) && \
    if [ "$ENVPLATE_ARCH" = "aarch64" ]; then ENVPLATE_ARCH="arm64"; fi && \
    wget -q https://github.com/kreuzwerker/envplate/releases/download/v${ENVPLATE_VERSION}/envplate_${ENVPLATE_VERSION}_$(uname -s)_${ENVPLATE_ARCH}.tar.gz -O - | tar xz && \
    chmod +x envplate && \
    mv envplate /usr/local/bin/ep && \
    apk del wget && \
    rm -rf /tmp/* /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d
COPY includes /etc/nginx/includes
COPY start.sh /start.sh

STOPSIGNAL SIGQUIT
CMD ["/start.sh"]