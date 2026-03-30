#! /bin/bash
USERID=$(id -u)
LOGS_FOlDER="/var/log/shell-script"
LoGS_FILE="$LOGS_FOlDER/0.log"

if [ $USERID -ne 0 ]; then
  echo "Please run the script as root or with sudo."
# exit 1
fi

VALIDATE () {
  if [ $1 -ne 0 ]; then
    echo "Failed to install $2."
 exit 1
  else
    echo "$2 installed successfully."
  fi
}

dnf install nginx -y &>> $LoGS_FILE
VALIDATE $? "Installing nginx web server"


dnf install mysql -y &>> $LoGS_FILE
VALIDATE $? "Installing mysql database server"

dnf install nodejs -y &>> $LoGS_FILE    
VALIDATE $? "Installing nodejs runtime"

