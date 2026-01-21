FROM debian:11

RUN apt update && apt upgrade -y && apt install -y \
    mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY script.sh /usr/local/bin/script.sh

RUN mkdir /run/mysqld
RUN chmod +x /usr/local/bin/script.sh

ENTRYPOINT ["/usr/local/bin/script.sh"]
