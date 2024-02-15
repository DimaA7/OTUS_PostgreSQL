[https://www.citusdata.com/blog/2023/03/06/patroni-3-0-and-citus-scalable-ha-postgres/#patroni](https://www.citusdata.com/blog/2023/03/06/patroni-3-0-and-citus-scalable-ha-postgres/#patroni)
[adavarski/docker-postgresql-ha-patroni-consul-zookeeper](https://github.com/adavarski/docker-postgresql-ha-patroni-consul-zookeeper/tree/main)
[zalando/patroni](https://github.com/zalando/patroni/blob/master/Dockerfile.citus)
[Patroni: A Template for PostgreSQL HA with ZooKeeper, etcd or Consul](https://github.com/UKHomeOffice/docker-postgres-patroni-not-tracking/blob/master/patroni/README.rst)

# Установка portainer
version: "3"
services:
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - 8000:8000
      - 9443:9443
      volumes:
        - portainer_data:/data
        - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
volumes:
  data:

$ docker compose -f portainer.yml up

First, create the volume that Portainer Server will use to store its database:
    docker volume create portainer_data
Then, download and install the Portainer Server container:
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

Проброс порта:
    ssh  -L 9443:178.154.200.237:9443 dima@178.154.200.237


    Сначала нам нужно клонировать репозиторий Patroni и создать patroni-citus образ docker
    $ git clone https://github.com/zalando/patroni.git
$ cd patroni
$ docker build -t patroni-citus -f Dockerfile.citus .

Как только образ будет готов, мы развернем стек с помощью:

$ docker-compose -f docker-compose-citus.yml up -d
Creating demo-etcd1   ... done
Creating demo-work1-2 ... done
Creating demo-coord2  ... done
Creating demo-coord3  ... done
Creating demo-work1-1 ... done
Creating demo-etcd2   ... done
Creating demo-work2-2 ... done
Creating demo-coord1  ... done
Creating demo-work2-1 ... done
Creating demo-haproxy ... done
Creating demo-etcd3   ... done



Сначала нам нужно клонировать репозиторий Patroni и создать patroni-citus образ docker:

$ git clone https://github.com/zalando/patroni.git
$ cd patroni
$ docker build -t patroni-citus -f Dockerfile.citus .
Sending build context to Docker daemon  573.6MB
Step 1/36 : ARG PG_MAJOR=15
… skip intermediate logs
Step 36/36 : ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
---> Running in 1933967fcb58
Removing intermediate container 1933967fcb58
---> 0eea66f3c4c7
Successfully built 0eea66f3c4c7
Successfully tagged patroni-citus:latest
Как только образ будет готов, мы развернем стек с помощью:

$ docker-compose -f docker-compose-citus.yml up -d
Creating demo-etcd1   ... done
Creating demo-work1-2 ... done
Creating demo-coord2  ... done
Creating demo-coord3  ... done
Creating demo-work1-1 ... done
Creating demo-etcd2   ... done
Creating demo-work2-2 ... done
Creating demo-coord1  ... done
Creating demo-work2-1 ... done
Creating demo-haproxy ... done
Creating demo-etcd3   ... done
Теперь мы можем убедиться, что контейнеры запущены:

$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                              NAMES
e7740f00796d   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd2
8a3903ca40a7   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd3
3d384bf74315   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute   0.0.0.0:5000-5001->5000-5001/tcp   demo-haproxy
2f6c9e4c63b8   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work2-1
4bd35bfdba58   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord1
8dce43a4f499   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work1-1
e76372163464   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work2-2
0de7bf5044fd   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord3
633f9700e86f   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord2
f50bb1e1d6e7   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd1
03bd34403ac2   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work1-2






Проброс порта:
    ssh  -L 5000:178.154.200.237:5000 dima@178.154.200.237


