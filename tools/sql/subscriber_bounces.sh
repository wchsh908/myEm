#!/bin/sh

tempfile=/tmp/tmpdboutput
 
sql='select B.emailaddress,A.bouncetype,A.bouncerule  from emarketer.email_list_subscriber_bounces as A left join emarketer.email_list_subscribers as B on A.subscriberid = B.subscriberid;'
echo $sql | mysql -u root -pwchsh908 > /var/www/html/sqlresult.txt
