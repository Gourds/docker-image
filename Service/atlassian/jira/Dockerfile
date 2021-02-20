FROM cptactionhank/atlassian-jira-software:7.8.2

USER root

COPY "atlassian-agent.jar" /opt/atlassian/jira/

#RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >>
 /opt/atlassian/jira/bin/setenv.sh

RUN sed -i '/jira.lf.date.relativize/{n;s/true/false/;}' /opt/atlassian/jira/atlassian-jira/WEB-INF/clas
ses/jpm.xml
