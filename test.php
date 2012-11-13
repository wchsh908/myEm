<?php 
echo "hi,this is a test page for php.<br/>";

	//2012-Sep-23, added by jinxiaohu
	function getnewEaddress()
	{
		//字符库0-9,a-z
		$charray = range('a', 'z');
		for ($i = 0; $i < 10; $i++)
		{
			$charray[$i + 26] = $i;
		}

		//打开读
		$fp = fopen("/etc/postfix/vdomains", "r");
		if (!$fp)
			return "Error,can not open /etc/postfix/vdomains";
		$strjoin="";
		while (!feof($fp))
		{
			$domain = fgets($fp, 999);
			$domain = trim($domain);
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
		fclose($fp);
		
		return $strjoin;
	}

$strjoin = getnewEaddress();
echo $strjoin;
	
//打开写
$fp = fopen("/tmp/emaccount/add/11.txt", 'a');
if (!$fp)
{
	echo 'cannot open file 11.txt<br/>';
}
 
$bounceusers = str_replace(";", "\n", $bounceusers);
fwrite($fp, $bounceusers, strlen($bounceusers));
fwrite($fp, "\n");
fclose($fp);
	

 
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

