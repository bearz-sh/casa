if ! command -v brave-browser &> /dev/null; then
    sudo apt install apt-transport-https curl -y

    URL="https://brave-browser-apt-release.s3.brave.com/"
    KEY="/etc/apt/trusted.gpg.d/brave-brower-archive-keyring.gpg"
    KEY_DOWNLOAD_URL="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"

    sudo curl -fsSLo "$KEY" "$KEY_DOWNLOAD_URL"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=$KEY] $URL stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

    sudo apt update -y

    sudo apt install brave-browser -y
fi 