


Помсмотреть ключ для подключения ноды
$ docker swarm join-token worker

docker swarm join --token



# Создание сервиса
    docker service create \
    --network my-net \
    --name zookeeper-1046_company_com \
    --mount type=bind,source=/home/docker/data/zookeeper,target=/data \
    --env ZOO_MY_ID=1 \
    --env ZOO_SERVERS="server.1=zookeeper-1046_company_com:2888:3888 server.2=zookeeper-0161_company_com:2888:3888 server.3=zookeeper-0114_company_com:2888:3888" \
    --constraint "node.hostname == 1046.company.com" \
    zookeeper

    docker service create \
    --network my-net \
    --name zookeeper-0161_company_com \
    --mount type=bind,source=/home/docker/data/zookeeper,target=/data \
    --env ZOO_MY_ID=2 \
    --env ZOO_SERVERS="server.1=zookeeper-1046_company_com:2888:3888 server.2=zookeeper-0161_company_com:2888:3888 server.3=zookeeper-0114_company_com:2888:3888" \
    --constraint "node.hostname == 0161.company.com" \
    zookeeper

    docker service create \
    --network my-net \
    --name zookeeper-0114_company_com \
    --mount type=bind,source=/home/docker/data/zookeeper,target=/data \
    --env ZOO_MY_ID=3 \
    --env ZOO_SERVERS="server.1=zookeeper-1046_company_com:2888:3888 server.2=zookeeper-0161_company_com:2888:3888 server.3=zookeeper-0114_company_com:2888:3888" \
    --constraint "node.hostname == 0114.company.com" \
    zookeeper