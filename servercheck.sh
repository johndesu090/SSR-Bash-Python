#!/bin/bash 
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
OS=CentOS
[ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
[ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
[ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
OS=CentOS
CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
OS=Ubuntu
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
[ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
echo "Does not support this OS, Please contact the author! "
kill -9 $$
fi

#Define
test_URL="https://google.com"
Timeout="10"
ssr_dir="/usr/local/shadowsocksr"
ssr_local="${ssr_dir}/shadowsocks"
log_file="/usr/local/SSR-Bash-Python/check.log"
uname="test"
uport="1314"
upass=`date +%s | sha256sum | base64 | head -c 32`
um1="chacha20"
ux1="auth_chain_a"
uo1="tls1.2_ticket_auth"
uparam="1"
maxsize="$((1024*1024))"

#Function
mades(){
	echo "Do you want the program to create an account for testing[Y/N]"
	read -n 1 yn
	if [[ $yn == [Yy] ]];then
		if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
			iptables-restore < /etc/iptables.up.rules
			clear
			iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $uport -j ACCEPT
			iptables -I INPUT -m state --state NEW -m udp -p udp --dport $uport -j ACCEPT
			iptables-save > /etc/iptables.up.rules
		fi

		if [[ ${OS} == CentOS ]];then
			if [[ $CentOS_RHEL_version == 7 ]];then
				iptables-restore < /etc/iptables.up.rules
				iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $uport -j ACCEPT
    			iptables -I INPUT -m state --state NEW -m udp -p udp --dport $uport -j ACCEPT
				iptables-save > /etc/iptables.up.rules
			else
				iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $uport -j ACCEPT
    			iptables -I INPUT -m state --state NEW -m udp -p udp --dport $uport -j ACCEPT
				/etc/init.d/iptables save
				/etc/init.d/iptables restart
			fi
		fi
		echo "User added successfully! The user information is as follows:"
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -a -u $uname -p $uport -k $upass -m $um1 -O $ux1 -o $uo1 -G $uparam
		ssrmsg=`python mujson_mgr.py -l -u $uname | tail -n 1 | sed 's/^[ \t]*//g'`
		echo "#User add OK!" >> ${log_file}
		echo "#The passwd = $upass" >> ${log_file}
		echo "#The URL = $ssrmsg" >> ${log_file}
	else
		echo "This program will not work without creating an account"
		uadd="no"
	fi
}

rand(){
	min=1000
	max=$((2000-$min+1))
	num=$(date +%s%N)
	echo $(($num%$max+$min))
}

dothetest(){
        if [[ ! -e ${log_file} ]];then
	        echo "The configuration file does not exist and fails!"
                exit 1
        fi
	nowdate=`date '+%Y-%m-%d %H:%M:%S'`
	filesize=`ls -l $log_file | awk '{ print $5 }'`
	#email=`cat ${log_file} | head -n 6 | tail -n 1 | awk -F" = " '{ print $2 }'`
	echo -e "========== Start recording test information[$(date '+%Y-%m-%d %H:%M:%S')] ==========\n" >> ${log_file}
	if [ $filesize -gt $maxsize ];then
		echo "The log file size has reached the upper limit, and an automatic dump will begin!" | tee -a ${log_file}
		tar -cjf servercheck"`date +%Y-%m-%d_%H:%M:%S`".tar.bz2 $log_file
		logset=`cat ${log_file} | head -n 6`
		rm -f ${log_file}
		echo "$logset" >> ${log_file}
		echo -e "========== Start recording test information[$(date '+%Y-%m-%d %H:%M:%S')] ==========\n" >> ${log_file}
		echo "The dump is complete!"
	fi
	local_port=$(rand)
	passwd=`cat ${log_file} | head -n 2 | tail -n 1 | awk -F" = " '{ print $2 }'`
	ip=`cat ${log_file} | head -n 4 | tail -n 1 | awk -F" = " '{ print $2 }'`
	nohup python "${ssr_local}/local.py" -b "127.0.0.1" -l "${local_port}" -s "${ip}" -p "${uport}" -k "${passwd}" -m "${um1}" -O "${ux1}" -o "${uo1}" > /dev/null 2>&1 &
	sleep 2s
	PID=$(ps -ef |grep -v grep | grep "local.py" | grep "${local_port}" | awk '{print $2}')
	if [[ -z ${PID} ]]; then
		echo "ShadowsocksR client fails to start and cannot connect to the server!" | tee -a ${log_file}
		echo "Start restart service" | tee -a ${log_file}
		export SSRcheck=Error
		#echo "Server detected${nowdate}There was an abnormal record, please check the log for details:${log_file}" | mutt -s "[Warning]SSR-Bash-Python" ${email}
		bash /usr/local/shadowsocksr/stop.sh
		bash /usr/local/shadowsocksr/logrun.sh
		iptables-restore < /etc/iptables.up.rules
		echo "The service has restarted!" | tee -a ${log_file}
		echo -e "========== End of recording test information[$(date '+%Y-%m-%d %H:%M:%S')] ==========\n\n" >> ${log_file}
		sleep 1m
		dothetest
	else
		Test_results=$(curl --socks5 127.0.0.1:${local_port} -k -m ${Timeout} -s "${test_URL}")
		if [[ -z ${Test_results} ]];then
			echo "The first connection failed, try again!" | tee -a ${log_file}
			sleep 2s
			Test_results=$(curl --socks5 127.0.0.1:${local_port} -k -m ${Timeout} -s "${test_URL}")
			if [[ -z ${Test_results} ]];then
				echo "2nd connection failed, try again!" | tee -a ${log_file}
				sleep 2s
				Test_results=$(curl --socks5 127.0.0.1:${local_port} -k -m ${Timeout} -s "${test_URL}")
				if [[ -z ${Test_results} ]];then
					echo "3rd connection failed, Start restart service" | tee -a ${log_file}
					bash /usr/local/shadowsocksr/stop.sh
					bash /usr/local/shadowsocksr/logrun.sh
					iptables-restore < /etc/iptables.up.rules
					echo "The service has restarted!" | tee -a ${log_file}
					Test_results=$(curl --socks5 127.0.0.1:${local_port} -k -m ${Timeout} -s "${test_URL}")
					if [[ -z ${Test_results} ]];then
						export SSRcheck=Error
						echo "Connection failed!" | tee -a ${log_file}
					else
						echo "Connection succeeded!" | tee -a ${log_file}
					fi
					#echo "Server detected${nowdate}There was an abnormal record, please check the log for details:${log_file}" | mutt -s "[Warning]SSR-Bash-Python" ${email}
				else
					echo "Connection succeeded!" | tee -a ${log_file}
				fi
			else
				echo "Connection succeeded!" | tee -a ${log_file}
			fi
		else
			echo "Connection succeeded!" | tee -a ${log_file}
		fi
		kill -9 ${PID}
		PID=$(ps -ef |grep -v grep | grep "local.py" | grep "${local_port}" | awk '{print $2}')
		if [[ ! -z ${PID} ]]; then
			echo "ShadowsocksR client stopped failing, please check!" | tee -a ${log_file}
			export SSRcheck=Error
			#echo "Server detected${nowdate}There was an abnormal record, please check the log for details:${log_file}" | mutt -s "[Warning]SSR-Bash-Python" ${email}
		fi
		echo -e "========== End of recording test information[$(date '+%Y-%m-%d %H:%M:%S')] ==========\n\n" >> ${log_file}
	fi
}

main(){
if [[ ! -e ${log_file} ]];then
	mades
	if [[ $uadd == no ]];then
		exit 1
	fi
	while :;do echo 
	echo "Please enter the interval time for each test (unit: minute) {not recommended below 10 minutes}[Default 30]:"
		read everytime
		if [[ -z ${everytime} ]];then
			everytime="30"
			break
		elif [[ ! ${everytime} =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
			echo "Please enter the correct number"
		else
			break
		fi
	done
	while :;do echo
		echo "Please enter the server's IP (check it if you don't know, domain name input is not supported):"
		read ip
		regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
		ckStep2=`echo $ip | egrep $regex | wc -l`
		if [[ $ckStep2 -eq 0 ]];then
			echo "Invalid ip address"
		else
			break
		fi
	done
	#while :;do echo
		#echo "Please enter your email for failure notification:"
		#read yourmail
		#str=`echo $yourmail | gawk '/^([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/{print $0}'`
		#if [[ -z $str ]];then
		#	echo "Invalid email address"
		#else
		#	break
		#fi
	#done
	echo "#The IP = $ip" >> ${log_file}
	echo "#The Time = ${everytime}m" >> ${log_file}
	#echo "#Your email = ${str}" >> ${log_file}
	echo "#############################################" >> ${log_file}
	if [[ ${values} == 1 ]];then
		dothetest
	fi
else
	thetime=`cat ${log_file} | head -n 5 | tail -n 1 | awk -F" = " '{ print $2 }'`
	if [[ -z ${thetime} ]];then
		rm -f ${log_file}
		main
		exit 1
	fi
	dothetest
	sleep ${thetime}
fi
}

runloop(){
	while :
	do
		if [[ -e ${log_file} ]];then
			main
		else
			echo "Not configured, exit"
			break
		fi
	done
}

#Main
if [[ $1 == "" ]];then
	echo "Power BY Stack GitHub:https://github.com/readour"
	echo "========================================="
	echo -e "You can running\e[32;49m servercheck.sh conf \e[0mto configure the program.\nAfter they run you should run\e[32;49m nohup servercheck.sh run & \e[0mto hang up it."
	echo -e "If you want to stop running this program.You should running \e[32;49m servercheck.sh stop \e[0m to stop it."
fi
if [[ $1 == stop ]];then
	thetime=`cat ${log_file} | head -n 5 | tail -n 1 | awk -F" = " '{ print $2 }'`
	PID=$(ps -ef |grep -v grep | grep "bash" | grep "servercheck.sh" | grep "run" | awk '{print $2}')
	if [[ -z ${PID} ]];then
		echo "The process does not exist, the program is not running or has ended"
	else
		kill -9 ${PID}
		PID=$(ps -ef |grep -v grep | grep "bash" | grep "servercheck.sh" | grep "run" | awk '{print $2}')
		if [[ -z ${PID} ]];then
			echo "Program has stopped working"
		else
			echo "End failed"
		fi
	fi
fi
if [[ $1 == hide ]];then
	values="1"
	nohup bash ${pwd}/servercheck.sh run &
fi
if [[ $1 == run ]];then
	values="1"
	runloop
fi
if [[ $1 == conf ]];then
	main
fi
if [[ $1 == reconf ]];then
	rm -f ${log_file}
	cd /usr/local/shadowsocksr
	python mujson_mgr.py -d -u $uname
	cd ${pwd}
	main
fi
if [[ $1 == log ]];then
	cat ${log_file}
	exit 0
fi
if [[ $1 == test ]];then
	PID=$(ps -ef |grep -v grep | grep "local.py" | grep "${local_port}" | awk '{print $2}')
	if [[ -z ${PID} ]];then
		dothetest
	else
		sleep 5s
		dothetest
	fi
fi
