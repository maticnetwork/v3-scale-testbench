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
docker run -d --net=host ${docker} bootnode --node-key ${priv}
docker run -d --name dd-agent -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e DD_API_KEY=${dd_api_key} -e DD_SITE="datadoghq.com" gcr.io/datadoghq/agent:7
