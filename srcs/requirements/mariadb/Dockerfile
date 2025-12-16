FROM debian:11

RUN apt update && apt upgrade -y && apt install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY init.sql /etc/mysql/init.sql

RUN mkdir /run/mysqld

ENTRYPOINT ["mysqld"]
