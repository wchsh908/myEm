#!/bin/sh
 
#事前准备.从数据库中一个临时表中导入total个domainname的收件人，存入to.txt用作收件人名单
prepare()
{
	rm -f $basedir/to.txt
	echo "select emailaddress into outfile '/tmp/tmpto.txt' from emarketer.tmp_list_subscribers where domainname = '$domainname' limit $total;" | mysql -u root -pwchsh908
	echo "delete from emarketer.tmp_list_subscribers where domainname = '$domainname' limit $total;" | mysql -u root -pwchsh908
	mv -f /tmp/tmpto.txt $basedir/to.txt

	if [ -f $basedir/from.txt ] && [ -f $basedir/to.txt ]
	then
		senders=($(cat $basedir/from.txt))
		count_senders=${#senders[*]}

		recipients=($(cat $basedir/to.txt))
		count_recipients=${#recipients[*]}
	else
		echo "Error.Can not find file of senders and recipients.Quit."
	exit 2
fi
}
 
#测试前:1.为避免混淆接下来收到的退信，移走现有未读退信;2.为避免混淆接下来的延迟队列，移走Postfix中所有队列
before_test()
{
	echo
	echo "BEFORE SEND:"
	if [ -d $bouncedir/new ]
	then
		echo "   move off all the unread mails of $bounceaddr. "
		for file in $(ls $bouncedir/new)
        do
			mv -f $bouncedir/new/$file $bouncedir/cur
		done
	fi
	echo '   move all the mails in the queue to the hold queue.'
	postsuper -h ALL

}

#测试后
after_test()
{
	echo
	echo "SEND END:"
	#等待发信完全结束了
	echo "   Please wait for a few seconds..."
	activecount=1
	while (( $activecount != 0 ))
	do
		sleep 5
		activecount=$(find /var/spool/postfix/active -type f | wc -l)
	done

	#统计退信数和延迟数
	if [ -d $bouncedir/new ]
	then
		bouncecount=$(ls $bouncedir/new | wc -l)
	fi
	defercount=$(find /var/spool/postfix/deferred -type f | wc -l)

	echo "   There are $(($defercount)) mails deferred in the queue, and $(($bouncecount)) mails bounced to $bounceaddr."
	
	#恢复之前的队列  
	echo "   Move mails in the hold queue BACK to original place."
	postsuper -H ALL
}


do_test()
{
	echo
	echo "START SEND:"
	echo "   We can use these accounts: ${senders[*]} , for $count_recipients recipients. "
	echo "   Begin to send $total mails in $time minutes."

	i=0
	sleep_cycle=$((1000000*60/$speed))

	while (( $i < $total ))
	do
		j=$(($i%$count_senders))
		k=$(($i%$count_recipients))
		fromaddr=${senders[$j]}
		toaddr=${recipients[$k]}
		echo "   $(($i+1)) $(date "+%T"): Send an email From:$fromaddr, To:$toaddr"
		#目前程序还不够完善，邮件内容也需要改变
		sed -e "s/__fromADDR/$fromaddr/g;s/__toADDR/$toaddr/g;s/__replytoADDR/$fromaddr/g;s/__bounceADDR/$bounceaddr/g" mailtemplate.txt | sendmail -f $bounceaddr $toaddr
		usleep $sleep_cycle
		i=$(($i+1))
	done
}


#输入参数不对时，提示用法
showusage()
{
	echo "Wrong input. Usage:"
	echo "./mailtest.sh @domainame speed minute : (e.g ./mailtest.sh @qq.com 60 2: test to send emails to qq.com in 2 mimutes with the speed of 60 emails per minute."
	exit 1
}



###################################################################################################
#程序入口
###################################################################################################

#全局变量
domainname=$1
speed=$2
time=$3
total=$(($speed*$time))

basedir=/var/www/html/tools/mailtest
bounceaddr='bounce1@foubei.com'
bouncedir='/home/vmail/foubei.com/bounce1/Maildir'

#发收件人名单、个数
senders=""
count_senders=0
recipients=""
count_recipients=0

if (( $# != 3 ))
then
	showusage
fi

echo 'This is a script to test how many emails can be sent to one domain(e.g. qq.com, 163.com) on a IP.'
echo 'Before you run this scipt, you must MAKE SURE no others mails are sent on this machine.'
echo 'The senders lists are stored in "from.txt" and the recipients lists are stored in "to.txt"'
echo 'Press q or quit to quit, press any other keys to continue'

read key
if [ "$key" = q ] || [ "$key" = Q ] || [ "$key" = quit ] || [ "$key" = QUIT ]
then
	echo 'Quit, bye-bye!'
	exit 2
fi

prepare
before_test
do_test
after_test

exit 0
