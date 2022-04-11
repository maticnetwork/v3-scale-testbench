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
bootnode --node-key ${priv} \
-metrics -metrics.expensive -metrics.prometheus-addr=0.0.0.0:7071

docker run -d --name dd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
--add-host host.docker.internal:host-gateway \
-l com.datadoghq.ad.check_names='["openmetrics"]' \
-l com.datadoghq.ad.init_configs='[{}]' \
-l com.datadoghq.ad.instances='[[{"openmetrics_endpoint":"http://host.docker.internal:7071/metrics", "namespace": "v3"}]]' \
-e DD_TAGS=v3 \
-e DD_API_KEY=${dd_api_key} \
-e DD_SITE="datadoghq.com" \
gcr.io/datadoghq/agent:7
