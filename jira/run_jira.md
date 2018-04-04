## Docker安装jira

Step1: install mysql

Step2: run jira


## Install Mysql

```
#docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=JxqzN2 -d mysql/mysql-server:latest
#docker run --name mysql005 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=888888 -idt mysql:8 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
docker run --name mysql -p 3306:3306 -v /data/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=888888 -idt mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_bin
#How to init mysql: https://confluence.atlassian.com/adminjiraserver072/connecting-jira-applications-to-mysql-828787562.html
#CREATE DATABASE IF NOT EXISTS jira_db DEFAULT CHARACTER SET utf8;

# if necessary run follow command
CREATE DATABASE jiradb CHARACTER SET utf8 COLLATE utf8_bin;
grant ALL PRIVILEGES on jira_db.* to jira_user@"%" Identified by "jirsaf3fs6";
SHOW CREATE DATABASE db_name;
flush privileges;

# if database character not right can use follow command
alter database name character set utf8;#修改数据库成utf8的.
alter table type character set utf8;#修改表用utf8.
alter table type modify type_name varchar(50) CHARACTER SET utf8;#修改字段用utf8
```


## Run Jira

```
docker run -p 18080:8080 -dit --name jira_v1 docker.io/cptactionhank/atlassian-jira
```








## References

[one blog](https://xuqiang.me/Docker-JIRA-7-3-8-%E7%A0%B4%E8%A7%A3%E9%83%A8%E7%BD%B2.html)

[two site](https://www.pmowner.com/2017/05/13/%E4%BD%BF%E7%94%A8docker%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BAjira%E4%BD%93%E9%AA%8C%E7%8E%AF%E5%A2%83/)

[three](http://www.yfshare.vip/2017/05/09/%E9%83%A8%E7%BD%B2JIRA-7-2-2-for-Linux/)
