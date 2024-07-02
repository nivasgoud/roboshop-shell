#!/bin/bash
ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=/tmp/$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Started executing the script" &>> $LogFile

Validate(){
    if [ $1 -ne 0 ]
    then
       echo "Failed...$2"
       exit 1
    else
      echo "Success...$2"
    fi
}

if [ $ID -ne 0 ]
then
    echo "Run the script with root user"
    exit 1
else
    echo "You have sudo access to root"
fi 

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LogFile

Validate $? "In Copying the repo"

dnf install mongodb-org -y &>> $LogFile

Validate $? "In Installing the mongodb"

systemctl enable mongod &>> $LogFile

Validate $? "In enabling mongod"

systemctl start mongod

Validate $? "In starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod &>> $LogFile

Validate $? "In Restarting mongod"
