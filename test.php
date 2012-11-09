<?php 
echo "hi,this is a test page for php.";

exec("cat /etc/postfix/vdomains", $arraydms);
//给每个list分配帐号
foreach ($arraydms as $domain)
{
	echo $arraydms;
}
 ?>

