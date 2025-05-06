FROM php:8.4-fpm-bullseye

RUN apt update && apt install -y \
    supervisor \
    nginx

RUN apt update && apt install -y \
    git \
    libicu-dev \
    libzip-dev \
    zip \
    unzip

RUN docker-php-ext-install \
    intl \
    zip

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

COPY --chown=www-data:www-data --chmod=550 . /var/www/html

COPY deploy/supervisor.conf /etc/supervisor/

COPY --chown=www-data:www-data deploy/nginx.conf /etc/nginx/sites-available/pricing-simulator.conf

RUN <<EOF
    rm /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/pricing-simulator.conf /etc/nginx/sites-enabled/
EOF

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisor.conf"]