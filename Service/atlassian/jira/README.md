


### crack

打开注释
Dockerfile中的`#RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >>
 /opt/atlassian/jira/bin/setenv.sh`
docker-compose.yml中的`#image: jira:v7.8.2_crack`

```
docker build -t jira:v7.8.2_crack .
java -jar atlassian-agent.jar -p jira -m aaa@bbb.com -n my_name -o https://crack.io -s BAZ0-JG2E-PH
IE-MD6E
```


- 创建Jira数据库

```bash
#mysql> show variables like 'char%';
mysql> CREATE DATABASE jira_db CHARACTER SET utf8 COLLATE utf8_bin;
mysql> grant ALL PRIVILEGES on jira_db.* to jira_user@"%" Identified by "yourpassword;
mysql> SHOW CREATE DATABASE jira_db;
mysql> flush privileges;
```


- 修改JVM参数

```bash
docker exec -it -u root jira /bin/bash
#进入容器后执行以下命令
sed -i 's@JVM_MINIMUM_MEMORY=.*@JVM_MINIMUM_MEMORY="1024m"@' /opt/atlassian/jira/bin/setenv.sh
sed -i 's@JVM_MAXIMUM_MEMORY=.*@JVM_MAXIMUM_MEMORY="2048m"@' /opt/atlassian/jira/bin/setenv.sh
#修改完之后，退出容器然后重启Jira容器即可
docker restart jira
```
