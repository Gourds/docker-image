FROM debian:buster-slim
LABEL "Author":"guoyafeng@taiyouxi.cn" \
      "Date": "2021-01-18"
ENV ARDB_DATA  /opt/ardb-data
ENV ARDB_HOME  /opt/ardb
ENV THEAD_POOL_SIZE = 4
ENV RUN_USER ardb

RUN useradd --user-group --system --create-home --no-log-init ${RUN_USER}

ARG ARDB_PKG=ardb_0.9.4_v2.tar.gz

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
           ca-certificates\
           dpkg-dev \
           tini;\
    rm -rf /var/lib/apt/lists/*;\
    mkdir -p ${ARDB_HOME} ${ARDB_DATA};
ADD ${ARDB_PKG}  ${ARDB_HOME}/
COPY entrypoint.sh /entrypoint.sh

RUN chown -R ${RUN_USER}:${RUN_GROUP} ${ARDB_HOME}\
    && chown -R ${RUN_USER}:${RUN_GROUP} ${ARDB_DATA}\
    && chown -R ${RUN_USER}:${RUN_GROUP} /entrypoint.sh

VOLUME ${ARDB_DATA}

WORKDIR ${ARDB_HOME}
USER ${RUN_USER}
EXPOSE 16379
CMD [""]
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
