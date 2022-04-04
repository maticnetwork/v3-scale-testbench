#!/bin/bash

N=$1

# build accounts
docker run -v $PWD/account-data:/data example init-account --datadir /data/test-dir- --num $N

# build genesis file
docker run -v $PWD/account-data:/data example init-genesis --output /data

# Build the bootnode
docker run -v $PWD/bootnode:/data example bootnode --save-key /data --dry-run

# Change permissions (again)
sudo chmod -R 755 account-data
sudo chmod -R 755 bootnode
