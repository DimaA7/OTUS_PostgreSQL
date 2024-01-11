**Домашнее задание Бэкапы**

    Цель: Применить логический бэкап. Восстановиться из бэкапа
    Описание/Пошаговая инструкция выполнения домашнего задания:

# Создаем ВМ/докер c ПГ.
    ДЗ выполняю на ВМ в Яндекс облаке.

# Создаем БД, схему и в ней таблицу.
    postgres=# create database backup;
    CREATE DATABASE
    backup=# create table test1(id serial primary key, name text, age int);
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
    
# Под линукс пользователем Postgres создадим каталог для бэкапов
    Смотрю где домашняя папка postgres, чтобы создать там папку для бэкапа
        $  cat /etc/passwd
        ...
        postgres:x:114:1001:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
        ...
    
    Перехожу под пользователем postgres в linux
        dima@otus:/var/lib/postgresql$ su postgres
        Password:
        postgres@otus:~$

    Создаю папку
        postgres@otus:~$ mkdir arch_backup

# Сделаем логический бэкап используя утилиту COPY
    Команда для бэкапа
        backup=# \copy test1 to '/var/lib/postgresql/arch_backup/test1.csv' with delimiter ',';
        COPY 101
    
    Смотрю что получились
        Файл создан
            postgres@otus:~$ cd ./arch_backup
            postgres@otus:~/arch_backup$ ls -l
            total 4
            -rw-r--r-- 1 postgres dima 1859 Jan 11 19:17 test1.csv
        Файл заполнен данными
            postgres@otus:~/arch_backup$ nano test1.csv
            0,Светлана,90
            1,Юрий,26
            2,Светлана,8
            3,Анна,50
            4,Валерий,103
            5,Иван,31
            6,Вероника,4
            7,Марина,111
            8,Дмитрий,69
            9,Вероника,112

# Восстановим в 2 таблицу данные из бэкапа.
    Вначале с ошибкой
        backup=# \copy test2 from '/var/lib/postgresql/arch_backup/test1.csv' with delimiter ',';
        ERROR:  relation "test2" does not exist

    Создаю таблицу test2 для восстановления
        backup=#  create table test2(id int, name text, age int);
        CREATE TABLE
  
    Восстанавливаю
        backup=# \copy test2 from '/var/lib/postgresql/arch_backup/test1.csv' with delimiter ',';
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

    postgres@otus:~/arch_backup$ pg_dump -d backup --create -U postgres -Fc > /var/lib/postgresql/arch_backup/arh_backup.gz
    
    postgres@otus:~/arch_backup$ ls -l
    total 12
    -rw-r--r-- 1 postgres dima 4240 Jan 11 19:31 arh_backup.gz
    -rw-r--r-- 1 postgres dima 1859 Jan 11 19:17 test1.csv

# Используя утилиту pg_restore восстановим в новую БД только вторую таблицу!

    Создаю БД для восстановления
        backup=# create database backup2;
        CREATE DATABASE
    
    Восстанавливаю    
        postgres@otus:~/arch_backup$ pg_restore -d backup2 -t test2 -U postgres /var/lib/postgresql/arch_backup/arh_backup.gz

    Проверяю что получилось
        backup2=# \dt+
                                   List of relations
        Schema | Name  | Type  |  Owner   | Persistence | Access method | Size  | Description
        --------+-------+-------+----------+-------------+---------------+-------+-------------
        public | test2 | table | postgres | permanent   | heap          | 16 kB |
        (1 row)

        backup2=# select * from test2;
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

Из трудностей было определиться с папкой для бэкапа. Вначале делал бэкап в домашнюю папку своего пользователя, но для этого надо к ней дать права пользователю postgres. Сложновато. Потом решил сделать бэкап в домашнюю папку пользователя postgres, создав в ней подпапку arch_backup. Получилось проще.


ДЗ сдается в виде миниотчета на гитхабе с описанием шагов и с какими проблемами столкнулись.

Критерии оценки:
Выполнение ДЗ: 10 баллов

2 балл за красивое решение
2 балл за рабочее решение, и недостатки указанные преподавателем не устранены