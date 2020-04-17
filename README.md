### Personal Docker guide

Include some docker file and Some related documents


### How to make better use of Dockerfile



### Base image

```
alpine:小巧、安全
https://hub.docker.com/_/alpine
```

### Local Registry

```
#Run Registries
docker run -d -p 5000:5000 -v /data/myregistry:/var/lib/registry --name hub registry:2

#Test Registries
docker tag alpine:3.9 10.0.1.221:5000/alpine
docker push 10.0.1.221:5000/alpine
http://10.0.1.221:5000/v2/_catalog

# Run Web UI
docker run --name hub_ui \
  -d \
  -e ENV_DOCKER_REGISTRY_HOST=10.0.1.221 \
  -e ENV_DOCKER_REGISTRY_PORT=5000 \
  -p 38080:80 \
  konradkleine/docker-registry-frontend:v2

#Web UI
http://10.0.1.221:38080/repositories/

#Clinet Set Insecure Registries
docker pull 10.0.1.221:5000/alpine:latest
```

### 问题

```
#go alpine timezone
FROM alpine:3.9
RUN apk update && apk add --no-cache tzdata
ENV TZ Asia/Shanghai
```
