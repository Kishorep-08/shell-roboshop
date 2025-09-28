#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo "$0" | awk -F. '{print$1}')
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MYSQL_HOST=mysql.kishore-p.space
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
        echo -e "$R Error $N: $2 got failed" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2......$G Success $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Installing python"

################ Creating System user ################

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating System user"
else
    echo -e "User already exists ...... $Y Skipping $N" | tee -a $LOG_FILE
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

############ Application code setup ############
curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip  /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "unzipping code"

pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Creating payment service "

systemctl daemon-reload

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting payment service"

