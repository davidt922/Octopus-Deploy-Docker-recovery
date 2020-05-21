#!/bin/bash


db_container_name="ci_db_octopus_1"
octopus_container_name="octopus"
master_key=$(find ./backupFiles/ -name "*Master_Key*" -printf "%f\n")
echo "Warning: your Master Key is:"
cat ./backupFiles/$master_key
echo "  "
echo "Set to .env file and reestart the octopus containers before continue"
sleep 15

echo "Restore Octopus config..."
octopus_repository=$(find ./backupFiles/ -name "*backup_Octopus_repository*" -printf "%f\n")
octopus_artifacts=$(find ./backupFiles/ -name "*backup_Octopus_artifacts*" -printf "%f\n")
octopus_taskLogs=$(find ./backupFiles/ -name "*backup_Octopus_taskLogs*" -printf "%f\n")
octopus_cache=$(find ./backupFiles/ -name "*backup_Octopus_cache*" -printf "%f\n")

docker run --name octopus_config_restore --rm --volumes-from $octopus_container_name -v $(pwd)/backupFiles:/backup ubuntu bash -c "cd /repository && tar xvf /backup/$octopus_repository --strip 1"
docker run --name octopus_config_restore --rm --volumes-from $octopus_container_name -v $(pwd)/backupFiles:/backup ubuntu bash -c "cd /artifacts && tar xvf /backup/$octopus_artifacts --strip 1"
docker run --name octopus_config_restore --rm --volumes-from $octopus_container_name -v $(pwd)/backupFiles:/backup ubuntu bash -c "cd /taskLogs && tar xvf /backup/$octopus_taskLogs --strip 1"
docker run --name octopus_config_restore --rm --volumes-from $octopus_container_name -v $(pwd)/backupFiles:/backup ubuntu bash -c "cd /cache && tar xvf /backup/$octopus_cache --strip 1"


echo "Restore Database ..."
db_octopus=$(find ./backupFiles/ -name "*db_OctopusDeploy*" -printf "%f\n")
db_master=$(find ./backupFiles/ -name "*db_master*" -printf "%f\n")
db_model=$(find ./backupFiles/ -name "*db_model*" -printf "%f\n")
db_msdb=$(find ./backupFiles/ -name "*db_msdb*" -printf "%f\n")
db_temp=$(find ./backupFiles/ -name "*db_tempdb*" -printf "%f\n")


sudo docker exec -it $db_container_name mkdir /var/opt/mssql/backup
docker cp "backupFiles/$db_octopus" $db_container_name:/var/opt/mssql/backup/
docker cp "backupFiles/$db_master" $db_container_name:/var/opt/mssql/backup/
docker cp "backupFiles/$db_model" $db_container_name:/var/opt/mssql/backup/
docker cp "backupFiles/$db_msdb" $db_container_name:/var/opt/mssql/backup/
docker cp "backupFiles/$db_temp" $db_container_name:/var/opt/mssql/backup/


sudo docker exec -it $db_container_name /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'N0tS3cr3t!' -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$db_octopus'"  | tr -s ' ' | cut -d ' ' -f 1-2
sudo docker exec -it $db_container_name /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'N0tS3cr3t!' -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$db_master'"  | tr -s ' ' | cut -d ' ' -f 1-2
sudo docker exec -it $db_container_name /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'N0tS3cr3t!' -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$db_model'"  | tr -s ' ' | cut -d ' ' -f 1-2
sudo docker exec -it $db_container_name /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'N0tS3cr3t!' -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$db_msdb'"  | tr -s ' ' | cut -d ' ' -f 1-2
sudo docker exec -it $db_container_name /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'N0tS3cr3t!' -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$db_temp'"  | tr -s ' ' | cut -d ' ' -f 1-2

docker restart $db_container_name
docker restart $octopus_container_name
