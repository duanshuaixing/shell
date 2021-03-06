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

install_nexus(){

	#install nexus

	cat /etc/passwd |grep nexus

	if [ $? -ne 0 ];then

		ls nexus-3.13.0-01-unix.tar.gz &>/dev/null
                if [ $? -ne 0 ];then
                        wget http://developer1.bj.bcebos.com/linux/nexus/nexus-3.13.0-01-unix.tar.gz
                        wait
                fi

		ls nexus-3.13.0-01-unix.tar.gz
		if [ $? -ne 0 ];then
			echo " nexus download is filed, please  retry! "
			exit 2
		fi

		tar -xf nexus-3.13.0-01-unix.tar.gz -C /opt/
		ln -s /opt/nexus-3.13.0-01 /opt/nexus
		useradd -d "/home/nexus" -m -s "/sbin/nologin" nexus
		chown -R nexus:nexus /opt/nexus
		chown -R nexus:nexus /opt/sonatype-work
		echo run_as_user='"nexus"' >>/opt/nexus/bin/nexus.rc

cat << EOF >/etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus-3.13.0-01/bin/nexus start
ExecStop=/opt/nexus-3.13.0-01/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target

EOF

		systemctl daemon-reload
             	systemctl  start nexus.service
             	systemctl enable nexus.service
	fi


}

install_jdk
source /etc/profile
install_nexus

