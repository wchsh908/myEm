#!/bin/sh

tempfile=/tmp/tmpdboutput
fileid=/var/www/html/tools/sql/lastbounceid.txt
if [ -f $fileid ]
then
	lastbounceids=($(cat $fileid))
	lastbounceid=${lastbounceids[1]}
fi
if (( $(( $lastbounceid )) <= 0 ))
then 
	lastbounceid=0
fi

sql="select B.emailaddress,A.bouncetype,A.bouncerule  from emarketer.email_list_subscriber_bounces as A left join emarketer.email_list_subscribers as B on A.subscriberid = B.subscriberid where A.bounceid > $lastbounceid;"
echo $sql | mysql -u root -pwchsh908 > /var/www/html/sqlresult.txt

sql="select max(bounceid) from emarketer.email_list_subscriber_bounces";
echo $sql | mysql -u root -pwchsh908 > $fileid
