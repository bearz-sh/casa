if ! command -v darktable &> /dev/null; then
    echo 'deb http://download.opensuse.org/repositories/graphics:/darktable:/stable/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/graphics:darktable:stable.list
    curl -fsSL https://download.opensuse.org/repositories/graphics:darktable:stable/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/graphics_darktable_stable.gpg > /dev/null
    sudo apt update
    sudo apt install darktable -y
fi 

