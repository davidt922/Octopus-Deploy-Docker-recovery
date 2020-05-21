 #!/bin/bash

 if [ "$#" -ne 1 ]; then
     echo "Missing target folder: Default /root/Backups/Octopus"
     TGT_FOLDER="/root/Backups/Octopus"
 else
     TGT_FOLDER=$1
 fi

 sudo mkdir -p $TGT_FOLDER


#Global vars
db_container_name="ci_db_octopus_1"
octopus_container_name="octopus"


 echo "Back-up Octopus..."
 docker run --name postgres_data_backup --rm --volumes-from $octopus_container_name -v $TGT_FOLDER:/backup ubuntu tar cvf /backup/backup_Octopus_repository_`date +%d-%m-%Y"_"%H_%M_%S`.tar /repository
 docker run --name postgres_data_backup --rm --volumes-from $octopus_container_name -v $TGT_FOLDER:/backup ubuntu tar cvf /backup/backup_Octopus_artifacts_`date +%d-%m-%Y"_"%H_%M_%S`.tar /artifacts
 docker run --name postgres_data_backup --rm --volumes-from $octopus_container_name -v $TGT_FOLDER:/backup ubuntu tar cvf /backup/backup_Octopus_taskLogs_`date +%d-%m-%Y"_"%H_%M_%S`.tar /taskLogs
 docker run --name postgres_data_backup --rm --volumes-from $octopus_container_name -v $TGT_FOLDER:/backup ubuntu tar cvf /backup/backup_Octopus_cache_`date +%d-%m-%Y"_"%H_%M_%S`.tar /cache

 echo "Back-up Octopus database..."
 docker exec -it ci_db_octopus_1 /opt/mssql-tools/bin/sqlcmd    -S localhost -U SA -P 'N0tS3cr3t!'    -Q "BACKUP DATABASE [OctopusDeploy] TO DISK = N'/var/opt/mssql/backup/db_OctopusDeploy.bak' WITH NOFORMAT, NOINIT, NAME = 'Octopus-Deploy-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
 docker exec -it ci_db_octopus_1 /opt/mssql-tools/bin/sqlcmd    -S localhost -U SA -P 'N0tS3cr3t!'    -Q "BACKUP DATABASE [master] TO DISK = N'/var/opt/mssql/backup/db_master.bak' WITH NOFORMAT, NOINIT, NAME = 'master-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
 docker exec -it ci_db_octopus_1 /opt/mssql-tools/bin/sqlcmd    -S localhost -U SA -P 'N0tS3cr3t!'    -Q "BACKUP DATABASE [model] TO DISK = N'/var/opt/mssql/backup/db_model.bak' WITH NOFORMAT, NOINIT, NAME = 'model-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
 docker exec -it ci_db_octopus_1 /opt/mssql-tools/bin/sqlcmd    -S localhost -U SA -P 'N0tS3cr3t!'    -Q "BACKUP DATABASE [msdb] TO DISK = N'/var/opt/mssql/backup/db_msdb.bak' WITH NOFORMAT, NOINIT, NAME = 'msdb-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

echo "Copy Database backup to backup folder"
sudo docker cp $db_container_name:/var/opt/mssql/backup/db_OctopusDeploy.bak $TGT_FOLDER
sudo docker cp $db_container_name:/var/opt/mssql/backup/db_master.bak $TGT_FOLDER
sudo docker cp $db_container_name:/var/opt/mssql/backup/db_model.bak $TGT_FOLDER
sudo docker cp $db_container_name:/var/opt/mssql/backup/db_msdb.bak $TGT_FOLDER

echo "Get Master Key..."
docker exec -it $octopus_container_name cat /home/octopus/.octopus/OctopusServer/Server/Server.linux.config | grep -o -P '(?<=<set key="Octopus.Storage.MasterKey">).*(?=</set>)' > Master_Key

sudo docker cp $octopus_container_name:/home/octopus/.octopus/OctopusServer/Server/Master_Key $TGT_FOLDER
