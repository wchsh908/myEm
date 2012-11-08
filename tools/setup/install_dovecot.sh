#!/bin/bash

echo
echo "---------------------------------安装配置dovecot------------------------------------"
echo

BACKUPDIR=/etc/backup

echo
echo "[正在备份账号密码...]"
mkdir /etc/backup
if [ -f /etc/dovecot/passwd ]; then
	mv /etc/dovecot/passwd $BACKUPDIR/passwd
else
	echo > $BACKUPDIR/passwd
fi

echo
echo "[正在删除dovecot...]"
yum -y erase dovecot

echo
echo "[正在重装dovecot...]"
yum -y install dovecot
chkconfig dovecot on

echo
echo "[正在配置dovecot...]"
cat dovecot.conf > /etc/dovecot.conf

echo
echo "[正在还原密码...]"
mkdir /etc/dovecot
mv $BACKUPDIR/passwd /etc/dovecot/passwd


echo
echo "[正在重启dovecot...]"
service dovecot restart

echo
echo "[结束...]"