#!/usr/bin/env bash
#about tools
#version v1

trap "" HUP INT QUIT TSTP
hty=/tmp
read -p "Input address: " address

menu(){
			printf "
			
			
				     			 TOOLS  
			
			 1.nslookup			6.ping			11.hping3-dos
			 
			 2.dig				7.curl			12.whois
			
			 3.baidu-dns			8.elinks		13.clear
			 
			 4.google-dns			9.nmap			14.exit
			 
			 5.ali-dns			10.traceroute		15.expect
			 
			
			"
}

menu

while true

do

	read -p " Please input [0 menu]:" action
	case "$action" in
	0)
		clear
		menu
		;;
	1)
		echo  $(date +"%F %H:%M") $address |tee -a $hty/nslookup.txt
		nslookup $address |tee -a  $hty/nslookup.txt
		echo "================================" >>$hty/nslookup.txt
		;;
	2)
		echo $(date +"%F %H:%M") $address |tee -a  $hty/dig.txt
		dig $address +trace |grep $address |tee -a $hty/dig.txt
		echo "================================" >>$hty/dig.txt
		;;
	3)	
		echo $(date +"%F %H:%M") $address baidu-dns |tee -a $hty/dig.txt
		dig @180.76.76.76 $address |tee -a $hty/dig.txt
		echo "================================" >>$hty/dig.txt
		;;
	4)
		echo $(date +"%F %H:%M") $address google-dns |tee -a $hty/dig.txt
		dig @8.8.8.8 $address |tee -a $hty/dig.txt
		echo "================================" >>$hty/dig.txt
		;;
	5)
		echo $(date +"%F %H:%M") $address aliyun-dns |tee -a $hty/dig.txt
		dig @223.5.5.5 $address |tee -a $hty/dig.txt
		echo "================================" >>$hty/dig.txt
		;;
	6)
		echo $(date +"%F %H:%M") $address |tee -a $hty/ping.txt
		ping -c 10 $address |tee -a $hty/ping.txt
		echo "================================" >>$hty/ping.txt
		;;
	7)
		echo $(date +"%F %H:%M") $address |tee -a $hty/curl.txt
		curl -k -v $address |tee -a $hty/curl.txt
		echo "================================" >>$hty/curl.txt
		;;
	8)
		elinks $address
		;;
	9)
		echo $(date +"%F %H:%M") $address |tee -a $hty/nmap.txt
		nmap -sT -Pn -sV  $address |tee -a $hty/nmap.txt
		echo "================================" >>$hty/nmap.txt
		;;
	10)
		echo $(date +"%F %H:%M") $address |tee -a $hty/tcptraceroute.txt
		tcptraceroute $address |tee -a $hty/tcptraceroute.txt
		echo "================================" >>$hty/tcptraceroute.txt
		;;
	11)
		hping3 -S -U --flood -V --rand-source $address
		;;
	12)
		echo $(date +"%F %H:%M") $address |tee -a $hty/whois.txt
		whois $address |tee -a $hty/whois.txt
		echo "================================" >>$hty/whois.txt
		;;
	13)
		clear
		menu
		;;
	14)
		clear
		exit
		;;
	15)	echo ""
		echo " Look forward to your suggestion ！"
		;;
	"")
		continue
		;;
	*)
		echo "error"
	esac
done
