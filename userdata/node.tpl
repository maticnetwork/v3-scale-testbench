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

# Run docker containers
