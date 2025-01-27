#!/bin/bash

function reados()
{
    echo 'debian'
}

git submodule update --init --recursive

if [[ $(reados) == 'debian' ]]; then
    sudo apt install python3 python3-pip

    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
    sudo apt update
    sudo apt -y install postgresql-12 postgresql-client-12 postgresql-server-dev-12

    pg_ctlcluster 12 main start
	service postgresql restart
	sudo -u postgres createuser -s root

    # https://github.com/ankane/dexter/blob/master/guides/Linux.md
    wget -qO- https://dl.packager.io/srv/pghero/dexter/key | sudo apt-key add -
    sudo wget -O /etc/apt/sources.list.d/dexter.list \
      https://dl.packager.io/srv/pghero/dexter/master/installer/ubuntu/20.04.repo
    sudo apt update
    sudo apt -y install dexter

    # https://github.com/gregrahn/tpcds-kit
    sudo apt -y install flex bison byacc
elif [[ $(reados) == 'darwin' ]]; then
    brew install python3

    brew install postgresql@12
    brew services start postgresql
    brew install ankane/brew/dexter
fi

cd hypopg
make
sudo make install
rm *.bc import/*.bc
cd ..

pip3 install -r requirements.txt
