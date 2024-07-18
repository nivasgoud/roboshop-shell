#!/bin/bash

IMAGEID=ami-0b4f379183e5706b9
SECURITY_GROUP=sg-0db659996615c588e
SUBNET=subnet-0ac3df5627209a411
INSTANCES=("mongodb" "user" "catalogue" "cart" "redis" "mysql" "shipping" "rabbitmq" "payment" "dispatch" "web")
ZONEID=Z011790315XPHAM9K6BCC
DOMAIN_NAME=nivasdevops.online

for i in "${INSTANCES[@]}"

do

    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    
    then
        INSTANCE_TYPE=t3.small
    else
        INSTANCE_TYPE=t2.micro
    fi
    
    IPADDRESS=$(aws ec2 run-instances --image-id $IMAGEID  --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET --associate-public-ip-address --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query "Instances[0].PrivateIpAddress" --output text)

    echo "$i ==:: $IPADDRESS "


    #Route 53 Configuration
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IPADDRESS'"
            }]
        }
        }]
    }'
 
    
done