
#step
mkdir /local/data && chmod -R 777 /local/data
docker run --name ardb -d -v /home/arvon/docker_ardb/ardb-data:/opt/ardb-data/ ardb:v0.9.4_v2
docker stop ardb
docker rm --volumes ardb
