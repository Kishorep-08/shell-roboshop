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
MONGODB_HOST=mongodb.kishore-p.space
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

######## NodeJS Setup #########
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodesjs:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

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
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip  /tmp/user.zip &>> $LOG_FILE
VALIDATE $? "unzipping code"

npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies"

############ user service setup ############
cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Creating user service"

systemctl daemon-reload

systemctl enable user &>> $LOG_FILE
VALIDATE $? "Enabling user service"

systemctl start user &>> $LOG_FILE
VALIDATE $? "Starting user service"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e  "Script Executed in $Y $TOTAL_TIME seconds $N"
