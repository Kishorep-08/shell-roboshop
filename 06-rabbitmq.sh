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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "Creating roboshop user in rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"&>> $LOG_FILE
VALIDATE $? "Setting password for roboshop user"


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e  "Script Executed in $Y $TOTAL_TIME seconds $N"