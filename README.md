# Backup and Restore for Octopus Deploy

This are two very basic scripts that allows to backup and reestore the Octopus Deploy that is runing in dockers in a unix systemsystem for both, the Octopus deploy instance and its attached database.

Its use is very straightforward:

To Backup:

1. open the backupOctopus.sh file and modify the variables octopus_container_name and db_container_name for the names of your octopus instance and its attached database

2. Execute the script  `sh backupOctopus.sh`, by default it will generate the backup files in `/root/Backups/Octopus`but if you want to save the files in another route you just have to indicated after the name of the file `sh backupOctopus.sh /backups/Octopus` In case the folder does not exist it will be created automatically

To Restore:

1. First of all you have to find the file `Master_key` in the reestored files and copy its value

2. Start an Octopus instance using this master key [for more information click here](https://hub.docker.com/r/octopusdeploy/octopusdeploy)

3. Insert all the backup files inside the backupFiles folder

4. Execute the script `sh restoreOctopus.sh` and let the magic happens
