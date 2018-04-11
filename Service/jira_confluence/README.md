### Update

>`2018-04-11 15:59:33` 添加Confluence部署，重写Dockerfile 

>`2018-04-0x` 记录Jira部署

### 部署Jira

**概述：** jira使用docker部署，使用docker mysql但数据挂载在外面

**ENV：**
版本：7.3.8
环境：Centos7

### 部署Confluence

由于官方的Dockerfile存在很多问题，现在附上我自己改的Dockerfile，主要解决以下问题。

- 1. JDK问题
官方使用的基础镜像使用的是openJDK，但是Confluence又报错说平台不支持，要换成Oracle JDK

- 2. 连接Mysql问题
官方的对于PostSQL可以支持，但连接Mysql的话需要自己装对应连接mysql的JAR包，另外，web连接mysql时注意连接参数
觉得jar包直接放进git不是很科学，就先不放了,贴一下[下载地址](https://dev.mysql.com/downloads/file/?id=476197)，目录结构如下
```bash
├── Dockerfile
├── entrypoint.sh
├── Fonts.zip
├── java-mysql
│   ├── mysql-connector-java-5.1.46-bin.jar
│   └── mysql-connector-java-5.1.46.jar
└── tmp
    ├── bitbucket-pipelines.yml
    └── hooks
        └── post_push
```

- 3. 字体问题
我添加了windows下的字体目录直接放到容器的字体目录下，另外还需要在Confluence中配置对应参数，我这里没有配置，原因是还没有解决PPT的中文编码问题，但是可以先把自己放入容器，就算手动配置也会方便很多

### Install confluence with docker

- init mysql
``` bash
docker run --name mysql -p 3306:3306 -v /data/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -idt mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_bin
```
```
CREATE DATABASE confluence CHARACTER SET utf8 COLLATE utf8_bin;
grant ALL PRIVILEGES on confluence.* to confluence_user@"%" Identified by "cafnceaf3fs6";
SHOW CREATE DATABASE confluence;
flush privileges;
```

- run confluence
``` bash
docker run -v /data/confluence:/var/atlassian/application-data/confluence --name="confluence" -d -p 8090:8090 -p 8091:8091 atlassian/confluence-server
#Then you can use http://yourhost:8090 setup the website
#And if you use mysql as database, may be you need follow command
docker cp /tmp/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46.jar bbac1d7a421c:/opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46.jar
docker cp /tmp/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar bbac1d7a421c:/opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46-bin.jar
# Then restart confluence
# And may be you will find the error like 'Your database must use 'READ-COMMITTED' as the default isolation level'
# There have three methods to solove this problem , But I think the following method is the most concise
# Answer：https://confluence.atlassian.com/confkb/confluence-fails-to-start-and-throws-mysql-session-isolation-level-repeatable-read-is-no-longer-supported-error-241568536.html
jdbc:mysql://10.10.1.7:3306/confluence?sessionVariables=tx_isolation='READ-COMMITTED'&useSSL=false
```
