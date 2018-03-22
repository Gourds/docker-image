From centos:7
USER root
ADD ardb_0.9.4_v2.tar.gz /mnt/
RUN yum install -y gcc gcc-c++ automake make zlib-devel which bzip2-devel
ENV storage_engine=rocksdb
RUN cd /mnt/ardb/ &&\
    make &&\
    mkdir /opt/ardb/bin/ -p  &&\
    sed -i 's@^home.*@home /opt/ardb/@' /mnt/ardb/ardb.conf &&\
    sed -i 's@^thread-pool-size.*@thread-pool-size 1@' /mnt/ardb/ardb.conf &&\
    cp /mnt/ardb/src/ardb-*  /opt/ardb/bin/ &&\
    cp /mnt/ardb/ardb.conf /etc/ardb.conf  &&\
    rm -rf /mnt/ardb/
RUN echo "/opt/ardb/bin/ardb-server /etc/ardb.conf" >> /opt/ardb/start.sh &&\
    echo "tail -f /opt/ardb/log/ardb-server.log" >> /opt/ardb/start.sh
WORKDIR /opt/
CMD ["/usr/bin/sh", "/opt/ardb/start.sh"]
#ENTRYPOINT ["/usr/bin/sh", "/opt/ardb/start.sh"]
