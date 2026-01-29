FROM debian:12

RUN apt-get update && apt-get install -y \
    vsftpd \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY vsftpd.conf /etc/vsftpd.conf

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 21
EXPOSE 21000-21010

ENTRYPOINT ["/usr/local/bin/script.sh"]
