<html>
<meta charset=utf-8 />
<head>
	<title>添加邮箱帐号</title>
</head>
<body>

<form action="./process.php" method="get">
	添加新的域名: 
	<input type="text" name="txt_domain" >
	<input type="submit" name="sbmt_adddomain" value="添加">
</form>

<form action="./process.php" method="get">
	添加新的邮箱帐号: 
	<input type="text" name="txt_username" >
	@
	<input type="text" name="txt_userdomain" >
	<input type="submit" name ="sbmt_adduser" value="添加">
</form>


<p>已经注册的邮箱帐号：</p>

<?php 
//system("./run", $result);
//foreach ($result as $line)
//	echo $line;

$last_line = system('./xxx', $retval);    
echo $last_line;

/*
$root = '/home/vmail';
$seperator = '/';
//$root = 'D:\\profile';
//$seperator = '\\';
$i=1;
$rHandle = opendir($root);

while($fileDomain = readdir($rHandle))
{
	$fileDomainFull = $root.$seperator.$fileDomain;
	if (is_dir($fileDomainFull) && $fileDomain != '.' && $fileDomain != '..')
	{
		echo '<tr>';
		echo '<td>';
		echo '<div>	'.$i.': '.$fileDomain.'</div>';
		echo '</td>';
		echo '<td width=60> ';
		echo '<div><a href=process.php?option=1&domain='.$fileDomain.'>'.'删除</a>.</div>';
		echo '</td>';
		echo '</tr>';
		$i++;
		
		$dmHandle = opendir($fileDomainFull);
		while ($fileUser = readdir($dmHandle))
		{
			$fileUserFull = $fileDomainFull.$seperator.$fileUser;
			if (is_dir($fileUserFull) && $fileUser != '.' && $fileUser != '..')
			{
				echo '<tr>';
				echo '<td> ';
				echo '<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$fileUser.'@'.$fileDomain.'</div>';
				echo '</td>';
				echo '<td width=60> ';
				echo '<div><a href=process.php?option=2&user='.$fileUser.'&domain='.$fileDomain.'>'.'删除</a>.</div>';
				echo '</td>';
				echo '</tr>';
			}
		}
		closedir($fileDomainFull);
	}
}
closedir($root);

*/

?>



</body>
</html>
