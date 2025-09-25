#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0935c7424eff90287

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value="$instance"}]" --query "Instances[0].InstanceId" --output text)

    if [ $instance != "frontend" ]
    then #Get Private IP
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
    fi
    echo "$INSTANCE_ID : $IP"
done