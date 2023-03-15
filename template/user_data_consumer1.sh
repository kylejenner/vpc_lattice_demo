#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Consumer1 app running on EC2” > /var/www/html/index.html