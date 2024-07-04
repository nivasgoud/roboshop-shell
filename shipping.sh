#!/bin/bash

ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=/tmp/$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MYSQL_SERVER_IPADDRESS=

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

dnf install maven -y

Validate $? "Installing Maven"

id roboshop

if [ $id -ne 0 ]
then
    useradd roboshop
    Validate $? "In creating the user roboshop"
    exit 1
else
    echo "user roboshop already exists skipping the task"
fi

mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip

Validate $? "Downloading the shipping code from remote s3 bucket"

cd /app

unzip -o /tmp/shipping.zip

Validate $? "Extracting the shipping code to application directory"

cd /app

mvn clean package

Validate $? "Installing the shipping application using maven tool"

mv target/shipping-1.0.jar shipping.jar

Validate $? "In moving the shipping application from targets to app directory"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service

Validate $? "In copying the shipping service to systemd services"

systemctl daemon-reload

Validate $? "In reloading the systemd configuration"

systemctl enable shipping 

Validate $? "In enabling the shipping service permanently to auto-start during server restart"

systemctl start shipping

Validate $? "In starting the shipping service"

dnf install mysql -y

Validate $? "Installing mysql for loading shipping schema data"

mysql -h $MYSQL_SERVER_IPADDRESS -uroot -pRoboShop@1 < /app/schema/shipping.sql 

Validate $? "In loading the shipping data to mysql"

systemctl restart shipping

Validate $? "In restarting the shipping service because it functions/dependent once the shipping schema is loaded to MYSQL DB"