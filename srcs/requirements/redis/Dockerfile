FROM debian:11

RUN apt update && apt install -y redis-server \
 && rm -rf /var/lib/apt/lists/*

COPY redis.conf /etc/redis/redis.conf

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/script.sh"]
