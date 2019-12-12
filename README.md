# SSR Multi-user management script (based on the official mujson version)
- [x] Stable Version V1.7.2：[![Build Status](https://travis-ci.org/Readour/AR-B-P-B.svg?branch=master)](https://travis-ci.org/Readour/AR-B-P-B)  [![Code Climate](https://codeclimate.com/github/Readour/AR-B-P-B/badges/gpa.svg)](https://codeclimate.com/github/Readour/AR-B-P-B)

- [x] Beta Version V1.9.8：[![Build Status](https://travis-ci.org/Readour/AR-B-P-B.svg?branch=develop)](https://travis-ci.org/Readour/AR-B-P-B)

## Introduction ##

A shell script that integrates basic operations such as SSR multi-user management, traffic restriction, and encryption changes. Is an auxiliary script based on ShadowsocksR's official mujson. It is convenient for users to operate, and supports the rapid establishment of an SSR service environment.

- Please use it with caution, we will not be responsible for any problems！！！！
- If you find a script bug, please post issues in time, thank you very much

## Supported Operating System ##
* Ubuntu 14
* Ubuntu 16
* Debian 7
* Debian 8
* CentOS 6
* CentOS 7 (recommended)

## Features ##
- Fully automatic unattended installation, only one command for server deployment, you and SSR are so elegant ：）
- One-click enable and disable SSR service
- Add, delete, modify user port, password and connection limit
- Support fool-style user addition, A noob can also use
- Freely restrict user port traffic usage and port network speed
- Automatically modify firewall rules
- Self-modify parameters such as SSR encryption method, protocol, and obfuscation
- Automatic statistics, easy to query the traffic usage of each user port
- Automatically install the Libsodium library to support encryption methods such as Chacha20
- Support user QR code generation (only available in development version)
- Supports one-click construction of ss-panel-V3-mod, with front-end and back-end automatic docking, no additional operations required (only available for development version)
- One-click build of fool-like BBR, sharp speed, LotServer (risky, only development version is available)
- Customizable server inspection and automatic restart of services to ensure stable and effective links
- Configuration can be backed up and restored. The migration server only needs to restore the configuration on the new server.
- Support IP blacklist function, you can query the port and directly add to the blacklist, forbid this IP to access all services of the server
- Allows to limit account validity period for different users, and automatically delete accounts when they expire



## Scripting Security Statement ##
**This script is written in Shell and Python languages, and all code is completely clean. There is no so-called backend or mining code, any information about you will not be uploaded, and data security is fully considered in all aspects. About the QR code generation process is installed via pip [third-party software package](https://github.com/lincolnloop/python-qrcode)，Generated by third-party software locally on the server, the generated QR code link will also be automatically destroyed without uploading any information. Your IP is blocked, or your server has an abnormally high load, which has nothing to do with the script itself. Please do your own server security maintenance work, for example: Do not use weak passwords, do not use the default SSH port, etc. to prevent Blasted by idlers. _In the principle of mutual trust between people, please confirm that you believe me and my script, otherwise please don’t use it, don’t understand, please don’t spray, easy to hurt! !! !!_**


## Installation & Update ##
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/johndesu090/SSR-Bash-Python/master/install.sh && bash install.sh

## Self-examination (without eggs 😝) ##
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/johndesu090/SSR-Bash-Python/master/self-check.sh && bash self-check.sh

## Uninstall ##
    wget -q -N --no-check-certificate https://raw.githubusercontent.com/johndesu090/SSR-Bash-Python/master/install.sh && bash install.sh uninstall

## Install offline ##
    #This method can be used in the case of bad network conditions, resulting in missing files. You can also download the script for backup
    wget -q -N --no-check-certificate https://down.fdos.me/install.sh && bash install.sh
    
## Client Downloads ##
Commonly used platforms：[Android](https://github.com/shadowsocksrr/shadowsocksr-latest-bin-backup/raw/master/Shadowsocksr-android-3.4.0.5.apk)、[MacOS](https://github.com/qinyuhang/ShadowsocksX-NG-R/releases/download/1.4.3-R8/ShadowsocksX-NG-R8.dmg)、[Windows](https://github.com/Readour/ShadowsocksR-Csharp/releases/download/4.7.0/ShadowsocksR-4.7.0-win.CONCISE.7z)、[Linux](https://github.com/shadowsocks/shadowsocks-qt5/releases/download/v2.9.0/Shadowsocks-Qt5-x86_64.AppImage)、[OpenWrt/LEDE](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/releases)、[iOS](https://github.com/Readour/breakwa11.github.io/raw/master/download/Shadowrocket%202.1.14.ipa)

## DONATIONS ##
<span style="font-size:18px;"><span style="color:#E53333;"></span></span><span style="font-size:16px;color:#E53333;">**PAYPAL**</span>E-mail：<johnford090@gmail.com> **GCASH** Number: 09206200840
