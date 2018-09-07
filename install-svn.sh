#!/usr/bin/env bash
install_svn(){
	rpm -qa |grep subversion &>/dev/null

	if [ $? -eq 0 ];then
                echo "subversion already installed"
                exit 0
        fi

        if [ $UID -ne 0 ];then
                echo "Permission denied"
                exit 1
        fi


	yum install subversion
	mkdir /var/svn && cd /var/svn
	svnadmin create /var/svn/svnrepos
	cd /var/svn/svnrepos/conf
	echo baidu = baidu@123 >>/var/svn/svnrepos/conf/passwd
	echo [/] >>/var/svn/svnrepos/conf/authz
	echo baidu=rw >>/var/svn/svnrepos/conf/authz
	sed -i "s/# anon-access = read/anon-access = none/g" '/var/svn/svnrepos/conf/svnserve.conf'
	sed -i "s/# auth-access = write/auth-access = write/g" '/var/svn/svnrepos/conf/svnserve.conf'
	sed -i "s/# password-db = passwd/password-db = passwd/g" '/var/svn/svnrepos/conf/svnserve.conf'
	sed -i "s/# authz-db = authz/authz-db = authz/g" '/var/svn/svnrepos/conf/svnserve.conf'
	sed -i "s/# realm = My First Repository/realm = /var/svn/svnrepos/g" '/var/svn/svnrepos/conf/svnserve.conf'
	svnserve -d -r /var/svn/svnrepos
}

install_svn
