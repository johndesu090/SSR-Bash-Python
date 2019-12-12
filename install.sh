#!/bin/bash
#Set PATH
unset check
for i in `echo $PATH | sed 's/:/\n/g'`
do
        if [[ ${i} == "/usr/local/bin" ]];then
                check="yes"
        fi
done
if [[ -z ${check} ]];then
        echo "export PATH=${PATH}:/usr/local/bin" >> ~/.bashrc
        . ~/.bashrc
fi

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

StopInstall(){
    echo -e "\nInstallation aborted and started cleaning files!"
    sleep 1s
    rm -rf /usr/local/bin/ssr
    rm -rf /usr/local/SSR-Bash-Python
    rm -rf /usr/local/shadowsocksr
    rm -rf ${PWD}/libsodium*
    rm -rf /etc/init.d/ssr-bash-python
    rm -rf /usr/local/AR-B-P-B
    if [[ ${OS} == CentOS  ]];then
        sed -n -i 's#/etc/init.d/ssr-bash-python#d' /etc/rc.d/rc.local
    fi
    if [[ ${OS} == CentOS && ${CentOS_RHEL_version} == 7  ]];then
        systemctl stop iptables.service
        systemctl restart firewalld.service
        systemctl disable iptables.service
        systemctl enable firewalld.service
    fi
    checkcron=$(crontab -l 2>/dev/null | grep "timelimit.sh")
    if [[ ! -z ${checkcron} ]];then
        crontab -l > ~/crontab.bak 1>/dev/null 2>&1
        sed -i "/timelimit.sh/d" ~/crontab.bak 1>/dev/null 2>&1
        crontab ~/crontab.bak 1>/dev/null 2>&1
        rm -rf ~/crontab.bak
    fi
    rm -rf $0
    echo "Cleaned up!"
}

#Get Current Directory
workdir=$(pwd)

#Install Basic Tools
if [ ! -e /usr/local/bin/ssr ];then
if [[ $1 == "uninstall" ]];then
	echo "Are you joking? How to uninstall without you installing！"
	exit 1
fi
echo "Start deployment"
trap 'StopInstall 2>/dev/null && exit 0' 2
sleep 2s
if [[ ${OS} == Ubuntu ]];then
	apt-get update
	apt-get install python -y
	apt-get install python-pip -y
	apt-get install git -y
	apt-get install language-pack-zh-hans -y
	apt-get -y install vnstat bc
    apt-get -y install net-tools
    apt-get install build-essential screen curl -y
    apt-get install cron -y
fi
if [[ ${OS} == CentOS ]];then
	yum install python screen curl -y
	yum install python-setuptools -y && easy_install pip -y
	yum install git -y
	yum install bc -y
	yum install vnstat -y
	yum install net-tools -y
    yum groupinstall "Development Tools" -y
    yum install vixie-cron crontabs -y
fi
if [[ ${OS} == Debian ]];then
	apt-get update
	apt-get install python screen curl -y
	apt-get install python-pip -y
	apt-get install git -y
	apt-get -y install net-tools
	apt-get -y install bc vnstat
    apt-get install build-essential -y
    apt-get install cron -y
fi
if [[ $? != 0 ]];then
    echo "Installation failed, please try again later！"
    exit 1 
fi
#Install Libsodium
libsodiumfilea="/usr/local/lib/libsodium.so"
libsodiumfileb="/usr/lib/libsodium.so"
if [[ -e ${libsodiumfilea} ]];then
    echo "libsodium It has been installed!"
elif [[ -e ${libsodiumfileb} ]];then
    echo "libsodium It has been installed!"
else
    cd $workdir
    export LIBSODIUM_VER=1.0.16
    wget -q https://github.com/jedisct1/libsodium/releases/download/${LIBSODIUM_VER}/libsodium-$LIBSODIUM_VER.tar.gz
    tar xvf libsodium-$LIBSODIUM_VER.tar.gz
    pushd libsodium-$LIBSODIUM_VER
    ./configure --prefix=/usr && make
    make install
    popd
    ldconfig
    cd $workdir && rm -rf libsodium-$LIBSODIUM_VER.tar.gz libsodium-$LIBSODIUM_VER
#    if [[ ! -e ${libsodiumfile} ]];then
#    	echo "libsodium installation failed!"
#    	exit 1
#    fi
fi
cd /usr/local
git clone https://github.com/johndesu090/shadowsocksr
cd ./shadowsocksr
git checkout manyuser
git pull
if [ $1 == "develop" ];then
    git checkout stack/dev
fi
fi

#Install SSR and SSR-Bash
if [ -e /usr/local/bin/ssr ];then
	if [[ $1 == "uninstall" ]];then
		echo "Start uninstall"
		sleep 1s
		echo "Delete:/usr/local/bin/ssr"
		rm -f /usr/local/bin/ssr
		echo "Delete:/usr/local/SSR-Bash-Python"
		rm -rf /usr/local/SSR-Bash-Python
		echo "Delete:/usr/local/shadowsocksr"
		rm -rf /usr/local/shadowsocksr
		echo "Delete:${PWD}/install.sh"
		rm -f ${PWD}/install.sh
        echo "Clean up miscellaneous!"
        crontab -l > ~/crontab.bak 1>/dev/null 2>&1
        sed -i "/timelimit.sh/d" ~/crontab.bak 1>/dev/null 2>&1
        crontab ~/crontab.bak 1>/dev/null 2>&1
        rm -rf ~/crontab.bak
		sleep 1s
		echo "Uninstall complete!!"
		exit 0
	fi
    if [[ ! $yn == n ]];then
        if [[ ! -e /usr/local/SSR-Bash-Python/version.txt ]];then
        	yn="y"
        fi
    fi
    if [[ ${yn} == [yY] ]];then
        mv /usr/local/shadowsocksr/mudb.json /usr/local/mudb.json
        rm -rf /usr/local/shadowsocksr
        cd /usr/local
        git clone https://github.com/johndesu090/shadowsocksr
        if [[ $1 == develop ]];then
            cd ./shadowsocksr
            git checkout stack/dev
            rm -f ./mudb.json
            mv ../mudb.json ./mudb.json
        else
            rm -f ./shadowsocksr/mudb.json
            mv /usr/local/mudb.json /usr/local/shadowsocksr/mudb.json
        fi
    fi
	echo "Start Update"
	sleep 1s
	echo "Cleaning up older versions"
	rm -f /usr/local/bin/ssr
	sleep 1s
	echo "Start deployment"
	cd /usr/local/shadowsocksr
	git pull
    git checkout manyuser
    if [[ $1 == "develop" ]];then
        git checkout stack/dev
    fi
fi
if [[ -d /usr/local/SSR-Bash-Python ]];then
    if [[ $yn == [yY] ]];then
        rm -rf /usr/local/SSR-Bash-Python
        cd /usr/local
        git clone https://github.com/johndesu090/SSR-Bash-Python.git
    fi
    cd /usr/local/SSR-Bash-Python
    git checkout master
    git pull
    if [[ $1 == "develop" ]];then
        git checkout develop
        git pull
    fi
else
    cd /usr/local
    git clone https://github.com/johndesu090/SSR-Bash-Python.git	
    cd SSR-Bash-Python
    git checkout master
    if [[ $1 == "develop" ]];then
        git checkout develop
    fi
    cd ..
    bashinstall="no"
fi
cd /usr/local/shadowsocksr
bash initcfg.sh
if [[ ! -e /usr/bin/bc ]];then
	if [[ ${OS} == CentOS ]];then
		yum install bc -y
	fi
	if [[ ${OS} == Ubuntu || ${OS} == Debian ]];then
		apt-get install bc -y
	fi
fi
if [[ ${bashinstall} == "no" ]]; then

#Start when boot
if [[ ${OS} == Ubuntu || ${OS} == Debian ]];then
    cat >/etc/init.d/ssr-bash-python <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          SSR-Bash_python
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: SSR-Bash-Python
# Description: SSR-Bash-Python
### END INIT INFO
iptables-restore < /etc/iptables.up.rules
bash /usr/local/shadowsocksr/logrun.sh
EOF
    chmod 755 /etc/init.d/ssr-bash-python
    chmod +x /etc/init.d/ssr-bash-python
    cd /etc/init.d
    update-rc.d ssr-bash-python defaults 95
fi

if [[ ${OS} == CentOS ]];then
    echo "
iptables-restore < /etc/iptables.up.rules
bash /usr/local/shadowsocksr/logrun.sh
" > /etc/rc.d/init.d/ssr-bash-python
    chmod +x  /etc/rc.d/init.d/ssr-bash-python
    echo "/etc/rc.d/init.d/ssr-bash-python" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
fi

#Change CentOS7 Firewall
if [[ ${OS} == CentOS && $CentOS_RHEL_version == 7 ]];then
    systemctl stop firewalld.service
    yum install iptables-services -y
    sshport=$(netstat -nlp | grep sshd | awk '{print $4}' | awk -F : '{print $NF}' | sort -n | uniq)
    cat << EOF > /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport ${sshport} -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
    systemctl restart iptables.service
    systemctl enable iptables.service
    systemctl disable firewalld.service
fi
fi
#Install SSR-Bash Background
if [[ $1 == "develop" ]];then
	wget -q -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/johndesu090/SSR-Bash-Python/master/ssr
	chmod +x /usr/local/bin/ssr
else
	wget -q -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/johndesu090/SSR-Bash-Python/master/ssr
	chmod +x /usr/local/bin/ssr
fi

#Modify ShadowsocksR API
nowip=$(grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" /usr/local/shadowsocksr/userapiconfig.py)
sed -i "s/sspanelv2/mudbjson/g" /usr/local/shadowsocksr/userapiconfig.py
sed -i "s/UPDATE_TIME = 60/UPDATE_TIME = 10/g" /usr/local/shadowsocksr/userapiconfig.py
sed -i "s/SERVER_PUB_ADDR = '${nowip}'/SERVER_PUB_ADDR = '$(wget -qO- -t1 -T2 ipinfo.io/ip)'/" /usr/local/shadowsocksr/userapiconfig.py
#INstall Success
read -t 20 -p "Enter the domain name bound to your host (please enter it within 20 seconds, this step will skip this step. The local IP is filled in by default): " ipname
if [[ -z ${ipname} ]];then
    ipname=$(wget -qO- -t1 -T2 ipinfo.io/ip)
fi
echo "$ipname" > /usr/local/shadowsocksr/myip.txt
if [[ $1 == develop ]];then
    if [[ -e /usr/local/SSR-Bash-Python/check.log ]];then
        cd /usr/local/SSR-Bash-Python
        read -n 1 -t 3 -p "Do you want to reconfigure the server inspection configuration (note that this will clear your logs)[Y/N]" yn
        if [[ $yn == [Yy] ]];then
        	bash servercheck.sh reconf
        	nohup bash servercheck.sh run 2>/dev/null &
        else
        	bash servercheck.sh stop
        	nohup bash servercheck.sh run 2>/dev/null &
            echo "Service restarted"
        fi
    else
        read -t 10 -p "Whether to set server self-test, experimental function！[Y/N]" yn
        if [[ $yn == [yY] ]];then
        	cd /usr/local/SSR-Bash-Python
        	bash servercheck.sh conf
        	nohup bash servercheck.sh run 2>/dev/null &
        	PID=$(ps -ef |grep -v grep | grep "bash" | grep "servercheck.sh" | grep "run" | awk '{print $2}')
        	if [[ -z ${PID} ]];then
            	echo "The program failed to start, please contact the developer"
            fi
        else
        	echo "You actually rejected T.T"
        fi
    fi
    checkcron=$(crontab -l 2>/dev/null | grep "timelimit.sh")
    if [[ -z ${checkcron} ]];then
        crontab -l > ~/crontab.bak 1>/dev/null 2>&1
        sed -i "/timelimit.sh/d" ~/crontab.tmp 1>/dev/null 2>&1
        echo -e "\n*/5 * * * * /bin/bash /usr/local/SSR-Bash-Python/timelimit.sh c" >> ~/crontab.bak
        crontab ~/crontab.bak
        rm -r ~/crontab.bak 
    fi
fi
if [[ -e /etc/sysconfig/iptables-config ]];then
        ipconf=$(cat /etc/sysconfig/iptables-config | grep 'IPTABLES_MODULES_UNLOAD="no"')
        if [[ -z ${ipconf} ]];then
                sed -i 's/IPTABLES_MODULES_UNLOAD="yes"/IPTABLES_MODULES_UNLOAD="no"/g' /etc/sysconfig/iptables-config
                echo "Installation is complete, rebooting server in 5 seconds"
                sleep 5s
                reboot
        fi
fi
bash /usr/local/SSR-Bash-Python/self-check.sh
echo 'The installation is complete! Enter ssr to use this program ~'
if [[ ${check} != "yes" ]] ;then
        echo "If you run ssr and can't find the command, please try to log out and log in again."
fi
echo 'The original author has stopped this script update. This version is a magic change from the last version before the author deletion.'
echo 'Dont like spraying!'
echo 'Use with caution! Research only！'
echo 'Use with caution! Research only！'
echo 'Use with caution! Research only！'
