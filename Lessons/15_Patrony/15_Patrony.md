
Документация: https://patroni.readthedocs.io/en/latest/index.html
Репозиторий: https://github.com/zalando/patroni
Выступление на конференции: https://www.youtube.com/watch?v=lMPYerAYEVs&t=8109s

# Материалы
 ## Разработчики: Александр Кукушкин, Алексей Клюкин (Zalando SE)
  [Документация:](https://patroni.readthedocs.io/en/latest/index.html)

  [Репозиторий:](https://github.com/zalando/patroni)

  [Выступление на конференции:](https://www.youtube.com/watch?v=lMPYerAYEVs&t=8109s)

 # Patroni
  [lalbrekht/otus-patroni Patroni cluster demo stand](https://github.com/lalbrekht/otus-patroni)

  [zalando/patroni - Template for PostgreSQL HA with ZooKeeper, etcd or Consul](https://github.com/zalando/patroni/blob/master/README.rst)

  [Как мы построили надёжный кластер PostgreSQL на Patroni](https://habr.com/ru/companies/vk/articles/452846/)

  [Управление высокодоступными PostgreSQL кластерами с помощью Patroni | А.Клюкин, А.Кукушкин](https://www.youtube.com/watch?v=lMPYerAYEVs)
  
  [Set Up a Highly Available PostgreSQL Cluster using Docker on Ubuntu 20.04](https://www.techsupportpk.com/2022/02/set-up-highly-available-postgresql-cluster-docker-ubuntu.html)

  [Set Up a Highly Available PostgreSQL 11 Cluster on Ubuntu 20.04](https://www.techsupportpk.com/2020/02/how-to-set-up-highly-available-postgresql-cluster-ubuntu-19-20.html)

  [Patroni + Consul](https://gitlab.com/otus_linux/patroni)

  [Patroni + Zookeeper](https://temofeev.ru/info/articles/zaryazhay-patroni-testiruem-patronizookeeper-klaster-chast-pervaya/)

  [Etcd](https://github.com/coreos/etcd)

  [Пример установки и запуска patroni в среде Docker Swarm. Предполагается, что установка выполняется на пустой машине с OS Debian 10.](https://github.com/tsvetkov-vladimir/docker-patroni)

  [Patroni cluster (with Zookeeper) in a docker swarm on a local machine](https://habr.com/ru/articles/527370/)

  [Patroni 3.0 & Citus: Scalable, Highly Available Postgres](https://www.citusdata.com/blog/2023/03/06/patroni-3-0-and-citus-scalable-ha-postgres/)

  
# High availability – высокая доступность
    Распределенное хранилище
    • NFS NAS/SAN - https://habr.com/ru/post/137938/
    • DRBD - https://habr.com/ru/post/417473/
    • ISCSI (+ LVM)
    Мульти-мастер
    • BDR
    • Bucardo
    Логическая репликация
    • pglogical
    • slony
    • в postgresql с 10 версии
    Физическая репликация
    • в postgresql начиная с 9.6
    Облака
    • Yandex Cloud, GKE, AWS

# Встроенные решения
    ● Patroni
    ● Stolon:
        ○ проксирует все запросы в мастер ноду, нельзя давать нагрузку на реплики;
        ○ мастер выбирается самостоятельно при switchover-e.
    ● repmgr:
        ○ нет защиты от двойного мастера (split brain);
        ○ нет нужды в DCS.
    ● Citus pg_auto_failover
    ● Slony

# Физическая репликация
    Плюсы:
    • встроенная фича;
    • минимальная задержка;
    • идентичные копии.
    Минусы:
    • нужны одинаковые мажорные версии;
    • нет автоматического failover

У постгреса нет какого-либо решения по автоматическому фейловеру из коробки

# Patroni
• демон Patroni будет запущен рядом с PostgreSQL;
• Patroni управляет PostgreSQL;
• демон принимает решение promotion/demotion;
• TTL для ключа или сессии лидера;
• Watch для ключа лидера.


# DCS (распределенное хранилище данных)
    • принцип: key – value;
    • хранит информацию о том, кто сейчас лидер;
    • хранит конфигурацию кластера;
    • имеет алгоритмы решения задач консенсуса
    (RAFT, PAXOS);
    • обеспечивает отказоустойчивость;
    • PostgreSQL не умеет взаимодействовать с DCS;
    • демон Patroni умеет взаимодействовать с DCS.
    etcd / Consul / Zookeeper

# Направление клиентов
    • HAProxy
    • Pgbouncer (pgPool, Odyssey)
    • KeepaliveD
    • TCP Proxy (NGINX)

# Настройка ETCD
  ## Установка: apt -y install etcd
    vi /etc/default/etcd
    ETCD_NAME="etcd-Name-1"
    ETCD_LISTEN_CLIENT_URLS="http://192.168.1.14:2379,http://localhost:2379"
    ETCD_ADVERTISE_CLIENT_URLS="http://hostname1:2379"
    ETCD_LISTEN_PEER_URLS="http://192.168.1.14:2380"
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://hostname1:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd_Name_Claster"
    ETCD_INITIAL_CLUSTER="etcd-Name-1=http://hostname1:2380, etcd-Name-2=http://hostname2:2380, etcd-Name-3 =
    http://hostname3:2380"
    ETCD_INITIAL_CLUSTER_STATE="new"
    ETCD_DATA_DIR="/var/lib/etcd"

 ## Команды:
    systemctl status etcd etcdctl cluster-health
    systemctl start etcd
    systemctl stop etcd
    systemctl is-enabled etcd
    systemctl restart etcd etcdctl member list
    rm -R /var/lib/etcd/member/

# Кластер Patroni
    Name IP-address Purpose
    Node1 192.168.1.11 PostgreSQL, Patroni
    Node2 192.168.1.12 PostgreSQL, Patroni
    Etcd 192.168.1.14 etcd

 ## Настройка кластера Patroni
  ### Установка (на каждой ноде):
    • apt -y install postgresql установка PostgreSQL
    • ln -s /var/lib/postgresql/14/bin/* /usr/sbin
    • apt -y install python python3-pip установка Python и зависимостей
    • pip install setuptools
    • apt -y install libpq-dev
    • pip install psycopg2
    • pip install psycopg2-binary
    • pip install patroni
    • pip install python-etcd или python-consul
    • конфигурационный файл patroni.yml (/etc/patroni.yml)
    • Дата директория - с правами для пользователя postgres
 ### Действия (на каждой ноде):
        • systemctl stop postgresql
        • sudo -u postgres pg_dropcluster 14 main
        • systemctl daemon-reload
        • vi /etc/systemd/system/patroni.service
        [Unit]
        Description=High availability PostgreSQL Cluster
        After=syslog.target network.target
        [Service]
        Type=simple:
        User=postgres
        Group=postgres
        ExecStart=/usr/local/bin/patroni /etc/patroni.yml
        KillMode=process
        TimeoutSec=30
        Restart=no
        [Install]
        WantedBy=multi-user.target

 ### Patroni.yml
    • vi /etc/patroni.yml
    scope: Name_Cluster
    namespace: /db/
    name: Node1
    restapi:
    listen: 192.168.1.11 :8008
    connect_address: 192.168.1.11 :8008
    etcd:
    hosts: hostname1:2379, hostname2:2379,
    hostname3:2379
    bootstrap:
    dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576

        DCS:
        • loop_wait - минимальный промежуток в секундах между попытками обновить ключ лидера.
        • ttl - время жизни ключа лидера, рекомендуется как минимум loop_wait + retry_timeout * 2
        • retry-timeout - общее время всех попыток внутри одной операции
        • maximun_lag_on_failover - максимальное отставание ноды от лидера для того, чтобы участвовать в выборах

    …
    postgresql:
    use_pg_rewind: true
    parameters:
    autovacuum_analyze_scale_factor: 0.01
    …
    initdb:
    - encoding: UTF8
    pg_hba:
    - host replication replicator 127.0.0.1/8 md5
    - host replication replicator 192.168.1.11 md5
    - host replication replicator 192.168.1.12 md5
    - host all all 0.0.0.0/0 md5
    users:
    admin:
    password: Пароль админа
    options:
    - createrole
    - createdb

    …
    postgresql:
    listen: 127.0.0.1, 192.168.1.11 :5432
    connect_address: 192.168.1.11 :5432
    data_dir: /var/lib/postgresql/14/main
    bin_dir: /usr/lib/postgresql/14/bin
    authentication:
    replication:
    username: replicator
    password: Пароль
    superuser:
    username: postgres
    password: Пароль
    rewind:
    username: rewind_user
    password: Пароль
    parameters:
    unix_socket_directories: '.'

    …
    tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false

        Tags:
        • nofailover (true/false) - в положении true нода никогда не станет мастером
        • noloadbalance (true/false) - replica всегда возвращает код 503
        • clonefrom (true/false) - patronictl выберет предпочтительную ноду для pgbasebackup
        • nosync (true/false) - нода никогда не станет синхронной репликой
        • replicatefrom (node name) - указать реплику с которой снимать реплику

    Действия:
    на 1 ноде
    • sudo -u postgres patroni /etc/patroni.yml
    • systemctl start patroni
    • systemctl status patroni
    на остальных нодах
    • systemctl enable patroni
    • systemctl start patroni

  ### Команды Patroni
    systemctl start patroni.service - запуск Patroni
    systemctl status patroni - просмотр состояния
    systemctl stop patroni - остановка Patroni
    patronictl --help - утилита для управления кластером
    patronictl -c /etc/patroni.yml list - отображение данных кластера
    patronictl -c /etc/patroni.yml reload имя - перезагрузка
    patronictl -c /etc/patroni.yml switchover - ручное переключение

# Автоматический failover
    systemctl stop patroni – или любой другой способ протестировать failover =)
    1. 30 секунд по умолчанию на истечение ключа в DCS.
    2. После чего Patroni стучится на каждую ноду в кластере и спрашивает, не мастер ли
    ты, проверяет WAL логи, насколько близки они к мастеру. В итоге если WAL логи у
    всех одинаковые то, промоутится следующий по порядку.
    3. Опрос нод идёт параллельно. 
   
  ## Команды Patroni
    systemctl stop patroni
    patronictl -c /etc/patroni.yml list
    systemctl start patroni
    patronictl -c /etc/patroni.yml list
    curl –v http://192.168.1.11:8008/patroni | master | replica
    В PostgreSQL:
    select pg_is_in_recovery();
    true – replica
    false – maste

 ## Switchover vs failover
    Failover
    • Экстренное переключение Мастера на новую ноду.
    • Происходит автоматически.
    • Ручной вариант - manual failover - только когда система не может решить на кого переключать.
    Switchover
    • Переключение роли Мастера на новую ноду. Делается вручную, по сути плановые работы.
 ## Switchover
    patronictl -c /etc/patroni.yml switchover

# Глобальная конфигурация
    patronictl -c /etc/patroni.yml edit-config

    patronictl -c /etc/patroni.yml restart postgres

# Локальная конфигурация
    Что делать если нужно поменять конфигурацию PostgreSQL только локально:
    • patroni.yml
    • postgresql.base.conf
    • ALTER SYSTEM SET - имеет наивысший приоритет
    Параметры : max_connections, max_locks_per_transaction, wal_level, max_wal_senders,
    max_prepared_transactions, max_replication_slots, max_worker_processes
    не могу быть переопределены локально - Patroni их перезаписывает 

# Пользовательские скрипты
    postgresql:
    callbacks:
    on_start: /opt/pgsql/pg_start.sh
    on_stop: /opt/pgsql/pg_stop.sh
    on_restart: /opt/pgsql/pg_restart.sh
    on_role_change: /opt/pgsql/pg_role_change.sh

# Реинициализация
    patronictl -c /etc/patroni.yml reinit postgres node1 - реинициализирует ноду в кластере.
    Т.е. по сути удаляет дата директорию и делает pg_basebackup

# Режим паузы
    patronictl -c /etc/patroni.yml pause|resume - отключается | включается
    автоматический failover
    Ставится глобальная пауза на все ноды
    Проведение плановых работ, например с etcd или обновление PostgreSQL
    Тем ни менее:
    • можно создавать реплики;
    • ручной switchover возможен.

# Синхронная репликация
    synchronous_mode: true/false - не делает failover ни на какую реплику кроме синхронной
    synchronous_mode_strict: true/false - если синхронная реплика пропала, то мастер не принимает новые записи пока она не вернется
    synchronous_commit to local / off – установка асинхронного режима для транзакции даже при общем синхронном режиме


