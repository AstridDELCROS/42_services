FROM alpine:3.12.0

WORKDIR /tmp

RUN mkdir -p /etc/telegraf

# Install mysql packages
RUN apk add --no-cache mysql mysql-client
RUN apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY init_db.sh    /usr/sbin/init_db.sh

CMD entrypoint.sh
