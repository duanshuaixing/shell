#!/usr/bin/env bash
install_docker(){

	docker version &>/dev/null

        if [ $? -eq 0 ];then
                echo "docekr already installed"
                exit 0
        fi

        if [ $UID -ne 0 ];then
                echo "Permission denied"
                exit 1
        fi

	wget https://github.com/duanshuaixing/shell/blob/master/docker-ce.repo -P /etc/yum.repos.d/
	yum -y install yum-utils device-mapper-persistent-data lvm2
	yum makecache fast
	yum -y install docker-ce-18.03.1.ce-1.el7.centos
	systemctl start docker.service
	systemctl enable docker.service

	mkdir -p /etc/docker
	tee /etc/docker/daemon.json <<-'EOF'
	{
  		"registry-mirrors": ["https://t3xbrfwz.mirror.aliyuncs.com"]
	}
	EOF
	systemctl daemon-reload
	systemctl restart docker
}

install_docker
