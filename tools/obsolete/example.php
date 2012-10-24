
<html>
<head>
</head>
<body>
hello,world<br/>
<?php 
echo "<br/><br/>";

//shell_exec("ls -l");
echo "<br/><br/>";

$fp = fopen("/tmp/list_bounces.txt", 'a+');
if (!$fp)
{
echo "file open error";
}


exec("/usr/bin/sudo cat /etc/postfix/vdomains", $arrayout);
$currtime=date('mdhi');
$strbounces="";
$ii=1;
while ($ii <=50)
{
	foreach ($arrayout as $domain)
	{
		if (ereg ('^([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$', $domain))
		{
			$num = $ii < 10 ?  "0".$ii : $ii;

			$strbounces .= "info".$currtime.$num."@".$domain;
			$ii ++;						
		
			if ($ii <= 50)						
			{								
				$strbounces .= ";";						
			}							
			else		
			{						
				break;							
			}
		}
	}
}
$arrayb=split(";",$strbounces);
foreach ($arrayb as $b)
{
	fwrite($fp, $b);
	fwrite($fp, "\n");
}
fclose($fp);

//echo $strbounces;


//system("/usr/bin/sudo  /bin/sh ./postaccountadmin.sh -a gene@news.vipwoo.com");
echo "<br/><br/>";

?>

</body>
</html>
