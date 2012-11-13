#!/bin/bash

echo
echo "---------------------------------安装phpmyadmin------------------------------------"
echo

sleep 2
if [ -d /var/www/html/phpmyadmin ];then
	rm -rf /var/www/html/phpmyadmin
fi

tar -xzvf packages/phpMyAdmin-3.5.2-all-languages.tar.gz
mv phpMyAdmin-3.5.2-all-languages phpmyadmin
mv phpmyadmin /var/www/html

echo
echo "---------------------------------安装EmailMarketer------------------------------------"
echo
sleep 2

if [ -d /var/www/html/emailmarketer ];then
	rm -rf /var/www/html/emailmarketer
fi

unzip packages/emailmarketer.zip
mv emailmarketer /var/www/html

sleep 2
echo "[拷贝改动过的emailmarketer的源代码...]"
cp -rf em_src/* /var/www/html/emailmarketer

cd /var/www/html
chmod -R a+w emailmarketer/admin/com/storage
chmod -R a+w emailmarketer/admin/temp
chmod -R a+w emailmarketer/admin/includes/config.php


echo "结束."


