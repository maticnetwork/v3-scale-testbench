#!/bin/bash

# Install docker
yum update -y
amazon-linux-extras install docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
docker info

# Install yum
yum install -y tmux

# Run bootnode
docker run -d \
--net=host ${docker} \
bootnode --node-key ${priv}
