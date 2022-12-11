# !/bin/bash
if grep -q POWERSHELL_TELEMETRY_OPTOUT  "/etc/environment"; then
   echo "POWERSHELL_TELEMETRY_OPTOUT found"
else 
   echo "POWERSHELL_TELEMETRY_OPTOUT not found"
   echo 'POWERSHELL_TELEMETRY_OPTOUT="1"' | sudo tee -a /etc/environment 
fi

if grep -q DOTNET_CLI_TELEMETRY_OPTOUT  "/etc/environment"; then
   echo "DOTNET_CLI_TELEMETRY_OPTOUT found"
else 
   echo "DOTNET_CLI_TELEMETRY_OPTOUT not found"
   echo 'DOTNET_CLI_TELEMETRY_OPTOUT="1"' | sudo tee -a /etc/environment 
fi

DOWNLOADS_DIR="/home/$SUDO_USER/Downloads"

if ! command -v pwsh &> /dev/null; then
    sudo apt-get install -y wget git keepassxc apt-transport-https software-properties-common

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


export POWERSHELL_TELEMETRY_OPTOUT="1"
export DOTNET_CLI_TELEMETRY_OPTOUT="1"


SUDOER_FILE="/etc/sudoers.d/$SUDO_USER"
if test -f "$SUDOER_FILE"; then
    echo "$SUDOER_FILE exists."
else 
    echo "$SUDO_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee $SUDOER_FILE
fi