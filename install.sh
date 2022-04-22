#!/bin/sh
# Poseidon v2 install script
# Only tested on ubuntu 18.04

install_docker () {
    echo "Installing Docker"
    if [ -x "$(command -v docker)" ]; then
        echo "Docker is already installed, continuing"
    else
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
        sudo apt update
        sudo apt install -y docker-ce
        sudo usermod -aG docker $USER
        echo "Docker Installed"
    fi
}

install_docker_compose () {
    echo "Installing Docker Compose"
    if [ -d ~/.docker/cli-plugins/docker-compose ]
    then
        echo "Docker Compose is already installed, continuing"
    else
        sudo mkdir -p ~/.docker/cli-plugins/
        sudo curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
        sudo chmod +x ~/.docker/cli-plugins/docker-compose
        echo "Docker Compose Installed"
    fi
}
get_poseidon_password () {
        cd /etc/poseidon
        var=$(sudo docker compose logs | grep "Created initial user admin with password:")
        local foo=`echo $var | cut -c 68-`
        echo $foo
}
install_poseidon_server () {
    echo "Downloading Poseidon Server"
    if [ -d /etc/poseidon ]
    then
        echo "/etc/poseidon exists.. skipping"
    else
        cd /etc
        sudo git config --global credential.helper store
        sudo git clone https://github.com/OpaqueIOT/poseidon.git poseidon
        cd /etc/poseidon
        sudo cp .env.example .env
        printf "\n\nWARNING: Default ENV variables will be used. Please edit .env file to change them in /etc/poseidon/.env\n\n"
        sleep 2
        echo "Poseidon Server Downloaded Successfully, installing & starting."
        sudo docker compose up --detach
        echo "Poseidon Server Started"
    fi
}
install_poseidon_ui () {
    echo "Downloading Poseidon UI"
    if [ -d /etc/poseidon-ui ]
    then
        echo "/etc/poseidon-ui exists.. skipping"
    else
        cd /etc
        sudo git clone https://github.com/OpaqueIOT/poseidon-ui-v2.git poseidon-ui
        cd /etc/poseidon-ui
        IP=$(curl -s https://ipinfo.io/ip)
        echo "setting ui api url to $IP"
        printf "ENV = 'production'\nVUE_APP_BASE_API = 'http://%s:8080/api'" $IP > .env.production
        echo "Poseidon UI Downloaded Successfully, installing & starting."
        sudo docker compose up --detach
        echo "Poseidon Server Started"
    fi
}
finish_display_info () {
    IP=$(curl -s https://ipinfo.io/ip)
    PASS="$(get_poseidon_password)"
    printf "\n ==== Poseidon Server & UI Successfully Installed! ==== \n\n"
    printf "API Server at $IP:8080\n"
    printf "IOT Server at $IP:22048\n\n"

    printf "Web UI accessable at http://$IP\n"
    printf "Default admin password is $PASS\n"

}
# Invoke your function
printf "Poseidon Install Script\n"
install_docker
install_docker_compose
install_poseidon_server
install_poseidon_ui
echo "Installation Complete"
finish_display_info