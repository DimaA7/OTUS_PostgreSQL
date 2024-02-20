**ДЗ Репликация**

Цель: реализовать свой миникластер на 3 ВМ.
Описание/Пошаговая инструкция выполнения домашнего задания:

# На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение.

Использую 3 контейнера в Docker

docker network create replication
docker container run -it -p 5551:5432 --name=db1 --network replication --hostname=db1 ubuntu:22.04 bash
docker container run -it -p 5552:5432 --name=db2 --network replication --hostname=db2 ubuntu:22.04 bash
docker container run -it -p 5553:5432 --name=db3 --network replication --hostname=db3 ubuntu:22.04 bash


docker exec -it db1 bash
docker exec -it db2 bash
docker exec -it db3 bash



docker container run -it -p 5651:5432 --name=db_1 --network replication --hostname=db_1 ubuntu2004-pg15:latest bash
docker container run -it -p 5652:5432 --name=db_2 --network replication --hostname=db_2 ubuntu2004-pg15:latest bash
docker container run -it -p 5653:5432 --name=db_3 --network replication --hostname=db_3 ubuntu2004-pg15:latest bash

docker exec -it db_1 bash
docker exec -it db_2 bash
docker exec -it db_3 bash

Portainer
https://158.160.32.35:9443

# sudo apt remove postgresql-15


# Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2.
# На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение.
# Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
# 3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ).

ДЗ сдается в виде миниотчета на гитхабе с описанием шагов и с какими проблемами столкнулись.
реализовать горячее реплицирование для высокой доступности на 4ВМ. Источником должна выступать ВМ №3. Написать с какими проблемами столкнулись.

Критерии оценки:
Выполнение ДЗ: 10 баллов

5 баллов за задание со *
плюс 2 балл за красивое решение
минус 2 балл за рабочее решение, и недостатки указанные преподавателем не устранены