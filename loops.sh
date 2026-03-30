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
    echo "Failed to install $2." | tee -a $LoGS_FILE
# exit 1
  else
    echo "$2 installed successfully." | tee -a $LoGS_FILE
  fi
}

for package in $@
do
  dnf install $ackage -y &>> $LoGS_FILE
  VALIDATE $? "Installing $package"
done

