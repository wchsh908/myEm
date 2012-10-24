#!/bin/sh

# 本程序用于从输入的退信邮箱帐号中读取新邮件并作分析处理。功能包括：
# 1.查出无效的邮箱地址，结果放在user_not_found目录下各个文件中。


#分析一封邮件.参数：邮件文件全名;返回:无
read163()
{
	#网易
	if grep -q -m1 "550 User not found"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(vip.163.com|163.com|126.com|yeah.net)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/163
	fi
}


readqq()
{
	#腾讯
	if grep -q -m1 "550 Mailbox not found"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(vip.qq.com|qq.com|foxmail.com)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/qq
	fi
}

readsina()
{
	#新浪
	if grep -q -m1 "User unknown in virtual mailbox table"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(vip.sina.com|sina.com|sina.com.cn)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/sina
	fi
}

readhotmail()
{
	#微软
	if grep -q -m1 "mailbox unavailable"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(hotmail.com|live.cn|msn.com)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/hotmail
	fi
}

readyahoo()
{
	#雅虎
	if grep -q -m1 "user doesn't have a * account"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(yahoo.com.cn|yahoo.cn|yahoo.com|yahoo.com.hk|yahoo.com.tw)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/yahoo
	fi
}

readsohu()
{
	#搜狐
	if grep -q -m1 "User unknown in local recipient table"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(sohu.com)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/sohu
	fi
}


readgmail()
{
	#gmail
	if grep -q -m1 "550-5.1.1"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(gmail.com)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/gmail
	fi
}

readchinatelecom()
{
	#中国电信
	if grep -q -m1 "550 no such user"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(21cn.com|189.cn)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/chinatelecom
	fi	
}

readtom()
{
	#tom和163.net
	if grep -q -m1 "554 Invalid recipient"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(tom.com|163.net)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/tom
	fi
	
}

read139()
{
	#中国移动139
	if grep -q -m1 "User not found"  $1
	then
		recipient=$(grep -Eo -m1 "([a-zA-Z0-9_-.+]+)@(139.com)" $1)
		echo "User not found: $recipient. "
		echo $recipient >> $basedir/user_not_found/139
	fi
}


##################################################################################################################

# 分析一个邮箱帐号下的所有新邮件.参数：合法的邮箱帐号名;返回:无.
readaccount()
{
	acct=$1
	bcuser=${acct%@*}
	bcdomain=${acct#*@}
	if [ -d "/home/vmail/$bcdomain/$bcuser/Maildir" ]
	then 
		getaccounttime $acct	# 获取我们上次处理这个邮箱帐号的时间，保存在变量$lasttime里
		bouncedirs="/home/vmail/$bcdomain/$bcuser/Maildir/cur /home/vmail/$bcdomain/$bcuser/Maildir/new"
		for bcdir in $bouncedirs
		do
			if [ -d $bcdir ]
			then
				for bcfile in $(ls $bcdir)	#取出每封邮件
				do
					mailfile=$bcdir/$bcfile
					getfiletime $mailfile	#获取邮箱文件的修改时间，结果保存在$filetime里
					#如果该邮件的修改时间晚于我们上次处理这个邮箱帐号的时间 被认为是新邮件,才会分析处理
					if (( $filetime > $lasttime ))
					then
						if grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(vip.163.com|163.com|126.com|yeah.net)"  $mailfile
						then
							read163 $mailfile		#网易系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(vip.qq.com|qq.com|foxmail.com)"  $mailfile
						then
							readqq $mailfile		#腾讯系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(vip.sina.com|sina.com|sina.com.cn)"  $mailfile
						then
							readsina $mailfile		#新浪系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(hotmail.com|live.cn|msn.com)"  $mailfile
						then
							readhotmail $mailfile	#hotmail系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(yahoo.com.cn|yahoo.cn|yahoo.com|yahoo.com.hk|yahoo.com.tw)"  $mailfile
						then
							readyahoo $mailfile	#雅虎系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(sohu.com)"  $mailfile 
						then
							readsohu $mailfile		#搜狐
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(gmail.com)"  $mailfile
						then
							readgmail $mailfile	#谷歌
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(21cn.com|189.cn)"  $mailfile
						then
							readchinatelecom $mailfile		#中国电信系列
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(tom.com|163.net)"  $mailfile
						then
							readtom $mailfile			#tom和163.net
						elif grep -Eqo -m1 "([a-zA-Z0-9_-.+]+)@(139.com)"  $mailfile
						then
							read139 $mailfile		#中国移动139
						fi
					fi
				done
			fi
		done
		setaccounttime $acct
	else        
		echo "Error.can not get emails from $acct."
	fi
}


# 获取一个文件的修改时间.参数:文件名;返回:全局变量filetime.
getfiletime()
{
	#文件的修改时间，原本格式是2012-09-05 20:25:50.000000000 +0800这样
	filetime=$(stat -c%y $1)
	#时间处理一下，去掉- 空格 : 和秒后面的字符串
	filetime=${filetime//-/}
	filetime=${filetime// /}
	filetime=${filetime//:/}
	filetime=${filetime//.*/}       #最终成为20120905202550这样的格式。处理成这种格式是为了好比较早晚                                
}


# 记录我们这次对一个邮箱帐号分析的时间.参数：邮箱帐号;返回:无
setaccounttime()
{
	curtime=$(date "+%Y%m%d%H%M%S")			#格式是20120905202550
	sed '/'"$1"'/d' $basedir/lasttime.txt > tmp	#删除旧标记
	echo "$1:$curtime" >> tmp			#追加新标记
	mv -f tmp $basedir/lasttime.txt
}


# 获取一个邮箱帐号的上次处理它的时间.参数:邮箱帐号;返回:全局变量lasttime
getaccounttime()
{
	if grep -Eqo -m1 "$1:[0-9]+"  $basedir/lasttime.txt
	then
		str=$(grep -Eo -m1 "$1:[0-9]+"  $basedir/lasttime.txt)
		lasttime=${str#*:}	#剔除前半段(帐号)
	else
		lasttime=0
	fi
}



##############################################################################################################
#程序入口
##############################################################################################################


#全局变量
basedir=/var/www/html/tools/bounce
filetime=0
lasttime=0
i=1


#打开bash的开关,使shell支持5个扩展的模式匹配操作符
shopt -s extglob


#处理输入的参数
if (( $# != 0 ))
then
	#输入的是邮箱帐号
	bc_accounts=$@
else
	#没有输入参数，从bounce_accounts.txt这个文档中读出退信邮箱帐号
	if [ -f $basedir/bounce_accounts.txt ]
	then
		bc_accounts=$(cat $basedir/bounce_accounts.txt)
	else
		echo "bounce_accounts.txt not found.Quit."
		exit 1
	fi
fi


for account in $bc_accounts
do
	#判断是不是一个合法的email邮箱帐号
	if [[ $account != +([a-zA-Z0-9_-.+])@+([a-zA-Z0-9_-.+]).[a-zA-Z][a-zA-Z]?([a-zA-Z])?([a-zA-Z])?([a-zA-Z]) ]]
	then	
		echo "$i. Error!$account is not an email account."
	else
		echo "$i. Reading and analysing new emails of $account."
		readaccount $account
	fi
done

exit 0
