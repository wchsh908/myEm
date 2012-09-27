#!/bin/sh

#shopt -s extglob

showusage()
{
	echo 'Invalid input. Usage:'
	echo './postaccountadmin.sh -s:  Show all current domains and mail accounts;'
	echo './postaccountadmin.sh -a domain:  Add a virtual domain;'
	echo './postaccountadmin.sh -a user@domain:  Add a mail account;'
	echo './postaccountadmin.sh -a filename:  Add mail accounts(no domain) from a file(full path);'
	echo './postaccountadmin.sh -d domain:  Delete a virtual domain;'
	echo './postaccountadmin.sh -d user@domain: Delete a mail account;'
	echo './postaccountadmin.sh -a filename:  Delete mail accounts(no domain) from a file(full path);'
	exit 1
}

#检查确保输入的域名必须是虚拟域
#参数：1.域名
checkVdomain()
{
	#获取postfix中设置的myhostname和mydomain，不能输入这两个域
	tmp=$(postconf myhostname)
	myhn=${tmp#*= }
	tmp=$(postconf mydomain)
	mydm=${tmp#*= }
	
	#不能不是虚拟域
	if [ $domain = $myhn ] || [ $domain = $mydm ]
	then
		echo "失败. $domain不是虚拟域."
		return 2
	fi
	return 0
}
#检查某域名的目录是否已经建立
domaindirExists()
{
	[ -d /home/vmail/$domain ]
}

#检查某帐号的mailbox是否已经建立
userdirExists()
{
	[ -d /home/vmail/$domain/$user/Maildir ]
}

#检查某域名是否记录到postfix的配置文本vdomains中
vdomainExists()
{
	grep -Eqw "^$domain" /etc/postfix/vdomains
}

#检查某帐号是否记录到postfix的配置文本vmailbox中
mailboxExists()
{
	grep -qw "$user@$domain" /etc/postfix/vmailbox
}

#检查某帐号是否记录到dovecot的配置文本passwd中
vpasswdExists()
{
	grep -qo "$user@$domain" /etc/dovecot/passwd 
}

#显示这台机器上所有的邮箱域名和用户帐号
showallaccounts()
{
	echo 'Here are all the domains and user accounts:'
	i=1
	maildir=/home/vmail
	for filedomain in $maildir/*
	do
		if [ -d "$filedomain" ]
		then
			domain=$(echo $filedomain | sed "s!$maildir/!!")
			if vdomainExists	#不仅要在文件夹中存在，还要在vdomains配置文件中存在
			then
				echo "$i. $domain:"	
				for fileuser in $filedomain/*
				do
					if  [ -d "$fileuser" ]
					then
						user=$(echo $fileuser | sed "s!$filedomain/!!")
						if mailboxExists && vpasswdExists
						then
							echo "	$user@$domain"
						fi
					fi
				done
				echo
				i=$(($i+1))
			fi
		fi
	done
	
	return 0
}


adddomain()
{
	echo "正在添加域名$domain ..."
	if  domaindirExists  &&  vdomainExists 
	then	
		echo "[失败].域名 $domain 已存在."
		return 3
	else
		if ! domaindirExists
		then
			mkdir /home/vmail/$domain
			chown -R vmail:vmail /home/vmail/$domain
		fi
			
		if ! vdomainExists
		then
			echo "$domain" >> /etc/postfix/vdomains
		fi
		
		echo "[成功].添加域名$domain成功."
	fi
	return 0
}

adduser()
{
	echo "正在添加帐号$user@$domain ..."
	if ! domaindirExists || ! vdomainExists
	then
		#连域名都不存在
		echo "[失败].域名$domain不存在或者不完整，请先添加域名$domain."
		return 6
	else
		if  userdirExists  &&  mailboxExists &&  vpasswdExists
		then
			#帐号已存在
			echo "[失败].帐号$user@$domain已存在."
			return 7
		else
			#创建目录
			if  ! userdirExists
			then
				cd /home/vmail/$domain
				mkdir $user
				mkdir $user/Maildir
				chown -R vmail:vmail $user
			fi
			#添加文本
			if ! mailboxExists
			then
				echo "$user@$domain     $domain/$user/Maildir/"  >>  /etc/postfix/vmailbox
				postmap /etc/postfix/vmailbox
			fi
			#添加密码
			if ! vpasswdExists
			then
				echo "$user@$domain:{plain}wchsh908:5000:5000::/home/vmail/$domain/$user/"  >> /etc/dovecot/passwd
			fi
			
			echo "[成功].添加帐号$user@$domain成功."
		fi
	fi
	return 0
}


deluser()
{
	echo "正在删除帐号$user@$domain ..."
	if  ! userdirExists  &&  ! mailboxExists &&  ! vpasswdExists
	then
		#帐号已存在
		echo "[失败].帐号$user@$domain不存在."
		return 8
	else
		#从文本文件中删除匹配的某一行
		#删除目录
		cd /home/vmail/$domain
		rm -rf $user
		#删除文本
		cp -f /etc/postfix/vmailbox /home/tmp
		sed '/'"$user@$domain"'/d' /home/tmp > /etc/postfix/vmailbox
		postmap /etc/postfix/vmailbox
		#删除密码
		cp -f /etc/dovecot/passwd /home/tmp
		sed '/'"$user@$domain"'/d' /home/tmp > /etc/dovecot/passwd
		echo "[成功].删除帐号$user@$domain成功."
	fi
	
	return 0
}

deldomain()
{
	echo "正在删除域名$domain ..."
	if  ! domaindirExists && ! vdomainExists 
	then	
		echo "[失败].域名 $domain 不存在."
		return 4
	elif grep -qo "@$domain" /etc/postfix/vmailbox  #这里的grep一定要用 -o
	then
		#不是一个空的域，里面仍然有用户
		echo "[失败].仍有帐号在使用$domain这个域名.请先删除所有用户帐号，然后再重试."
		return 5
	else
		#从域名配置文件中删除匹配的域名
		cp -f /etc/postfix/vdomains /home/tmp
		#还是有bug的
		sed "/^$domain/d" /home/tmp > /etc/postfix/vdomains
		#删除目录
		cd /home/vmail
		rm -rf $domain
		echo "[成功].删除域名$domain成功."
	fi
	return 0
}


fromfile()
{
	#这时的param是文件名
	for element in $(cat $param)
	do 
		if  echo $element | grep -Eqw  "([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" 
		then
			user=${element%@*}
			domain=${element#*@} 
			
			if checkVdomain 
			then
				if [ "$option" = '-a' ]
				then
					adduser
				elif [ "$option" = '-d' ]
				then
					deluser
				else
					showusage
				fi
			fi
		fi
	done
}


########################################################################################################################
#程序入口
########################################################################################################################
	
if ! [ -d /home/vmail ] 
then
	mkdir /home/vmail
	chown -R vmail:vmail /home/vmail
fi

#1.一个参数 -s
if (( $# == 1 ))
then
	# -s显示所有域名和帐号
	if [ ${1} = '-s' ]
	then	
		showallaccounts
	else
		showusage
	fi
	
#2.两个参数:添加或者删除 域名或者帐号
elif (( $# == 2 ))
then
	option=${1}   
	param=${2}
	
	#2.1输入的是个邮箱帐号
	if  echo $param | grep -Eqw  "([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" 
	then
		user=${param%@*}
		domain=${param#*@} 
		checkVdomain $domain
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
	
	#2.2输入的是个域名
	elif  ( echo $param | grep -Eqw  "([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})"  )
	then
		domain=$param
		checkVdomain $domain
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
	#2.3输入的是个文件
	elif [ -f $param ] 
	then
		if [ -r $param ]
		then
			fromfile
		else
			echo "[失败].文件$param不可读."
		fi
	else
		showusage
	fi
	
#3.不是1个或2个参数都报错
else
	showusage
fi

echo "Quit."