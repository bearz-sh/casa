# !/bin/bash

BWD=$(dirname $(realpath $0))

sudo bash $BWD/install-node.sh 

if ! command -v yarn &> /dev/null; then
    npm install -g yarn
fi