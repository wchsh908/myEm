#!/bin/sh

tempfile=/tmp/tmpdboutput

#展示系统当前安装的数据库
echo "Here are all databases on this machine:"
echo "show databases;"| mysql -u root -pwchsh908 > $tempfile
echo "------------------------------------"
cat $tempfile
echo "------------------------------------"
echo

#选择数据库
while (( 1 ))
do
	echo "Please type to choose a database, or type q to quit:"
	#等待输入
	read db
	if [ $db != "Database" ] && grep -Eqw "^$db" $tempfile
	then
		echo "You have choose database: $db."
		break
	elif [ $db = q ]
	then
		echo "Quit,byebye~"
		rm -f $tempfile
		exit 1
	else
		echo "Invalid input, try again!"
	fi
done


temptable=$db.tmp_email_list_subscribers
datatable=$db.email_list_subscribers

#读取所有的收件人列表的id、列表名、列表中的收件人人数
echo; echo "Here are all the recipients lists:"
echo "select listid, name, subscribecount from $db.email_lists;" | mysql -u root -pwchsh908 > $tempfile
echo "------------------------------------"
cat $tempfile
echo "------------------------------------"
echo

while (( 1 ))
do
	echo "Please type a listid to choose a list that we shuffle, or type q to quit:"
	#等待输入收件人列表id
	read listid
	#1.正确的输入了listid
	if grep -Eqw "^$listid" $tempfile
	then
		echo;echo
		echo "BEFORE PROCESSING:"
		#展示这份收件人名单中，前20个使用最多的邮箱域名
		echo "   Here are the top 20 mail domains in this recipients list."
		echo "------------------------------------"
		echo "select count(*) as count, domainname from $datatable where listid = $listid group by domainname order by count desc limit 20;"| mysql -u root -pwchsh908		
		echo "------------------------------------"
		#展示这份收件人名单中的前100位收件人。大致可以看出域名的集中程度
		echo "   Here are the first 100 recipients in this list before we shuffle:"
		echo "------------------------------------"
		echo "select emailaddress from $datatable where listid = $listid limit 100;" | mysql -u root -pwchsh908
		echo "------------------------------------"
		echo; echo
		echo "PROCESSING:"
		#把数据库中listid下的收件人名单搬运到一个临时数据表中
		echo "   Copying data to a temp table..."
		echo "create table if not exists $temptable select * from $datatable where listid=$listid;" | mysql -u root -pwchsh908

		#删除数据库中listid下的未随机排序的收件人名单
		echo "   Deleting the unshuffled original data, please wait..."
		echo "delete from $datatable where listid=$listid;" | mysql -u root -pwchsh908
	
		#在临时数据表中给收件人名单编好随机的顺序
		echo "   Shuffling..."
		echo "alter table $temptable add srand FLOAT; update $temptable set srand = RAND();" | mysql -u root -pwchsh908

		#把临时数据表中的收件人名单再复制回数据库中，现在是随机排序的了
		echo "   Copying the shuffled data back to database, please wait..."
		echo "insert into $datatable select NULL, listid, emailaddress, domainname, format, confirmed, confirmcode, requestdate, requestip,  confirmdate,  confirmip,  subscribedate,  bounced,  unsubscribed, unsubscribeconfirmed,  formid  from $temptable order by srand; " | mysql  -u root -pwchsh908

		#删除临时数据表	
		echo "   Drop the temp table."
		echo "drop table $temptable" | mysql  -u root -pwchsh908

		echo "   Shuffle succeed!"
		echo; echo
		echo "AFTER PROCESSING:"
		echo "   Here are the first 100 recipients in your list after we shuffle:"
		echo "------------------------------------"
		echo "select emailaddress from $datatable where listid = $listid limit 100;" | mysql -u root -pwchsh908
		echo "------------------------------------"
		echo; echo
		break
	#2.输入了q,退出
	elif [ $listid = q ]
	then
		echo "Quit,byebye~"
		rm -f $tempfile
		exit 1
	#3.错误的输入
	else
		echo "Invalid input, try again!"
	fi
done

echo "Quit."
rm -f $tempfile
exit 0
