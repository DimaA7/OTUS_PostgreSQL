Описание/Пошаговая инструкция выполнения домашнего задания:

# создайте новый кластер PostgresSQL 14
sudo pg_createcluster 15 main2 -p 5433
Creating new PostgreSQL cluster 15/main2 ...

# зайдите в созданный кластер под пользователем postgres
sudo -u postgres psql -p 5433
psql (16.1 (Ubuntu 16.1-1.pgdg22.04+1), server 15.5 (Ubuntu 15.5-1.pgdg22.04+1))
Type "help" for help.

# создайте новую базу данных testdb
postgres=# CREATE DATABASE testdb;
CREATE DATABASE

# зайдите в созданную базу данных под пользователем postgres
postgres=# \c testdb;
psql (16.1 (Ubuntu 16.1-1.pgdg22.04+1), server 15.5 (Ubuntu 15.5-1.pgdg22.04+1))
You are now connected to database "testdb" as user "postgres".
testdb=#

# создайте новую схему testnm
testdb=# create schema testnm;
CREATE SCHEMA

# создайте новую таблицу t1 с одной колонкой c1 типа integer
testdb=# create table t1 (
    c1 integer);
CREATE TABLE

# вставьте строку со значением c1=1
testdb=# insert into t1 (c1) values (1);
INSERT 0 1

# создайте новую роль readonly
postgres=# create role readonly;
CREATE ROLE

# дайте новой роли право на подключение к базе данных testdb
postgres=# GRANT CONNECT ON DATABASE testdb TO readonly;
GRANT

# дайте новой роли право на использование схемы testnm
testdb=# GRANT USAGE ON SCHEMA testnm TO readonly;
GRANT

# дайте новой роли право на select для всех таблиц схемы testnm
testdb=# GRANT SELECT ON ALL TABLES IN SCHEMA testnm TO readonly;
GRANT

# создайте пользователя testread с паролем test123
testdb=# create user testread with password 'test123';
CREATE ROLE

# дайте роль readonly пользователю testread
testdb=# GRANT readonly TO testread;
GRANT ROLE

# зайдите под пользователем testread в базу данных testdb
 sudo -u postgres psql -d testdb -U testread -p 5433
psql (16.1 (Ubuntu 16.1-1.pgdg22.04+1), server 15.5 (Ubuntu 15.5-1.pgdg22.04+1))
Type "help" for help.

testdb=>

# сделайте select * from t1;
testdb=> select * from t1;
ERROR:  permission denied for table t1
# получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)
# напишите что именно произошло в тексте домашнего задания
# у вас есть идеи почему? ведь права то дали?
# посмотрите на список таблиц
# подсказка в шпаргалке под пунктом 20
# а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)

Таблицу создал в схеме public а не в схеме testnm. 
testdb=# \dt
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | t1   | table | postgres
(1 row)

При создании таблицы надо было указать схему.

# вернитесь в базу данных testdb под пользователем postgres

sudo -u postgres psql -d testdb -U postgres -p 5433
psql (16.1 (Ubuntu 16.1-1.pgdg22.04+1), server 15.5 (Ubuntu 15.5-1.pgdg22.04+1))
Type "help" for help.

# удалите таблицу t1
testdb=# drop table t1;
DROP TABLE

# создайте ее заново но уже с явным указанием имени схемы testnm

вставьте строку со значением c1=1
зайдите под пользователем testread в базу данных testdb
сделайте select * from testnm.t1;
получилось?
есть идеи почему? если нет - смотрите шпаргалку
как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку
сделайте select * from testnm.t1;
получилось?
есть идеи почему? если нет - смотрите шпаргалку
сделайте select * from testnm.t1;
получилось?
ура!
теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);
а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
есть идеи как убрать эти права? если нет - смотрите шпаргалку
если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что сделали и почему выполнив указанные в ней команды
теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
расскажите что получилось и почему

Критерии оценки:
Выполнение ДЗ: 10 баллов
плюс 2 балл за красивое решение
минус 2 балл за рабочее решение, и недостатки указанные преподавателем не устранены