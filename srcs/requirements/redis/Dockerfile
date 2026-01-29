FROM debian:12

RUN apt-get update && apt-get install -y \
    redis-server \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY redis.conf /etc/redis/redis.conf

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/script.sh"]
