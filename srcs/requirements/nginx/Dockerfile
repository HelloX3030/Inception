FROM debian:12

RUN apt update && apt install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# Remove default config
RUN rm -f /etc/nginx/sites-enabled/default

# Copy our configs
COPY conf.d/ /etc/nginx/conf.d/

EXPOSE 443

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
