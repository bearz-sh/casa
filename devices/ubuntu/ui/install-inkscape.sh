if ! command -v inkscape &> /dev/null; then

    sudo add-apt-repository ppa:inkscape.dev/stable -y
    sudo apt update -y
    sudo apt install inkscape -y
fi