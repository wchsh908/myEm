<html>
<head>
<title>添加邮箱帐号</title>
</head>

<body>

<?php

$opt=$_GET["option"];

if ($opt == '1')//删除域名
{
	echo "./run -d ".$_GET['domain']."\n";
	exec("./run -d ".$_GET['domain']);
}
else if ($opt == '2')//删除帐号
{
	echo "./run -d ".$_GET['user'].' '.$_GET['domain']."\n";
	passthru("./run -d ".$_GET['user'].' '.$_GET['domain']);
}
else
{
	if ($_GET['sbmt_adddomain'])//添加域名
	{
		echo "./run -a ".$_GET['txt_domain']."\n";
		exec("./run -a ".$_GET['txt_domain']);
		$_GET['sbmt_adddomain'] = 0;
	}
	else if ($_GET['sbmt_adduser'])//添加帐号
	{
		echo "./run -a ".$_GET['txt_username'].' '.$_GET['txt_userdomain']."\n";
		passthru("./run -a ".$_GET['txt_username'].' '.$_GET['txt_userdomain']);
		$_GET['sbmt_adduser'] = 0;
	}
	else
	{
		echo "无效的输入！"."<BR>";
	}
}

?>

<form action="./postaccountadmin.php" method="get">
	<input type="submit" name="sbmt_adddomain" value="确定">
</form>

</body>

</html>

