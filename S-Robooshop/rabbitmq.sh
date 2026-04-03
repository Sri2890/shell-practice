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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LoGS_FILE
VALIDATE $? "Copying RabbitMQ repository configuration file"

dnf install rabbitmq-server -y &>> $LoGS_FILE
VALIDATE $? "Installing RabbitMQ message broker server"

systemctl enable rabbitmq-server &>> $LoGS_FILE
VALIDATE $? "Enabling RabbitMQ service to start on boot"

systemctl start rabbitmq-server &>> $LoGS_FILE
VALIDATE $? "Starting RabbitMQ service"

rabbitmqctl add_user roboshop roboshop123 &>> $LoGS_FILE
VALIDATE $? "Adding RabbitMQ user for roboshop application"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LoGS_FILE