#!/bin/bash

CHECK_OUT_DIR="/home/anant/temp"
APP_DIR="/opt/php_apps"
TIMESTAMP="`date +%s`"
DATE="`date -d @$TIMESTAMP --rfc-2822`"
BACKUP_DIR="/home/anant/backup"
REDIS_MEM_6379="`ps aux | grep "redis-server\ \*\:6379" | awk '{ print $6}'`"
DATABASE_NAME="demo_data"
USER="root"
PASS=" "
MYSQLFILE="$DATABASE_NAME-$DATE.sql"
MYSQL_DIR="/home/data/my_sql_backup"
My_Sql_Dump() {

mysqldump --opt --user=$USER --password=$PASS $DATABASE_NAME > $MYSQLFILE

tar -czf backup$DATE.tar.gz $MYSQLFILE

s3cmd put backup$DATE.tar.gz s3://bucket_name
Status=$?

if [ {$Status} = 0 ]
then
	echo "File succesfully uploaded"
else	

	echo "File failed to upload to s3"
	
fi

}

Check_Out_In_Temp() 
{
if [[ $EUID -eq 0 ]]; then
        echo "Please run this script as non-root user!"
        exit 1
else
	mkdir -p $CHECK_OUT_DIR
        echo "Checking out from git repository to temp"
        cd $CHECK_OUT_DIR

        git clone $url
        if [ -n "$1" ]; then
            cd $CHECK_OUT_DIR
            git checkout $1
        fi
        echo "Done!"
fi
}

Taking_Backup_Of_Dir() {

        cd $APP_DIR

        if [ -d $APP_DIR ]; then

                echo "Taking Backup of application"
                
		mkdir $BACKUP_DIR_$DATE
                cp -r $APP_DIR $BACKUP_DIR_$date

                echo "Backup done."

                echo "Removing Existing application folder..."

                rm -rf $APP_DIR

                echo "Application folder Removed!"
	
        fi
}

Restarting_Php_App() {

	APP="php7.0-fpm"
	cp  -r  $CHECK_OUT_DIR  $APP_DIR
        echo "Moving to app directory"
	if [ -d $APP_DIR ]; then
	cd $APP_DIR 

        echo "Restarting PHP server"
       
	sudo systemctl restart $APP

        echo "done"
fi

}

Remove_Old_App() {
		
		
	if [ -d $CHECK_OUT_DIR ] then
	echo "File exist in temp Directory"
	rm -rf $CHECK_OUT_DIR
else
	echo "File does not Exists in temp Directory"
fi

}

#If the application is using redis then check whether the redis process exists or not

Redis_Check(){

	if [ -n $REDIS_MEM_6379 ] 
	then
        echo "Redis process exists"
else
        echo "Redis process does not exists"
fi

}
My_Sql_Dump
Check_Out_In_Temp
Taking_Backup_Of_Dir
Restarting_Php_App
Remove_Old_App
Redis_Check


