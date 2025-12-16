FROM debian:11

RUN apt update && apt upgrade -y && apt install -y \
    mariadb-server

ENTRYPOINT ["mysql_safe"]
