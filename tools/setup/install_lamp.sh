#!/bin/bash

echo
echo "[正在配置系统环境...]"
sleep 2
iptables -F
setenforce Permissive


echo
echo "---------------------------------安装配置LAMP------------------------------------"
echo

echo
echo "[正在卸载LAMP...]"
sleep 2
service httpd stop
service mysqld stop
yum -y erase httpd php mysql mysql-server php-mysql 
yum -y erase httpd-manual mod_ssl mod_perl mod_auth_mysql 
yum -y erase php-mcrypt php-gd php-xml php-mbstring php-ldap php-pear php-xmlrpc php-imap 
yum -y erase mysql-connector-odbc mysql-devel libdbi-dbd-mysql 

echo
echo "[正在安装LAMP...]"
sleep 2
yum -y install httpd php mysql mysql-server php-mysql 
yum -y install httpd-manual mod_ssl mod_perl mod_auth_mysql 
yum -y install php-mcrypt php-gd php-xml php-mbstring php-ldap php-pear php-xmlrpc php-imap 
yum -y install mysql-connector-odbc mysql-devel libdbi-dbd-mysql 

chkconfig httpd on
chkconfig mysqld on 

#cat '<?php phpinfo(); ?>' > /var/www/html/test.php

echo
echo "[正在配置MySQL...]"
sleep 2
#字符集问题
echo '[mysqld]' >> /etc/my.cnf
echo 'default-character-set=utf8' >> /etc/my.cnf
echo '[client]' >> /etc/my.cnf
echo 'default-character-set=utf8' >> /etc/my.cnf

service httpd start
service mysqld start

#密码安全问题
#默认没有密码，任何人都可以登录mysql
#先给root用户设置密码，然后用root登录，删除匿名用户
mysqladmin -u root password 'wchsh908'
echo 'update mysql.user set Password=PASSWORD("wchsh908") where User="root"'| mysql -u root -pwchsh908
echo 'delete from mysql.user where User=""' | mysql -u root -pwchsh908


echo "结束."


