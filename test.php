<?php 
echo "hi,this is a test page for php.<br/>";

	//2012-Sep-23, added by jinxiaohu
	private function getnewEaddress()
	{
		//字符库0-9,a-z
		$charray = range('a', 'z');
		for ($i = 0; $i < 10; $i++)
		{
			$charray[$i + 26] = $i;
		}

		//打开读
		$domainarray = file("/etc/postfix/vdomains");
		if (count($domainarray) == 0)
			return "Error,can not open /etc/postfix/vdomains";
		$strjoin="";
		foreach ($domainarray as $domain)
		{
			if (ereg ('^([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$', $domain))
			{
				$str = "bo_";
				$count = rand(10, 15);//长度
				for ($i = 0; $i < $count; $i++)
				{
					$index = rand(0, 35);
					$str .= $charray[$index];
				}
				$str .= "@".$domain;
				
				if ($strjoin == "")
					$strjoin .= $str;	
				else
					$strjoin .= ";".$str;
			}
		}
		return $strjoin;
	}

$strr = getnewEaddress();
echo $strr;
	
//打开写
$fp = fopen("/var/tmp/newaccount.txt", 'a');
if (!$fp)
{
	echo 'cannot open file newaccount.txt<br/>';
}
$strjoin = str_replace(";", "\r", $strjoin);
fwrite($fp, $strjoin,strlen($strjoin));
fclose($fp);



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

