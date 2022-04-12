#!/bin/bash

# Install docker
yum update -y
amazon-linux-extras install docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
docker info

# Install dependencies
yum install -y tmux awscli 

# Download account data from S3
mkdir /data
chown ec2-user:ec2-user /data
aws s3 sync s3://${bucket}/test-dir-${index} /data/
aws s3 cp s3://${bucket}/genesis.json /data/genesis.json

# Run docker container
docker run -d \
--net=host \
-v /data:/data ${docker} \
server -datadir /data \
-chain /data/genesis.json \
-mine \
-bind 0.0.0.0 \
-metrics -metrics.expensive -metrics.prometheus-addr=0.0.0.0:7071 \
-bootnodes ${bootnode}

docker run -d --name dd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
--add-host host.docker.internal:host-gateway \
-l com.datadoghq.ad.check_names='["openmetrics"]' \
-l com.datadoghq.ad.init_configs='[{}]' \
-l com.datadoghq.ad.instances='[[{"openmetrics_endpoint":"http://host.docker.internal:7071/metrics", "namespace": "v3", "metrics": ["geth*","txpool*","trie*","system*","state*","rpc*","p2p*","les*","eth*","chain*"]}]]' \
-e DD_TAGS="network:v3-dev deployment:test1" \
-e DD_API_KEY=${dd_api_key} \
-e DD_SITE="datadoghq.com" \
gcr.io/datadoghq/agent:7
