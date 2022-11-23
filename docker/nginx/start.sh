#!/bin/bash
set -e

/usr/local/bin/ep -v /etc/nginx/conf.d/wordpress.conf
/usr/local/bin/ep -v /etc/nginx/conf.d/db.wordpress.conf

exec nginx -g 'daemon off;'