 #!/bin/bash

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Initialization
userlimit="/usr/local/SSR-Bash-Python/timelimit.db"
nowdate=$(date +%Y%m%d%H%M)
declare -a param=($1 $2 $3)
unset edit

#Set function
checkonly(){
	if [[ -e ${userlimit} ]];then
		for line in $(cat ${userlimit})
		do
			if [[ ! -z ${line} ]];then
				port=$(echo ${line} | awk -F':' '{ print $1 }')
				limitdate=$(echo ${line} | awk -F':' '{ print $2 }')
				if [[ ${nowdate} -ge ${limitdate} ]];then
					cd /usr/local/shadowsocksr/
					python mujson_mgr.py -d -p ${port} 1>/dev/null 2>&1
					sed -i '/'"${line}"'/d' ${userlimit}
				fi
			fi
		done
	fi
}

Add(){
	if [[ ! -e ${userlimit} ]];then
		touch ${userlimit}
	fi
	checkuser=$(grep -i "${param[1]}:" ${userlimit})
	if [[ ${edit} == "yes" || -z ${checkuser} ]];then
		if [[ ${param[2]} == *d ]];then
			timing=$(echo ${param[2]} | sed 's\d\\g')
			dating=$(date +%Y%m%d%H%M --date="+${timing}day")
		elif [[ ${param[2]} == *m ]];then
			timing=$(echo ${param[2]} | sed 's\m\\g')
			dating=$(date +%Y%m%d%H%M --date="+${timing}month")
		elif [[ ${param[2]} == *h ]];then
			timing=$(echo ${param[2]} | sed 's\h\\g')
			dating=$(date +%Y%m%d%H%M --date="+${timing}hour")
		elif [[ ${param[2]} == "a" ]];then
			exit 0
		else
			echo "Incorrect parameter attribute value"
			exit 1
		fi
		echo "${param[1]}:${dating}" >> ${userlimit}
	else
		Edit
	fi
}

Edit(){
	checkuser=$(grep -i "${param[1]}:" ${userlimit})
	if [[ -z ${checkuser} ]];then
		Add
	else
		limitdate=$(echo ${checkuser} | awk -F':' '{ print $2 }')
		edit="yes"
		sed -i '/'"${checkuser}"'/d' ${userlimit}
		Add
	fi
}

EasyAdd(){
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
	if [[ ${lsid} == 1 ]];then
		read -p "Enter your username: " uid
		cd /usr/local/shadowsocksr
		checkuid=$(python mujson_mgr.py -l -u ${uid})
		if [[ -z ${checkuid} ]];then
			echo "Username does not exist!"
			EasyAdd
		else
			read -p "Please enter the validity period (unit: month [m] day [d] hour [h], for example: 1m for 1 month) {default: one month [1m]}: " limit
			if [[ -z ${limit} ]];then
				limit="1m"
			fi
			port=$(python mujson_mgr.py -l -u ${uid} | grep "port :" | awk -F" : " '{ print $2 }')
			bash /usr/local/SSR-Bash-Python/timelimit.sh a ${port} ${limit} || EasyAdd
			datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
			if [[ -z ${datelimit} ]];then
				datelimit="permanent"
			fi
			echo -e "Added successfully! Current user port number：${port},Valid until：${datelimit}\n"
		fi
	fi
	if [[ ${lsid} == 2 ]];then
		read -p "Enter the port number: " port
		cd /usr/local/shadowsocksr
		checkuid=$(python mujson_mgr.py -l -p ${port})
		if [[ -z ${checkuid} ]];then
			echo "User does not exist!"
			EasyAdd
		else
			read -p "Please enter the validity period (unit: month [m] day [d] hour [h], for example: 1m for 1 month) {default: one month [1m]}: " limit
			if [[ -z ${limit} ]];then
				limit="1m"
			fi
			bash /usr/local/SSR-Bash-Python/timelimit.sh a ${port} ${limit} || EasyAdd
			datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
			if [[ -z ${datelimit} ]];then
				datelimit="permanent"
			fi
			echo -e "Added successfully! Current user port number：${port},Valid until：${datelimit}\n"
		fi
	fi
}

EasyEdit(){
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
	if [[ ${lsid} == 1 ]];then
		read -p "Enter your username: " uid
		cd /usr/local/shadowsocksr
		checkuid=$(python mujson_mgr.py -l -u ${uid})
		if [[ -z ${checkuid} ]];then
			echo "Username does not exist!"
			EasyEdit
		else
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
		fi
	fi
	if [[ ${lsid} == 2 ]];then
		read -p "Enter the port number: " port
		cd /usr/local/shadowsocksr
		checkuid=$(python mujson_mgr.py -l -p ${port} 2>/dev/null)
		if [[ -z ${checkuid} ]];then
			echo "User does not exist!"
			EasyEdit
		else
			datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
			if [[ -z ${datelimit} ]];then
				datelimit="permanent"
			fi
			echo -e "Current user port number：${port},Valid until：${datelimit}\n"
			read -p "Please enter a new validity period (unit: month [m] day [d] hour [h], for example: 1m for 1 month) {default: permanent [a]}: " limit
			if [[ -z ${limit} ]];then
				limit="a"
			fi
		fi
	fi
	bash /usr/local/SSR-Bash-Python/timelimit.sh e ${port} ${limit} || EasyEdit
	datelimit=$(cat ${userlimit} | grep "${port}:" | awk -F":" '{ print $2 }' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9}\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1年\2月\3日 \4:/')
	if [[ -z ${datelimit} ]];then
		datelimit="permanent"
	fi
	echo -e "Successful modification! Current user port number: $ {port}, new Valid until：${datelimit}\n"
}

readme(){
	echo "Usage: $0 params [port] [expiration time]"
	echo "params can be one or more of the following :"
	echo "    a | A    : Add a time limit for a user."
	echo "    e | E    : Modify a user's time limit."
	echo "If you do not add any parameters after the first parameter,you will enter a simple interface to operate."
	echo ""
	echo 'About the second parameter "port" :'
	echo "    As the unique identifier of a user,the port number is unique and the script determines the user's basis.So when you add an account with the same port number,the script will overwrite the original record without any hint."
	echo ""
	echo 'About the third parameter "expiration time" :'
	echo '    Account expiration date refers to the period from the current date.This is true whether it is added or modified.The format is "number+unit".For example,one month is "1m",one day is "1d" and one hour is "1h".'
	echo ""
	echo "Note: This script does not interact with other scripts.When you add traffic to a user, the script will still be deleted as before."
	echo ""
	echo "e.g.: "
	echo "bash ./timelimit.sh a 443 1m      #You will add a month's validity to a user with a port number of 443."
	echo ""
	echo "If you find a bug, send it to 'johnford090@gmail.com'"
}

#Main
case ${param[0]} in
	a|A)
 		if [[ -z ${param[1]} && -z ${param[2]} ]];then
 			EasyAdd
 		else
 			Add
 		fi
 		;;
 	e|E)
 		if [[ -z ${param[1]} && -z ${param[2]} ]];then
 			EasyEdit
 		else
 			Edit
 		fi
 		;;
 	c|C)
 		checkonly
 		;;
 	*)
 		readme
 		;;
esac
exit 0