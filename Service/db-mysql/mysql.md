

### 安装Myql

使用官方镜像直接启动容器即可。不过使用Jira和Confluence时需要添加几个mysql启动配置,具体可参考[【Mysql镜像说明】](https://hub.docker.com/_/mysql/)，`packet`及`log_file_size`参数为应用要求防止大文件无法存储，`utf8`是为了支持中文
```bash
docker run --name mysql -p 3306:3306 -v /data/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=yourpasswd -idt mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_bin --max_allowed_packet=512M --innodb_log_file_size=2GB
#docker run -it --rm docker.io/mysql/mysql-server --verbose --help
docker ps -a #查看容器状态
docker exec -it mysql /bin/bash #进入容器，PS由于mysql启动后root用户监听localhost所以创建Database时需要进入容器内部
```
