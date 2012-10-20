#!/bin/sh

showusage()
{
	echo 'Invalid input. Usage:'
	echo './mxquery.sh filename:  Query mx record for domains in the file.'
	exit 1
}

########################################################################################################################
#程序入口
########################################################################################################################

output=mxquery.txt

if (( $# == 1 )); then
	if [ -f ${1} ] && [ -r ${1} ]; then
		filename=${1}
		echo > $output
		for element in $(cat $filename)
		do
			domain=${element#*@}
			echo
			echo "正在验证$domain:"	
			if  echo $domain | grep -Eqw  "([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" ; then
				answer=$(dig -t mx $domain +short)
				if [ "$answer" = "" ];then 
					echo "错误！经过DNS查询，域名$domain没有通过MX记录验证。"
					echo $domain$'\t'"mx" >> $output
				else 
					echo "正确。域名$domain通过了MX记录验证。"
				fi;
			else
				echo "错误！$domain从格式上讲不是一个有效的域名。"
				echo $domain$'\t'"fmt"  >> $output
			fi
		done
	else
		echo "Error. Cannot access file ${1}."
	fi
else
	showusage
fi

echo "Quit."