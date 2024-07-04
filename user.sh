#!/bin/bash

ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=/tmp/$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_SERVER_IPADDRESS=
exec &>$LogFile

echo "Started executing the script" &>> $LogFile


Validate(){
    if [ $1 -ne 0 ]
    then
        echo "Failed..in..$2"
        exit 1
    else
        echo "Success..in..$2"
    fi
}

if [ $ID -ne 0 ]
then
    echo "Execute the script with sudo access"
    exit 1
else
    echo "You have root access"
fi

dnf module disable nodejs -y

Validate $? "Disabling Nodejs"

dnf module enable nodejs:18 -y

Validate $? "Enabled the NodeJS 18 version"

dnf install nodejs -y

Validate $? "Installing NodeJs"

id roboshop

if [ $? -ne 0 ]
then
   useradd roboshop
   Validate $? "Creating User roboshop"
   exit 1
else
   echo "User roboshop already exists"
fi

mkdir -p /app

Validate $? "Creating application directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

Validate $? "Downloading the user application code from remote s3"

cd /app 

unzip -o /tmp/user.zip

Validate $? "Extracted the User code to application directory"

cd /app 

npm install 

Validate $? "Installing the User NodeJS application"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

Validate $? "Copying the user application service start file to systemd location"

systemctl daemon-reload

Validate $? "Reloading the systemctl configurations"

systemctl enable user 

Validate $? "User application start permanently whenever instance got restarted"

systemctl start user

Validate $? "Starting the user application"

cp  /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

Validate $? "copying the mongo repo"

dnf install mongodb-org-shell -y

Validate $? "Installing the mongodb"

mongo --host $MONGODB_SERVER_IPADDRESS </app/schema/user.js

Validate $? "Importing the user schema and tables in to MongoDB"


