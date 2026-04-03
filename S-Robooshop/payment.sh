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
MYSQL_HOST=mysql.srinivas2890.online

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

dnf install python3 gcc python3-devel -y &>> $LoGS_FILE
VALIDATE $? "Installing python3 runtime and development tools"

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

curl -o /tmp/payment.zip "https://roboshop-artifacts.s3.amazonaws.com/payment.zip" &>> $LoGS_FILE
VALIDATE $? "Downloading payment application code from S3 bucket"


cd /app &>> $LoGS_FILE
VALIDATE $? "Changing directory to /app"

rm -rf /app/* &>> $LoGS_FILE
VALIDATE $? "Cleaning up old application code from /app directory"

unzip /tmp/payment.zip &>> $LoGS_FILE
VALIDATE $? "Extracting payment application code"

cd /app 
pip3 install -r requirements.txt &>> $LoGS_FILE
VALIDATE $? "Installing python dependencies for payment application"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>> $LoGS_FILE
VALIDATE $? "Copying payment  systemd service file to systemd directory"

systemctl daemon-reload &>> $LoGS_FILE
VALIDATE $? "Reloading systemd daemon to apply changes"

systemctl enable payment &>> $LoGS_FILE
VALIDATE $? "Enabling payment service to start on boot" 

systemctl start payment &>> $LoGS_FILE
VALIDATE $? "Starting payment service"



