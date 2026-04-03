#! /bin/bash
USERID=$(id -u)
LOGS_FOlDER="/var/log/shell-reboshop"
LoGS_FILE="$LOGS_FOlDER/$0.log"

R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'

SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.srinivas2890.online

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

dnf modules disable nodejs -y &>> $LoGS_FILE
VALIDATE $? "Disabling nodejs module to avoid conflicts with nodejs installation"

dnf enable nodejs:20 -y &>> $LoGS_FILE
VALIDATE $? "Enabling nodejs 20 module stream"

dnf install nodejs -y &>> $LoGS_FILE
VALIDATE $? "Installing nodejs runtime"

id roboshop &>> $LoGS_FILE
if [ $? -ne 0 ]; then
  echo "Creating roboshop system user..." | tee -a $LoGS_FILE
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LoGS_FILE 
VALIDATE $? "Creating roboshop system user"
else
  echo -e "roboshop system user already exists." | tee -a $LoGS_FILE  
fi 

mkdir -p /app &>> $LoGS_FILE
VALIDATE $? "Creating /app directory for application code"

curl -o /tmp/catalogue.zip "https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip" &>> $LoGS_FILE
VALIDATE $? "Downloading catalogue application code from S3 bucket"


cd /app &>> $LoGS_FILE
VALIDATE $? "Changing directory to /app"

rm -rf /app/* &>> $LoGS_FILE
VALIDATE $? "Cleaning up old application code from /app directory"

unzip /tmp/catalogue.zip &>> $LoGS_FILE
VALIDATE $? "Extracting catalogue application code"

npm install &>> $LoGS_FILE
VALIDATE $? "Installing catalogue application dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $LoGS_FILE
VALIDATE $? "Copying catalogue systemd service file to systemd directory"

systemctl daemon-reload &>> $LoGS_FILE
VALIDATE $? "Reloading systemd daemon to apply changes"

systemctl enable catalogue &>> $LoGS_FILE
VALIDATE $? "Enabling catalogue service to start on boot"

systemctl start catalogue &>> $LoGS_FILE
VALIDATE $? "Starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LoGS_FILE
VALIDATE $? "Copying MongoDB repository configuration file"

dnf install mongodb-mongosh -y &>> $LoGS_FILE
VALIDATE $? "Installing MongoDB shell client"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -le 0 ]; then
     mongosh --host $MONGODB_HOST <app/db/master-data.js &>> $LoGS_FILE
    VALIDATE $? "Importing MongoDB schema for catalogue application"
else
    echo "MongoDB schema for catalogue application already exists. Skipping import." | tee -a $LoGS_FILE
fi

systemctl restart catalogue &>> $LoGS_FILE
VALIDATE $? "Restarting catalogue service to apply changes"

