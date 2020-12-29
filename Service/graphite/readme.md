mkdir /opt/graphite/{graphite-config,graphite-storage,graphite-custom,graphite-nginx-config,graphite-stastsd-config,graphite-logrotate-config,graphite-log,graphite-redis}


# test
 while true; do echo -n "example:$((RANDOM % 100))|c" | nc -w 1 -u 127.0.0.1 8125; done
