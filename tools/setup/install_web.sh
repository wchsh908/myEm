#!/bin/bash

echo
sleep 2
echo "---------------------------------安装phpmyadmin------------------------------------"
echo

tar -xzvf packages/phpMyAdmin-3.5.2-all-languages.tar.gz
mv phpMyAdmin-3.5.2-all-languages /phpmyadmin
mv phpmyadmin /var/www/html

echo
sleep 2
echo "---------------------------------安装EmailMarketer------------------------------------"
echo

unzip packages/emailmarketer.zip
#/var/www/html可能也有emailmarketer目录，-u使得只覆盖旧的
cp -ru emailmarketer /var/www/html
rm -rf emailmarketer
cd /var/www/html
chmod -R a+w emailmarketer/admin/com/storage
chmod -R a+w emailmarketer/admin/temp
chmod -R a+w emailmarketer/admin/includes/config.php

iptables -F

echo "结束."


