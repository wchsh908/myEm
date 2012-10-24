#!/bin/sh

output=/var/www/html/result/sql_bounceaddress_result.txt
lastidFile=/var/www/html/tools/sql/lastbounceid.txt
if [ -f $lastidFile ]
then
	lastbounceids=($(cat $lastidFile))
	lastbounceid=${lastbounceids[1]}
fi
if (( $(( $lastbounceid )) <= 0 ))
then 
	lastbounceid=0
fi

sql="select B.emailaddress,A.bouncetype,A.bouncerule  from emarketer.email_list_subscriber_bounces as A left join emarketer.email_list_subscribers as B on A.subscriberid = B.subscriberid where A.bounceid > $lastbounceid;"
echo $sql | mysql -u root -pwchsh908 > $output

sql="select max(bounceid) from emarketer.email_list_subscriber_bounces";
echo $sql | mysql -u root -pwchsh908 > $lastidFile
