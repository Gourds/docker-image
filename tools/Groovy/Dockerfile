FROM anapsix/alpine-java:8_jdk
LABEL "Author":"arvon2014@gmail.com" \
      "Date":"2018-05-25"
       #http://groovy-lang.org/install.html
ENV GROOVY_VERSION 2.4.15
ENV GROOVY_HOME /opt/groovy
ENV PATH $PATH:$GROOVY_HOME/bin

RUN apk update -qq \
    && apk add ca-certificates  bash zip curl python py-pip\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    && pip install awscli

RUN cd tmp \
    && wget https://dist.apache.org/repos/dist/release/groovy/${GROOVY_VERSION}/distribution/apache-groovy-binary-${GROOVY_VERSION}.zip \
    && unzip apache-groovy-binary-${GROOVY_VERSION}.zip -d  /tmp/ \
    && mv /tmp/groovy-${GROOVY_VERSION} ${GROOVY_HOME} \
    && rm -rf apache-groovy-binary-${GROOVY_VERSION}.zip


CMD ['tail']
