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

dnf install maven -y &>> $LoGS_FILE
VALIDATE $? "Installing maven build tool"

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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LoGS_FILE
VALIDATE $? "Downloading shipping application code from S3 bucket"


cd /app &>> $LoGS_FILE
VALIDATE $? "Changing directory to /app"

rm -rf /app/* &>> $LoGS_FILE
VALIDATE $? "Cleaning up old application code from /app directory"

unzip /tmp/shipping.zip &>> $LoGS_FILE
VALIDATE $? "Extracting shipping application code"

cd /app 
mvn clean package 
VALIDATE $? "Building shipping application using maven"

mv target/shipping-1.0.jar shipping.jar &>> $LoGS_FILE
VALIDATE $? "Building shipping application using maven"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LoGS_FILE
VALIDATE $? "Copying shipping systemd service file to systemd directory"

systemctl daemon-reload &>> $LoGS_FILE
VALIDATE $? "Reloading systemd daemon to apply changes"

systemctl enable shipping &>> $LoGS_FILE
VALIDATE $? "Enabling shipping service to start on boot"  

systemctl start shipping &>> $LoGS_FILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>> $LoGS_FILE
VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>> $LoGS_FILE

if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LoGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LoGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LoGS_FILE
    VALIDATE $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>> $LoGS_FILE
VALIDATE $? "Restarting shipping service to apply changes"


