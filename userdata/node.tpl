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
aws s3 sync s3://${bucket}/genesis.json /data/genesis.json

# Run docker container
docker run -v /data:/data ${docker} -datadir /data -chain /data/genesis.json -mine -bootnode ${bootnode}
