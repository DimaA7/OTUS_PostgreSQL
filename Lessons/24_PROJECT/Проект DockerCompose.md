[Создание масштабируемой и высокодоступной системы Postgres с помощью Patroni 3.0 и Citus](https://habr.com/ru/companies/otus/articles/755032/)
[Patroni 3.0 & Citus: Scalable, Highly Available Postgres](https://www.citusdata.com/blog/2023/03/06/patroni-3-0-and-citus-scalable-ha-postgres/#patroni)
[adavarski/docker-postgresql-ha-patroni-consul-zookeeper](https://github.com/adavarski/docker-postgresql-ha-patroni-consul-zookeeper/tree/main)
[zalando/patroni](https://github.com/zalando/patroni/blob/master/Dockerfile.citus)
[Patroni: A Template for PostgreSQL HA with ZooKeeper, etcd or Consul](https://github.com/UKHomeOffice/docker-postgres-patroni-not-tracking/blob/master/patroni/README.rst)

# Установка portainer
    ## Docker файл portainer.yml 
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
 ## Запуск контейнера
      $ docker compose -f portainer.yml up
 ## Создание volume для хранения БД Portainer сервера
      $ docker volume create portainer_data
 ## Загрузка и установка контейнера 
      $ docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
 ## Проброс порта portainer:
      ssh  -L 9443:178.154.200.237:9443 dima@178.154.200.237
      https://localhost:9443/
      https://[ip address]:9443/

# Установка patroni-citus
 ## Клонирование репозитория Patroni и создание docker-образа patroni-citus
      $ git clone https://github.com/zalando/patroni.git
      $ git clone https://github.com/DimaA7/zpatroni.git
      $ cd zpatroni
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

 ## Разворачивание стека из образа:
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

 ## Теперь мы можем убедиться, что контейнеры запущены:
      $ docker ps
          CONTAINER ID   IMAGE            COMMAND                  CREATED        STATUS       PORTS                             NAMES
          ec9322c7db45   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-etcd3
          f22c0be7edf2   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-coord3
          d6506905584f   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-coord1
          d8b1641c029b   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-work1-1
          1fc25ac4a37a   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-work1-2
          7b2252c0c465   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-work2-2
          44249c6cb58a   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   0.0.0.0:5000-5001->5000-5001/tcp, :::5000-5001->5000-5001/tcp, 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp   demo-haproxy
          d83766873152   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-etcd2
          e68c60d3f67d   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-coord2
          024daed3b0a3   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-work2-1
          1a9964759fab   patroni-citus    "/bin/sh /entrypoint…"   2 hours ago    Up 2 hours   demo-etcd1
          6b54295e54a6   portainer/portainer-ce:latest "/portainer" 47 hours ago  Up 4 hours   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp, 9000/tcp portainer

# Запустить/остановить/перезапустить все запущенные контейнеры:
        docker start $(docker ps -a -q)
        docker stop $(docker ps -a -q)
        docker restart $(docker ps -a -q)
        В docker ps команде перечислены все запущенные контейнеры, а -q опция вернет только идентификатор контейнера. Это передается в docker команду для остановки каждого контейнера.

# Открытие сайта HA Proxy
    Проброс порта: HA Proxy
        ssh  -L 7000:178.154.200.237:7000 dima@178.154.200.237
        http://158.160.125.195:7000/
        http://localhost:7000/


# Подключение к БД 
      docker exec -ti demo-haproxy bash
          postgres@haproxy:~$ patronictl list
      
          postgres@haproxy:~$ psql -h localhost -p 5000 -U postgres -d citus
          Password for user postgres: postgres
      
              citus=# \dx

              select nodeid, groupid, nodename, nodeport, noderole
              from pg_dist_node order by groupid

# Создание распределенной таблицы Citus и запись в нее данных 
 ## Создание 
          citus=# create table my_distributed_table(id bigint not null generated always as identity, value double precision);
          CREATE TABLE
          citus=# select create_distributed_table('my_distributed_table', 'id');
          create_distributed_table
          --------------------------

          (1 row)
 ## Запись
          citus=# with inserted as (
              insert into my_distributed_table(value)
              values(random()) RETURNING id
          ) SELECT now(), id from inserted\watch 0.01



$ docker exec -ti demo-haproxy bash

postgres@haproxy:~$ patronictl switchover

TRUNCATE TABLE

https://app.diagrams.net/#G1q7p86UrdyCVclpDKvGH00LGZ8CwGWhnf#%7B%22pageId%22%3A%22q9_abYsVsID2bkDwJTH_%22%7D


$ docker exec -ti demo-work1-1 bash
postgres@work1-1:~$ patronictl list
+ Citus cluster: demo ----------+--------------+-----------+----+-----------+
| Group | Member  | Host        | Role         | State     | TL | Lag in MB |
+-------+---------+-------------+--------------+-----------+----+-----------+
|     0 | coord1  | 172.21.0.4  | Leader       | running   |  2 |           |
|     0 | coord2  | 172.21.0.10 | Sync Standby | streaming |  2 |         0 |
|     0 | coord3  | 172.21.0.3  | Replica      | streaming |  2 |         0 |
|     1 | work1-1 | 172.21.0.5  | Leader       | running   |  2 |           |
|     2 | work2-2 | 172.21.0.7  | Replica      | running   |  3 |         0 |
+-------+---------+-------------+--------------+-----------+----+-----------+


postgres@work1-1:~$ etcdctl member list
1bab629f01fa9065, started, etcd3, http://etcd3:2380, http://172.21.0.2:2379
8ecb6af518d241cc, started, etcd2, http://etcd2:2380, http://172.21.0.9:2379
b2e169fcb8a34028, started, etcd1, http://etcd1:2380, http://172.21.0.12:2379