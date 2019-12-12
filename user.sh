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

echo ""
echo '1.Add users in one click'
echo '2.Add user'
echo '3.Delete user'
echo '4.Modify user'
echo '5.Display user traffic information'
echo '6.Display username and port information'
echo '7.View port user connection status'
echo '8.Generate user QR code'
echo '9.Add validity period to existing account'
echo "Enter directly to return to the previous menu"

while :; do echo
	read -p "please choose: " userc
        if [[ -z "$userc" ]];then  
                ssr
                break
        fi
	if [[ ! $userc =~ ^[1-9]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
done

if [[ $userc == 1 ]];then
	bash /usr/local/SSR-Bash-Python/user/easyadd.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 2 ]];then
	bash /usr/local/SSR-Bash-Python/user/add.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 3 ]];then
	bash /usr/local/SSR-Bash-Python/user/del.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 4 ]];then
	bash /usr/local/SSR-Bash-Python/user/edit.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 5 ]];then
	echo "1.Use username"
	echo "2.Use port"
	echo ""
	while :; do echo
		read -p "please choose: " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			echo "Typing error! Please enter the correct number!"
		else
			break	
		fi
	done
	if [[ $lsid == 1 ]];then
		read -p "Enter your username: " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -l -u $uid
	fi
	if [[ $lsid == 2 ]];then
		read -p "Enter the port number: " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -l -p $uid
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 6 ]];then
	P_V=`python -V 2>&1 | awk '{print $2}'`
	P_V1=`python -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}'`
	if [[ ${P_V1} == 3 ]];then
		echo "Your current python version does not support this feature"
		echo "Current version: ${P_V}, please downgrade to version 2.x"
	else
		python /usr/local/SSR-Bash-Python/user/show_all_user_info.py
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 7 ]];then
	read -p "Please enter the user port number:  " uid
	if [[ "$uid" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
		port=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$uid"`
		if [[ -z ${port} ]];then
			echo "The port number does not exist"
			sleep 2s
			bash /usr/local/SSR-Bash-Python/user.sh
		else
			n=$(netstat -ntu | grep :${uid} | grep  "ESTABLISHED" | awk '{print $5}' | cut -d : -f 1 | sort -u | wc -l)
			echo -e "Current port number \e[41;37m${uid}\e[0m total \e[42;37m${n}\e[0m user connections"
			i=1
			for ips in `netstat -ntu | grep :${uid} | grep  "ESTABLISHED" | awk '{print $5}' | cut -d : -f 1 | sort -u`
			do
				if [[ $i -ge 3 ]];then
					sleep 1s
				fi
				if [[ $i -ge 5 ]];then
					sleep 2s
				fi
                theip=$(curl -L -s ip.cn/${ips})
                if [[ -z ${theip} ]];then
                    ipadd=$(curl -L -s freeapi.ipip.net/${ips} | sed 's/\"//g;s/,//g;s/\[//g;s/\]//g')
                    theip=$(echo "当前 IP: ${ips} 来自: ${ipadd}")
                fi
                echo ${theip}
				i=$((i+1))
			done
			echo "You can enter the IP address and add it to the blacklist. This cannot be undone (press Enter to return)"
			while : 
			do
				read ip
				if [[ -z ${ip} ]];then
					break
				fi
				regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
				ckStep2=$(echo $ip | egrep $regex | wc -l)
				if [[ $ckStep2 -eq 0 ]];then
					echo "Invalid ip address"
					echo "Please enter again"
				else
					break
				fi
			done
			if [[ -z ${ip} ]];then
				bash /usr/local/SSR-Bash-Python/user.sh
				exit 0
			fi
			banip=$(iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep "$ip")
			if [[ ! -z ${banip} ]];then
				echo "The IP address ${ip} already exists on the banned list, please do not execute it again!"
				echo "List of current bans:"
				iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -nr 
				bash /usr/local/SSR-Bash-Python/user.sh
				exit 0
			fi
			rsum=`date +%s%N | md5sum | head -c 6`
			echo -e "Enter below \e[31;49m $rsum \e[0m Indicates that you are sure IP：${ip} Blacklisted, this is currently unrecoverable"
			read -n 6 -p "please enter: " choise
			if [[ $choise == $rsum ]];then
				if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
					iptables-restore < /etc/iptables.up.rules
					iptables -A INPUT -s ${ip} -j DROP
					iptables-save > /etc/iptables.up.rules
				fi
				if [[ ${OS} == CentOS ]];then
					if [[ $CentOS_RHEL_version == 7 ]];then
						iptables-restore < /etc/iptables.up.rules
						iptables -A INPUT -s ${ip} -j DROP
						iptables-save > /etc/iptables.up.rules
					else
						iptables -A INPUT -s ${ip} -j DROP
						/etc/init.d/iptables save
						/etc/init.d/iptables restart
					fi
				fi
				echo "List of current bans:"
				iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -nr
			else
				echo "input error"
				sleep 2s
			fi
		fi
	fi
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 8 ]];then
	bash /usr/local/SSR-Bash-Python/user/qrcode.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 9 ]];then
	bash /usr/local/SSR-Bash-Python/timelimit.sh a
	bash /usr/local/SSR-Bash-Python/user.sh
fi
exit 0
