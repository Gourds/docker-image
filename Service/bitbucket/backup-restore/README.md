---
title: Bitbucket备份还原
date: 2018-06-12 12:40:00
tags: [运维工具,云服务]
---

### 使用指南

选择官方推荐的客户端模式进行备份还原，由于是使用Docker方式进行的部署，所以在备份还原中存在两点问题。
>1. 备份程序需要访问bitbucket服务器的家目录
>2. 备份程序需要能直接访问Postgresql的网络

综上所以决定备份采用docker进行备份还原操作（使备份的docker容器可以访问bitbucket容器挂载卷和postgresql的网络）

- 可指定的参数
以下参数可以再启动容器的时候通过`-e`参数指定进行覆盖
```
ENV BITBUCKET_S_HOME /srv/docker/bitbucket/app-data/
ENV BITBUCKET_S_USER YourUserName
ENV BITBUCKET_S_PASSWORD YourPassword
ENV BITBUCKET_S_URL http://yourURL/
ENV BACKUP_S_DIR /data
```

- 备份Bitbucket
备份时直接执行以下命令即可，执行完成后容器会自动销毁，备份文件保存在`/tmp/test-bak`目录下，可以在启动容器时自行更改
``` bash
docker run  --rm -d --name bit1 -v /tmp/test-bak:/data  -e BITBUCKET_S_HOME=/var/atlassian/application-data/bitbucket --link=bitbucket_postgresql_1 --volumes-from bitbucket_bitbucket_1  --net bitbucket_default bitbucket-backup-restore:v1
```

- 还原Bitbucket
**注意：**由于还原操作需要指定要还原的备份文件，且需要其他条件（停止Bitbucket服务、还原目录为空），所以这里是提供执行环境，进入环境后手动进行还原操作,步骤如下
>Step1. 启动并进入还原容器
>Step2. 修改确认配置文件
>Step3. 进行还原
>Step4. 修改还原目录的权限
>Step5. 启动Bitbucket服务

``` bash
#Step1
docker run --rm -it --name bit1 -v /tmp/test-bak:/data  -e BITBUCKET_S_HOME=/var/atlassian/application-data/bitbucket --link=bitbucket_postgresql_1 --volumes-from bitbucket_bitbucket_1  --net bitbucket_default bitbucket-backup-restore:v1  /bin/bash
#Step2
sh /entrypoint.sh
#Step3
java -jar bitbucket-restore-client.jar /Your/BackupData/Path
#Step4
chown -R daemon.daemon $BITBUCKET_S_HOME
```


### 制作镜像

- 下载客户端包
``` bash
wget https://maven.atlassian.com/content/groups/public/com/atlassian/bitbucket/server/backup/bitbucket-backup-distribution/3.3.4/bitbucket-backup-distribution-3.3.4.zip
```

- 构建目录
下载好包后按照以下目录结构进行构建
``` bash
#目录结构
.
├── bitbucket-backup-distribution-3.3.4.zip
├── Dockerfile
└── entrypoint.sh
#构建命令
docker build -t bitbucket-backup-restore:v1 .
```

### 验证命令

- 查看Postgresql数据库
```bash
psql -h hostname -p 5432 -U bitbucket bitbucket_production -W
#进入数据库
\dt
#列出数据库所有表
\c
#切换数据库名
```
