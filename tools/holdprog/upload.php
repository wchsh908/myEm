<html>
<head>
<title>Uploading...</title>
</head>
<body>
<h1>Uploading file...</h1>
<?php
if($_FILES['userfile']['error']>0)
{
	echo 'Problem: ';
	switch ($_FILES['userfile']['error'])
	{
		case 1: echo '文件超出了规定上传的最大尺寸'; break;
		case 2: echo 'File exceeded max_file_size'; break;
		case 3: echo '文件只上传了一部分'; break;
		case 4: echo '没有选上文件'; break;
	}
	exit;
}

//if ($_FILES['userfile']['type'] != 'text/plain')
//{
//	echo 'Problem: file is not plain text';
//	exit;
//}

$upfile = '../upload/'.$_FILES['userfile']['name'];
if (is_uploaded_file($_FILES['userfile']['tmp_name']))
{
	if (!move_uploaded_file($_FILES['userfile']['tmp_name'], $upfile))
	//if (!copy($_FILES['userfile']['tmp_name'], $upfile))
	{
		echo 'Problem: Could not move file to destination directory '.$upfile;
		print_r($_FILES);
		exit;
	}
}
else
{
	echo 'Problem: Possbile file upload attack.Filename: ';
	echo $_FILES['userfile']['name'];
	exit;
}

echo '文件上传成功！现位于/var/www/html/upload目录下<br><br>';
if ($_FILES['userfile']['type'] == 'text/plain')
{
	$fp = fopen($upfile, 'r');
	$contents = fread($fp, filesize($upfile));
	fclose($fp);
	
	$contents = strip_tags($contents);
	$fp = fopen($upfile, 'w');
	fwrite($fp, $contents);
	fclose($fp);
	echo 'Preview of uploaded file contents:<br><hr>';
	echo $contents;
	echo '<br><hr>';
}
?>
</body>

</html>
