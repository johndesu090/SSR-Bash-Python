#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

AutoIptables(){
    rsum=`date +%s%N | md5sum | head -c 6`
    echo "Please note before use, this function will reset the firewall configuration, existing connections may be interrupted."
    echo -e "Enter below to indicate that you are aware of the risks and agree to continue"
    read readsum
    if [[ ${readsum} == ${rsum} ]];then
        netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq >> ./port.conf
        bash /usr/local/SSR-Bash-Python/iptables2.sh
        if [[ ${OS} =~ ^Ubuntu$|^Debian$  ]];then
            iptables-restore < /etc/iptables.up.rules
            for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
            for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
            iptables-save > /etc/iptables.up.rules
        fi
        if [[ ${OS} == CentOS  ]];then
           if [[ $CentOS_RHEL_version == 7  ]];then
               iptables-restore < /etc/iptables.up.rules
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
               iptables-save > /etc/iptables.up.rules
           else
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done 
               for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
               /etc/init.d/iptables save
               /etc/init.d/iptables restart
           fi
        fi
        rm -f ./port.conf
    else
        echo "Typing error, exit!"
        bash /usr/local/SSR-Bash-Python/dev.sh
        exit 0
    fi
}
echo "Test area, do not use at will"
echo "1.Update SSR-Bsah"
echo "2.One-click blocking of BT download, SPAM email traffic (cannot be undone)"
echo "3.Prevent brute force SS connection information (failure after restart)"
echo "4.Deploy ssr-panel"
echo "5.BBR Console"
echo "6.Rui Su Console"
echo "7.LotServer Console"
echo "8.UML-LKL(OpenVZ-BBR)installation"
echo "9.Firewall enhanced configuration (risky)"
while :; do echo
	read -p "Please select： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-9]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
done

if [[ $devc == 1 ]];then
	rm -rf /usr/local/bin/ssr
	cd /usr/local/SSR-Bash-Python/
	git pull
	wget -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/readour/AR-B-P-B/develop/ssr
	chmod +x /usr/local/bin/ssr
	echo 'SSR-Bash update success'
	ssr
fi

if [[ $devc == 2 ]];then
	wget -q -N --no-check-certificate https://raw.githubusercontent.com/johndesu090/SSRcentos/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh banall
	rm -rf ban_iptables.sh
fi

if [[ $devc == 3 ]];then
	nohup tail -F /usr/local/shadowsocksr/ssserver.log | python autoban.py >log 2>log &
fi

if [[ $devc == 4 ]];then
	#Code from：https://91vps.us/2017/08/24/ss-panel-v3-mod/
	rsum=`date +%s%N | md5sum | head -c 6`
	echo "You are about to deploy ss-panel. The whole process takes a long time and there are risks. Please ensure that your system is clean."
	echo "To avoid accidental disconnection and installation interruption, it is recommended to run in screen"
	echo "The installation script was not written by me, source：https://github.com/mmmwhy/ss-panel-and-ss-py-mu/blob/master/ss-panel-v3-mod.sh"
	echo "Default account: 91vps Default password: 91vps"
	echo -e "Enter below to indicate that you are aware of the risks and agree to the installation. Entering other content will exit the installation！"
	read -n 6 -p "please enter： " choise
	if [[ $choise == $rsum ]];then
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/ss-panel-v3-mod.sh && chmod +x ss-panel-v3-mod.sh && bash ss-panel-v3-mod.sh
	else
		echo "Typing error, installation exit！"
		sleep 2s
		ssr
	fi
fi
bbrcheck(){
cd /usr/local/SSR-Bash-Python
#GitHub:https://github.com/ToyoDAdoubi
if [[ ! -e bbr.sh ]]; then
	echo "No BBR script found, start downloading..."
	if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh; then
		echo "BBR Script download failed !" && exit 1
	else
		echo "BBR Script download completed !"
		chmod +x bbr.sh
	fi
fi
}
if [[ $devc == 5 ]];then 
	[[ $OS = "CentOS" ]] && echo "This script does not support CentOS BBR !" && exit 1
	echo "what are you going to do？"
	echo "1.Install BBR"
	echo "————————"
	echo "2.Start BBR"
	echo "3.Stop BBR"
	echo "4.View BBR status"
	echo ""
	while :; do echo
	read -p "please choose： " ubbr
	[ -z "$ubbr" ] && ssr && break
	if [[ ! $ubbr =~ ^[1-4]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
	done
	if [[ $ubbr == 1 ]];then
		rsum=`date +%s%N | md5sum | head -c 6`
		echo " [Please note before installation]"
		echo "1. Install and start BBR, need to replace the kernel, there is a risk of replacement failure (cannot boot after restart)"
		echo "2. This script only supports Debian / Ubuntu system to replace the kernel, OpenVZ and Docker do not support kernel replacement"
		echo "3. During the Debian kernel replacement, you will be prompted [Are you sure you want to stop uninstalling the kernel], please select NO "
		echo ""
		echo -e "Enter below to indicate that you are aware of the risks and agree to the installation. Entering other content will exit the installation！"
		read -n 6 -p "please choose： " choise
		if [[ $choise == $rsum ]];then
			bbrcheck
			bash bbr.sh
		else
			echo "Typing error, installation exit！"
			sleep 2s
			ssr
		fi
	fi
	if [[ $ubbr == 2 ]];then
		bbrcheck
		bash bbr.sh start
	fi
	if [[ $ubbr == 3 ]];then
		bbrcheck
		bash bbr.sh stop
	fi
	if [[ $ubbr == 4 ]];then
		bbrcheck
		bash bbr.sh status
	fi
fi
install_rz(){
	[[ -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Sharp Speed(Server Speeder) has been installed !" && ssr
	cd /usr/local/SSR-Bash-Python
	#Borrow 91yun.rog's happy version of sharp speed
	wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder.sh
	[[ ! -e "serverspeeder.sh" ]] && echo "Sharp Speed installation script download failed !" && ssr
	bash serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /usr/local/SSR-Bash-Python/serverspeeder.sh
		rm -rf /usr/local/SSR-Bash-Python/91yunserverspeeder
		rm -rf /usr/local/SSR-Bash-Python/91yunserverspeeder.tar.gz
		echo "Sharp Speed(Server Speeder) The installation is complete !" && exit 0
	else
		echo "Sharp Speed(Server Speeder) installation failed !" && exit 1
	fi
}
if [[ $devc == 6 ]];then
	echo "what are you going to do？"
	echo "1.Install Sharp Speed"
	echo "2.Uninstall Sharp Speed"
	echo "————————"
	echo "3.Start Sharp Speed"
	echo "4.Stop Sharp Speed"
	echo "5.Restart Sharp Speed"
	echo "6.View Sharp Speed status"
	echo "note： Sharp Speed And LotServer cannot be installed / started at the same time！"
	while :; do echo
	read -p "please choose： " urz
	[ -z "$urz" ] && ssr && break
	if [[ ! $urz =~ ^[1-6]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
	done
	if [[ $urz == 1 ]];then
		install_rz
	fi
	if [[ $urz == 2 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Not installed Sharp Speed(Server Speeder)，Please check !" && exit 1
		echo "Sure to uninstall Sharp Speed(Server Speeder)？[y/N]" && echo
		stty erase '^H' && read -p "(Default: n):" unyn
		[[ -z ${unyn} ]] && echo && echo "Cancelled..." && exit 1
		if [[ ${unyn} == [Yy] ]]; then
			chattr -i /serverspeeder/etc/apx*
			/serverspeeder/bin/serverSpeeder.sh uninstall -f
			echo && echo "Sharp Speed(Server Speeder) Uninstall complete !" && echo
		fi
	fi
	if [[ $urz == 3 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Not installed Sharp Speed(Server Speeder)，Please check !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh start
		/serverspeeder/bin/serverSpeeder.sh status
	fi
	if [[ $urz == 4 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Not installed Sharp Speed(Server Speeder)，Please check !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh stop
	fi
	if [[ $urz == 5 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Not installed Sharp Speed(Server Speeder)，Please check !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh restart
		/serverspeeder/bin/serverSpeeder.sh status
	fi
	if [[ $urz == 6 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "Not installed Sharp Speed(Server Speeder)，Please check !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh status
	fi
fi
install_ls(){
	[[ -e /appex/bin/serverSpeeder.sh ]] && echo "LotServer has been installed !" && exit 1
	#Github: https://github.com/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh"
	[[ ! -e "/tmp/appex.sh" ]] && echo "LotServer Installation script download failed !" && exit 1
	bash /tmp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo "LotServer The installation is complete !" && exit 1
	else
		echo "LotServer installation failed !" && exit 1
	fi
}
if [[ $devc == 7 ]];then
	echo "what are you going to do？"
	echo "1.Install LotServer"
	echo "2.Uninstall LotServer"
	echo "————————"
	echo "3.Start LotServer"
	echo "4.Stop LotServer"
	echo "5.Restart LotServer"
	echo "6.View LotServer status"
	echo "note： Sharp Speed with LotServer Not both Install/Start！"
	while :; do echo
	read -p "please choose： " uls
	[ -z "$uls" ] && ssr && break
	if [[ ! $uls =~ ^[1-6]$ ]]; then
		echo "Typing error! Please enter the correct number!"
	else
		break	
	fi
	done
	if [[ $uls == 1 ]];then
		install_ls
	fi
	if [[ $uls == 2 ]];then 
		echo "Sure to uninstall LotServer？[y/N]" && echo
		stty erase '^H' && read -p "(Default: n):" unyn
		[[ -z ${unyn} ]] && echo && echo "Cancelled..." && exit 1
		if [[ ${unyn} == [Yy] ]]; then
			wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
			echo && echo "LotServer Uninstall complete !" && echo
		fi
	fi
	if [[ $uls == 3 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "Not installed LotServer，Please check !" && exit 1
		/appex/bin/serverSpeeder.sh start
		/appex/bin/serverSpeeder.sh status
	fi
	if [[ $uls == 4 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "Not installed LotServer，Please check !" && exit 1
		/appex/bin/serverSpeeder.sh stop
	fi
	if [[ $uls == 5 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "Not installed LotServer，Please check !" && exit 1
		/appex/bin/serverSpeeder.sh restart
		/appex/bin/serverSpeeder.sh status
	fi
	if [[ $uls == 6 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "Not installed LotServer，Please check !" && exit 1
		/appex/bin/serverSpeeder.sh status
	fi
fi
if [[ $devc == 8 ]];then
	cd /usr/local/SSR-Bash-Python
	if [[ -e /root/lkl/run.sh ]];then
		echo "you has been installed over LKL"
	else
		echo "开始InstallLKL"
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Huiaini/UML-LKL/master/lkl-install.sh && bash lkl-install.sh
		rm -f lkl-install.sh
	fi
	if [[ -d $PWD/uml-ssr-64 ]];then
		echo "you has been installed over UML"
	else
		echo "Start Install 
		UML"
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Huiaini/UML-LKL/master/uml.sh && bash uml.sh
	fi
fi
if [[ $devc == 9  ]];then
    AutoIptables
    bash /usr/local/SSR-Bash-Python/dev.sh
    exit 0
fi
