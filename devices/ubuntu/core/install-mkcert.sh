# !/bin/bash

if ! command -v mkcert &> /dev/null; then
    sudo apt install libnss3-tools -y
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    sudo rm mkcert-v*-linux-amd64
fi