FROM alpine:3.12.0

WORKDIR /tmp

RUN mkdir -p /etc/telegraf

RUN apk add --no-cache openssl vsftpd
RUN apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY vsftpd.conf   /etc/vsftpd/vsftpd.conf

CMD entrypoint.sh
