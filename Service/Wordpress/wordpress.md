



```bash
version: '3.1'

services:

  wordpress:
    image: wordpress
    restart: always
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress2019
      WORDPRESS_DB_NAME: wordpress
    networks:
      - "wordpressnet"

  db:
    image: mysql:5.7.23
    restart: always
    container_name: "mysql_jms"
    environment:
      MYSQL_ROOT_PASSWORD: helloworld
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress2019
    volumes:
      - /data/data/frank_guo/wordpress/mysql:/var/lib/mysql
      - ./my.cnf:/etc/mysql/conf.d/custom.cnf
    networks:
      - "wordpressnet"
```
