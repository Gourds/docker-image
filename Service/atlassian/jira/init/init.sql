CREATE DATABASE jira_db CHARACTER SET utf8 COLLATE utf8_bin;
grant ALL PRIVILEGES on jira_db.* to jira_user@"%" Identified by "jirapass";
flush privileges;
