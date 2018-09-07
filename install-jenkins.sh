#!/usr/bin/env bash

install_jdk(){
	if [ $UID -ne 0 ];then
                echo "Permission denied"
                exit 1
        fi
	
	# install jdk

	java -version

	if [ $? -ne 0 ];then
		
		ls jdk-8u181-linux-x64.tar.gz &>/dev/null
		if [ $? -ne 0 ];then
			wget http://developer1.bj.bcebos.com/linux/java/jdk-8u181-linux-x64.tar.gz
			wait
		fi
		
		ls jdk-8u181-linux-x64.tar.gz &>/dev/null
		
		if [ $? -ne 0 ];then
			echo "jdk download is filed, please retry"
			exit 2
		fi

		tar -xf jdk-8u181-linux-x64.tar.gz -C /usr/local/
		ln -s /usr/local/jdk1.8.0_181 /usr/local/java
		 
		echo "JAVA_HOME=/usr/local/java" >>/etc/profile
           	echo "PATH=\$JAVA_HOME/bin:\$PATH" >>/etc/profile
           	echo "export JAVA_HOME PATH" >>/etc/profile
		
		source /etc/profile

	else
                echo "jdk already installed"
                exit 0
        fi

}

install_jenkins(){
	wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
	rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
	yum -y install jenkins
	sed -i '/candidates=/a\\/usr/local/java/bin/java' /etc/init.d/jenkins
	systemctl daemon-reload
	systemctl start jenkins && /sbin/chkconfig jenkins on
	
	wait
	key=`cat /var/lib/jenkins/secrets/initialAdminPassword`
	echo "=================================================="
	echo ""
	echo $key
	echo "dashboard = ip + 8080"
	echo ""
	echo "=================================================="
}


install_jdk
install_jenkins
