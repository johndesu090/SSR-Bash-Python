#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo "1.Display all user traffic information"
echo "2.Clear the specified user traffic"
echo "3.Clear all user traffic"
echo "Enter directly to return to the previous menu"

while :; do echo
	read -p "please choose： " tc
	[ -z "$tc" ] && ssr && break
	if [[ ! $tc =~ ^[1-3]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break
	fi
done

if [[ $tc == 1 ]];then
	P_V=`python -V 2>&1 | awk '{print $2}'`
	P_V1=`python -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}'`
	if [[ ${P_V1} == 3 ]];then
		echo "Your current python version does not support this feature"
		echo "Current version: ${P_V}, please downgrade to version 2.x"
	else
		python /usr/local/SSR-Bash-Python/show_flow.py
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

if [[ $tc == 2 ]];then
	echo "1.Use username"
	echo "2.Use port"
	echo ""
	while :; do echo
		read -p "please choose： " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			echo "Typing error! Please enter the correct number!"
		else
			break	
		fi
	done

	if [[ $lsid == 1 ]];then
		read -p "Enter your username: " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -c -u $uid
		echo "Username cleared ${uid} User traffic"
	fi
	
	if [[ $lsid == 2 ]];then
		read -p "Enter the port number: " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -c -p $uid
		echo "The port number has been cleared to ${uid} User traffic"
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

if [[ $tc == 3 ]];then
	cd /usr/local/shadowsocksr
	python mujson_mgr.py -c
	echo "The traffic usage records of all users have been cleared"

	echo ""
	bash /usr/local/SSR-Bash-Python/traffic.sh
fi

