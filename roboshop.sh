#!/bin/bash

IMAGEID=ami-0b4f379183e5706b9
SECURITY_GROUP=sg-0db659996615c588e
SUBNET=subnet-0ac3df5627209a411
INSTANCES=("mongodb" "user" "catalogue" "cart" "redis" "mysql" "shipping" "rabbitmq" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"

do

  if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
  
  then
      INSTANCE_TYPE=t3.small
  else
      INSTANCE_TYPE=t2.micro
   fi
  
  aws ec2 run-instances --image-id $IMAGEID  --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET --tags Key=Name, Value=$i

done