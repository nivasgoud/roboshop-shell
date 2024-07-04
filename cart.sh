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

dnf module disable nodejs -y

Validate $? "Disabling nodejs prior version to 18"

dnf module enable nodejs:18 -y

Validate $? "Enabling NodeJS 18 version"

dnf install nodejs -y

Validate $? "Installing NodeJS 18 version"

id roboshop

if [ $id -ne 0 ]
then
    useradd roboshop
    Validate $? "Creating the user roboshop"
    exit 1
else
    echo "User roboshop already exists"
fi

mkdir -p /app

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

Validate $? "Downloading the cart application code from remote s3 storage"

cd /app 

unzip -o /tmp/cart.zip

Validate $? "In extracting the cart application into app directory"

cd /app

npm install 

Validate $? "Installing the cart NodeJS application using npm tool"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

Validate $? "Copied the cart service config to system to start the cart application"

systemctl daemon-reload

Validate $? "Reloading the systemd configurations with cart service"

systemctl enable cart 

Validate $? "Enabling permanent service start application in instance"

systemctl start cart

Validate $? "Starting the cart service application"