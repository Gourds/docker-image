#!/bin/bash
cd $BITBUCKET_BACKUP_HOME$BITBUCKET_BACKUP_VERSION
sed -i "s@^#bitbucket.home=@bitbucket.home=${BITBUCKET_S_HOME}@" backup-config.properties
sed -i "s@^#bitbucket.user=@bitbucket.user=${BITBUCKET_S_USER}@" backup-config.properties
sed -i "s@^#bitbucket.password=@bitbucket.password=${BITBUCKET_S_PASSWORD}@" backup-config.properties
sed -i "s@^#bitbucket.baseUrl=@bitbucket.baseUrl=${BITBUCKET_S_URL}@" backup-config.properties
sed -i "s@^#backup.home=@backup.home=${BACKUP_S_DIR}@" backup-config.properties

# backup
if [ $# -eq 1 ];then
    if [ $1 == 'backup' ];then
        java -jar bitbucket-backup-client.jar
    elif [ $1 == 'restore' ];then
        echo "Command: java -jar bitbucket-restore-client.jar /Your/BackupData/Path"
    else
        echo "Usage: $0  backup|restore"
    fi
else
    echo "Usage: $0  backup|restore"
fi
