#!/bin/bash
## jumperserver install
###############################################################################
#Author: arvon
#Email:arvon2014@gmail.com
#Blog: http://blog.arvon.top/
#Date:
#Filename:
#Revision: 1.0
#License: GPL
#Description: record install course In fact it's not a script just record
#Notes:
###############################################################################

#ENV:centos7.2.1511
'''
【报错Failed to get D-Bus connection: Operation not permitted解决]
https://seven.centos.org/2015/12/fixing-centos-7-systemd-conflicts-with-docker/
'''
##
yum install -y gcc make zlib-devel
yum install -y docker
docker pull centos:7.2.1511

#init myql
'''
mysqladmin -uroot -p password "Wwdfsad2"
grant ALL PRIVILEGES  on *.* to ser@"%" Identified by "jumapds3";
flush privileges;
CREATE DATABASE IF NOT EXISTS jumpserver DEFAULT CHARACTER SET utf8;
'''
docker run --privileged -it -d -v /sys/fs/cgroup:/sys/fs/cgroup -p 80:8000 -p 2222:2222 --name jumpserver jumpserver:3.0.3 /sbin/init
docker run --privileged -it -d -e "container=docker" -v /sys/fs/cgroup:/sys/fs/cgroup -p 80:8000 -p 2222:2222 --name jumpserver jumpserver:3.0.4 /sbin/init
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

'''
docker exec -it jumpserver /bin/bash
/usr/local/python3/bin/python3 -m venv py3
source py3/bin/activate
cd /opt/jumpserver/jumpserver-0.3.3
./service.sh restart
./service.sh status
'''

'''
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
Could not parse metalink https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=i386 error was
##https://www.centos.org/forums/viewtopic.php?f=13&t=49828
yum remove epel-release --disablerepo=epel\*
yum install epel-release
'''
