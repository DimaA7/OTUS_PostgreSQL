[ZooKeeper Administrator's Guide](https://zookeeper.apache.org/doc/r3.3.3/zookeeperAdmin.html)
[Zookeeper Docker Official Image](https://hub.docker.com/_/zookeeper)


Использование портов

2181 - Порт подключения клиента
2888 - используется узлом- лидером для связи с узлом- последователем , вызываемым Quorum port
8080 - Порт сервера администратора, мы можем получить доступ к состоянию узла с помощью API
3888 - Порт выборов лидера (для голосования за лидера)