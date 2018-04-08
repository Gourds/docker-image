### 即学即用Docker

全书176页
容器不同于VMware或者Xen这种虚拟化系统，是一种完全不同的虚拟化方式，所有容器共用一个内核，而且容器之间的隔离完全在这个内核中实现，这叫做操作系统虚拟化。
容器是自成一体的执行环境，所有容器共用宿主机的内核，而且系统中的容器之间是相互隔离的（不强制一定要隔离）。
容器的最大优势是高效使用资源，因为不用为了使用各个独立的功能而运行整个操作系统。因为容器共用一个内核，所以隔离执行的任务和底层硬件之间少了一层交互。运行在容器里面的进程只需要使用很少一部分内核，进程在特权模式下进出处理器时不会再调出一个完整的内核。


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
