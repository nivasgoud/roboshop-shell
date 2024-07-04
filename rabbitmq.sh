#!/bin/bash

ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=/tmp/$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash

Validate $? "In running Yum repo script provided by the client"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

Validate $? "In running the Yum repo script for Rabbit MQ"

dnf install rabbitmq-server -y 

Validate $? "In Installing RabbitMQ-Server"

systemctl enable rabbitmq-server 

Validate $? "In enabling permanent service during the server start"

systemctl start rabbitmq-server 

Validate $? "In starting the rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123

Validate $? "In creating user for rabbitmq login"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

Validate $? "In setting permissions"
