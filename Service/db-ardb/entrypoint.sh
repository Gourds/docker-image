#!/bin/sh
sed -i -e "s@^home.*@home ${ARDB_HOME}@;\
           s@^data-dir.*@data-dir ${ARDB_DATA}@;\
           s@^daemonize.*@daemonize no@;\
           s@^logfile.*@logfile stdout@;\
           s@^thread-pool-size.*@thread-pool-size ${THEAD_POOL_SIZE}@"  ${ARDB_HOME}/ardb/ardb.conf

${ARDB_HOME}/ardb/src/ardb-server ${ARDB_HOME}/ardb/ardb.conf
