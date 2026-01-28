#!/bin/sh
set -e

FTP_USER="$(cat /run/secrets/ftp_user)"
FTP_PASS="$(cat /run/secrets/ftp_password)"

# Create required vsftpd chroot dir
mkdir -p /var/run/vsftpd/empty

# Create user if not exists
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Ensure correct ownership
chown -R www-data:www-data /var/www/html
chown -R "$FTP_USER:$FTP_USER" /var/www/html/wp-content

exec vsftpd /etc/vsftpd.conf
