#!/bin/bash

# 检测操作系统类型
detect_os() {
    if grep -Eqi "centos" /etc/issue || grep -Eq "centos" /etc/*-release; then
        OS="CentOS"
    elif grep -Eqi "debian" /etc/issue || grep -Eq "debian" /etc/*-release; then
        OS="Debian"
    elif grep -Eqi "ubuntu" /etc/issue || grep -Eq "ubuntu" /etc/*-release; then
        OS="Ubuntu"
    else
        echo "不支持的操作系统类型"
        exit 1
    fi
}

# 检测并安装sudo命令
install_sudo() {
    if ! command -v sudo &> /dev/null; then
        if [ "$OS" == "CentOS" ]; then
            yum install -y sudo
        elif [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
            apt-get update
            apt-get install -y sudo
        fi
    fi
}

install_docker() {
    if ! command -v docker &> /dev/null; then
        if [ "$OS" == "CentOS" ]; then
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install docker-ce docker-ce-cli containerd.io -y
        elif [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
            sudo apt-get update
            sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
            sudo apt-get update
            sudo apt-get install docker-ce -y
        fi
        systemctl start docker
        systemctl enable docker
    else
        echo "Docker 已安装，跳过安装步骤"
    fi
}

install_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        curl -fsSL https://get.docker.com | bash -s docker
        curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose 已安装，跳过安装步骤"
    fi
}

install_xrayr_docker() {
    docker pull ghcr.io/xrayr-project/xrayr:master
    docker run --restart=always --name xrayr -d -v ~/config.yml:/etc/XrayR/config.yml --network=host ghcr.io/xrayr-project/xrayr:master
}

copy_config_to_home() {
    cp /etc/XrayR/config.yml ~/
}

main() {
    detect_os
    install_sudo
    install_docker
    install_docker_compose
    install_xrayr_docker
    copy_config_to_home
    echo "安装完成"
}

main

