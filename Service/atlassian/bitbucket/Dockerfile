FROM atlassian/bitbucket-server:7.9.1

USER root

COPY "atlassian-agent.jar" /opt/atlassian/bitbucket

RUN  sed -i 's@JAVA_OPTS="-classpath.*@&\nJAVA_OPTS="-javaagent:/opt/atlassian/bitbucket/atlassian-agent
.jar ${JAVA_OPTS}"@' /opt/atlassian/bitbucket/bin/_start-webapp.sh
