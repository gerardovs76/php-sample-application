# Etapa de construcción
FROM composer:latest as builder

WORKDIR /app

# Copia los archivos de Composer
COPY composer.json composer.lock ./

# Configura tiempos de espera más largos para Composer y Git
RUN composer config --global process-timeout 2000 \
    && git config --global http.lowSpeedLimit 1000 \
    && git config --global http.lowSpeedTime 60

# Instala dependencias
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-suggest --optimize-autoloader

# Etapa final
FROM php:7.4-apache

# Instala extensiones de PHP necesarias y otras dependencias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install zip mysqli pdo pdo_mysql

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia los archivos de la etapa de construcción
COPY --from=builder /app/vendor /var/www/html/vendor
COPY --from=builder /app/composer.json /app/composer.lock /var/www/html/

# Copia el resto de los archivos de la aplicación
COPY . /var/www/html

# Configura Apache y los permisos
RUN sed -i 's|/var/www/html|/var/www/html/web|g' /etc/apache2/sites-available/000-default.conf \
    && a2enmod rewrite \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Copia la configuración personalizada de Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Genera el autoloader optimizado
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Cambia al directorio web
WORKDIR /var/www/html/web

# Expone el puerto 80
EXPOSE 80

# Inicia Apache en primer plano
CMD ["apache2-foreground"]