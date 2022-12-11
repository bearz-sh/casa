# !/bin/bash

BWD=$(dirname $(realpath $0))

sudo bash $BWD/install-prebuilt-mpr.sh 

if ! command -v just &> /dev/null; then
    sudo apt install just -y
fi 