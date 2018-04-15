---
title: Gitlab搭建使用记录
date: 2018-04-14 20:54:00
tags: [版本控制,Shell]
---
Gitlab有迁移升级的打算，尝试下新版本（10.6.4)顺带记录一下过程。我这里尝试两种安装方法，一种是Omnibus包安装（官方推荐），另一种会尝试Docker。
操作之前看一把架构图,图片来自官方哈
![1](http://oqfz9mxmq.bkt.clouddn.com/20180413-gitlab-1.jpeg)

<!--more-->

### 使用Omnibus安装（centos7）

- 基础环境配置
```bash
yum install -y curl policycoreutils-python openssh-server
systemctl enable sshd
systemctl start sshd
```

- IPtables配置（不需要的话直接跳过）
```bash
systemctl start firewalld
firewall-cmd --permanent --add-service=http
systemctl reload firewalld
```

- 邮件服务器安装及配置（如有自己的邮件服务器跳过postfix安装，直接配置SMTM服务器即可）
具体配置就不写了，可以参照廖雪峰的[【文章】](https://www.liaoxuefeng.com/article/00137387674890099a71c0400504765b89a5fac65728976000)
```bash
yum install postfix
systemctl enable postfix
sed -i 's/^inet_interfaces = .*/inet_interfaces = 127.0.0.1/g' /etc/postfix/main.cf
#if no sed will report an error like "fatal: parameter inet_interfaces: no local interface found for"
systemctl start postfix
#config   #使用已有的邮件服务器，这个不写了
#useradd -m -s /bin/bash arvon #创建邮件用户
#echo "123456" | passwd --stdin arvon #设置密码
#telnet localhost 25 #测试主机邮件端口
```

#### 安装gitlab

**添加Gitlab安装源及安装gitlab**
既然选择了gitlab一部分原因也是因为开源，所以用免费的CE就行，关于[【CE和EE的区别】](https://www.gitlab.com.cn/products/)另外可以使用国内的镜像源来提升安装速度，如[【清华镜像站】](https://mirror.tuna.tsinghua.edu.cn/help/gitlab-ce/)
```bash
#curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
#EXTERNAL_URL="http://193.112.135.23" yum install -y gitlab-ee #IP地址填写期望访问的URL地址
EXTERNAL_URL="http://193.112.135.23" yum install -y gitlab-ce
```
这里安装的版本`gitlab-ce-10.6.4-ce.0.el7.x86_64`
在RHEL/CentOS上可以新建yum源`/etc/yum.repos.d/gitlab-ce.repo`
```xml
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```
安装完成后自己就启动了，十分智能，WEB服务端口默认是`80`，还是看看安装在哪了都有哪些路径
```
[root@VM_0_11_centos gitlab]# rpm -qa |grep  gitlab-ce |xargs rpm -ql |wc -l
81091
[root@VM_0_11_centos gitlab]# rpm -qa |grep  gitlab-ce |xargs rpm -ql |grep /opt/gitlab |wc -l
81090
```
可见装了这么多东西，都在`/opt/gitlab`下

#### 配置gitlab及组件说明

- 配置gitlab
访问`http://193.112.135.23:80/`会提示你重置密码，重置密码后用`root`和你重置后的密码就可以登录了

- Gitlab相关路径
```xml
/opt/gitlab #Gitlab安装位置
/etc/gitlab/gitlab.rb #Gitlab主要配置文件
/var/opt/gitlab/git-data/repositories/ #代码仓库保存位置
/var/opt/gitlab/backups/ #代码仓库备份位置
/var/log/gitlab/ #日志位置
/var/opt/gitlab/postgresql/data/ #postgresql数据及配置目录
/var/opt/gitlab/redis #Redis配置目录
/var/opt/gitlab/gitlab-rails/etc/unicorn.rb  #unicorn配置文件
```

- 服务及进程作用
>- **nginx**
>Web服务器,提供Httpweb浏览管理服务
>- **gitlab-shell**
>处理一些git命令什么的
>- **unicorn**
>Gitlab自身的WEB服务器，Ruby Web Server，托管 GitLab Rails 服务。增加 unicorn 的 workers 数量，可以减少应用的响应时间并提高处理并发请求的能力。对于大部分实例，建议的配置：CPU 核心数 + 1 = unicorn workers 数
>- **gitlab-workhorse**
>轻量级别代理服务器，用来处理大的 HTTP 请求，比如文件上传下载如Git Push/Pull ，其它请求会反向代理到 GitLab Rails 应用，即反向代理给后端的 unicorn
>- **gitaly**
>RPC 服务，执行 gitlab-shell 和 gitloab-workhorse 的 git 操作，并向 GitLab web 应用程序提供一个 API，以从 git（例如 title, branches, tags, other meta data）获取属性，并获取 blob（例如 diffs，commits，files）
>- **postgresql**
>使用PostgreSQL必须确认GitLab使用的数据库安装了`pg_trgm`扩展。 这个扩展需要PostgreSQL使用root用户在GitLab每个数据库里面执行 `CREATE EXTENSION pg_trgm;`命令
>- **redis**
>Redis 存储每个客户端的sessions和后台任务队列。Redis需求的存储空间很小, 大约每个用户25kB
>- **sidekiq**
>Sidekiq使用多线程处理后台任务（异步）。这个进程启动的时候会使用整个Rails堆栈（200MB+），但是它会在内存泄漏的情况下增加。一个用户非常活跃的服务器上（10,000个活跃用户），Sidekiq进程会占用1GB+的内存
>- **logrotate**
>日志文件管理

- Gitlab管理命令
```bash
/opt/gitlab/bin/gitlab-ctl status #查看状态
/opt/gitlab/bin/gitlab-ctl stop
/opt/gitlab/bin/gitlab-ctl start
#/opt/gitlab/bin/gitlab-ctl show-config #查看当前配置
/opt/gitlab/bin/gitlab-ctl help #获取命令行帮助
cat /opt/gitlab/version-manifest.json | grep build_version #查看版本
```

- 安装及配置完成
现在可以在gitlab上创建项目、用户及用户组了。之后就可以正常使用了

#### 附邮件配置

在主配置文件`/etc/gitlab/gitlab.rb`如下修改，更详细的配置参考[【官方说明】](https://docs.gitlab.com/omnibus/settings/smtp.html#smtp-settings)
```xml
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.server"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "smtp user"
gitlab_rails['smtp_password'] = "smtp password"
gitlab_rails['smtp_domain'] = "example.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
# If your SMTP server does not like the default 'From: gitlab@localhost' you
# can change the 'From' with this setting.
gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'
```
修改完成后通过命令`/opt/gitlab/bin/gitlab-ctl reconfigure`使配置生效

### 使用Docker安装Gitlab

按照官网来了一遍，主要注意以下3点,更详细可以参考[【Docker Install Guide地址】](https://docs.gitlab.com/omnibus/docker/)和[【Docker File地址:】 ](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker)
>1. 端口配置，可以参照以下命令，注意不要和宿主机冲突
>2. hostname参数,这个hostname类似手动装的那个配置，会在pull库时候用就是上面显示的那个连接
>3. 客户端再pull代码的时候命令需要改成`git clone ssh://git@host:port/your-project.git`

- 启动命令
```bash
docker run --detach \
    --hostname 12.13.14.13 \
    --publish 443:443 --publish 8080:80 --publish 222:22 \
    --env 'GITLAB_PORT=18080' \
    --env 'GITLAB_SHELL_SSH_PORT=222' \
    --env 'GITLAB_SSH_PORT=222' \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

- 客户端连接命令
```bash
git clone ssh://git@12.13.14.13:222/root/arvon-test.git
touch demo.txt
git add .
git config --global user.email "arvon@gourds.com"
git config --global user.name "arvon"
git commit -m 'add test'
git push origin master #推远端
cat .git/config #查看git配置
git pull #拉代码
```

### Gitlab备份还原（CentOS7）

**关于备份的官方说明**
>"You can only restore a backup to exactly the same version and type (CE/EE) of GitLab on which it was created. The best way to migrate your repositories from one server to another is through backup restore."


**注意点**
>1. 如果是通过源码安装，需要确保自己安装了rsync服务,可以通过`yum install -y rsync`安装
>2. 备份配置可以在主配置文件`/etc/gitlab/gitlab.rb`中`Backup Settings`选项下修改，一般不需修改
>3. 推荐备份`/etc/gitlab`这个目录，如果使用了`two-factor`至少要备份`/etc/gitlab/gitlab-secrets.json`
>4. 注意`8.17`之后的版本，这个版本[【详情描述】](https://docs.gitlab.com/ce/raketasks/backup_restore.html#backup-strategy-option)引入了新的备份策略`COPY`可以解决备份过程中由于数据快速变化而导致备份过程失败这个问题，可以通过`gitlab-rake gitlab:backup:create STRATEGY=copy`在执行备份的时候指定，不过需要占用额外的1X磁盘。
>5. 如果想有选择的备份Project，可以参照[【官方说明】](https://docs.gitlab.com/ce/raketasks/backup_restore.html#excluding-specific-directories-from-the-backup)配置
>6. 使用AWS服务的话推荐使用S3，可以参照[【官方说明】](https://docs.gitlab.com/ce/raketasks/backup_restore.html#uploading-backups-to-a-remote-cloud-storage)配置

#### 配置备份还原

**配置backup**
```bash
sh -c 'umask 0077; tar -cf $(date "+etc-gitlab-%s.tar") -C / etc/gitlab'
```

**配置restore**
```bash
mv /etc/gitlab /etc/gitlab.$(date +%s)
tar -xf etc-gitlab-1399948539.tar -C /
/usr/bin/gitlab-ctl reconfigure  #重新加载配置
```

#### 数据备份还原

**数据备份**
```bash
#如果使用Omnibus安装方式
/opt/gitlab/bin/gitlab-rake gitlab:backup:create
#如果使用源码安装的话
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```
**另外**如果使用AWS的服务需要将备份传S3那么可以直接再Gitlab的主配置文件进行配置，如何配置可以参照[【官方说明】](https://docs.gitlab.com/ce/raketasks/backup_restore.html#using-amazon-s3),里面的`bucket`参数只能写bucket的名字，不能有二级目录

**数据还原**
将备份的数据文件放的需要还原的Gitlab主机上的备份目录
```
[root@VM_0_11_centos gitlab]# ls /var/opt/gitlab/backups/
1523625192_2018_04_13_10.6.4_gitlab_backup.tar
```
然后停止连接数据库的进程
```bash
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
gitlab-ctl status
```
然后执行还原命令
```bash
# This command will overwrite the contents of your GitLab database!
gitlab-rake gitlab:backup:restore BACKUP=1523625192_2018_04_13_10.6.4
#还原使用备份文件名除去"_gitlab_backup.tar"这个部分
```
如果有必要还原`/etc/gitlab/gitlab-secrets.json`最后重启Gitlab
```bash
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true
```
还原完成
另如因还原需要降级
>`Gitlab`历史版本地址[【戳这里】](https://packages.gitlab.com/gitlab/gitlab-ce)
>`yum downgrade "下载的旧版本的文件名"`

**备份脚本**[【获取脚本】](https://github.com/Gourds/daily-scripts/blob/master/shell-scripts/backup_gitlab.sh)
```bash
#!/usr/bin/env sh
RETVAL=0
: ${ConfigBakDir:=/data/backup/gitlab}
function backup_config(){
    [ -d /etc/gitlab ] || exit 4
    [ -d ${ConfigBakDir} ] || mkdir -p ${ConfigBakDir}
    sh -c "cd ${ConfigBakDir} && umask 0077 && tar -cf $(date "+etc-gitlab-%s_%Y_%m_%d.tar") -C / etc/gitlab"
    RETVAL=$?
}
function backup_data(){
    [ -f `which gitlab-rake` ] || exit 5
    gitlab-rake gitlab:backup:create
    RETVAL=$?
}
function restore_data(){
    [ -f `which gitlab-rake` ] && [ -f `which gitlab-ctl` ] || exit 6
    if [[ `gitlab-ctl status unicorn |awk '{print $1}' |sed 's/://'` != 'run' ]] && [[ `gitlab-ctl status sidekiq |awk '{print $1}' |sed 's/://'` != 'run' ]];then
        msg='''Usage: gitlab-rake gitlab:backup:restore BACKUP=1523625192_2018_04_13_10.6.4'''
        echo $msg
    else
        echo 'Please make sure unicorn and sidekiq process have stop ! Now exit'
        exit 7
    fi
}
case $1 in
    bak-etc)
    backup_config
    ;;
    bak-data)
    backup_data
    ;;
    bak)
    backup_config
    backup_data
    ;;
    restore)
    restore_data
    ;;
    *)
    echo $"Usage: $0 {bak|bak-etc|bak-data|restore}"
    RETVAL=2
esac
exit $RETVAL
```

**存储策略**
如果想定期删除一段时间前的备份文件，官方配置里已经有现成可配置的地方，在主配置文件`/etc/gitlab/gitlab.rb`中通过设置以下参数后，然后重新加载配置即可
```bash
# limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```

**计划任务**
```bash
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1
#The CRON=1 environment setting tells the backup script to suppress all progress output if there are no errors.This is recommended to reduce cron spam.
```



### Docker情况下的备份还原


```bash
# backup config
docker exec -t <your container name> /bin/sh -c 'umask 0077; tar cfz /secret/gitlab/backups/$(date "+etc-gitlab-\%s.tgz") -C / etc/gitlab'
# backup data
docker exec -t <your container name> gitlab-rake gitlab:backup:create
```

### 参考文档

[【Gitlab官网】](https://docs.gitlab.com.cn/ce/administration/index.html)
[【官方配置备份还原说明】](https://docs.gitlab.com/omnibus/settings/backups.html)
[【官方数据备份还原说明】](https://docs.gitlab.com/ce/raketasks/backup_restore.html#creating-a-backup-of-the-gitlab-system)
[【备份还原说明】](https://gitlab.com/help/raketasks/backup_restore.md)
[【备份脚本说明】](https://github.com/sund/auto-gitlab-backup)
[【mallux的Blog】](https://blog.mallux.me/2017/02/27/gitlab/)
