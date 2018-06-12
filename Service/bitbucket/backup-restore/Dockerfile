FROM anapsix/alpine-java:8_jdk
LABEL "Author":"arvon2014@gmail.com" \
      "Date":"2018-06-12"
ENV RUN_USER  daemon
ENV RUN_GROUP daemon
ENV BITBUCKET_BACKUP_HOME /bitbucket-backup/
ENV BITBUCKET_BACKUP_VERSION bitbucket-backup-3.3.4
ENV BITBUCKET_S_HOME /srv/docker/bitbucket/app-data/
ENV BITBUCKET_S_USER YourUserName
ENV BITBUCKET_S_PASSWORD YourPassword
ENV BITBUCKET_S_URL http://yourURL/
ENV BACKUP_S_DIR /data

VOLUME $BACKUP_S_DIR

ADD bitbucket-backup-distribution-3.3.4.zip /bitbucket-backup/

RUN apk update -qq \
    && update-ca-certificates \
    && apk add ca-certificates tini \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*
RUN cd /bitbucket-backup/ \
    && unzip bitbucket-backup-distribution-3.3.4.zip \
    && rm -rf bitbucket-backup-distribution-3.3.4.zip \
    && mv bitbucket-backup-client-3.3.4 $BITBUCKET_BACKUP_VERSION

COPY entrypoint.sh /entrypoint.sh
WORKDIR $BITBUCKET_BACKUP_HOME$BITBUCKET_BACKUP_VERSION

CMD ["/entrypoint.sh", "backup"]
ENTRYPOINT ["/sbin/tini", "--"]
