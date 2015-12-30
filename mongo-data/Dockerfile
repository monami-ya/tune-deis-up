FROM monami0ya/docker-baseimage:14.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get install -y openssl && \
    mkdir -p /data/db /data/db/keyfile && \
    openssl rand -base64 741 > /data/db/mongodb-keyfile && \
    chmod 600 /data/db/mongodb-keyfile && \
    chown -R 999 /data/db && \
    apt-get autoremove -y openssl && \
    apt-get clean

ENTRYPOINT [ "sleep" ]
CMD [ "infinity" ]

