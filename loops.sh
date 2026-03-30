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
      
for package in $@ # ./loops.sh nginx mysql nodejs
# for package in nginx mysql nodejs
do
    dnf list installed $package &>> $LoGS_FILE
    if [ $? -ne 0 ]; then
      echo "$package is not installed. Installing $package..." | tee -a $LoGS_FILE
      dnf install $package -y &>> $LoGS_FILE
      VALIDATE $? "Installing $package"
    else
      echo "$package is already installed." | tee -a $LoGS_FILE
    fi  
done

