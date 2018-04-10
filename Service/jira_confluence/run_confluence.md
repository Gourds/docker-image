


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
jdbc:mysql://10.10.1.7:3306/confluence?sessionVariables=tx_isolation='READ-COMMITTED'
```
