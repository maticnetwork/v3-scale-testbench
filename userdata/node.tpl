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
aws s3 sync s3://<source_bucket>/test-dir-${index} /data/
aws s3 sync s3://<source_bucket>/genesis.json /home/genesis.json

# Run docker container
docker run -v /data:/data ${docker} --data-dir /data --genesis /home/genesis.json --bootnode ${bootnode}
