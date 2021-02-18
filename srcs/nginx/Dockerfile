FROM alpine:3.12.0

WORKDIR /tmp

RUN mkdir -p /etc/telegraf

RUN apk add --no-cache nginx openssl
RUN apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN mkdir -p /var/www/html;

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY default.conf  /etc/nginx/conf.d/default.conf
COPY index.html    /var/www/html/index.html

CMD entrypoint.sh
