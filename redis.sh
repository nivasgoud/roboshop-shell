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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LogFile

Validate $? "Installing redis repo file"

dnf module enable redis:remi-6.2 -y &>> $LogFile

Validate $? "Enabling redis 6.2 from package stream"

dnf install redis -y &>> $LogFile

Validate $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

Validate $? "Replaced with public access"

systemctl enable redis 

Validate $? "to start redis permanently whenever host got restarted"

systemctl start redis &>> $LogFile

Validate $? "Started Redis Cache Database"