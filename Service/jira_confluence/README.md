### Update

>`2018-04-13 13:48` 整理归纳 

>`2018-04-11 15:59` 添加Confluence部署，重写Dockerfile

>`2018-04-0x` 记录Jira部署


### 环境准备

**本地实践环境:**
>OS：`CentOS Linux release 7.2.1511 (Core)`
>Docker:`v1.13.1`

**启动Docker并将Docker添加至开机启动**
- 在Centos7上
```bash
yum install docker -y
systemctl enable docker.service
systemctl start docker.service
```
- 在Centos6及Amazon Linux上
```bash
yum install docker -y
chkconfig --add docker
/etc/init.d/docker start
```

**Iptables及SELinux设置**
- 在Centos7上
```bash
#SELinux disabled
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
getenforce
#Iptables setup
yum install iptables-services
iptables -I  INPUT -p tcp --dport 3306 -j ACCEPT
iptables -I  INPUT -p tcp --dport 18080 -j ACCEPT
iptables -I  INPUT -p tcp --dport 8090 -j ACCEPT
service iptables save
#Other Command(Don't config)
#systemctl stop firewalld.service
#systemctl disable firewalld.service
```

### 安装Myql

使用官方镜像直接启动容器即可。不过使用Jira和Confluence时需要添加几个mysql启动配置,具体可参考[【Mysql镜像说明】](https://hub.docker.com/_/mysql/)，`packet`及`log_file_size`参数为应用要求防止大文件无法存储，`utf8`是为了支持中文
```bash
docker run --name mysql -p 3306:3306 -v /data/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=yourpasswd -idt mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_bin --max_allowed_packet=512M --innodb_log_file_size=2GB
#docker run -it --rm docker.io/mysql/mysql-server --verbose --help
docker ps -a #查看容器状态
docker exec -it mysql /bin/bash #进入容器，PS由于mysql启动后root用户监听localhost所以创建Database时需要进入容器内部
```
- 创建Jira数据库
```bash
#mysql> show variables like 'char%';
mysql> CREATE DATABASE jira_db CHARACTER SET utf8 COLLATE utf8_bin;
mysql> grant ALL PRIVILEGES on jira_db.* to jira_user@"%" Identified by "yourpassword;
mysql> SHOW CREATE DATABASE jira_db;
mysql> flush privileges;
```
- 创建Confluence数据库
```bash
#mysql> show variables like 'char%';
mysql> create database confluence CHARACTER SET utf8 COLLATE utf8_bin;
mysql> grant ALL PRIVILEGES on confluence.* to confluence_user@"%" Identified by "yourpassword";
mysql> SHOW CREATE DATABASE confluence;
mysql> flush privileges;
```
- 创建数据库备份用户
```bash
mysql> grant select on *.* to backup_user@"%" Identified by "yourpassword";
mysql> flush privileges;
```

### 安装Jira

使用官方镜像直接启动Jira容器。这个服务没有太多问题，注意端口是否监听正确及相关端口（数据库端口、应用端口）是否放开，这里的端口放开是指本机防火墙，外网防火墙不应放行数据库端口
```bash
docker run -p 18080:8080 -dit --name jira docker.io/cptactionhank/atlassian-jira
#Manage Application
docker ps
docker exec -it jira /bin/bash
docker stop jira
docker start jira
docker logs jira
docker logs -f jira
```
在浏览器访问`http://host_address:18080`跟着提示安装即可。


### 安装Confluence

由于Jira使用的是MySQL方便起见Confluence也要用Mysql，但是使用官方镜像会有以下问题
>a.官方的对于PostSQL支持可以,但无法直接连接mysql需要自行安装支持java连接mysql的组件
>b.中文Office在Confluence的预览查看会出现乱码情况，需要修改confluence连接参数及自行添加中文字体库
>c.官方使用了不受支持的`openjdk`，需要更改jdk环境为`Oracle JDK`

鉴于这种情况使用这个官方镜像就很不理智了，还希望使用docker，只能自己做一个镜像了

#### 制作镜像

- 准备工作
>- **Step 1:** 下载`java-mysql`
>可以从Mysql官方[【下载地址】](https://dev.mysql.com/downloads/file/?id=476197)进行下载解压，只需要其中的两个文件，按下面的目录结构存放就可以了
>**Step 2:** 准备中文字体库
这个可以从身边现成的windows机器上直接压缩拷贝过来就行了，windows下的字体存放在`C:\Windows\Fonts`,然后按下面的目录结构存放就可以了，注意这个压缩包需要和我下面目录的一直，不然需要自行更改`Dockerfile`文件,还有这个压缩包应该是解压完后是`Fonts/字体`这样的结构。

- 构建的目录结构
```bash
├── chinese-win.tar.gz
├── Dockerfile
├── entrypoint.sh
├── java-mysql
    ├── mysql-connector-java-5.1.46-bin.jar
    └── mysql-connector-java-5.1.46.jar
```

- 构建文件及启动脚本
主构建文件`Dockerfile`如下
```bash
FROM anapsix/alpine-java:8_jdk
LABEL "Author":"arvon2014@gmail.com" \
      "Date":"2018-04-11"
ENV RUN_USER  daemon
ENV RUN_GROUP daemon
ENV CONFLUENCE_HOME /var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL_DIR   /opt/atlassian/confluence
#
VOLUME ["${CONFLUENCE_HOME}"]
#
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
ADD chinese-win.tar.gz  /usr/share/fonts/
#RUN fc-cache -fv
#ADD atlassian-confluence-6.8.1.tar.gz $CONFLUENCE_INSTALL_DIR/
RUN chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR}/ \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME}/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
#    && sed -i -e '/.*-Dconfluence.context.path=.*/a\CATALINA_OPTS="-Dconfluence.document.conversion.fontpath=/usr/share/fonts/Fonts/ ${CATALINA_OPTS}"' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8090"/port="8090" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml
COPY entrypoint.sh              /entrypoint.sh
COPY java-mysql/mysql-connector-java-5.1.46.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46.jar
COPY java-mysql/mysql-connector-java-5.1.46-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46-bin.jar
#
RUN chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR}/
#
CMD ["/entrypoint.sh", "-fg"]
ENTRYPOINT ["/sbin/tini", "--"]
#
#CMD tail -f /entrypoint.sh
```
启动脚本`entrypoint.sh`如下
```bash
#!/bin/bash
set -euo pipefail
# Setup Catalina Opts
: ${CATALINA_CONNECTOR_PROXYNAME:=}
: ${CATALINA_CONNECTOR_PROXYPORT:=}
: ${CATALINA_CONNECTOR_SCHEME:=http}
: ${CATALINA_CONNECTOR_SECURE:=false}
: ${CATALINA_OPTS:=}
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyName=${CATALINA_CONNECTOR_PROXYNAME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyPort=${CATALINA_CONNECTOR_PROXYPORT}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorScheme=${CATALINA_CONNECTOR_SCHEME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorSecure=${CATALINA_CONNECTOR_SECURE}"
export CATALINA_OPTS
# Start Confluence as the correct user
if [ "${UID}" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${RUN_USER}:${RUN_GROUP}, then downgrade permission to ${RUN_USER}"
    PERMISSIONS_SIGNATURE=$(stat -c "%u:%U:%a" "${CONFLUENCE_HOME}")
    EXPECTED_PERMISSIONS=$(id -u ${RUN_USER}):${RUN_USER}:700
    if [ "${PERMISSIONS_SIGNATURE}" != "${EXPECTED_PERMISSIONS}" ]; then
        chmod -R 700 "${CONFLUENCE_HOME}" &&
            chown -R "${RUN_USER}:${RUN_GROUP}" "${CONFLUENCE_HOME}"
    fi
    # Now drop privileges
    exec su -s /bin/bash "${RUN_USER}" -c "$CONFLUENCE_INSTALL_DIR/bin/start-confluence.sh $@"
else
    exec "$CONFLUENCE_INSTALL_DIR/bin/start-confluence.sh" "$@"
fi
```

- 构建镜像
```bash
ls #进入dockerfile同级目录
docker build -t confluence-oracle-jdk:v6.8.1 . --no-cache #构建镜像，这个需要一点时间，建议使用Tmux
docker images #查看镜像
```

#### 启动Confluence

主要问题一般会出在构建阶段，如果启动失败可以尝试注释`Dockerfile`的启动命令，然后进入容器手动调试
```bash
docker run -v /data/confluence:/var/atlassian/application-data/confluence --name="confluence" -d -p 8090:8090 -p 8091:8091 confluence-oracle-jdk:v6.8.1 #调试期间可以加上 --rm参数
#Manage Confluence
docker ps
docker exec -it confluence /bin/bash
docker stop confluence
docker start confluence
docker logs confluence
docker logs -f confluence
```
容器启动后跟Jira一样检查端口和防火墙配置,确认没问题后，在浏览器访问`http://host_address:8090`跟着提示安装，**注意**在web界面连接数据库的时候需要选择`String`模式，然后按照如下参数填写,如果没来得及修改，可以在`/data/confluence/confluence.cfg.xml`这个配置里修改重启。另外如需链接Jira在最后根据提示选择就可以了，别的就没啥了。
```bash
jdbc:mysql://host_address:3306/confluence?sessionVariables=tx_isolation='READ-COMMITTED'&useSSL=false&useUnicode=true&characterEncoding=utf8
# Answer：https://confluence.atlassian.com/confkb/confluence-fails-to-start-and-throws-mysql-session-isolation-level-repeatable-read-is-no-longer-supported-error-241568536.html
```

### 数据备份

奉上一个拙劣的脚本，还能使就懒的改了,对了在非`Amazon Linux`上，传S3记得装`pip install awscli --upgrade`
```bash
#* * 3 * * sh /data/arvon/scripts
ipaddr='10.0.1.7'
username='backup_user'
password='yourpasswd'
dest_dir='/data/mysql_data_bak'
###
function dump_db(){
all_area=`echo "show databases" | mysql -h${ipaddr} -u${username} -p${password} |egrep -v "information_schema|mysql|performance_schema|Database|sys"`
mkdir ${dest_dir}/`date +%F` -p
for area in $all_area;do
    mysqldump -h${ipaddr} -u${username} -p${password} --default-character-set=utf8 --comments=FALSE --tables --no-create-info=FALSE --add-drop-table=TRUE --no-data=FALSE ${area}  >${dest_dir}/`date +%F`/`date +%F`_${area}.sql
    cd ${dest_dir}/`date +%F`  && tar czvf `date +%F`_${area}.sql.tar.gz `date +%F`_${area}.sql && rm -rf `date +%F`_${area}.sql
    echo "[`date +%F_%R`] [INFO] Now the `date +%F`_${area}.sql have been backuped" >> /var/log/mysql_back.log
done
}
function load_db(){
#usage:load_db 2017-05-23
time_want=$1
mysql -h${ipaddr} -u${username} -p${password} --default-character-set=utf8 --execute="DROP DATABASE IF EXISTS  ${area}";
mysql -h${ipaddr} -u${username} -p${password} --default-character-set=utf8 --execute="CREATE DATABASE IF NOT EXISTS  ${area} DEFAULT CHARACTER SET utf8";
mysql -h${ipaddr} -u${username} -p${password} --default-character-set=utf8 --database= ${area} <${dest_dir}/${time_want}_${area}.sql;
}
function upload_s3(){
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
aws --region=cn-northwest-1 s3 cp  /data/mysql_data_bak/`date +%F`  s3://itbackups/confluence-jira-mysql/`date +%F`  --recursive
}

dump_db
upload_s3
#load_db 2017-05-23
```
