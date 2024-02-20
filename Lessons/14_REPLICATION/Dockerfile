FROM ubuntu:22.04
RUN
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
    apt update && sudo apt dist-upgrade -y
    apt install -y lsb_release iputils-ping sudo vim netcat nano mc gnupg2 wget

    # postgresql postgresql-contrib

    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -q  &&\
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -&&\
        sudo apt update &&\
        sudo DEBIAN_FRONTEND=noninteractive apt install postgresql-15 postgresql-client -y

    sudo service postgresql start


    sudo systemctl enable postgresql
    sudo systemctl start postgresql
sudo systemctl stop postgresql

sudo pg_ctlcluster 15 main restart
sudo pg_ctlcluster 15 main stop
sudo pg_ctlcluster 15 main start

# sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null


sudo apt remove postgresql-15