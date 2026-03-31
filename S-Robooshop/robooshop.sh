#!/bin/bash

AMI="ami-0220d79f3f480ecf5"
SGID="sg-095bed2c4e0868764"
Hosted_zone_id="Z03848281H6OUIMZOLZ40"
Domain_name="srinivas2890.online"


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
    
    sleep 30

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
              --instance-ids $instance_id \
              --query "Reservations[0].Instances[0].PublicIpAddress" \
              --output text
        )
        record_name="$Domain_name" # srinivas2890.online
    else     
        IP=$(
            aws ec2 describe-instances \
              --instance-ids $instance_id \
              --query "Reservations[0].Instances[0].PrivateIpAddress" \
              --output text
        )
        record_name="$instance.$Domain_name" # mogodb.srinivas2890.online
    fi
    aws route53 change-resource-record-sets \
  --hosted-zone-id $Hosted_zone_id \
  --change-batch '
  {
    "Comment": "Adding record for '$instance'",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$record_name'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'$IP'"
            }
          ]
        }
      }
    ]
  }'
 echo "Launched EC2 instance for $instance with IP: $IP"
 echo "Created DNS record for $instance: $record_name -> $IP"
done