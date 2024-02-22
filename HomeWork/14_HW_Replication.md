**ДЗ Репликация**

Цель: реализовать свой миникластер на 3 ВМ.
Описание/Пошаговая инструкция выполнения домашнего задания:


# Подготовка 3-х контейнеров в docker для теста. 
    Использую 3 контейнера в Docker с установленной Ubuntu 22.04 и PostgreSQL 15.

  ## Создание сети docker
    docker network create replication
  ## Сорздание и запуск контейнеров из подготовленного имиджа
    docker container run -it -p 5651:5432 --name=db_1 --network replication --hostname=db_1 ubuntu2004-pg15:latest bash
    docker container run -it -p 5652:5432 --name=db_2 --network replication --hostname=db_2 ubuntu2004-pg15:latest bash
    docker container run -it -p 5653:5432 --name=db_3 --network replication --hostname=db_3 ubuntu2004-pg15:latest bash
  ## Команды для запуска bash на контейнерах:
    docker exec -u root -it db_1 bash
    docker exec -u root -it db_2 bash
    docker exec -u root -it db_3 bash
  ## Команды для запуска plsql
    psql --host db_1 --port 5432 -U postgres -d postgres
    psql --host db_2 --port 5432 -U postgres -d postgres
    psql --host db_3 --port 5432 -U postgres -d postgres
  ## Подключение с локальной машины:
    psql -h localhost -U postgres -p 5432 -d postgres
  ## Команды для перезагрузки контейнеров
    docker restart db_1
    docker restart db_2
    docker restart db_3
  ## Команда запуска сервиса Docker
    service postgresql start

  ## Вход в Portainer
    https://158.160.32.35:9443

  ## Проверка соединения
    # nc -vz db_1 5432
    # nc -vz db_2 5432
    # nc -vz db_3 5432

    

# На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение.
 ## Создание итаблицы TEST
    # CREATE TABLE TEST(id serial primary key, name text, age int);
    CREATE TABLE
  
 ## Заполнение таблицы автосгенерированными 100 записями.
    insert into test(id, name, age)
    select generate_series(0,100), 
    (array['Иван', 'Юрий', 'Дмитрий', 'Марат', 'Петр', 'Валерий', 'Сергей', 'Андрей', 'Светлана', 'Екатерина', 'Марина', 'Анна', 'Вероника'])[(random() * 14)::int],
    floor(random() * (120-1+1) + 1)::int;
 
 ## создание таблицы test2 для чтения
    # CREATE TABLE TEST2(id serial primary key, name text, age int);
    CREATE TABLE

# Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2.
 ## создание публикации на ВМ db_1 
    CREATE PUBLICATION test_pub FOR TABLE test;
    \password

 ## Создание подписки на ВМ db_1
    CREATE SUBSCRIPTION test2_sub
    CONNECTION 'host=db_2 port=5432 user=postgres password=postgres dbname=postgres'
    PUBLICATION test2_pub WITH (copy_data = true);

# На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение.

 ## Создание итаблицы TEST
    CREATE TABLE TEST2(id serial primary key, name text, age int);
  
 ## Заполнение таблицы автосгенерированными 100 записями.
    insert into test2(id, name, age)
    select generate_series(0,100), 
    (array['Иван', 'Семен', 'Виталий', 'Алексей', 'Дмитрий', 'Валентин', 'Аким', 'Антон', 'Вера', 'Софья', 'Мария', 'Алена', 'Алла'])[(random() * 14)::int],
    floor(random() * (120-1+1) + 1)::int;
 
 ## создание таблицы test для чтения
    CREATE TABLE TEST(id serial primary key, name text, age int);

# Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
  ## создание публикации test2 на ВМ db_2 
    CREATE PUBLICATION test2_pub FOR TABLE test2;
    \password

  ## Создание подписки на таблицу test на ВМ db_2
    CREATE SUBSCRIPTION test_sub
    CONNECTION 'host=db_1 port=5432 user=postgres password=postgres dbname=postgres'
    PUBLICATION test_pub WITH (copy_data = true);

# 3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ).
   postgres=# alter system set wal_level = 'logical';
   ALTER SYSTEM
   Рестарт Postgres

    postgres=# create database repl;
    CREATE DATABASE
    postgres=# \c repl 
    You are now connected to database "repl" as user "postgres".

    repl=# create table test (id serial primary key, name text, age int);
    CREATE TABLE
    repl=# create table test2 (id serial primary key, name text, age int);;
    CREATE TABLE
    
    repl=# create subscription subs_test connection 'host=db_1 user=postgres password=postgres dbname=postgres' publication publ_test with (copy_data = true);
    NOTICE:  created replication slot "subs_test" on publisher
    CREATE SUBSCRIPTION

    repl=# create subscription subs_test2 connection 'host=db_2 user=postgres password=postgres dbname=postgres' publication publ_test2 with (copy_data = true);
    NOTICE:  created replication slot "subs_test2_3" on publisher
    CREATE SUBSCRIPTION
 
 ## Просмотр подписок на db_3
   repl=# \dRs+
                                                                 List of subscriptions
     Name     |  Owner   | Enabled | Publication  | Binary | Streaming | Synchronous commit |                         Conninfo                          
--------------+----------+---------+--------------+--------+-----------+--------------------+-----------------------------------------------------------
 subs_test    | postgres | t       | {publ_test1} | f      | f         | off                | host=db_1 user=postgres password=postgres dbname=repl
 subs_test2   | postgres | t       | {publ_test2} | f      | f         | off                | host=db_2 user=postgres password=postgres dbname=repl 
  



ДЗ сдается в виде миниотчета на гитхабе с описанием шагов и с какими проблемами столкнулись.
реализовать горячее реплицирование для высокой доступности на 4ВМ. Источником должна выступать ВМ №3. Написать с какими проблемами столкнулись.

Критерии оценки:
Выполнение ДЗ: 10 баллов

5 баллов за задание со *
плюс 2 балл за красивое решение
минус 2 балл за рабочее решение, и недостатки указанные преподавателем не устранены