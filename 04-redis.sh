#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo "$0" | awk -F. '{print$1}')
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]
then
    echo -e "$R Error $N: Install with root privileges" | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...... $R failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2......$G Success $N" | tee -a $LOG_FILE
    fi
}

########## Redis Installation & Setup ###########
dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling default redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing default redis"

sed -i 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing all remote connections"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling  redis"
systemctl start redis &>> $LOG_FILE
VALIDATE $? "Starting redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo "Script executed in $TOTAL_TIME seconds"