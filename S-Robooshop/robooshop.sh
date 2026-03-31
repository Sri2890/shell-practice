#!/bin/bash

AMI="ami-0220d79f3f480ecf5"
SGID="sg-095bed2c4e0868764"


for instance in $@ # mogodb nodejs shell frontend
do
  echo "Launching EC2 instance for $instance..."
  
  instance_id=$(aws ec2 run-instances \
    --image-id $AMI \
    --instance-type t3.micro \
    --security-group-ids $SGID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
    
    if [ $instance_id == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
              --instance-ids $instance_id \
              --query "Reservations[0].Instances[0].PublicIpAddress" \
              --output text
        )
    else     
        IP=$(
            aws ec2 describe-instances \
              --instance-ids $instance_id \
              --query "Reservations[0].Instances[0].PrivateIpAddress" \
              --output text
        )
    fi
 echo "Launched EC2 instance for $instance_id with IP: $IP"
done