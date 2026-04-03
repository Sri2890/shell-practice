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

dnf install mysql-server -y &>> $LoGS_FILE
VALIDATE $? "Installing mysql database server"

systemctl enable mysqld &>> $LoGS_FILE
VALIDATE $? "Enabling mysqld service to start on boot"

systemctl start mysqld &>> $LoGS_FILE
VALIDATE $? "Starting mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LoGS_FILE
VALIDATE $? "Securing mysql installation and setting root password"

