FROM debian:12

RUN apt-get update && apt-get install -y \
    nginx \
    gettext-base \
 && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/sites-enabled/default

# Copy ALL templates
COPY conf.d/adminer.conf.template /etc/nginx/templates/
COPY conf.d/monitor.conf.template /etc/nginx/templates/
COPY conf.d/static.conf.template /etc/nginx/templates/
COPY conf.d/wordpress.conf.template /etc/nginx/templates/

# Copy entrypoint
COPY script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT ["/script.sh"]
CMD ["nginx", "-g", "daemon off;"]
