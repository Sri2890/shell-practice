#! /bin/bash
USERID=$(id -u)
if [ $USERID -ne 0 ]; then
  echo "Please run the script as root or with sudo."
  exit 1
fi
echo "Installing nginx web server..."
dnf install nginx -y

if [ $? -ne 0 ]; then
  echo "Failed to install nginx. Please check the error messages above."
else
  echo "nginx installed successfully."
fi

dnf install mysql -y
if [ $? -ne 0 ]; then
  echo "Failed to install mysql. Please check the error messages above."
else
  echo "mysql installed successfully."
fi

dnf install nodejs -y
if [ $? -ne 0 ]; then
  echo "Failed to install nodejs. Please check the error messages above."
else
  echo "nodejs installed successfully."
fi
