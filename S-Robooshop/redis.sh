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

dnf module disable redis -y &>> $LoGS_FILE
VALIDATE $? "Disabling redis module to avoid conflicts with redis installation"

dnf module enable redis:7 -y &>> $LoGS_FILE
VALIDATE $? "Enabling redis 7 module stream"

dnf install redis -y &>> $LoGS_FILE
VALIDATE $? "Installing redis database server"

sed -i -e 's/127.0.0.1/0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>> $LoGS_FILE
VALIDATE $? "Updating redis.conf file to allow remote connections and disable protected mode"

systemctl enable redis 
VALIDATE $? "Enabling redis service to start on boot"   

systemctl start redis 
VALIDATE $? "Starting redis service"