#!/usr/bin/env bash
mount_bos(){

	echo ""
	read -p "Please input region [bj|gz|su|hkg]: " region 
	endpoint=http://$region.bcebos.com

	rpm -qa |grep bosfs &>/dev/null

	if [ $? -ne 0 ];then
		yum -y install http://sdk.bce.baidu.com/console-sdk/bosfs-1.0.0-8.el6.x86_64.rpm &>/dev/null
	fi

	read -p "Please input ak:" ak
	read -p "Please input sk:" sk
	read -p "Please input Bucketname:" bucketname
	read -p "Please input Targetname:" targetname

	if [ $UID -ne 0 ];then
		echo "Permission denied"
		exit 1
	fi

	bosfs $bucketname $targetname -o endpoint=$endpoint -o ak=$ak -o sk=$sk &>/dev/null

	if [ $? -eq 0 ];then
		echo "============================================="
		echo ""
		echo " $bucketname has been mounted to $targetname "
		echo ""
		echo "============================================="
	fi
}

mount_bos
