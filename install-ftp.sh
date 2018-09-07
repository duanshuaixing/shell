#!/usr/bin/env bash

install_ftp(){

	rpm -qa |grep vsftpd &>/dev/null

	if [ $? -eq 0 ];then
                echo "vsftpd already installed"
                exit 0
        fi

        if [ $UID -ne 0 ];then
                echo "Permission denied"
                exit 1
        fi


	yum install -y vsftpd
	systemctl enable vsftpd.service
	systemctl start vsftpd.service
	sed -i "s/#anon_upload_enable=YES/anon_upload_enable=YES/g" '/etc/vsftpd/vsftpd.conf'
	sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" '/etc/vsftpd/vsftpd.conf'

	chmod o+w /var/ftp/pub/
	systemctl restart vsftpd.service
	useradd -d /var/ftp/pub -m baidu -s /sbin/nologin
	echo "baidu@123" |passwd --stdin baidu
	netstat -antup | grep ftp
}
