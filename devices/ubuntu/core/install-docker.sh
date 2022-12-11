# !/bin/bash

if ! command -v docker &> /dev/null; then
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    KEY="/etc/apt/trusted.gpg.d/docker.gpg"
    KEY_DOWNLOAD_URL="https://download.docker.com/linux/ubuntu/gpg"
    URL="https://download.docker.com/linux/ubuntu"

    curl -fsSL $KEY_DOWNLOAD_URL | sudo gpg --dearmor -o $KEY

    echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEY] $URL $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update -y

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
fi 