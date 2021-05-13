FROM php:8.0.6-fpm-alpine3.13

MAINTAINER Yurij Karpov <acrossoffwest@gmail.com>

RUN apk update

ADD  https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

RUN apk add \
git nano bash \
supervisor \
dcron curl

RUN install-php-extensions \
    imagick exif \
    zip \
    pdo_mysql mysqli \
    opcache pcntl redis

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=2.0.13 && \
    rm composer-setup.php

# Configure Cron
RUN mkdir -p /var/log/cron \
    && mkdir -m 0644 -p /var/spool/cron/crontabs \
    && touch /var/log/cron/cron.log \
    && mkdir -m 0644 -p /etc/cron.d

RUN chmod 777 /var/log/cron/cron.log

# Copy cron schedule
COPY ./crontab_schedule /tmp/crontab_schedule
RUN crontab /tmp/crontab_schedule && rm /tmp/crontab_schedule

# supervisor installation &&
# create directory for child images to store configuration in
RUN mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor

RUN rm -rf /var/cache/apk/*

CMD ["crond"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
