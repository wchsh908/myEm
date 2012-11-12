<?php 
echo "hi,this is a test page for php.<br/>";


$domainarray = file("/etc/postfix/vdomains");
foreach ($domainarray as $domain)
{
	echo $domain;
	echo "<br/>";
}


$fp = fopen("/var/www/html/result/newaccount.txt", 'a');
if (!$fp)
{
	echo 'cannot open file newaccount.txt<br/>';
}



/*
$fp = fopen("/etc/postfix/vdomains", 'r');
if (!$fp)
{
	echo 'cannot open file vdomains.txt<br/>';
}
while (!feof($fp))
{
	$domain = fgets($fp, 9999);
}
*/


/*
exec("cat /etc/postfix/vdomains", $arraydms);
//给每个list分配帐号
foreach ($arraydms as $domain)
{
	echo $domain;
	echo "<br/>";
}

*/
 ?>

