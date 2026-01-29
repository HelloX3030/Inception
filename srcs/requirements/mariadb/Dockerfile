FROM debian:12

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

# MariaDB runtime dirs
RUN mkdir -p /run/mysqld \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
