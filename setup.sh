#!/usr/bin/env bash

setup_package_dependencies () {
    sudo apt-get -q -y install git
    sudo apt-get -q -y install make
    sudo apt-get -q -y install libxslt-dev
    sudo apt-get -q -y install libxml2-dev
    sudo apt-get -q -y install ruby1.9.1-dev
    sudo apt-get -q -y install mysql-client-5.5
    sudo apt-get -q -y install unzip
}

setup_aws_cli () {
    CLI_VERSION='AWS-ElasticBeanstalk-CLI-2.5.1'
    CLI_FILE="$CLI_VERSION.zip"
    SCRIPT_PATH=`pwd`
    CLI_LOCATION="$SCRIPT_PATH/$CLI_VERSION"
    curl -s -O "https://s3.amazonaws.com/elasticbeanstalk/cli/$CLI_FILE"
    unzip -o -q $CLI_FILE

    echo "export CLI_LOCATION=$CLI_LOCATION" >> ~/.bash_profile
    source ~/.bash_profile
}

setup_ssh_hey () {
    KEY_FILE='id_rsa'

    if [ -f ~/.ssh/$KEY_FILE ]; then
        return
    fi

    EMAIL='alexrfalkowski@gmail.com'
    MESSAGE="NOTE: Make sure you add the contents of ~/.ssh/$KEY_FILE.pub to Github. Please follow the instructions here https://help.github.com/articles/generating-ssh-keys"
    ssh-keygen -q -t rsa -C $EMAIL -N '' -f $KEY_FILE
    mv -f id_rsa* ~/.ssh
    echo -e "\033[1m$MESSAGE\033[0m"
}

setup_package_dependencies
setup_aws_cli
setup_ssh_hey

exit 0
