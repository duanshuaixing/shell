#!/usr/bin/env bash

install_docker_ubuntu(){

	docker version &>/dev/null

	if [ $? -eq 0 ];then
		echo "docekr already installed"
		exit 0
	fi

	if [ $UID -ne 0 ];then
                echo "Permission denied"
                exit 1
        fi

	apt-get -y install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
	apt-get -y update
	apt-cache madison docker-ce
	apt-get -y install docker-ce=17.03.2~ce-0~ubuntu-xenial
	docker version
 
}

install_docker_ubuntu
