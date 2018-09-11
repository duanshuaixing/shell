：#!/usr/bin/env bash


init_master_os(){
	os_version=`cat /etc/redhat-release |sed "s/.*release//g"|awk '{print $1}' | awk -F. '{print $1}'`

	if [ "${os_version}" -ne "7" ]; then
		echo " The operating system is not centos7 "
		exit 1
	fi

	if [ $UID -ne 0 ];then
		echo "Permission denied"
		exit 2
	fi

	read -p "Input master hostname: " m1_hoatname
	read -p "Input "$m1_hostname"_ip:" m1_ip
	read -p "Input node hostname: " n1_hoatname
	read -p "Input "$n1_hostname"_ip:" n1_ip
	read -p "Input "$n1_hostname"_password:" n1_passwd
	

	master_hostname=`tail -2 /etc/hosts |awk '{print $NF}'`
        hostnamectl set-hostname $master_hostname
	yum -y install wget  ntpdate expect
	swapoff -a
	systemctl stop firewalld && systemctl stop firewalld
	setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	iptables -P FORWARD ACCEPT
	echo "net.bridge.bridge-nf-call-ip6tables = 1" >>/etc/sysctl.d/k8s.conf
	echo "net.bridge.bridge-nf-call-iptables = 1" >>/etc/sysctl.d/k8s.conf
	echo "vm.swappiness=0" >>/etc/sysctl.d/k8s.conf

	echo "$m1_ip   $m1_hoatname" >>/etc/hosts
	echo "$n1_ip   $n1_hoatname" >>/etc/hosts
	echo "$n1_passwd" >>/tmp/npasswd.txt
}


install_master_k8s(){
	tar -xf k8s_1.8.2_admin.tar.gz
	wait
	cd ./k8s_1.8.2/k8s_1.8.2_docker/ && yum -y localinstall *.rpm
	wait
	systemctl enable docker && systemctl start docker
	wait
	cd ../k8s_1.8.2_images/ && for i in `ls .`;do docker load < $i;done
	wait
	cd ../k8s_1.8.2_rpm/ && yum -y localinstall *.rpm
	wait
	sed -i 's/systemd/cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	systemctl daemon-reload
	systemctl enable kubelet && systemctl start kubelet
	wait
        kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version v1.8.2 --skip-preflight-checks
	wait
        mkdir -p $HOME/.kube
        \cp /etc/kubernetes/admin.conf $HOME/.kube/config
        chown $(id -u):$(id -g) $HOME/.kube/config
        systemctl restart kubelet
	wait
	kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version v1.8.2 --skip-preflight-checks >>/root/kubeadm_join.txt
	wait
	mkdir -p $HOME/.kube
	/cp  /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config
	systemctl restart kubelet
	cd ../k8s_1.8.2_yaml/ && kubectl apply -f calico.yaml
	cd

}

scp_file_master(){

	if [ ! -f ~/.ssh/id_rsa ];then
		ssh-keygen -P "" -f ~/.ssh/id_rsa
	fi 
	/usr/bin/expect <<-EOF
	spawn ssh-copy-id `tail -1 /etc/hosts |awk '{print $NF}'`
		expect {
			"(yes/no)" { send "yes\r";exp_continue }
			"password:" { send "`cat /tmp/npasswd.txt`\r" }
		}

	expect eof
	EOF

	scp ./k8s_1.8.2_admin.tar.gz root@`tail -1 /etc/hosts |awk '{print $NF}'`:/root/
        scp /etc/hosts root@`tail -1 /etc/hosts |awk '{print $NF}'`:/etc/hosts
        scp /etc/sysctl.d/k8s.conf root@`tail -1 /etc/hosts |awk '{print $NF}'`:/etc/sysctl.d/k8s.conf
        scp /root/kubeadm_join.txt root@`tail -1 /etc/hosts |awk '{print $NF}'`:/root/
        scp ./offline-k8sadmin.sh root@`tail -1 /etc/hosts |awk '{print $NF}'`:/root/
	#cd /tmp/ && rm -rf npasswd.txt && cd

}

install_node(){
	#init_node_os
	node_hostname=`tail -1 /etc/hosts |awk '{print $NF}'`
	ssh root@$node_hostname	"hostnamectl set-hostname $node_hostname"
	ssh root@$node_hostname "yum -y install wget  ntpdate expect"
	wait
	ssh root@$node_hostname "ntpdate ntp1.aliyun.com"
	wait
	ssh root@$node_hostname "swapoff -a && systemctl stop firewalld && systemctl disable firewalld"
	ssh root@$node_hostname "setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config"
	ssh root@$node_hostname "iptables -P FORWARD ACCEPT"
	
	#init_node_k8s
	ssh root@$node_hostname	"cd $HOME && tar -xf k8s_1.8.2_admin.tar.gz"
	wait
	ssh root@$node_hostname "cd $HOME/k8s_1.8.2/k8s_1.8.2_docker/ && yum -y localinstall *.rpm"
	wait
	ssh root@$node_hostname "systemctl enable docker && systemctl start docker"
	wait
	ssh root@$node_hostname "cd $HOME/k8s_1.8.2/k8s_1.8.2_images/ && `for i in `ls .`;do docker load < $i;done`"
	wait
	ssh root@$node_hostname "cd $HOME/k8s_1.8.2/k8s_1.8.2_rpm/ && yum -y localinstall *.rpm"
	wait
	ssh root@$node_hostname "sed -i 's/systemd/cgroupfs/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
	ssh root@$node_hostname "systemctl daemon-reload"
	ssh root@$node_hostname "systemctl enable kubelet && systemctl start kubelet"
	ssh root@$node_hostname "tail -3 /root/kubeadm_join.txt |head -1 |bash"
}

install_dashboard(){
	cd $HOME/k8s_1.8.2/k8s_1.8.2_yaml
	kubectl apply -f kubernetes-dashboard.yaml 
	kubectl create -f dashboard-admin.yaml
}
init_master_os
wait
install_master_k8s
wait
scp_file_master
wait
install_node
wait
install_dashboard



