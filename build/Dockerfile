FROM alpine:latest

RUN apk add --no-cache curl
RUN apk add --no-cache moreutils

# INSTALL MSMTP MAIL SERVER
RUN apk add --no-cache openssl msmtp
ENV MSMTP_LOG_FILE="/var/log/msmtp/msmtp.log"
RUN touch /etc/msmtprc && \
	chmod 777 /etc/msmtprc && \
	printf "defaults\nlogfile ${MSMTP_LOG_FILE}\n" >/etc/msmtprc
RUN echo $(dirname ${MSMTP_LOG_FILE}) && \
	mkdir $(dirname ${MSMTP_LOG_FILE}) && \
	touch ${MSMTP_LOG_FILE} && \
	chmod 777 ${MSMTP_LOG_FILE}

COPY ./crontab /etc/crontabs/root
RUN chmod 644 /etc/crontabs/root

COPY ./scripts /scripts
RUN chmod 755 /scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
