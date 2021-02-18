FROM alpine:3.12.0

WORKDIR /tmp

RUN mkdir -p /etc/telegraf

# Install nginx and additional packages
RUN apk add --no-cache nginx php7 php7-fpm  php7-opcache \
php7-gd php7-mysqli php7-zlib php7-curl php7-mbstring php7-json \
php7-session php7-bz2 php-zip openssl
RUN apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

# Install phpmyadmin
ARG PHPMA_VERSION="5.0.4"
ARG PHPMA_FILE="phpMyAdmin-${PHPMA_VERSION}-all-languages.tar.gz"

RUN wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMA_VERSION}/${PHPMA_FILE}

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY default.conf  /etc/nginx/conf.d/default.conf

CMD entrypoint.sh