FROM python:3.6-alpine3.6 as builder

RUN apk --no-cache add build-base tar musl-utils openssl-dev
RUN pip3 install setuptools cx_Freeze==6.0b1 requests-aws4auth boto3

COPY . .
RUN ln -s /lib/libc.musl-x86_64.so.1 ldd
RUN ln -s /lib /lib64
RUN pip3 install -r requirements.txt
RUN python3 setup.py build_exe

FROM alpine:3.6
ENV CURATOR_CONFIG_HOME /data/curator-config
RUN apk --no-cache upgrade && apk --no-cache add ca-certificates  && \
    mkdir -p "${CURATOR_CONFIG_HOME}"
COPY --from=builder build/exe.linux-x86_64-3.6 /curator/
VOLUME ["${CURATOR_CONFIG_HOME}"]
USER root:root


ENTRYPOINT ["/curator/curator"]
