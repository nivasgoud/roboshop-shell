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

dnf install python36 gcc python3-devel -y

Validate $? "In installing Python 3.6"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop
    Validate $? "Creating the user roboshop"
    exit 1
else
   echo "User roboshop is already exists skipping in creation"
fi

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

Validate $? "Downloading the payment application code from remote s3 bucket"

cd /app 

unzip -o /tmp/payment.zip

Validate $? "Extracting the payment code to application directory"

cd /app 

pip3.6 install -r requirements.txt

Validate $? "Installing payment application using pip installer"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service

Validate $? "In copying the payment service to systemd configuration"

systemctl daemon-reload

Validate $? "In reloading the systemd process to update the payment service configuration"

systemctl enable payment 

Validate $? "In enabling the payment service permanently to start during server start"

systemctl start payment

Validate $? "In starting the payment service"