FROM alpine:3.12.0

WORKDIR /tmp
RUN mkdir -p /etc/telegraf

RUN apk add --no-cache grafana telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/v3.13/community

COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY grafana.db /usr/share/grafana/data/grafana.db
COPY entrypoint.sh /usr/bin/entrypoint.sh

CMD entrypoint.sh