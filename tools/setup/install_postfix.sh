#!/bin/bash

echo
echo "---------------------------------安装配置dovecot------------------------------------"
echo

BACKUPDIR=/etc/backup


#备份文件
echo
echo "[正在备份域名和账号...]"
if [ -f /etc/postfix/vdomains ];then
	mv /etc/postfix/vdomains  $BACKUPDIR/vdomains
else
	echo > $BACKUPDIR/vdomains
fi

if [ -f /etc/postfix/vmailbox ];then
	mv /etc/postfix/vmailbox  $BACKUPDIR/vmailbox
else
	echo > $BACKUPDIR/vmailbox
fi

echo
echo "[正在删除postfix...]"
yum -y erase postfix
echo
echo "[正在重新安装postfix...]"
yum -y install postfix
chkconfig postfix on

echo
echo "[正在配置postfix...]"
#基本配置
postconf -e 'mydestination=localhost,localhost.$mydomain,$myhostname,$mydomain' 
postconf -e 'inet_interfaces=all' 
postconf -e 'home_mailbox = Maildir/'
postconf -e 'maximal_queue_lifetime = 3d'
postconf -e 'queue_run_delay = 500s'
postconf -e 'minimal_backoff_time = 500s'
postconf -e 'maximal_backoff_time = 4000s'

#配合dovecot的SASL配置
postconf -e 'smtpd_sasl_type = dovecot' 
postconf -e 'smtpd_sasl_path = private/auth-client' 
postconf -e 'smtpd_sasl_local_domain =' 
postconf -e 'smtpd_sasl_security_options = noanonymous' 
postconf -e 'broken_sasl_auth_clients = yes' 
postconf -e 'smtpd_sasl_auth_enable = yes' 
postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination"

#虚拟域配置
#存放虚拟域名列表的配置文件
postconf -e "virtual_mailbox_domains = /etc/postfix/vdomains"
#虚拟域邮箱账号的根目录
postconf -e "virtual_mailbox_base= /home/vmail" 
#存放虚拟域账号列表的配置文件
postconf -e "virtual_mailbox_maps = hash:/etc/postfix/vmailbox"
#配置用户
groupadd -g 5000 vmail 
useradd -m -g vmail -u 5000 -d /home/vmail -s /bin/bash vmail 
postconf -e "virtual_minimum_uid = 5000"
postconf -e "virtual_uid_maps = static:5000"
postconf -e "virtual_gid_maps = static:5000"

#还原域名和账号文件
echo
echo "[正在还原域名和账号...]"
mv $BACKUPDIR/vdomains /etc/postfix/vdomains  
mv $BACKUPDIR/vmailbox /etc/postfix/vmailbox  

#重启
echo
echo "[正在账号数据库...]"
newaliases
postmap /etc/postfix/vmailbox

#重启
echo
echo "[正在重启postfix...]"
postfix stop
postfix start

echo
echo "[结束.]"
