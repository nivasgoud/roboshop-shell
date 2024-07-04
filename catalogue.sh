#/bin/bash
ID=$(id -u)
TimeStamp=$(date +%F#%H::%M::%S)
LogFile=$0-$TimeStamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"

MONGODB_SERVER_IPADDRESS=0.0.0.0

Validate(){
    if [ $1 -ne 0 ]
    then
        echo "Failed..$2"
        exit 1
    else
        echo "Success..$2"
    fi
}

if [ $ID -ne 0 ]
then
    echo " Run the script with sudo user"
    exit 1
else
    echo "You have right privelages"
fi

dnf module disable nodejs -y &>> $LogFile

Validate $? "Disabling NodeJS"

dnf module enable nodejs:18 -y &>> $LogFile

Validate $? "Enabling NodeJS18"

dnf install nodejs -y &>> $LogFile

Validate $? "In Installing NodeJS18"

useradd roboshop

mkdir /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

Validate $? "Downloading the Catalogue application Code"

cd /app 

unzip /tmp/catalogue.zip

cd /app

npm install &>> $LogFile

cp catalogue.service /etc/systemd/system/catalogue.service

Validate $? "Copying to the system folder"

systemctl daemon-reload &>> $LogFile

Validate $? "In reloading the systemd daemon process ID"

systemctl enable catalogue &>> $LogFile

Validate $? "In enabling the catalogue service as permanent"

systemctl start catalogue  &>> $LogFile

Validate $? "In starting the catalogue service"

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y &>> $LogFile

Validate $? "Installed Mongodb client to load the schema data in to MongoDB"

mongo --host $MONGODB_SERVER_IPADDRESS </app/schema/catalogue.js

Validate $? "In Loading the catalogue data into MongoDB"

