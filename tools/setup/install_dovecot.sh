#!/bin/bash

echo
echo "---------------------------------安装配置dovecot------------------------------------"
echo

BACKUPDIR=/etc/p_d_backup
if ! [ -d /etc/p_d_backup ];then
	mkdir /etc/p_d_backup
fi
rm -f /etc/p_d_backup/*


echo
echo "[正在备份账号密码...]"
echo
sleep 2
if [ -f /etc/dovecot/passwd ]; then
	mv /etc/dovecot/passwd $BACKUPDIR/passwd
else
	echo > $BACKUPDIR/passwd
fi

echo
echo "[正在删除dovecot...]"
echo
sleep 2
yum -y erase dovecot
rm -rf /etc/dovecot

echo
echo "[正在安装dovecot...]"
echo
sleep 2
yum -y install dovecot
chkconfig dovecot on

echo
echo "[正在配置dovecot...]"
echo
sleep 2
cat dovecot.conf > /etc/dovecot.conf

echo
echo "[正在还原账号密码...]"
echo
sleep 2
mkdir /etc/dovecot
mv $BACKUPDIR/passwd /etc/dovecot/passwd


echo
echo "[正在重启dovecot...]"
service dovecot restart

echo
echo "[结束...]"