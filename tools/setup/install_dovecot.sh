#!/bin/bash

echo "正在备份账号密码..."
if [ -f /etc/dovecot/passwd ]; then
	mv /etc/dovecot/passwd /var/passwd
else
	echo > /var/passwd
fi

echo "正在删除dovecot..."
yum -y erase dovecot
echo "正在重装dovecot..."
yum -y install dovecot
chkconfig dovecot on


echo "正在配置dovecot..."
cat dovecot.conf > /etc/dovecot.conf

echo "正在还原密码..."
mkdir /etc/dovecot
mv /var/passwd /etc/dovecot/passwd

echo "正在重启dovecot..."
service dovecot restart

