FROM alpine:3.12.0

WORKDIR /tmp

RUN mkdir -p /etc/telegraf

# Install nginx and additional packages
RUN apk add --no-cache nginx php-fpm php7-common php7-iconv       \
    php7-json php7-gd php7-curl php7-openssl php7-xml php7-mysqli php7-pdo      \
    php7-pdo_mysql php7-soap php7-xmlrpc php7-mcrypt php7-gettext php7-ctype    \ 
    php7-dom php7 php7-phar
RUN apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community



# Install wordpress
ARG WP_VERSION="wordpress-5.6"
ARG WP_FILE="${WP_VERSION}.tar.gz"

RUN wget https://wordpress.org/${WP_FILE}   && \
    tar -xzf ${WP_FILE}                     && \
    mv wordpress /var/www/                  && \
    rm -rf ${WP_FILE}

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar  && \
    chmod +x wp-cli.phar                                                            && \
    mv wp-cli.phar /usr/sbin/wp


# Adding config files
COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY default.conf  /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh

CMD entrypoint.sh
