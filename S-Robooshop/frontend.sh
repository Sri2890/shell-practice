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

dnf module disable nginx -y &>> $LoGS_FILE
dnf module enable nginx:1.24 -y &>> $LoGS_FILE
dnf install nginx -y &>> $LoGS_FILE
VALIDATE $? "Installing nginx web server"

systemctl enable nginx &>> $LoGS_FILE
VALIDATE $? "Enabling nginx service to start on boot"

systemctl start nginx &>> $LoGS_FILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>> $LoGS_FILE
VALIDATE $? "Cleaning default nginx web content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LoGS_FILE
VALIDATE $? "Downloading frontend application code from S3 bucket"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LoGS_FILE
VALIDATE $? "Extracting frontend application code to nginx web root directory"

rm -rf /etc/nginx/nginx.conf &>> $LoGS_FILE
VALIDATE $? "Removing default nginx configuration file" 

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LoGS_FILE
VALIDATE $? "Copying custom nginx configuration file to /etc/nginx directory"   

systemctl restart nginx &>> $LoGS_FILE
VALIDATE $? "Restarting nginx service to apply new configuration"
