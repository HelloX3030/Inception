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

# Change ownership of the data directory to mysql user
RUN chown -R mysql:mysql /var/lib/mysql

# Switch to mysql user
USER mysql

CMD ["mysqld"]
