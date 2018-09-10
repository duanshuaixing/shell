#!/usr/bin/env bash

install_docker(){
	wget http://duansx-kubernetes.bj.bcebos.com/k8s-install/public/repos/docker-ce.repo -P /etc/yum.repos.d/
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

install_docker-compose(){
	curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
	#backup
	#wget http://developer1.bj.bcebos.com/linux/docker-compose/docker-compose
	
	chmod a+x /usr/local/bin/docker-compose
	
}

install_https(){
	#https://github.com/goharbor/harbor/blob/master/docs/configure_https.md
	wget https://storage.googleapis.com/harbor-releases/harbor-offline-installer-v1.5.2.tgz
	#backup
	#http://developer1.bj.bcebos.com/linux/harbor/harbor-offline-installer-v1.5.2.tgz
	tar -xf harbor-offline-installer-v1.5.2.tgz
	mkdir -p harbor/ssl && cd harbor/ssl
	read -p "Please input your domainname:" domain
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 365 -out ca.crt
	openssl	req -newkey rsa:4096 -nodes -sha256 -keyout  $domain.key -out  $domain.csr		
	openssl x509 -req -days 365 -in $domain.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $domain.crt
	cd ..
}

install_harbor(){
	sed -i "s/reg.mydomain.com/$domain/" harbor.cfg
	sed -i '/^ui_url/c\ui_url_protocol = https' harbor.cfg
	sed -ri "/^ssl_cert =/c\ssl_cert = ./ssl/$domain.crt" harbor.cfg
	sed -ri "/^ssl_cert_key/c\ssl_cert_key = ./ssl/$domain.key" harbor.cfg
	sed -ri "/^harbor_admin_password = Harbor12345/c\harbor_admin_password = duan@1994" harbor.cfg
	./prepare
	./install.sh	

}
install_docker && wait && install_docker-compose && wait && install_https && wait && install_harbor
