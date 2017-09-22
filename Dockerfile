FROM php:7-alpine

RUN curl -L https://github.com/just-containers/s6-overlay/releases/download/v1.20.0.0/s6-overlay-amd64.tar.gz \
    -o /tmp/s6-overlay-amd64.tar.gz \
  && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && rm /tmp/s6-overlay-amd64.tar.gz
ENTRYPOINT ["/init"]

VOLUME [ "/data" ]

RUN php -r "readfile('https://getcomposer.org/installer');" \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer create-project composer/satis:dev-master --prefer-dist --no-dev \
  && cd /satis \
  && composer dump-autoload -o \
  && rm -r ~/.composer/cache/*

RUN apk add --no-cache git openssh zlib-dev \
  && docker-php-ext-install zip \
  && echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
  && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

COPY ./services.d/ /etc/services.d/
