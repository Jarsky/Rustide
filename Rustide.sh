#!/bin/bash
# Rustide:
#   Automatically install, update and run Rust Server
#       Create a backup of users scripts & data
#
# History:
# 2016-08-15 Ported from Windows to Linux.
auth="Jarsky"
ver="1.7"
updated="01/01/2022"
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

## SET YOUR SERVER SETTINGS HERE
## YOU MUST CHANGE THE RCON PASSWORD

_hostname="Rust Server"
_ident="rustide"
_port="28015"
_rport="28016"
_rcon="rust123"
_players="100"
_level="Procedural Map"
_seed="0"
_worldsize="4000"
_serverimg="http://i.imgur.com/yHWZSYQ.png"
_serverurl="http://oxidemod.org"
_serverdesc="Welcome to our Rustide server!"

## HERE ARE SOME MORE ADVANCED SETTINGS

_autostart=YES
_autorestart=NO
_autoupdate=YES
_forceupdate=NO
_savebackup=YES
_maxbackups=3
_backuploc=./backups
_dependencies=YES       #tested with Ubuntu 20 & 21


## DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOURE DOING

BASEDIR=$(pwd)
RED='\033[0;31m'
BLU='\033[0;34m'
GRN='\033[0;32m'
YEL='\033[1;33m'
CYA='\033[1;36m'
NC='\033[0m'

echo -e "${CYA}"
echo " ================================================="
echo " =                                               ="
echo " =                                               ="
echo " =            Rustide v$ver by $auth             ="
echo " =   This script auto updates Rust + Oxide Mod   ="
echo " =               Updated $updated              ="
echo " =                                               ="
echo " =                                               ="
echo " ================================================="
echo -e "${NC}"

sleep 2


### FUNCTIONS ###

function fRCONcheck() {
        if [ $_rcon = "rust123" ]; then
                echo -e "${RED}***${YEL}YOU MUST CHANGE THE RCON PASSWORD TO RUN${RED}***${NC}\n"
                exit 1
        fi
}

function fCheckOS() {
        if [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
                OS=$DISTRIB_ID
                VER=$DISTRIB_RELEASE
        elif [ -f /etc/debian_version ]; then
                OS=Debian
                VER=$(cat /etc/debian_version)
        elif [ -f /etc/redhat-release ]; then
                OS=CentOS
                VER=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)
        else
                OS=$(uname -s)
                VER=$(uname -r)
        fi
}

function fDependencies(){

        if [ $OS = "Ubuntu" ] && [ $(dpkg-query -W -f='${Status}' lib32gcc-s1 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                        if [ "$EUID" -ne 0 ]; then
                        echo -e "${YEL}You are missing some packages to run SteamCMD Properly${NC}\n"
                        echo -e "${YEL}You must run as ${RED}sudo${YEL} for first run e.g sudo ${BASH_SOURCE[0]}${NC}\n"
                        echo -e "${YEL}This is to install required packages${NC}\n"
						exit 0
                        fi
                        apt-get -y install lib32gcc-s1 libc6 gcc-multilib screen unzip
			echo ""
			echo -e "${GRN}You can now start the script normally using ${BASH_SOURCE[0]}${NC}\n"
			echo ""
			exit 1						
        elif [ $OS = "CentOS" ] && [ yum -q list installed glibc.i686 &>/dev/null && echo "Error" ]; then
                        if [ "$EUID" -ne 0 ]; then
                        echo -e "${YEL}You are missing some packages to run SteamCMD Properly${NC}\n"
                        echo -e "${YEL}You must run as ${RED}sudo${YEL} for first run e.g sudo ${BASH_SOURCE[0]}${NC}\n"
                        echo -e "${YEL}This is to install required packages${NC}\n"
						exit 0
                        fi
                        yum -y install glibc.i686 libstdc++.i686 screen unzip
			echo ""
			echo -e "${GRN}You can now start the script normally using ${BASH_SOURCE[0]}${NC}\n"
			echo ""
			exit 1
        fi
}

function fSteamCMD(){
        if [ ! -d "./SteamCMD" ]; then
                echo ""
                echo -e "${GRN}Installing SteamCMD${NC}\n"
                echo ""
                mkdir ./SteamCMD
        wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz && tar -xvzf steamcmd_linux.tar.gz -C ./SteamCMD
        rm -f steamcmd_linux.tar.gz
                ./SteamCMD/steamcmd.sh +quit
        fi
}

function fRustUpdate(){
        echo ""
        echo -e "${GRN}Starting Rust Update${NC}\n"
        echo ""
        ./SteamCMD/steamcmd.sh +force_install_dir ../rust +login anonymous +app_update 258550 validate +quit
}

function fBuildOxide(){
        echo ""
        echo -e "${GRN}Updating Oxide${NC}\n"
        echo ""
                if [ ! -f "./Oxide-Rust.zip" ]; then
                wget --waitretry=5 --output-document=Oxide-Rust.zip https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip --no-check-certificate
                fi
        if [ -d "./temp/" ]; then rm -rf "./temp"; fi
        mkdir -p ./temp/server/$_ident && mkdir -p ./temp/RustDedicated_Data/Managed
        cp -R ./rust/server/$_ident/ ./temp/server/$_ident/ && cp -R ./rust/RustDedicated_Data/Managed/ ./temp/RustDedicated_Data/Managed/
        unzip ./Oxide-Rust.zip -d ./temp && rm -f ./Oxide-Rust.zip
        cp -r ./temp/. ./rust/.
                if [ $_savebackup = "NO" ]; then
                rm -rf ./temp
                fi
}

function fBackup(){
        if [ -d "./rust/server/"$_ident"/" ]; then
                        echo ""
                        echo -e "${GRN}Running backup${NC}\n"
                        echo ""
                        if [ $_savebackup = "YES" ] && [ "ls -l "$_backuploc"/backup_"$_ident"-"*" | wc -l -le "$_maxbackups"" ]; then
                                if [ ! -d "$_backuploc" ]; then mkdir $_backuploc; fi
                               tar -czvf $_backuploc"/backup_"$_ident"-"$(date '+%Y-%m-%d_%I-%M')".tar.gz" ./temp && rm -rf ./temp
                        fi
                fi
}

function fCleanBackup(){
                if [ $("ls -A "$_backuploc"/backup_"$_ident"-"*.tar.gz | wc -l) -ge $_maxbackup ]; then
                rm `"ls -td "$_backuploc"/backup_"$_ident"-"*".tar.gz" | awk 'NR>$_maxbackup'`
                fi
}

### END FUNCTIONS ###


fRCONcheck;

if [ $_dependencies = "YES" ]; then
fCheckOS;
fDependencies;
fi

fSteamCMD;
fRustUpdate;
fBuildOxide;
fBackup;
fCleanBackup;

if [ $_autostart = "YES" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib64:$BASEDIR/rust/RustDedicated_Data/Plugins/x86_64
        while :
        do
                echo ""
                echo -e "${GRN}Starting Rust Server...${NC}\n"
                echo -e "${GRN}Connect using Rusty Tool for Console http://oxidemod.org/resources/rusty-server-rcon-administration-tool.53/${NC}\n"
                echo ""
                cd ./rust
        exec ./RustDedicated -batchmode -nographics +server.identity $_ident +server.hostname $_hostname +server.port $_port +server.maxplayers $_players +rcon.port $_rport +rcon.password $_rcon +rcon.ip 0.0.0.0 +server.saveinterval 900 +server.level $_level +server.seed $_seed +server.url $_serverurl +server.headerimage $_serverimg +server.description $_serverdesc +server.globalchat true +server.worldsize $_worldsize +oxide.directory "server/"$_ident"/oxide" +cfg "server/"$_ident"/cfg/server.cfg" -autoupdate
        done
fi
