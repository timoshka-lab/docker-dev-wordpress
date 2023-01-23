FROM docker:latest

RUN set -ex && \
    apk update && \
    apk upgrade && \
    apk add --no-cache tzdata bash && \
    rm -rf /tmp/* /var/cache/apk/*

COPY cronjob /cronjob

CMD ["crond", "-l", "3", "-L", "/dev/stderr", "-f"]