FROM debian:11

RUN apt update && apt install -y redis-server \
 && rm -rf /var/lib/apt/lists/*

COPY redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
