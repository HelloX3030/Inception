FROM debian:latest

RUN apt update && apt upgrade && apt install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

CMD ["nginx", "-g", "daemon off;"]
