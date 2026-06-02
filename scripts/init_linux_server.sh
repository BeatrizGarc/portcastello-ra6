#!/bin/bash
# Servidor Linux miembro del dominio
hostnamectl set-hostname linux-server
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y samba winbind libpam-winbind libnss-winbind krb5-user acl

# Crear carpetas compartidas
mkdir -p /srv/samba/Comun
mkdir -p /srv/samba/Privado
chmod 777 /srv/samba/Comun
chmod 770 /srv/samba/Privado

# El alumno unirá la máquina al dominio y configurará smb.conf
