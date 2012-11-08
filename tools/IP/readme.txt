装完系统后，配置IP的过程如下：

1.把所有IP写到本目录的一个文件下，文件名为srcIP.txt
如果IP是连续的(比如从218.98.140.2一直到218.98.140.254)，你又懒得一个一个输入，可以用类似如下的命令将ip输入到srcIP.txt：
rm -f srcIP.txt
i=2;
while (( $i < 255 ))
do
	echo 218.98.140.$i >> srcIP.txt
	i=$(($i+1))
done

2.建好srcIP.txt后，运行./configip.sh，该脚本将复制ip配置文件。检查无误后，运行service network restart，IP分配成功。
注意这一步有风险，如果ip配置文件写的不正确，运行了service network restart后很有可能导致系统断网从而无法远程登录。

3.分配好了IP后，运行./serviceip start，系统即可自动切换源ip。如果想停止切换，运行./serviceip stop。
这个命令不是开机自动启动的，所以重启系统需要再次运行才会重新切换源ip。
同样，这个命令由于修改路由表，也有风险会导致系统断网。

