FROM anapsix/alpine-java:8_jdk
LABEL "Author":"arvon2014@gmail.com" \
      "Date":"2018-04-11"
ENV RUN_USER  daemon
ENV RUN_GROUP daemon
ENV CONFLUENCE_HOME /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL_DIR   /opt/atlassian/confluence

VOLUME ["${CONFLUENCE_HOME}"]

EXPOSE 8090
EXPOSE 8091

WORKDIR $CONFLUENCE_HOME

RUN apk update -qq \
    && update-ca-certificates \
    && apk add ca-certificates wget curl openssh bash procps openssl perl ttf-dejavu tini\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    && mkdir -p  ${CONFLUENCE_INSTALL_DIR}

ARG CONFLUENCE_VERSION=6.8.1
ARG DOWNLOAD_URL=http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz
RUN curl -L --silent                  ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$CONFLUENCE_INSTALL_DIR"

ADD Fonts.zip  /usr/share/fonts/
#ADD atlassian-confluence-6.8.1.tar.gz $CONFLUENCE_INSTALL_DIR/

RUN chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR}/ \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME}/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8090"/port="8090" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml

COPY entrypoint.sh              /entrypoint.sh
COPY java-mysql/mysql-connector-java-5.1.46.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46.jar
COPY java-mysql/mysql-connector-java-5.1.46-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46-bin.jar
#
RUN chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR}/
#
CMD ["/entrypoint.sh", "-fg"]
ENTRYPOINT ["/sbin/tini", "--"]
