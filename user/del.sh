#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo "1.Use username"
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
	python mujson_mgr.py -d -u $uid
	echo "Username successfully deleted $uid User traffic"
fi
if [[ $lsid == 2 ]];then
	read -p "Enter the port number: " uid
	cd /usr/local/shadowsocksr
	python mujson_mgr.py -d -p $uid
	echo "Successfully deleted port number as $uid User traffic"
fi
