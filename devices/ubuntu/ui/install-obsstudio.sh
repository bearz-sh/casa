

if ! command -v obs-studio &> /dev/null; then
    # will trigger enroll mok for secure boot => https://wiki.ubuntu.com/UEFI/SecureBoot
    sudo apt install v4l2loopback-dkms -y
    sudo add-apt-repository ppa:obsproject/obs-studio -y
    sudo apt update -y
    sudo apt install obs-studio -y
fi