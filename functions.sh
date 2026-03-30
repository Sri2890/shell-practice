#! /bin/bash
USERID=$(id -u)
if [ $USERID -ne 0 ]; then
  echo "Please run the script as root or with sudo."
  exit 1
fi

VALIDATE () {
  if [ $1 -ne 0 ]; then
    echo "Failed to install $2."
    exit 1
  else
    echo "$2 installed successfully."
  fi
}

dnf install nginx -y
VALIDATE $? "Installing nginx web server"


dnf install mysql -y
VALIDATE $? "Installing mysql database server"

dnf install nodejs -y
VALIDATE $? "Installing nodejs runtime"

