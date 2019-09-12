
Docker方式启动
```xml
version: '2'
services:
  phabricator:
    restart: always
    ports:
     - "62443:443"
     - "80:80"
     - "62022:22"
    volumes:
     - /srv/docker/phabricator/repos:/srv/repo
     - /srv/docker/phabricator/static:/srv/static
     - /srv/docker/phabricator/conf:/srv/phabricator/phabricator/conf
     - /srv/docker/phabricator/extensions:/srv/phabricator/phabricator/src/extensions
     - /srv/docker/phabricator/pha-keys:/hostkeys
    depends_on:
     - mysql
    links:
     - mysql
    environment:
     - MYSQL_HOST=mysql
     - MYSQL_USER=root
     - MYSQL_PASS=phabricator
     - PHABRICATOR_REPOSITORY_PATH=/repos
     - PHABRICATOR_HOST=wiki2.taiyouxi.net
     - PHABRICATOR_HOST_KEYS_PATH=/hostkeys/persisted
    image: redpointgames/phabricator
  mysql:
    restart: always
    volumes:
     - /srv/docker/phabricator-db/mysql:/var/lib/mysql
    image: mysql:5.7.14
    environment:
     - MYSQL_ROOT_PASSWORD=phabricator
    command: [
      "--character-set-server=utf8mb4",
      "--max-allowed-packet=33554432",
      "--sql_mode=STRICT_ALL_TABLES",
      "--innodb_buffer_pool_size=1600M"
      ]
```
