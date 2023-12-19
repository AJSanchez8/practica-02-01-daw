#!/bin/bash

# Para mostrar los comandos que se van ejecutando
set -ex 

# Actualizamos la lista de repositorios
apt update

# Actualizamos los paquetes del sistema 
apt upgrade -y

# Instalamos el servidor web Nginx
apt install nginx -y

# Instalamos MySQL Server
apt install mysql-server -y

# Instalamos php-fpm y php-mysql
apt install php-fpm php-mysql  -y

# Copiamos el archivo de configuración de Nginx
cp /home/ubuntu/practica-02-01-daw/conf/000-default.conf /etc/nginx/sites-available/default

# Configuración de la directiva cgi.fix_pathinfo para mejorar la seguridad
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.1/fpm/php.ini

# Reiniciamos el servicio fpm
systemctl restart php8.1-fpm

# Reiniciamos el servicio de Nginx
systemctl restart nginx

# Copiamos el archivo info de PHP
cp /home/ubuntu/practica-02-01-daw/php/index.php /var/www/html

# Cambiamos el usaurio y el prpopietario de la directorio de /var/www/html
chown -R www-data:www-data /var/www/html