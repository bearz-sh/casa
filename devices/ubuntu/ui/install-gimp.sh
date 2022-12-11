if ! command -v gimp &> /dev/null; then
    sudo add-apt-repository ppa:ubuntuhandbook1/gimp
    sudo apt update
    sudo apt install gimp
fi