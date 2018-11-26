From centos:6
USER root
ADD https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tar.xz /opt/Python-3.6.0.tar.xz
#COPY Python-3.6.0.tar.xz /opt/Python-3.6.0.tar.xz
RUN cd /opt/ &&\
    yum install -y wget xz gcc automake zlib-devel tar openssh-server &&\
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config &&\
    sed -i 's/^session    required     pam_loginuid.so/#&/' /etc/pam.d/sshd &&\
    chkconfig --add sshd &&\
    tar -xvf Python-3.6.0.tar.xz &&\
    cd /opt/Python-3.6.0 &&\
    ./configure --prefix=/usr/local/python3 &&\
    make && make install
RUN rm -rf /opt/Python-3.6.0.tar.xz &&\
    rm -rf /opt/Python-3.6.0 &&\
    /usr/local/python3/bin/python3 -m venv py3
RUN cd /opt/ &&\
    yum install -y unzip &&\
    wget https://github.com/jumpserver/jumpserver/archive/0.3.3.zip &&\
    unzip 0.3.3.zip &&\
    rm -rf /opt/0.3.3.zip
ADD https://bootstrap.pypa.io/get-pip.py /opt/get-pip.py
RUN cd /opt/ &&\
    python get-pip.py &&\
    rm /opt/get-pip.py
WORKDIR /opt/
