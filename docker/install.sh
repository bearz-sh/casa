# !/bin/bash

BWD=$(dirname $(realpath $0))

if [ "$(lsb_release -is)" -eq 'Ubuntu' ]; then 
    $dir = "$BWD/../devices/ubuntu/core"

    sudo bash "$dir/install-node.sh"
    sudo bash "$dir/install-just.sh"
    sudo bash "$dir/install-yarn.sh"
    sudo bash "$dir/install-powershell.sh"
    sudo bash "$dir/install-mkcert.sh"
    sudo bash "$dir/install-docker.sh"

    if ! command -v hsb &> /dev/null; then
        sudo yarn global install hsb-cli --prefix /usr/local
    fi 

    if ! command -v dotenv &> /dev/null; then
        sudo yarn global install dotenv-cli --prefix /usr/local
    fi 

    if [ ! -d "./node_modules" ]; then
        yarn install 
    if
fi 
