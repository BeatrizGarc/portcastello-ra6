#!/bin/bash
# Cliente Linux — unión a dominio con realmd
hostnamectl set-hostname linux-cli
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin

# El alumno ejecutará: realm join portcastello.local
