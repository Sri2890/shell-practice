#!/bin/bash

AMI="ami-0220d79f3f480ecf5"
SGID="sg-095bed2c4e0868764"


for instance in $@ # mogodb nodejs shell
do
  echo "Launching EC2 instance for $instance..."
  
aws ec2 run-instances \
    --image-id ami-0220d79f3f480ecf5 \
    --instance-type t3.micro \
    --security-group-ids sg-095bed2c4e0868764 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].PrivateIpAddress' \
    --output text

done