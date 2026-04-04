#! /bin/bash
USERID=$(id -u)
LOGS_FOlDER="/var/log/shell-reboshop"
LoGS_FILE="$LOGS_FOlDER/$0.log"


R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'

if [ $USERID -ne 0 ]; then
  echo "$R Please run the script as root or with sudo.$N" 
# exit 1
fi
mkdir -p $LOGS_FOlDER

VALIDATE () {
  if [ $1 -ne 0 ]; then
    echo "Failed to install $2." | tee -a $LoGS_FILE
# exit 1
  else
    echo "$2 installed successfully." | tee -a $LoGS_FILE
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LoGS_FILE
VALIDATE $? "Copying mongo.repo file to yum.repos.d directory"

dnf install mongodb-org -y &>> $LoGS_FILE
VALIDATE $? "Installing mongodb database server"

systemctl enable mongod &>> $LoGS_FILE
VALIDATE $? "Enabling mongod service to start on boot"

systemctl start mongod &>> $LoGS_FILE
VALIDATE $? "Starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf   
VALIDATE $? "Updating mongod.conf file to allow remote connections"

systemctl restart mongod &>> $LoGS_FILE
VALIDATE $? "Restarting mongod service to apply changes"
