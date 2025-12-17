FROM debian:latest

# Update package index, upgrade installed packages,
# install Nginx, then clean apt cache to keep the image small.
RUN apt update && apt upgrade -y && apt install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY default /etc/nginx/sites-available/default

# Document Expose HTTPS Port
EXPOSE 443

# Nginx will always be the main process.
ENTRYPOINT ["nginx"]

# -g allows passing global Nginx directives from the command line.
# "daemon off;" disables background daemonization so Nginx
# runs in the foreground as PID 1 (required for Docker).
CMD ["-g", "daemon off;"]
