#/bin/sh

basedir=/var/www/html/tools/bounce
files=$(ls $basedir/user_not_found)

cat /dev/null > tmp.sql
for file in $files
do
	users=$(cat $basedir/user_not_found/$file)
	for user in $users
	do
		echo $user
		echo "delete from emarketer.email_list_subscribers where emailaddress='$user';" >> tmp.sql
	done
done

mysql -u root -pwchsh908 < tmp.sql
