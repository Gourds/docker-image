Jenkins测试

### 配置测试git

```
yum install git
useradd git
mkdir -p /data/go-project;cd /data/go-project
git init go-test
cat 'hello' > README.md
git add README.md
git commit -m "test"
chown git.git /data/go-project
#git clone git@172.21.0.11:/data/go-project/go-test
```

### 安装Jenkins

```
mkdir /data/jenkins
#https://jenkins.io/download/
rpm -ivh https://pkg.jenkins.io/redhat-stable/jenkins-2.107.3-1.1.noarch.rpm
yum install java-1.8.0-openjdk
/etc/init.d/jenkins start
#http://192.144.171.175:8080  设置，安装推荐插件
```


### 从git获取grvvoy脚本


### 测试Groovy自动生成简单任务

```
#从远程代码仓库获取代码编译打包
pip install awscli
```

### 搭建groovy测试环境

```
docker run -it --rm --name s1 ss:v1 bash
```


### 插件

- Groovy
- Environment Injector Plugin
- Ansible
- Active Choices
- Dynamic Extended Choice Parameter



### 参考

https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin
https://juejin.im/entry/59bf6376f265da066b394310
https://www.w3cschool.cn/groovy/
