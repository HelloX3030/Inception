#!/bin/sh
set -e

FTP_USER="$(cat /run/secrets/ftp_user)"
FTP_PASS="$(cat /run/secrets/ftp_password)"

# Fail fast if TLS certs are missing
for f in /etc/vsftpd/certs/ftp.crt /etc/vsftpd/certs/ftp.key; do
    [ -f "$f" ] || { echo "Missing TLS cert: $f"; exit 1; }
done

# Required vsftpd chroot dir
mkdir -p /var/run/vsftpd/empty

# Create FTP user (no shell)
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m -s /usr/sbin/nologin "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Safe chroot layout
mkdir -p /var/www/html/wp-content
chown root:root /var/www/html
chmod 755 /var/www/html
chown -R "$FTP_USER:$FTP_USER" /var/www/html/wp-content

exec vsftpd /etc/vsftpd.conf
