#!/bin/bash

# Set the path to the jump server
jump_server=<jump_server_ip_or_hostname>

# Set the MySQL user and password
mysql_user=<mysql_username>
mysql_password=<mysql_password>

# Set the name of the database to backup
database_name=<database_name>

# Set the path to store the backup file
backup_path=<path_to_store_backup_file>

# Get the current date and time
current_date_time=$(date +%Y%m%d-%H%M%S)

# Set the backup file name using the current date and time
backup_file=${database_name}_${current_date_time}.sql

# Connect to the jump server and perform the MySQL dump
ssh $jump_server "mysqldump -u $mysql_user -p$mysql_password $database_name > $backup_path/$backup_file" &

# Wait for the MySQL dump to complete
wait $!

# Check if the MySQL dump was successful
if [ $? -eq 0 ]; then
    # Download the backup file from the jump server
    scp $jump_server:$backup_path/$backup_file . &

    # Wait for the backup file to be downloaded
    wait $!

    # Check if the backup file was successfully downloaded
    if [ -f $backup_file ]; then
        # Calculate the MD5 checksum of the backup file on the jump server
        remote_checksum=$(ssh $jump_server "md5sum $backup_path/$backup_file" | awk '{print $1}')

        # Calculate the MD5 checksum of the backup file on the local machine
        local_checksum=$(md5sum $backup_file | awk '{print $1}')

        # Compare the MD5 checksums
        if [ "$remote_checksum" == "$local_checksum" ]; then
            # Stop the MySQL server and drain current connections
            mysqladmin -u $mysql_user -p$mysql_password shutdown &

            # Wait for the MySQL server to stop and current connections to be drained
            wait $!

            # Restore the database with the previous backup
            mysql -u $mysql_user -p$mysql_password $database_name < $backup_file &

            # Wait for the database restore to complete
            wait $!

            # Check if the database restore was successful
            if [ $? -eq 0 ]; then
                echo "Successfully restored database from backup."
            else
                echo "Error restoring database from backup."
            fi
        else
            echo "Error: MD5 checksums do not match. Backup file may be corrupted."
        fi
    else
        echo "Error downloading backup file from jump server."
    fi
else
    echo "Error creating MySQL dump
