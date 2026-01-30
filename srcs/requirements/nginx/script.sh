#!/bin/sh
set -e

# Required environment
: "${DOMAIN:?DOMAIN is required}"
: "${ADMINER_DOMAIN:?ADMINER_DOMAIN is required}"
: "${MONITOR_DOMAIN:?MONITOR_DOMAIN is required}"
: "${STATIC_DOMAIN:?STATIC_DOMAIN is required}"

# Render configs
envsubst '$DOMAIN' \
  < /etc/nginx/templates/wordpress.conf.template \
  > /etc/nginx/conf.d/wordpress.conf

envsubst '$ADMINER_DOMAIN' \
  < /etc/nginx/templates/adminer.conf.template \
  > /etc/nginx/conf.d/adminer.conf

envsubst '$MONITOR_DOMAIN' \
  < /etc/nginx/templates/monitor.conf.template \
  > /etc/nginx/conf.d/monitor.conf

envsubst '$STATIC_DOMAIN' \
  < /etc/nginx/templates/static.conf.template \
  > /etc/nginx/conf.d/static.conf

exec "$@"
