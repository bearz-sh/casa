# !/bin/bash

if [ "$NODE_VERSION" -eq "" ]; then 
    NODE_VERSION="18"
fi 

if ! command -v just &> /dev/null; then
    curl -fsSL "https://deb.nodesource.com/setup_$NODE_VERSION.x" | sudo -E bash -
    sudo apt install nodejs -y
fi 