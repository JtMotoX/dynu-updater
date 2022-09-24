FROM alpine:latest

RUN apk add --no-cache curl

# SETUP USER
ARG USER_NAME=appuser
ARG USER_ID=9001
RUN adduser -u ${USER_ID} -S ${USER_NAME}

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

# SETUP DYNU LOGS
ENV DYNU_LOG_FILE="/var/log/dynu-updater/dynu-updater.log"
RUN mkdir -p $(dirname ${DYNU_LOG_FILE})

# SETUP SUPERCRONIC
ENV SUPERCRONIC_VERSION="v0.2.1"
RUN wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
	chmod 755 /usr/local/bin/supercronic
COPY --chown=root --chmod=644 ./crontab /home/${USER_NAME}/crontab
RUN supercronic -json -test /home/${USER_NAME}/crontab

COPY --chmod=755 ./scripts /scripts

USER ${USER_ID}:${USER_ID}

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD [ "run" ]
