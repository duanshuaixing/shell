#!/usr/bin/env bash
nj(){

	wget https://nodejs.org/dist/v6.9.5/node-v6.9.5-linux-x64.tar.xz
	tar xvf node-v6.9.5-linux-x64.tar.xz
	mkdir -p /opt/node/
	mv /root/node-v6.9.5-linux-x64/* /opt/node/
	ln -s /opt/node/bin/node /usr/local/bin/node
	ln -s /opt/node/bin/npm /usr/local/bin/npm
	}
njbig(){

	yum install git
	git clone https://github.com/cnpm/nvm.git ~/.nvm
	cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
	echo ". ~/.nvm/nvm.sh" >> /etc/profile
	source /etc/profile

	}

npm -v

if [ $? -ne 0 ];then
	nj
	wait
	npm -v
	if [ $? -eq 0 ];then
		echo "install node is ok "
	else
		echo "install node error"
	fi
else
	echo "your nodejs already install"
fi

nvm list-remote &>/dev/null
if [ $? -ne 0 ];then
	njbig 
	if [ $? -eq 0 ];then
		echo "nvm list-remote is ok"
	else
		echo "nvm list-remote error"
	fi
else
	echo "nvm list-remote  is already you know?"
fi
