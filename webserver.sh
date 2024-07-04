#!/bin/bash
ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=$0-$TimeStamp.log
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

dnf install nginx -y &>> $LogFile

Validate $? "Installing Nginx webserver"

systemctl enable nginx &>> $LogFile

Validate $? "Permanent enabling"

systemctl start nginx &>> $LogFile

Validate $? "Started Nginx"

rm -rf /usr/share/nginx/html/*

Validate $? "Removed the nginx default data"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

Validate $? "Dowloading the nginx roboshop static application data"

cd /usr/share/nginx/html

Validate $? "Changed the directory to nginx deployment location"

unzip -o /tmp/web.zip

Validate $? "Deployed the downloaded roboshop static code to deployment location"

cp roboshop.conf /etc/nginx/default.d/roboshop.conf 

systemctl restart nginx &>> $LogFile

Validate $? "Restarting Nginx Server"