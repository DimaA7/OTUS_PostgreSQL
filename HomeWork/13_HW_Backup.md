Домашнее задание
Бэкапы

Цель:
Применить логический бэкап. Восстановиться из бэкапа


Описание/Пошаговая инструкция выполнения домашнего задания:
# Создаем ВМ/докер c ПГ.

# Создаем БД, схему и в ней таблицу.
    postgres=# create database backup;
    CREATE DATABASE
    postgres=# create table test1(id serial primary key, name text, age int);
    CREATE TABLE
    
# Заполним таблицы автосгенерированными 100 записями.

    insert into test1(id, name, age)
    select generate_series(0,100), 
    (array['Иван', 'Юрий', 'Дмитрий', 'Марат', 'Петр', 'Валерий', 'Сергей', 'Андрей', 'Светлана', 'Екатерина', 'Марина', 'Анна', 'Вероника'])[(random() * 14)::int],
    floor(random() * (120-1+1) + 1)::int;
    
    id  |   name    | age
    -----+-----------+-----
    0 | Светлана  |  90
    1 | Юрий      |  26
    2 | Светлана  |   8
    3 | Анна      |  50
    4 | Валерий   | 103
    5 | Иван      |  31
    6 | Вероника  |   4
    7 | Марина    | 111
    8 | Дмитрий   |  69
    9 | Вероника  | 112
    ... 

    backup=# \d+ test1
                                                        Table "public.test1"
    Column |  Type   | Collation | Nullable |              Default              | Storage  | Compression | Stats target | Description
    -------+---------+-----------+----------+-----------------------------------+----------+-------------+--------------+-------------
    id     | integer |           | not null | nextval('test1_id_seq'::regclass) | plain    |             |              |
    name   | text    |           |          |                                   | extended |             |              |
    age    | integer |           |          |                                   | plain    |             |              |
    Indexes: "test1_pkey" PRIMARY KEY, btree (id)
    Access method: heap

    drop table test1;

# Под линукс пользователем Postgres создадим каталог для бэкапов

    Создаю папку     
        dima-a7@otus:~$ mkdir otus_backup
    Делаю владельцем папки пользователя postgres
        dima-a7@otus:~$ sudo chown postgres otus_backup
    
    Захожу под пользователем postgres
        dima-a7@otus:~/otus_backup$ su postgres
        Password:
        postgres@otus:/home/dima-a7/otus_backup$

    Создаю папку под пользователем postgres для бэкапов
        postgres@otus:/home/dima-a7/otus_backup$ mkdir arch_backup
        postgres@otus:/home/dima-a7/otus_backup$ cd ./arch_backup
        postgres@otus:/home/dima-a7/otus_backup/arch_backup$

    Перехожу в папку
        postgres@otus:/home/dima-a7$ cd ./otus_backup
        postgres@otus:/home/dima-a7/otus_backup$
    
    Смотрю права на папку arch_backup
        postgres@otus:/home/dima-a7/otus_backup$ ls -l
        total 4
        drwxr-xr-x 2 postgres dima-a7 4096 Jan 10 22:36 arch_backup

    Даю права на папку arch_backup
        $ sudo chmod o+w backuarch_backupp

    $ ls -l -d arch_backup
    drwxr-xrwx 2 root    root         4096 Jan  3 14:15 arch_backup

# Сделаем логический бэкап используя утилиту COPY
    backup=# \copy test1 to '/home/dima-a7/arch_backup/test1.csv' with delimiter ',';
    COPY 101

    dima-a7@otus:~/arch_backup$ ls -l
    -rw-rw-r-- 1 dima-a7 dima-a7      1859 Jan 10 20:33 test1.csv

# Восстановим в 2 таблицу данные из бэкапа.
  Вначале с ошибкой
    backup=# \copy test2 from '/home/dima-a7/arch_backup/test1.csv' with delimiter ',';
    ERROR:  relation "test2" does not exist

  Создаю таблицу test2 для восстановления
    backup=#  create table test2(id int, name text, age int);
    CREATE TABLE
  
  Восстанавливаю
    backup=# \copy test2 from '/home/dima-a7/arch_backup/test1.csv' with delimiter ',';
    COPY 101

    backup=# select * from test2;
    id  |   name    | age
    -----+-----------+-----
    0 | Светлана  |  90
    1 | Юрий      |  26
    2 | Светлана  |   8
    3 | Анна      |  50
    4 | Валерий   | 103
    5 | Иван      |  31
    6 | Вероника  |   4
    7 | Марина    | 111
    8 | Дмитрий   |  69
    9 | Вероника  | 112
    ...

    Данные скопировались. Отсутствие первичного ключа в test2 не повлияло.

    backup=# \d+ test2
                                                        Table "public.test2"
    Column |  Type   | Collation | Nullable |              Default              | Storage  | Compression | Stats target | Description
    -------+---------+-----------+----------+-----------------------------------+----------+-------------+--------------+-------------
    id     | integer |           | not null | nextval('test2_id_seq'::regclass) | plain    |             |              |
    name   | text    |           |          |                                   | extended |             |              |
    age    | integer |           |          |                                   | plain    |             |              |
    Access method: heap

# Используя утилиту pg_dump создадим бэкап в кастомном сжатом формате двух таблиц

    pg_dump -d backup --create -U postgres -Fc > /home/dima-a7/arch_backup/arh_backup.gz
    
    /arch_backup$ ls -l
    -rw-rw-r-- 1 dima-a7 dima-a7      4240 Jan 10 20:55 arh_backup.gz

# Используя утилиту pg_restore восстановим в новую БД только вторую таблицу!

    backup=# create database backup2;
    CREATE DATABASE
        
    $ sudo pg_restore -d backup2 -t test2 -U postgres /home/dima-a7/arch_backup/arh_backup.gz

ДЗ сдается в виде миниотчета на гитхабе с описанием шагов и с какими проблемами столкнулись.

Критерии оценки:
Выполнение ДЗ: 10 баллов

2 балл за красивое решение
2 балл за рабочее решение, и недостатки указанные преподавателем не устранены
