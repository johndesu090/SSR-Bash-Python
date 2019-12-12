#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Main
checkqr(){
	if [[ ! -e /usr/bin/qr ]];then
		if [[ ! -e /usr/local/bin/qr ]];then
			echo "You have not installed the QR code generation module"
			echo "Press Enter to continue, Ctrl + C to exit!"
			read -s
			echo "Installing, usually this does not take much time"
			pip -q install qrcode
			pip -q install git+git://github.com/ojii/pymaging.git
			pip -q install git+git://github.com/ojii/pymaging-png.git
			if [[ -e /usr/bin/qr ]];then
				echo "The installation is complete!"
			elif [[ -e /usr/local/bin/qr ]];then
				echo "The installation is complete!"
			else
				echo "Installation failed Please check if your Python is normal and try to reinstall"
				exit 1
			fi
		fi
	fi
}

readmsg(){
	cd /usr/local/shadowsocksr
	echo "Generate QR code for existing users:"
	echo ""
	echo "1.Use username"
	echo "2.Use port"
	echo ""
	while :; do echo
		read -p "please choose: " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			if [[ $lsid == "" ]]; then
				bash /usr/local/SSR-Bash-Python/user.sh 
				exit 0
			fi
			echo "Typing error! Please enter the correct number!"
		else
			break	
		fi
	done
	if [[ $lsid == 1 ]];then
		read -p "Enter your username: " uid
	elif [[ $lsid == 2 ]];then
		read -p "Enter the port number: " uid
	else
		echo "Typing error! Please enter the correct number!"
	fi
}

cleanwebqr(){
    sleep 120s
    screen -S $1 -X quit
    rm -rf /tmp/QR/$3
    iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $2 -j ACCEPT
}

rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}

checkmsg(){
if [[ $1 == "" ]];then
	readmsg
	if [[ $lsid == 1 ]];then
		ssrmsg=`python mujson_mgr.py -l -u $uid | tail -n 1 | sed 's/^[ \t]*//g'`
		username=`python mujson_mgr.py -l -u $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	elif [[ $lsid == 2 ]];then
		ssrmsg=`python mujson_mgr.py -l -p $uid | tail -n 1 | sed 's/^[ \t]*//g'`
		username=`python mujson_mgr.py -l -p $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	fi
elif [[ $1 == "u" ]];then
	ssrmsg=`python mujson_mgr.py -l -u $2 | tail -n 1 | sed 's/^[ \t]*//g'`
	username=`python mujson_mgr.py -l -u $2 | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
elif [[ $1 == "p" ]];then
	ssrmsg=`python mujson_mgr.py -l -p $2 | tail -n 1 | sed 's/^[ \t]*//g'`
	username=`python mujson_mgr.py -l -p $2 | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
fi
}
checkqr
while :;do
    checkmsg $1 $2
    if [[ -z ${username} || -z ${ssrmsg} ]];then
        echo "The username or port is invalid, please check for changes!"
    else
        break
    fi
done
cd ~
if [[ ! -d ./SSRQR ]];then
	mkdir SSRQR
fi
cd SSRQR
if [[ -e $username.png ]];then
	rm -f $username.png
fi
qr --factory=pymaging "$ssrmsg" > $username.png

while :;do
    cport=$(rand 1000 65535)
    port=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$cport"`
    if [[ -z ${port} ]];then
        break
    fi
done
cname=$(cat /dev/urandom | tr -dc A-Za-z0-9_ | head -c6 | sed 's/[ \r\b ]//g')

if [[ -e "$username.png" ]];then
	echo "Link information:$ssrmsg"
	echo "QR code generated successfully! ${HOME}/SSRQR/${username}.png"
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${cport} -j ACCEPT
    mkdir -p /tmp/QR/${username}
    cp "${HOME}/SSRQR/${username}.png" /tmp/QR/${username}
    cd /tmp/QR/${username}
    myip=`curl -m 10 -s http://members.3322.org/dyndns/getip`
    screen -dmS ${cname} python -m SimpleHTTPServer ${cport}
    cleanwebqr ${cname} ${cport} ${username} &
    echo "Please visit in time http://${myip}:${cport}/${username}.png To get the QR code, the link will expire after 120 seconds"
else
	echo "Due to strange reasons, the QR code failed to be generated successfully."
fi
