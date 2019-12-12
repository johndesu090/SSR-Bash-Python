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

#Main
updateme(){
	cd ~
	if [[ -e ~/version.txt ]];then
		rm -f ~/version.txt
	fi
	wget -q https://git.fdos.me/stack/AR-B-P-B/raw/develop/version.txt
	version1=`cat ~/version.txt`
	version2=`cat /usr/local/SSR-Bash-Python/version.txt`
	if [[ "$version1" == "$version2" ]];then
		echo "You are currently up to date"
		sleep 2s
		ssr
	else
		echo "The latest version is $version1, enter y to update, other keys to exit"
		read -n 1 yn
		if [[ $yn == [Yy] ]];then
			export yn=n
			wget -q -N --no-check-certificate https://git.fdos.me/stack/AR-B-P-B/raw/master/install.sh && bash install.sh develop
			sleep 3s
			clear
			ssr || exit 0
		else
			echo "Typing error, exit"
			bash /usr/local/SSR-Bash-Python/self.sh
		fi
	fi
}
sumdc(){
	sum1=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "|head -c 2`
	sum2=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "|head -c 1`
	solve=`echo "$sum1-$sum2"|bc`
	echo -e "Please enter the result of the operation indicates that you have confirmed, and the input will exit"
	read sv
}
backup(){
	echo "Start backup!"
	mkdir -p ${HOME}/backup/tmp
	cd ${HOME}/backup/tmp
	cp /usr/local/shadowsocksr/mudb.json ./
	if [[ -e /usr/local/SSR-Bash-Python/check.log ]];then
		cp /usr/local/SSR-Bash-Python/check.log ./
	fi
	if [[ -e /usr/local/SSR-Bash-Python/timelimit.db ]];then
		cp /usr/local/SSR-Bash-Python/timelimit.db ./
	fi
	netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq >> ./port.conf
	wf=`ls | wc -l`
	if [[ $wf -ge 2 ]];then
		tar -zcvf ../ssr-conf.tar.gz ./*
	fi
	cd ..
	if [[ -e ./ssr-conf.tar.gz ]];then
		rm -rf ./tmp
		echo "The backup was successful and the file is located ${HOME}/backup/ssr-conf.tar.gz"
	else
		echo "Backup failed"
	fi
}
recover(){
mkdir -p ${HOME}/backup 
echo "This will cause your existing configuration to be overwritten"
sumdc
if [[ "$sv" == "$solve" ]];then
    bakf=$(ls ${HOME}/backup | wc -l)
    if [[ ${bakf} != 1 ]];then
        cd /usr/local/SSR-Bash-Python/Explorer 
        if [[ ! -e /bin/usleep  ]];then
            gcc -o /bin/usleep ./usleep.c
        fi
        read -p "No backup file found or multiple backup files exist, please select manually (press Y to open a file manager)" yn
        if [[ ${yn} == [Yy] ]];then
            chmod +x /usr/local/SSR-Bash-Python/Explorer/*
            bash ./Explorer.sh "${HOME}/backup"
	    chmod -x /usr/local/SSR-Bash-Python/Explorer/*
            bakfile=$(cat /tmp/BakFilename.tmp)
            if [[ ! -e ${bakfile} ]];then
                echo "invalid!"
            fi
        fi
    fi
	if [[ -z ${bakfile} ]];then
		bakfile=${HOME}/backup/ssr-conf.tar.gz 
	fi
	if [[ -e ${bakfile} ]];then
        cd ${HOME}/backup
		tar -zxvf ${bakfile} -C ./
		if [[ -e ./check.log ]];then
			mv ./check.log /usr/local/SSR-Bash-Python/check.log
		fi
		if [[ -e /usr/local/SSR-Bash-Python/timelimit.db ]];then
			mv ./timelimit.db /usr/local/SSR-Bash-Python/timelimit.db
		fi
		if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
			iptables-restore < /etc/iptables.up.rules
			for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
			for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
			iptables-save > /etc/iptables.up.rules
			iptables -vnL
		fi
		if [[ ${OS} == CentOS ]];then
			if [[ $CentOS_RHEL_version == 7 ]];then
				iptables-restore < /etc/iptables.up.rules
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
				iptables-save > /etc/iptables.up.rules
				iptables -vnL
			else
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done 
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
				/etc/init.d/iptables save
				/etc/init.d/iptables restart
				iptables -vnL && sed -i '5a#tcp port rule' /etc/sysconfig/iptables
			fi
		fi
		rm -f /usr/local/shadowsocksr/mudb.json
		mv ./mudb.json /usr/local/shadowsocksr/mudb.json
		rm -f ./port.conf
		echo "The restore operation is complete, and it starts to check whether it has taken effect!"
		bash /usr/local/SSR-Bash-Python/servercheck.sh test
		if [[ -z ${SSRcheck} ]];then
			echo "The configuration has taken effect and the restore was successful"
		else
			echo "Configuration did not take effect, restore failed, please contact the author to resolve"
		fi
		rm /tmp/BakFilename.tmp
	else
		echo "The backup file does not exist, please check！"
	fi
else
	echo "Calculation error, correct result is $solve"
fi
}
#Show
echo "Input number selection function："
echo ""
echo "1.Check for updates"
echo "2.Switch to the regular version"
echo "3.Program self-test"
echo "4.Uninstall program"
echo "5.Backup configuration"
echo "6.Restore configuration"
while :; do echo
	read -p "please choose： " choice
	if [[ ! $choice =~ ^[1-6]$ ]]; then
		[ -z "$choice" ] && ssr && break
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
done

if [[ $choice == 1 ]];then
        updateme
fi
if [[ $choice == 2 ]];then
	echo "You will not be able to use some features after switching to the regular version"
	sumdc
	if [[ "$sv" == "$solve" ]];then
		bash /usr/local/SSR-Bash-Python/install.sh
		sleep 3s
		clear
		ssr || exit 0
	else
		echo "Calculation error, correct result is $solve"
		bash /usr/local/SSR-Bash-Python/self.sh
	fi
fi
if [[ $choice == 3 ]];then
	bash /usr/local/SSR-Bash-Python/self-check.sh
fi
if [[ $choice == 4 ]];then
	echo "what are you doing? Are you really so cruel?"
	sumdc
	if [[ "$sv" == "$solve" ]];then
		bash /usr/local/SSR-Bash-Python/install.sh uninstall
		exit 0
	else
		echo "Calculation error, correct result is $solve"
		bash /usr/local/SSR-Bash-Python/self.sh
	fi
fi
if [[ $choice == 5 ]];then
	if [[ ! -e ${HOME}/backup/ssr-conf.tar.gz ]];then
		backup
	else
		cd ${HOME}/backup
		mv ./ssr-conf.tar.gz ./ssr-conf-`date +%Y-%m-%d_%H:%M:%S`.tar.gz
		backup
	fi
	bash /usr/local/SSR-Bash-Python/self.sh
fi
if [[ $choice == 6 ]];then
	recover
	bash /usr/local/SSR-Bash-Python/self.sh
fi
exit 0
