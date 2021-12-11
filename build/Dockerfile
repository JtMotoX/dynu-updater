FROM alpine:latest

RUN apk add --no-cache curl
RUN apk add --no-cache moreutils

COPY ./crontab /etc/crontabs/root
RUN chmod 644 /etc/crontabs/root

COPY ./scripts /scripts
RUN chmod 755 /scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
