#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

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
echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
kill -9 $$
fi
uqr(){
	username=`python mujson_mgr.py -l -u $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	if [[ -e ~/SSRQR/$username.png ]];then
		bash /usr/local/SSR-Bash-Python/user/qrcode.sh u $uid
	fi
}
pqr(){
	username=`python mujson_mgr.py -l -p $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	if [[ -e ~/SSRQR/$username.png ]];then
		bash /usr/local/SSR-Bash-Python/user/qrcode.sh p $uid
	fi
}
echo -e "\n1.Use username"
echo "2.Use port"
echo ""
while :; do echo
	read -p "please choose: " lsid
	if [[ ! $lsid =~ ^[1-2]$ ]]; then
		if [[ $lsid == "" ]]; then
			bash /usr/local/SSR-Bash-Python/user.sh || exit 0
		fi
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
done
if [[ $lsid == 1 ]];then
	read -p "Enter your username: " uid
	cd /usr/local/shadowsocksr
	checkuid=$(python mujson_mgr.py -l -u $uid 2>/dev/null)
	if [[ -z ${checkuid} ]];then
		echo "User does not exist!"
		bash /usr/local/SSR-Bash-Python/user/edit.sh || exit 0
	else
		python mujson_mgr.py -l -u $uid
	fi
fi
if [[ $lsid == 2 ]];then
	read -p "Enter the port number: " uid
	cd /usr/local/shadowsocksr
	checkuid=$(python mujson_mgr.py -l -p $uid 2>/dev/null)
	if [[ -z ${checkuid} ]];then
		echo "User does not exist!"
		bash /usr/local/SSR-Bash-Python/user/edit.sh || exit 0
	else
		python mujson_mgr.py -l -p $uid
	fi
fi

echo -e "\n1.Change password"
echo "2.Modify encryption"
echo "3.Modify agreement"
echo "4.Modify obfuscation"
echo "5.Modify agreement parameter"
echo "6.Modify obfuscation parameter"
echo "7.Modify traffic"
echo "8.Modifying port restrictions"
echo "9.Modify the total port speed limit"
echo "10.Modify the number of connections"
echo "11.Modify time limit"
echo "12.Modify the port number"

while :; do echo
	read -p "please choose: " ec
	if [[ ! $ec =~ ^[1-9]$ ]]; then
		if [[ $ec == 10 ]]; then
			break
		elif [[ $ec == 11 ]]; then
			break
		elif [[ $ec == 12 ]]; then
			break
		fi
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
done

if [[ $ec == 1 ]];then
	read -p "enter password: " upass
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -k $upass
		echo "Username $uid password has been set to $upass"
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -k $upass
		echo "The port number $uid password has been set to $upass"
		pqr
	fi
fi
if [[ $ec == 2 ]];then
	echo "Encryption"
	echo '1.none'
	echo '2.aes-128-cfb'
	echo '3.aes-256-cfb'
	echo '4.aes-128-ctr'
	echo '5.aes-256-ctr'
	echo '6.rc4-md5'
	echo '7.chacha20'
	echo '8.chacha20-ietf'
	echo '9.salsa20'
	while :; do echo
		read -p " Enter new Encryption： " um
		if [[ ! $um =~ ^[1-9]$ ]]; then
			echo "Typing error! Please enter the correct number!"
		else
			break	
		fi
	done
	
	if [[ $um == 1 ]];then
		um1="none"
	fi
	if [[ $um == 2 ]];then
		um1="aes-128-cfb"
	fi
	if [[ $um == 3 ]];then
		um1="aes-256-cfb"
	fi
	if [[ $um == 4 ]];then
		um1="aes-128-ctr"
	fi
	if [[ $um == 5 ]];then
		um1="aes-256-ctr"
	fi
	if [[ $um == 6 ]];then
		um1="rc4-md5"
	fi
	if [[ $um == 7 ]];then
		um1="chacha20"
	fi
	if [[ $um == 8 ]];then
		um1="chacha20-ietf"
	fi
	if [[ $um == 9 ]];then
		um1="salsa20"
	fi
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -m $um1
		echo "Username $uid Encryption has been switched to $um1"
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -m $um1
		echo "The port number $uid Encryption has been switched to $um1"
		pqr
	fi
fi
if [[ $ec == 3 ]];then
	echo "Agreement method"
	echo '1.origin'
	echo '2.auth_sha1_v4'
	echo '3.auth_aes128_md5'
	echo '4.auth_aes128_sha1'
	echo '5.verify_deflate'
	echo '6.auth_chain_a'
	echo '7.auth_chain_b'
	echo '8.auth_chain_c'
	echo '9.auth_chain_d'
	echo '10.auth_chain_e'
	while :; do echo
	read -p "Enter Agreement method： " ux
	if [[ ! $ux =~ ^[1-9]$ ]]; then
		if [[ $ux == 10 ]]; then
			break
		fi
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
	done
	
	if [[ $ux == 2 ]];then
	while :; do echo
		read -p "Is it compatible with the original protocol（y/n）： " ifprotocolcompatible
		if [[ ! $ifprotocolcompatible =~ ^[y,n]$ ]]; then
			echo "Typing error! Please enter y or n!"
		else
			break
		fi
	done
	fi

	if [[ $ux == 1 ]];then
	ux1="origin"
	fi
	if [[ $ux == 2 ]];then
		ux1="auth_sha1_v4"
	fi
	if [[ $ux == 3 ]];then
		ux1="auth_aes128_md5"
	fi
	if [[ $ux == 4 ]];then
		ux1="auth_aes128_sha1"
	fi
	if [[ $ux == 5 ]];then
		ux1="verify_deflate"
	fi
	if [[ $ux == 6 ]];then
		ux1="auth_chain_a"
	fi
	if [[ $ux == 7 ]];then
		ux1="auth_chain_b"
	fi
	if [[ $ux == 8 ]];then
		ux1="auth_chain_c"
	fi
	if [[ $ux == 9 ]];then
		ux1="auth_chain_d"
	fi
	if [[ $ux == 10 ]];then
		ux1="auth_chain_e"
	fi

	if [[ $ifprotocolcompatible == y ]]; then
		ux1=${ux1}"_compatible"
	fi

	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -O $ux1
		echo "Username $uid Agreement method has been changed to $ux1"
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -O $ux1
		echo "The port number $uid Agreement method has been changed to $ux1"
		pqr
	fi
fi
if [[ $ec == 4 ]];then
	echo "Obfuscation"
	echo '1.plain'
	echo '2.http_simple'
	echo '3.http_post'
	echo '4.tls1.2_ticket_auth'
	while :; do echo
	read -p "Enter Obfuscation： " uo
	if [[ ! $uo =~ ^[1-4]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
	done
	
	if [[ $uo != 1 ]];then
		while :; do echo
			read -p "Is it compatible with the original obfuscation（y/n）： " ifobfscompatible
			if [[ ! $ifobfscompatible =~ ^[y,n]$ ]]; then
				echo "Typing error! Please enter y or n!"
			else
				break
			fi
		done
	fi

	if [[ $uo == 1 ]];then
		uo1="plain"
	fi
	if [[ $uo == 2 ]];then
		uo1="http_simple"
	fi
	if [[ $uo == 3 ]];then
		uo1="http_post"
	fi
	if [[ $uo == 4 ]];then
		uo1="tls1.2_ticket_auth"
	fi
	
	if [[ $ifobfscompatible == y ]]; then
		uo1=${uo1}"_compatible"
	fi
	
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -o $uo1
		echo "Username $uid Obfuscation has been changed to $uo1"
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -o $uo1
		echo "The port number $uid Obfuscation has been changed to $uo1"
	fi
fi
if [[ $ec == 5 ]];then
	read -p "Enter the protocol parameters: " ux2
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -G $ux2
		echo "Username $uid Protocol parameters changed to $ux2"
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -G $ux2
		echo "The port number $uid Protocol parameters changed to $ux2"
	fi
fi
if [[ $ec == 6 ]];then
	read -p "Enter obfuscation parameters: " uo2
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -g $uo2
		echo "Username $uid Obfuscation parameter has been changed to $uo2"
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -g $uo2
		echo "The port number $uid Obfuscation parameter has been changed to $uo2"
	fi
fi
if [[ $ec == 7 ]];then	
	while :; do echo
		read -p "Enter the traffic limit (just enter the number, unit: GB)： " ut
		if [[ "$ut" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
			break
		else
			echo 'Input Error! Please Try Again!'
		fi
	done
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -t $ut
		echo "Username $uid Traffic limit changed to $ut"
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -t $ut
		echo "The port number $uid Traffic limit changed to $ut"
		pqr
	fi
fi
if [[ $ec == 8 ]];then
	read -p "Input port restrictions (such as 1 ~ 80 and 90 ~ 100 input "1-80,90-100")： " ub
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		#python mujson_mgr.py -e -u $uid -f $ub
		echo "This feature is currently unavailable"
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		#python mujson_mgr.py -e -p $uid -f $ub
		echo "This feature is currently unavailable"
	fi
fi

if [[ $ec == 9 ]];then
	while :; do echo
		read -p "Total speed limit of input port (just enter numbers, unit: KB/s)： " us
		if [[ "$us" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
	   		break
		else
	   		echo 'Input Error!'
		fi
	done
	cd /usr/local/shadowsocksr
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -S $us
		echo "Username $uid User port speed limit has been modified to $us KB/s"
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -S $us
		echo "The port number $uid User port speed limit has been modified to $us KB/s"
		pqr
	fi
fi
 
if [[ $ec == 10 ]];then
	while :; do echo
		echo "Note: auth_* series protocols are not compatible with the original version."
		read -p "Enter the number of connections allowed (minimum 2 recommended)： " uparam
		if [[ "$uparam" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
	   		break
		else
	   		echo 'Input Error!'
		fi
	done
	if [[ $lsid == 1 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -u $uid -G $uparam
		echo "Username $uid The number of allowed connections has been modified to $uparam "
		uqr
	fi
	if [[ $lsid == 2 ]];then
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -e -p $uid -G $uparam
		echo "The port number $uid The number of allowed connections has been modified to $uparam "
		pqr
	fi
fi

if [[ $ec == 11 ]];then
	userlimit="/usr/local/SSR-Bash-Python/timelimit.db"
	if [[ ${lsid} == 1 ]];then
		port=$(python mujson_mgr.py -l -u ${uid} | grep "port :" | awk -F" : " '{ print $2 }')
		datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
		if [[ -z ${datelimit} ]];then
			datelimit="permanent"
		fi
		echo -e "Current user port number：${port},Valid until：${datelimit}\n"
		read -p "Please enter a new validity period (unit: month [m] day [d] hour [h], for example: 1m for 1 month) {default: permanent [a]}: " limit
		if [[ -z ${limit} ]];then
			limit="a"
		fi
		bash /usr/local/SSR-Bash-Python/timelimit.sh e ${port} ${limit} 
	fi
	if [[ ${lsid} == 2 ]];then
		datelimit=$(cat ${userlimit} | grep "${uid}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
		if [[ -z ${datelimit} ]];then
			datelimit="permanent"
		fi
		echo -e "Current user port number：${uid},Valid until：${datelimit}\n"
		read -p "Please enter a new validity period (unit: month [m] day [d] hour [h], for example: 1m for 1 month) {default: permanent [a]}: " limit
		if [[ -z ${limit} ]];then
			limit="a"
		fi
		bash /usr/local/SSR-Bash-Python/timelimit.sh e ${uid} ${limit}
		port=${uid}
	fi
	datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
	if [[ -z ${datelimit} ]];then
		datelimit="permanent"
	fi
	echo -e "Successfully modified! Current user port number：${port},New Valid until：${datelimit}\n"
fi

if [[ $ec == 12 ]];then
	if [[ ${lsid} == 1 ]];then
		port=$(python mujson_mgr.py -l -u ${uid} | grep "port :" | awk -F" : " '{ print $2 }')
	else
		port=${uid}
	fi
	while :;do
		read -p "Please enter a new port number:" newport
		if [[ "$newport" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
			if [[ ${newport} == ${port} ]];then
				echo -e "The new port number is the same as the original port number and cannot be changed. Exit!\n"
				exit 0
			fi
			if [[ $newport -ge "65535" || $newport -le "1" ]];then
				echo "Port range value[1,65535]"
			else
				checkport=$(netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$newport")
				if [[ -z ${checkport} ]];then
					break
				else
					echo "The port number already exists, please replace it!"
				fi
			fi
		else
			echo "Please key in numbers!"
		fi
	done
	cd /usr/local/shadowsocksr
	sed -i 's/"port": '"${port}"'/"port": '"${newport}"'/g' mudb.json
	if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
		iptables-restore < /etc/iptables.up.rules
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $newport -j ACCEPT
		iptables -I INPUT -m state --state NEW -m udp -p udp --dport $newport -j ACCEPT
		iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
		iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
		iptables-save > /etc/iptables.up.rules
	fi

	if [[ ${OS} == CentOS ]];then
		if [[ $CentOS_RHEL_version == 7 ]];then
			iptables-restore < /etc/iptables.up.rules
			iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $newport -j ACCEPT
    		iptables -I INPUT -m state --state NEW -m udp -p udp --dport $newport -j ACCEPT
    		iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
			iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
			iptables-save > /etc/iptables.up.rules
		else
			iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $newport -j ACCEPT
    		iptables -I INPUT -m state --state NEW -m udp -p udp --dport $newport -j ACCEPT
    		iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT
			iptables -D INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT
			/etc/init.d/iptables save
			/etc/init.d/iptables restart
		fi
	fi
	uid=${newport}
	pqr
	echo -e "The port number was successfully modified!\n"
fi
exit 0