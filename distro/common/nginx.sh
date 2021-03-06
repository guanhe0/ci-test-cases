#!/bin/bash

pushd ./utils
source ./sys_info.sh
popd

nginx_port=8080
set -x
case $distro in
	"debian" | "ubuntu" )
	nginx_conf="/etc/nginx/sites-available/default"
	sudo --help
	if [ $? -ne 0 ];then
		print_info  1 sudo_command_not_found
		echo "sudo command not found"
		$install_commands sudo
    fi
	sudo apt-get install -y nginx
	if [ $? -ne 0 ]; then
	sudo mv /var/lib/dpkg/info /var/lib/dpkg/info.bak
	sudo mkdir /var/lib/dpkg/info
	sudo apt-get update
	sudo apt-get install -y nginx
	sudo mv /var/lib/dpkg/info/* /var/lib/dpkg/info.bak
	sudo rm -rf /var/lib/dpkg/info
	sudo mv /var/lib/dpkg/info.bak /var/lib/dpkg/info
	fi
	;;
	"centos" )
	nginx_conf="/etc/nginx/nginx.conf"
	nginx_port=80
	sudo $install_commands nginx
	;;
esac

#sudo service nginx start
	sed -i "/ipv6only=on/d" $nginx_conf
	sed -i "s/listen 80 default_server/listen $nginx_port default_server/g" $nginx_conf
	sed -i "s/listen [::]:80/listen [::]:$nginx_port/g" $nginx_conf

sudo service nginx restart
ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
index=$(ls /var/www/html)
wget http://$ip:$nginx_port/${index}
if [ $? -eq 0 ]; then
	echo "nginx install success"
	print_info 0 install_nginx
else
	echo "nginx install fail"
	print_info 1 install_nginx
fi
