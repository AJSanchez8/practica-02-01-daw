#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex

# Actualizamos la lista de repositorios
apt update
# apt upgrade -y

# Importamos las variables de entorno
source .env

# Instalamos y actualizamos snap
snap install core
snap refresh core

# Eliminamos instalaciones previas de Certbot
apt remove certbot

# Instalamos el cliente de Certbot
snap install --classic certbot

# Creamos el enlace simbólico
ln -fs /snap/bin/certbot /usr/bin/certbot

certbot --nginx -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive