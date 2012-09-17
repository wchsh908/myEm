#!/bin/sh

shopt -s extglob

showusage()
{
	echo 'Bad input. Usage:'
	echo './postaccountadmin.sh -s:  Show all current domains and mail accounts;'
	echo './postaccountadmin.sh -a domain:  Add a virtual domain;'
	echo './postaccountadmin.sh -a user@domain:  Add a mail account;'
	echo './postaccountadmin.sh -d domain:  Delete a virtual domain;'
	echo './postaccountadmin.sh -d user@domain: Delete a mail account;'
}


#显示这台机器上所有的邮箱域名和用户帐号
showallaccounts()
{
	echo 'Here are all the domains and user accounts:'
	i=1
	maildir=/home/vmail
	for filedomain in $maildir/*
	do
		if [ -d "$filedomain" ];then
			basedomain=$(echo $filedomain | sed "s!$maildir/!!")
			echo "$i. $basedomain:"	
			for fileuser in $filedomain/*
			do
				if  [ -d "$fileuser" ];then
					baseuser=$(echo $fileuser | sed "s!$filedomain/!!")
					echo "	$baseuser"'@'"$basedomain"
				fi
			done
			echo
			i=$(($i+1))
		fi
	done
}


adddomain()
{
	#添加域名前先确认它不存在，不然会在配置文件中造成重复。从域名配置文件vdomains中检查	
	if grep -qw "$domain" /etc/postfix/vdomains
	then
		echo "Domain $domain already exists."
		echo "Quit."
	else	
		#域名不存在,将它添加至域名配置文件中
		
		cp -f /etc/postfix/vdomains /home/tmp
		sed '$a\'"$domain"  /home/tmp > /etc/postfix/vdomains	
		cd /home/vmail
		mkdir $domain
		chown -R vmail:vmail $domain
		echo "Add domain $domain succeed."
	fi
}


deldomain(){
	if grep -qw "*@$domain" /etc/postfix/vmailbox
	then
		#不是一个空的域，里面仍然有用户
		echo "Someone is using domain $domain.Please delete all the user on this domain first and then delete the domain."
		echo "Quit."
	else
		#从域名配置文件中删除匹配的域名
		cp -f /etc/postfix/vdomains /home/tmp
		sed '/'"$domain"'/d' /home/tmp > /etc/postfix/vdomains
		#删除目录
		cd /home/vmail
		rm -rf $domain
		echo "Delete domain $domain succeed."
	fi
}


adduser(){
	if grep -qw "$domain" /etc/postfix/vdomains
	then
		if grep -qw "$user@$domain" /etc/postfix/vmailbox
		then
			#帐号已存在
			echo "$user@$domain already exists."
			echo "Quit."
		else	
			#帐号不存在
			#创建目录
			cd /home/vmail/$domain
			mkdir $user
			mkdir $user/Maildir
			chown -R vmail:vmail $user
			#添加文本
                	cp -f /etc/postfix/vmailbox /home/tmp
                	sed '$a\'"$user@$domain     $domain/$user/Maildir/"  /home/tmp > /etc/postfix/vmailbox
			postmap /etc/postfix/vmailbox
			
	                cp -f /etc/dovecot/passwd /home/tmp
                	sed '$a\'"$user@$domain:{plain}wchsh908:5000:5000::/home/vmail/$domain/$user/"  /home/tmp > /etc/dovecot/passwd
			echo "Add mail account $user@$domain succeed."
		fi
	else
		#连域名都不存在
		echo "Domain $domain does not exist.Please add domain $domain first."
		echo "Quit."
	fi
}


deluser()
{
	#从文本文件中删除匹配的某一行
	cp -f /etc/postfix/vmailbox /home/tmp
	sed '/'"$user@$domain"'/d' /home/tmp > /etc/postfix/vmailbox
	postmap /etc/postfix/vmailbox

	cp -f /etc/dovecot/passwd /home/tmp
	sed '/'"$user@$domain"'/d' /home/tmp > /etc/dovecot/passwd
	#删除目录
	cd /home/vmail/$domain
	rm -rf $user
	
	echo "Delete mail account $user@$domain succeed."
}



#程序入口
if [ $# = 1 ]
then
	# -s显示所有域名和帐号
	if [ $1 = '-s' ]
	then	
		showallaccounts
	else
		showusage
	fi
	
elif [ $# = 2 ]
then
	option=$1   
	param=$2
	#输入的是个邮箱帐号
	if [[ $param == +([a-zA-Z0-9_-.+])@+([a-zA-Z0-9_-.+]).[a-zA-Z][a-zA-Z]?([a-zA-Z])?([a-zA-Z])?([a-zA-Z]) ]]
	then
		user=${param%@*}
        	       domain=${param#*@}
		#添加帐号
	 	if [ "$option" = '-a' ]
		then
	               adduser
        	#删除帐号
        	elif [ "$option" = '-d' ]
		then
        	       deluser
        	else
        	       showusage
        	fi
	#输入的是个域名
      	elif [[ $param == +([a-zA-Z0-9_-.+]).[a-zA-Z][a-zA-Z]?([a-zA-Z])?([a-zA-Z])?([a-zA-Z]) ]]
	then
	        domain=$param
        	#添加域名
        	if [ "$option" = '-a' ]
		then
                	adddomain
        	#删除域名
        	elif [ "$option" = '-d' ]
		then
                	deldomain
        	else
			showusage
		fi
	else
		showusage
	fi
#其他输入情况都报错
else
	showusage
fi
