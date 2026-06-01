#!/bin/bash
yum update -y
yum install httpd -y     # Installs apache (httpd) service
systemctl start httpd    # Starts httpd service
systemctl enable httpd   # Enables httpd to auto-start at system boot
echo "This is server 1 in AWS Region US-EAST-1 in AZ eu-north-1a" > /var/www/html/index.html
