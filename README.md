# mysqldumper
This script assumes that you have already set up passwordless ssh access to the jump server. You will need to replace the placeholders <jump_server_ip_or_hostname>, <mysql_username>, <mysql_password>, <database_name>, <backup_file_name>, and <path_to_store_backup_file> with the appropriate values for your setup.

The script first connects to the jump server and performs a MySQL dump of the specified database. It then downloads the backup file from the jump server and restores the database with the previous backup.

