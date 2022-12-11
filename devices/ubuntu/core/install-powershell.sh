# !/bin/bash
if grep -q POWERSHELL_TELEMETRY_OPTOUT  "/etc/environment"; then
   echo "POWERSHELL_TELEMETRY_OPTOUT found"
else 
   echo "POWERSHELL_TELEMETRY_OPTOUT not found"
   echo 'POWERSHELL_TELEMETRY_OPTOUT="1"' | sudo tee -a /etc/environment 
fi

if (( $EUID == 0 )); then
    DOWNLOADS_DIR="/home/$USER/Downloads"
    if [ ! -d "$DOWNLOADS_DIR" ]; then
        mkdir -p $DOWNLOADS_DIR
        chown -R $SUDO_USER $DOWNLOADS_DIR
    fi
else 
    DOWNLOADS_DIR="/home/$SUDO_USER/Downloads"
    if [ ! -d "$DOWNLOADS_DIR" ]; then
        mkdir -p $DOWNLOADS_DIR
        chown -R $SUDO_USER $DOWNLOADS_DIR
    fi
fi


if ! command -v pwsh &> /dev/null; then
    sudo apt-get install -y wget apt-transport-https software-properties-common

    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -P $DOWNLOADS_DIR
    # Register the Microsoft repository GPG keys
    sudo dpkg -i "$DOWNLOADS_DIR/packages-microsoft-prod.deb"
    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get update
    # Install PowerShell

    sudo apt-get install -y powershell
    rm "$DOWNLOADS_DIR/packages-microsoft-prod.deb"
else 
    echo "powershell installed"
fi