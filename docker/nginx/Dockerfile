ARG NGINX_VERSION=1.18
FROM nginx:${NGINX_VERSION}

ARG ENVPLATE_VERSION=1.0.2

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y &&  \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget && \
    ENVPLATE_ARCH=$(uname -m) && \
    if [ "$ENVPLATE_ARCH" = "aarch64" ]; then ENVPLATE_ARCH="arm64"; fi && \
    wget -q https://github.com/kreuzwerker/envplate/releases/download/v${ENVPLATE_VERSION}/envplate_${ENVPLATE_VERSION}_$(uname -s)_${ENVPLATE_ARCH}.tar.gz -O - | tar xz && \
    chmod +x envplate && \
    mv envplate /usr/local/bin/ep && \
    DEBIAN_FRONTEND=noninteractive apt-get remove -y wget && \
    rm -Rf /var/lib/apt /var/cache/apt

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d
COPY includes /etc/nginx/includes
COPY start.sh /start.sh

STOPSIGNAL SIGQUIT
CMD ["/start.sh"]