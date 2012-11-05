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

output=/var/www/html/result/mxresult.txt

if (( $# == 1 )); then
	if [ -f ${1} ] && [ -r ${1} ]; then
		filename=${1}
		echo "无效域名列表(1为格式错误,2为未通过MX记录验证)" > $output
		for element in $(cat $filename)
		do
			domain=${element#*@}
			echo
			echo "正在验证$domain:"	
			if  ! (echo $domain | grep -Eqw  "([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" ); then
				echo "错误！$domain从格式上讲不是一个有效的域名。"
                                echo $domain  >> $output
			else
				answer=$(dig -t mx $domain +short)
				if [ "$answer" != "" ];then
					echo "正确。域名$domain通过了MX记录验证。"
				else
					echo "未能通过验证，正在重新查询:"
					i=1
					while (( $i < 6 )) && [ "$answer" = "" ]
					do
						echo "第$i次重新查询..."
						answer=$(dig -t mx $domain +short)
						i=$(($i+1))
					done 
					if [ "$answer" = "" ];then
						echo "错误！经过多次DNS查询，域名$domain没有通过MX记录验证。"
						echo $domain >> $output
					else
						echo "正确。经过重新查询，域名$domain通过了MX记录验证。"
					fi
				fi
			fi
		done
	else
		echo "Error. Cannot access file ${1}."
	fi
else
	showusage
fi

echo "Quit."
