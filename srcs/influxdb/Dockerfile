FROM alpine:3.12.0

RUN mkdir -p /etc/telegraf

RUN apk add --no-cache influxdb telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /usr/bin/entrypoint.sh

CMD entrypoint.sh