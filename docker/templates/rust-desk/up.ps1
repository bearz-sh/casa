

if($IsWindows)
{
    sudo docker run --rm --entrypoint /usr/bin/rustdesk-utils  rustdesk/rustdesk-server-s6:latest genkeypair

} else {
    docker run --rm --entrypoint /usr/bin/rustdesk-utils  rustdesk/rustdesk-server-s6:latest genkeypair
}

sudo ufw allow 21115:21119/tcp
sudo ufw allow 8000/tcp
sudo ufw allow 21116/udp