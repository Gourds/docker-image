docker run -d --rm --name gourds-nginx \
    -v /data/docker-app/blog-data/static/:/usr/share/nginx/html/static/:ro \
    -v /data/docker-app/wiki-data/dokuwiki/:/usr/share/nginx/html/dokuwiki/:rw \
    -v /data/docker-app/nginx-config/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v /data/docker-app/nginx-config/conf.d/:/etc/nginx/conf.d/:ro \
    -p 80:80 \
    nginx
