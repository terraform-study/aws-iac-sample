#!/bin/bash
PORT=${port}
cd /tmp
yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
mv busybox-x86_64 busybox
chmod +x busybox

RZAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
IID=$(curl 169.254.169.254/latest/meta-data/instance-id)
LIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
echo "<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>" > index.html
nohup ./busybox httpd -f -p $PORT &