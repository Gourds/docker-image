---
title: Bitbucket实践
date: 2018-06-09 12:38:00
tags: [版本控制,Docker]
---

**前言：**之前使用了Atlassian公司的Confluence和Jira，现在新项目考虑使用Bitbucket做代码仓库，这里记录一下调研实践过程。由于之前的服务是使用docker进行部署的，所以Bitbucket也决定使用docker的方式进行部署。

除了下面的，docker设置连接Postgresql的时候需要由于是采用link的方式，所以可以在bitbucket容器中直接使用主机名也就是postgresql进行连接postgresql服务

<!--more-->

### 安装

使用Docker的方式，由于Bitbucket基于性能的考虑不推荐使用mysql([参考](https://confluence.atlassian.com/bitbucketserver/connecting-bitbucket-server-to-mysql-776640382.html))，所以最后根据推荐决定使用PostgreSQL，以下是编写的docker-compose,可以在[【Github】](https://github.com/Gourds/docker-image/tree/master/Service/bitbucket)进行查看和建议。

>2021-02-20 补充
*破解*
需要先打镜像再更改docker-compose中的镜像为新build的镜像重新启动即可

```sh
#下载解压crack包
wget https://gitee.com/pengzhile/atlassian-agent/attach_files/283101/download/atlassian-agent-v1.2.3.tar.gz
tar xvf atlassian-agent-v1.2.3.tar.gz
#打镜像
docker build  -t bitbucket:v7.9.1_crack .
#生成lisense
java -jar atlassian-agent.jar -p bitbucket -m aaa@bbb.com -n my_name -o https://crack.io -s BWQB-T57C-UJTD-HHHH
```



### 备份及还原

`Bitbucket`的备份主要包括两部分
- 家目录：包括仓库数据、日志、插件等，具体参考[【官方说明】](https://confluence.atlassian.com/bitbucketserver/bitbucket-server-home-directory-776640890.html)
- 数据库：`which contains data about pull requests, comments, users, groups, permissions, and so on.`

关于备份官方提供了3种方式


|类型|不停机备份|自定义备份|客户端备份|
|---|---|---|
|概述|使用内部一致性数据库快照和数据块级别文件系统快照进行不停机备份|使用增量备份及云供应商的快照功能|使用外部程序锁定bitbucker服务器实例，并以独立于供应商的格式备份其整个主目录和数据库。使用简单但不适用与高可用环境|
|高可用|不影响服务|不可用时间短，只需要几秒钟短暂锁定存储桶就可以创建一致的快照|不可用时间长。bitbucket在整个备份过程中被锁定，这可能需要几分钟或更长时间，特别是在大型组织中|
|版本支持|Bitbucket 4.8+|Bitbucket 4.0+ && Stash 2.12+|Bitbucket 4.0+ && Stash2.7+|
|文档|[【DOC】](https://confluence.atlassian.com/bitbucketserver/using-bitbucket-zero-downtime-backup-829920023.html)|[【DOC】](https://confluence.atlassian.com/bitbucketserver/using-bitbucket-server-diy-backup-776640056.html)|[【DOC】](https://confluence.atlassian.com/bitbucketserver/using-the-bitbucket-server-backup-client-776640064.html)|

我这里选择使用官方推荐的第三种方法进行备份还原，具体文档参照[【这里】](https://github.com/Gourds/docker-image/tree/master/Service/bitbucket/backup-restore)





### 参考文献

[【官方Docker参考】](https://bitbucket.org/atlassian/docker-atlassian-bitbucket-server)
[【官方备份说明】](https://confluence.atlassian.com/bitbucketserver/data-recovery-and-backups-776640050.html)
