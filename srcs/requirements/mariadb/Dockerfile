FROM debian:bookworm-slim

RUN apt update && apt install -y \
    mariadb-server \
    mariadb-client \
    bash \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

CMD ["mysqld"]
