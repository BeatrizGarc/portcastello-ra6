#!/bin/bash
# DC Ubuntu — Samba AD
hostnamectl set-hostname server-dc

# Liberar puerto 53 para Samba DNS
systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Instalar paquetes
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y samba smbclient winbind libpam-winbind libnss-winbind krb5-user chrony acl

# Preparar Samba AD DC
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# El alumno ejecutará: samba-tool domain provision --use-rfc2307 --interactive
