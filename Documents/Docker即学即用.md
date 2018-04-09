---
title: 即学即用Docker读书笔记
date: 2018-04-09 19:35:00
tags: [Docker,学习笔记]
---

[《即学即用Docker》](https://book.douban.com/subject/26700648/)这本书在手里也有很长时间了，现在补上读书笔记。感觉这书非常适合入门，对没有docker基础的推荐阅读。目前手里还有《Docker经典实例》和《Kubernetes权威指南》等待我的临幸，有时间就争取先来一遍。
**容器是什么**
容器不同于VMware或者Xen这种虚拟化系统，是一种完全不同的虚拟化方式，所有容器共用一个内核，而且容器之间的隔离完全在这个内核中实现，这叫做操作系统虚拟化。
容器是自成一体的执行环境，所有容器共用宿主机的内核，而且系统中的容器之间是相互隔离的（不强制一定要隔离）。
容器的最大优势是高效使用资源，因为不用为了使用各个独立的功能而运行整个操作系统。因为容器共用一个内核，所以隔离执行的任务和底层硬件之间少了一层交互。运行在容器里面的进程只需要使用很少一部分内核，进程在特权模式下进出处理器时不会再调出一个完整的内核。
<!--more-->

### 命令相关

``` bash
docker version
#查看docker版本信息
docker info
#查看服务器信息
docker run == docker create + docker start
#docker run 是两条命令的聚合
docker create --name="test-service" ubuntu:latest
#指定容器名称
docker run -d --name labels -l author=arvon -l tester=Mo  ubuntu:latest sleep 100
docker ps -a -f label=deployer=arvon
docker inspect 509531d14f70
#指定容器标签、通过ps可以组合标签过滤、通过inspect可以查看所有标注
docker run --rm -it ubuntu:latest /bin/bash
#启动一个没有任何特殊配置的容器，rm参数表示退出容器时会删除容器,i参数表示交互，t参数表示启动一个伪tty
docker run -it --hostname="test.example.com" ubuntu:latest /bin/bash
#启动一个主机名为test.example.com的容器
docker run --it --dns=8.8.8.8 --dns=8.8.4.4 --dns-search=example.com --dns-search=example2.com ubuntu:latest /bin/bash
#启动一个指定dns的容器，默认会使用宿主机resolv.conf
docker run --it --mac-address="xx.xx.xx.xx.xx.xx" ubuntu:latest /bin/bash
#指定MAC地址，默认会自己计算，尽量别使用这个玩意
docker run --it -v /mnt/data1:/data ubuntu:latest /bin/bash
#挂载本地data1到容器/data，不需要容器内预先存在挂载点，会自己创建
docker stop -t 25 mysql
#强制停止myql容器，适用于无法正常停止的情况，发送SIGTERM信号，如果25s后容易还没有停止，就发送SIGKILL信号，强制清除容器
docker kill mysql
#清除容器，跟Linux的Kill命令一样
docker kill --signal=USR1 mysql
#发送UNIX信号对容器进行管理
docker ps
#查看运行中的容器
docker ps -a
#查看所有容器
docker rm mysql
#删除容器
docker images
#列出镜像
docker rmi mysql:0.1
#删除镜像
docker inspect container_id
#查看容器详细信息
docker exec -it mysql /bin/bash
#进入运行中的容器mysql
docker stats
#查看docker容器的运行状态，类似top
```

### 关于资源配额

Docker使用Linux内核中cgroup功能控制Docker容器的可用资源，执行docker create时可以直接配置分配给容器的CPU和内存量。
使用`docker info`可以查看当前docker是否有支持，如不支持需要在内核启动时指定相应的参数，一般来说都是支持的。
**CPU配额**：cpu配额类似nice，可以看做是对任务优先级的调整
``` bash
docker run -it progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#创建一个容器包含2个cpu密集型1个io密集型和两个占用内存的进程，压测
docker run -it  -c 512  progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#理论上cpu的load会是上一条命令的一般，使用-c参数指定cpu配额，类似nice，默认配额为1024
docker run -it  -c 512  --cpuset=0 progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#创建一个容器--cpuset参数指定在特定cpu上运行，没有这个cpu的话容器启动会报错
```
**内存配额**：内存限额是硬性限制，设定限额后容器内存不足会像普通进程一样使用swap
``` bash
docker run -it -m 512m progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#创建一个内存限额512M交换分区限额512的容器,使用-m参数
docker run -it -m 512m --memory-swap= 1024m progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#创建一个内存限额512M交换分区限额1024M的容器，使用--memory-swap单独制定swap，设置为-1则禁用交换空间
```
**权限限制：**类似Linux中的ulimit
``` bash
docker run -d --default-ulimit nofile=50:150 --default-ulimit nproc=10:20
#告诉docker守护进程每个容器可以打开150个文件，运行20个进程，为硬性限制
```

### 容器自动重启
**自动重启**：共有三个参数可选
- `no`: 容器退出不重启
- `always`: 不管容器退出码是什么都重启
- `on-failure:3`: 在容器退出码不是零的情况下尝试重启3次，3次依然失败的话就放弃重启

``` bash
docker run --restart=on-failure:3 progrium/stress --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 120s
#启动一个容器容器退出后尝试重启3次
```

### 暂停容器

**暂停容器：** 暂停功能是通过cgroup的冻结程序实现的，暂停容器时容器的内存等状态还在，只是无法提供服务，类似于快照的状态
``` bash
docker pause mysql
#暂停容器
dcoker unpause mysql
#恢复容器，运行时间从恢复的这一时刻计算
```

### 镜像存储

**公共注册**
- Docker Hub
- Quay.io

**私有注册**
- docker-registry #支持了S3和Azure
- CoreOS Enterprose Registry
- Docker Hub Enterprise

### 容器命名空间

**nsenter工具**：Linux内核中的util-linux包里有个nsenter工具，用于进入linux的命令空间，因此可以通过这个工具进入运行在宿主机上的容器（不管这个容器是否有响应）
**注意：**nsenter命令只能在宿主机上使用，并且需要把容器里顶层进程的PID传递给nsenter，看起来很麻烦的说，不过jpetazzo/nsenter容器有一个方便的脚本docker—enter会让这个过程简单不少
``` bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
#安装nsenter工具到/usr/local/bin目录
docker inspect d2c3ce380095 --format {{.State.Pid}}
#查看容器的pid
nsenter --target 30302 --mount --uts --ipc --net --pid
#进入pid为30302的命名空间
docker-enter 12b57becb46b /bin/bash
#使用docker-enter命令相当于上面两条命令的合并，简单多了，主要用这个
```

### Docker日志

在Linux对log处理通常有两种方式，一种是将日志写入本地文件，一种是写入内核缓冲区然后使用dmesg命令读取。而docker提供的方式是使用`docker logs`

``` bash
docker logs d2c3ce380095
#查看容器的全部log
docker logs -f d2c3ce380095
#阻塞方式查看log，与Linux中tail -f基本相同
```

Docker中容器的默认log存储在`/var/lib/docker/containers/<your-contain-id>/`这个目录下，记录的格式如下
```
{"log":"[7] 04-08 13:10:00,633 INFO total_commands_processed:3906596\r\n","stream":"stdout","time":"2018-04-08T13:10:00.848081205Z"}
#log:实际log，stream：log的输出，time：docker守护进程收到log的时间
```

**Tips：**目前大规模部署docker时处理日志的最佳方式是把容器的log直接发送给系统日志syslog，使用这种方式构建容器时需要指定`--log-driver=syslog`选项

目前解决log问题的思路：
- 让应用直接把日志发给系统日志
- 在容器里使用进程管理器转发日志（如systemd、upstart、supervisor等）
- 在容器中运行一个日志中继器，包装容器的stdout和stderr
- 在服务器中把docker的JSON日志转发给系统日志

值得实践的方式：
- supervisor插件 ==> [github地址【python编写】](https://github.com/newrelic/supervisor-remote-logging)
- spotify发布的中继器 ==> [github地址【go编写】](https://github.com/spotify/syslog-redirector)
- 使用logspout集中处理日志 ==> [github地址【go编写】](https://github.com/gliderlabs/logspout)

### 监控docker

Docker提供简单的命令来查看一些比较基础的信息，`docker stats`以及`docker events`,推荐使用docker的API来对容器进行信息采集和监控，而且结合一些可视化的图表工具会更直观一点。
**可视化工具推荐**：商业化的就不推荐了只弄开源的东西
- cAdvisor 【google开发的】[项目地址](https://github.com/google/cadvisor)
- Nagios

**使用cAdvisor**
``` bash
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:v0.24.1
```
访问`http://localhost:8080`即可查看web页面，很不错。另外还提供了REST API，可以通过这个api在自己的监控系统中轻松的查询众多详细信息,另外我这里使用0.24.1的原因是使用latest版本报错了，现在暂时不想折腾这个，这个0.24.1版本可用。

### 部署工具介绍

**关于部署**：部署应该满足两个条件
- 可以重复执行，每次部署都做相同的事情
- 定义应用的配置，保证每次部署都使用相同的配置

**工具的类别**：
- 用于编排和部署，（替代Capistrano、Fabric、shell等）
这种工具基本上是在多个Docker守护进程之间采用异步方式协调应用的配置和部署过程，代表有：
>- New Relic开发的Centurion[【Github项目地址】](https://github.com/newrelic/centurion)
>- Spotify开发的Helios[【Github项目地址】](https://github.com/spotify/helios)
>- Ansible为Docker提供的工具[【官网地址】](https://www.ansible.com/integrations/containers/docker)

- 用于自动调度和集群管理，代替手工操作
使用分布式调度程序管理Docker，将整个网络看作是一个大电脑，通过定义一些策略，指明如何运行应用，不需要人为具体操作底层细节。
>- 最早出现在公众视野的是CroeOS退出的Fleet[【Github项目地址】](https://github.com/coreos/fleet)
>- 目前最火的是Google推出的Kubernetes[【官网地址】](https://kubernetes.io/)
>- 最成熟的是由加州伯克利分校研究人员编写的Mesos[【官网地址】](http://mesos.apache.org/)
>- Docker公司原生的Swarm[【Github项目地址】](https://github.com/docker/swarm)

### 命名空间

虽然容器和系统中其他进程公用一个内核，但看起来每个容器都有自己的文件系统、网络接口、硬盘和其他资源，其实这是一种抽象的处理，在内核中实现这种抽象的方法是使用命名空间，在命名空间中容器认为自己独占所有资源。命名空间实现的是视觉隔离，而且很多情况下实现的是功能的隔离，目的是让容器看起来像是运行在同一个内核之上的虚拟机。目前Linux内核实现的6种命名空间容器都有，如下：

- 挂载命名空间
>Docker主要使用这个命名空间让容器看起来有自己完整的文件系统，挂载命名空间与chroot实现类似，不过隔离性更好，而且深入到内核中，以至于`mount`和`unmount`系统调用都在命名空间中操作

- UTS命名空间
>UTS命名空间作用在内核上，利用UNIX分时系统给各个容器指定主机名和域名

- IPC命名空间
>这种命名空间把容器的System V进程间通信。消息队列和POSIX消息队列与主机的消息队列隔离开。IPC命名空间负责的进程间通信不是由文件系统资源实现的，而是由共享内存和信号量实现的，而且相互通信的进程在同一容器里。

- PID命名空间
>每个命名空间里的进程都有相对该命名空间而言唯一的PID，如在容器中看的ps和宿主机上看到的ps输出就是完全不同的

- 网络命名空间
>这种命名空间为容器提供专用的网络设备和端口等。`docker ps`命令输出会显示容器绑定的端口，这些端口分别在两个命名空间中。如容器里nginx一般会绑定80端口，其实这个端口在容器所属网络命名空间的网络接口上。这种命名空间让容器看起来像是拥有完全独立的网络栈。

- 用户命名空间
>用户命名空间把容器里的用户和用户组与Docker宿主机的用户和用户组隔离开。在容器里和宿主机上看到用户ID不同的原因就是因为有这个用户命名空间。

**补充说明之前的一个例子：**命名空间就是之前可以进入一个已经退出的容器的原因，以下命令就是进入这个容器的所有命名空间

```bash
nsenter --target $PID --mount --uts --ipc --net --pid
```

### 关于容器安全性

容器只是运行在Docker宿主机中的一个进程。容器实现的隔离性没有虚拟机实现的强。容器的性能之所以高其中的一个原因就是与宿主机公用一个内核，但是内核中的一切并不都会放在命名空间中，这就是人们认为Docker容器存在的安全隐患之一也是最严重的一个。

- 在容器中以非Root用户运行应用
>容器里的root用户其实是系统的root用户，不过容器里的root用户有些额外的限制，禁止了`/proc`和`/sys`文件系统中最危险的部分

- 使用`--privileged=true`选项赋予容器更大的权限（尽量不要用这个更不安全）
>有时候容器需要一些更多的权限去做一些事情，如挂载存储、修改网络配置、新建UNIX设备等。不过建议不是必须不要这么做，可以通过`--cap-add=NET_ADMIN`和`--cap-drop`结合起来赋予尽可能准确且尽可能少的权限。

- SELinux、AppArmor
>SELinux最初由美国国家安全局开发，目的是精确控制安全。AppArmor的目标与SELinux类似，不过比SELinux简单。Docker会根据所用平台对两者支持其一。这个根据实际需求再研究吧，也算是比较重的一块了。

- Docker守护进程安全性
>保证Docker安全性的基本做法与很多其他网络守护进程一样：加密通信、认证用户。另外最好不要让docker能直接访问互联网。如果需要在网络外部访问Docker宿主机，应该考虑使用VPN或SSH隧道做跳转。

### 容器化平台的12要素

- 代码基
>只把一份代码基纳入版本控制

- 依赖
>明确声明所需的依赖，并把依赖与周围的环境隔离开

- 配置
>在环境变量中存储配置，不在代码基的文件中存储。在创建Dockerfile的时候需要的配置使用环境变量的方式进行传递，在执行容器创建的时候再通过`-e`参数传入。如让容器使用类似这种配置`process.env.ENVIRONMNET`

- 后端服务
>把后端服务当做是附加资源。要在应用中实现优雅的降级方案，而且不能假定资源（如文件系统存储空间）始终可用

- 构建、发布、运行
>要严格区分构建和运行步骤，遵守这个流程，每一步自成一体，相互独立有利于缩短反馈循环，尽快解决部署过程中出现的问题

- 进程
>以一个或多个无状态的进程运行应用。任何共享数据都要从有状态的后端存储中获取，这么做便于重复部署应用实例，而且不会丢失重要的会话数据。应用不能长时间保存状态，保存状态的时间最好比单次请求并返回响应的时间短，而且越短越好。如果必须保存状态，最好使用远程数据存储，如Redis、PostgreSQL、Memcache，甚至是Amazon的S3服务

- 端口绑定
>通过绑定的端口提供服务

- 并发
>通过进程模型实现横向扩展

- 易用
>加快启动速度，使用优雅的方式关闭，尽量提升健壮性，Docker关闭或者清除容器会向容器发送标准的UNIX信号，因此容器化的应用可以检测这些信号，然后采取合适的方式优雅的关闭服务

- 开发环境和生产环境同等重要
>尽量保持开发环境，过度环境和生产环境一致

- 日志
>把日志当作事件流，服务本身不应该关心如何转发或者存储日志。事件不能缓冲，要通过流的形式写入标准输出，交给宿主进程处理。

- 管理进程
>使用一次性进程执行管理任务。主要观点是绝不要使用随意编写出来的计划任务脚本执行管理和维护任务，而要把这些脚本和相关的功能保存在应用的代码基里。不需要在应用的每个实例中运行，需要执行维护作业时，可以启动一个专门的容器，只执行指定的作业，执行完成后就结束生命周期。

### 响应式宣言

2013年7月，Typesafe公司CTO jonas和几个贡献者完善了这个宣言，根据这个宣言定义，`响应式系统`应具备四个特点：反应迅速、恢复力强、灵活性高、消息驱动
