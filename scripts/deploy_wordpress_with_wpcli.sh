#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex

# Actualizamos la lista de repositorios
apt update
# apt upgrade -y

# Variables de entorno
source .env

# Borrar instalaciones
rm -rf /tmp/wp-cli.phar

# rm -rf /var/www/html/*
# rm -rf /tmp/wordpress/*

# Descargar la herramienta wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

# Asignar permisos de ejecución
chmod +x /tmp/wp-cli.phar

# Mover el archivo a /usr/local/bin
mv /tmp/wp-cli.phar /usr/local/bin/wp

# Borrar instalaciones previas de WordPress
rm -rf /var/www/html/*

# Descargamos WordPress
wp core download \
  --locale=es_ES \
  --path=/var/www/html \
  --allow-root

# Crear la base de datos y el usuario para WordPress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Configuramos WordPress
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --path=/var/www/html \
  --allow-root

# Instalamos WordPress
wp core install \
  --url=$CERTIFICATE_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$CERTIFICATE_EMAIL \
  --path=/var/www/html \
  --allow-root  

# Instalación del plugin Permalink Manager Lite para los enlaces permanentes.
wp --path=/var/www/html plugin install permalink-manager --activate --allow-root
# Configurar la estructura de enlaces permanentes después de la instalación completa de WordPress
wp --path=/var/www/html option update permalink_structure '/%postname%/' --allow-root

#----------T E M A S ------------------------------------------------------------------------
# Comando para buscar temas
# wp theme search sport --path=/var/www/html
# Instalamos temas (en mi caso uno de naturaleza que me gustó)
wp theme install zino --activate --allow-root --path=/var/www/html 
#--------------------------------------------------------------------------------------------

# Instalar un plugin para modificar la ruta de wp-admin
wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root
wp option update whl_page "/administrador" --path=/var/www/html --allow-root

# Eliminar los temas que estén inactivos
wp theme delete $(wp theme list --status=inactive --field=name --path=/var/www/html --allow-root) --path=/var/www/html --allow-root

# Cambiar el propietario de la carpeta /var/www/html/
chown -R www-data:www-data /var/www/html/