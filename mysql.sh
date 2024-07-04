#!/bin/bash
ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=/tmp/$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MYSQL_PASSWORD=RoboShop@1
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

dnf module disable mysql -y

Validate $? "Disabling mysql version 5.8 as our application run on 5.7"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo

Validate $? "Copying mysql custom repository to yum repository"

dnf install mysql-community-server -y

Validate $? "Installing MySql Community"

systemctl enable mysqld

Validate $? "Enabling mysql service permanently to start during server start"

systemctl start mysqld

Validate $? "Starting mysql service"

mysql_secure_installation --set-root-pass $MYSQL_PASSWORD

Validate $? "In changing the default password to custom password"

