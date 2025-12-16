FROM debian:11

RUN apt update && apt upgrade -y && apt install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["mysql_safe"]
