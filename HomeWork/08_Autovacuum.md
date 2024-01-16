# ДЗ 05 автовакуум

## Объяснение по pgbench
Показатели до и после применения настроек примерно одинаковые, вероятно из-за того что база не наполнена. Только увеличилось среднее время отклика первого теста. Вероятно из-за того что снизилось количество коннекций и увеличился кэш (shared_buffers). При большем кэше время отклика больше в начале запросов, т.к. кэш надо прогреть.

## Объяснение по автовакууму
  При первом десятикратном обновлении 1000001 строк размер файла увеличился в 4,62 раза (с 50960K до 235264К). При втором обновлении 10 кратном обновлении размер файла увеличился в 15,48 раза больше исходного (с 235264К до 789264К).
  Изменение размера файла при обновлении с 1 по 10: 235264К - 50960K = 184304
  Изменение размера файла при обновлении с 11 по 20: 789264К - 235264К = 554000
      При обновлениях с 1 по 10 автовакуум происходил как минимум один раз после пятого обновление. В результате  обновления с 6 по 10 не так требовали увеличивать файл таблицы, т.к. заполнялись очищенные туплы.   При обновлении с 11 по 20 размер файла значительно больше, т.к. при этом не было автовакуумов. Туплы только добавлялись, но не чистились. При каждом обновлении Файл таблицы всегда увеличивался.
 

Ниже результаты работы в командной строке


# Проверка pgbench

 ## Запуск pgbench на ВМ1 с SSD кластер main15 без настроек
    dima@otus-db-pg-vm-1:~$ pgbench -c8 -P 6 -T 60 -p 5432 postgres
    pgbench (15.2 (Ubuntu 15.2-1.pgdg22.04+1))
    starting vacuum...end.
    progress: 6.0 s, 531.8 tps, lat 14.984 ms stddev 9.387, 0 failed
    progress: 12.0 s, 438.3 tps, lat 18.253 ms stddev 11.553, 0 failed
    progress: 18.0 s, 526.7 tps, lat 15.187 ms stddev 10.500, 0 failed
    progress: 24.0 s, 461.2 tps, lat 17.351 ms stddev 15.247, 0 failed
    progress: 30.0 s, 623.0 tps, lat 12.830 ms stddev 8.470, 0 failed
    progress: 36.0 s, 566.5 tps, lat 14.132 ms stddev 8.955, 0 failed
    progress: 42.0 s, 546.7 tps, lat 14.619 ms stddev 10.815, 0 failed
    progress: 48.0 s, 590.8 tps, lat 13.556 ms stddev 9.597, 0 failed
    progress: 54.0 s, 393.0 tps, lat 20.343 ms stddev 22.933, 0 failed
    progress: 60.0 s, 480.0 tps, lat 16.671 ms stddev 14.826, 0 failed
    transaction type: <builtin: TPC-B (sort of)>
    scaling factor: 1
    query mode: simple
    number of clients: 8
    number of threads: 1
    maximum number of tries: 1
    duration: 60 s
    number of transactions actually processed: 30956
    number of failed transactions: 0 (0.000%)
    latency average = 15.504 ms
    latency stddev = 12.565 ms
    initial connection time = 15.592 ms
    tps = 515.891460 (without initial connection time)
    dima@otus-db-pg-vm-1:~$

 ## Запуск pgbench на ВМ1 с SSD кластер main15 c целевыми настройками
      dima@otus-db-pg-vm-1:~$ pgbench -c8 -P 6 -T 60 -p 5432 postgres
      pgbench (15.2 (Ubuntu 15.2-1.pgdg22.04+1))
      starting vacuum...end.
      progress: 6.0 s, 321.7 tps, lat 24.743 ms stddev 24.910, 0 failed
      progress: 12.0 s, 514.0 tps, lat 15.586 ms stddev 10.282, 0 failed
      progress: 18.0 s, 569.7 tps, lat 14.043 ms stddev 8.370, 0 failed
      progress: 24.0 s, 483.7 tps, lat 16.542 ms stddev 52.186, 0 failed
      progress: 30.0 s, 624.3 tps, lat 12.803 ms stddev 7.368, 0 failed
      progress: 36.0 s, 445.2 tps, lat 17.984 ms stddev 15.950, 0 failed
      progress: 42.0 s, 567.7 tps, lat 14.082 ms stddev 8.807, 0 failed
      progress: 48.0 s, 498.8 tps, lat 16.028 ms stddev 8.215, 0 failed
      progress: 54.0 s, 451.2 tps, lat 17.743 ms stddev 13.582, 0 failed
      progress: 60.0 s, 655.2 tps, lat 12.215 ms stddev 7.659, 0 failed
      transaction type: <builtin: TPC-B (sort of)>
      scaling factor: 1
      query mode: simple
      number of clients: 8
      number of threads: 1
      maximum number of tries: 1
      duration: 60 s
      number of transactions actually processed: 30796
      number of failed transactions: 0 (0.000%)
      latency average = 15.584 ms
      latency stddev = 19.763 ms
      initial connection time = 15.167 ms
      tps = 513.229911 (without initial connection time)


 ## Инициализация pgbench на ВМ1 с SSD
otus-db-pg-vm-1
vCPU - 2
RAM 4
SSD: 18 ГБ

dima@otus-db-pg-vm-1:~$   pgbench -i postgres -p 5433
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.07 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 2.17 s (drop tables 0.00 s, create tables 0.07 s, client-side generate 1.76 s, vacuum 0.06 s, primary keys 0.29 s).


dima@otus-db-pg-vm-1:~$  pgbench -i postgres -p 5433
dropping old tables...
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.07 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 1.02 s (drop tables 0.02 s, create tables 0.01 s, client-side generate 0.68 s, vacuum 0.04 s, primary keys 0.28 s).

## Запуск pgbench на ВМ1 с SSD без настроек
dima@otus-db-pg-vm-1:~$ pgbench -c 8 -P 6 -T 60 -p 5433 postgres
pgbench (15.2 (Ubuntu 15.2-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 665.5 tps, lat 11.981 ms stddev 6.742, 0 failed
progress: 12.0 s, 751.7 tps, lat 10.635 ms stddev 6.253, 0 failed
progress: 18.0 s, 543.3 tps, lat 14.713 ms stddev 10.207, 0 failed
progress: 24.0 s, 548.0 tps, lat 14.612 ms stddev 9.535, 0 failed
progress: 30.0 s, 481.3 tps, lat 16.621 ms stddev 16.171, 0 failed
progress: 36.0 s, 602.0 tps, lat 13.280 ms stddev 10.325, 0 failed
progress: 42.0 s, 706.7 tps, lat 11.325 ms stddev 7.082, 0 failed
progress: 48.0 s, 549.2 tps, lat 14.573 ms stddev 49.266, 0 failed
progress: 54.0 s, 631.5 tps, lat 12.630 ms stddev 9.065, 0 failed
progress: 60.0 s, 310.5 tps, lat 25.832 ms stddev 24.132, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 34746
number of failed transactions: 0 (0.000%)
latency average = 13.814 ms
latency stddev = 18.688 ms
initial connection time = 14.987 ms
tps = 578.908410 (without initial connection time)

## Исходные настройки на ВМ1 с SSD:
postgres=# SELECT sourceline, name, setting, applied FROM pg_file_settings;
 sourceline |            name            |                setting                 | applied
------------+----------------------------+----------------------------------------+---------
         42 | data_directory             | /var/lib/postgresql/15/main            | t
         44 | hba_file                   | /etc/postgresql/15/main/pg_hba.conf    | t
         46 | ident_file                 | /etc/postgresql/15/main/pg_ident.conf  | t
         50 | external_pid_file          | /var/run/postgresql/15-main.pid        | t
         64 | port                       | 5433                                   | t
         65 | max_connections            | 100                                    | t
         67 | unix_socket_directories    | /var/run/postgresql                    | t
        101 | ssl                        | on                                     | t
        103 | ssl_cert_file              | /etc/ssl/certs/ssl-cert-snakeoil.pem   | t
        105 | ssl_key_file               | /etc/ssl/private/ssl-cert-snakeoil.key | t
        122 | shared_buffers             | 128MB                                  | t
        143 | dynamic_shared_memory_type | posix                                  | t
        229 | max_wal_size               | 1GB                                    | t
        230 | min_wal_size               | 80MB                                   | t
        530 | log_line_prefix            | %m [%p] %q%u@%d                        | t
        564 | log_timezone               | Etc/UTC                                | t
        570 | cluster_name               | 15/main                                | t
        679 | datestyle                  | iso, mdy                               | t
        681 | timezone                   | Etc/UTC                                | t
        695 | lc_messages                | en_US.UTF-8                            | t
        697 | lc_monetary                | en_US.UTF-8                            | t
        698 | lc_numeric                 | en_US.UTF-8                            | t
        699 | lc_time                    | en_US.UTF-8                            | t
        702 | default_text_search_config | pg_catalog.english                     | t

_# DB Version: 11
_# OS Type: linux
_# DB Type: dw
_# Total Memory (RAM): 4 GB
_# CPUs num: 1


max_connections = 100
shared_buffers = 128MB
#effective_cache_size = 3GB
#maintenance_work_mem = 64MB            # min 1MB
#checkpoint_completion_target = 0.5     # checkpoint target duration, 0.0 - 1.0
#wal_buffers = -1                       # min 32kB, -1 sets based on shared_buffers
#default_statistics_target = 500
#random_page_cost = 4
#effective_io_concurrency = 2
#work_mem = 6553kB
#min_wal_size = 4GB
#max_wal_size = 16GB

## Целевые настройки:

_ # DB Version: 11
_# OS Type: linux
_# DB Type: dw
_# Total Memory (RAM): 4 GB
_# CPUs num: 1
_# Data Storage: hdd

max_connections = 40
shared_buffers = 1GB
effective_cache_size = 3GB
maintenance_work_mem = 512MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 500
random_page_cost = 4
effective_io_concurrency = 2
work_mem = 6553kB
min_wal_size = 4GB
max_wal_size = 16GB




## Иницилизация phbench на ВМ2 c HDD

otus-db-pg-vm-2
vCPU - 2
RAM 4
SSD: 18 ГБ

dima@otus-db-pg-vm-2:~$ pgbench -i postgres -p 5432
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.09 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 0.75 s (drop tables 0.00 s, create tables 0.20 s, client-side generate 0.18 s, vacuum 0.14 s, primary keys 0.22 s).

## Запуск phbench на ВМ2 c HDD с настройками по умолчанию
dima@otus-db-pg-vm-2:~$ pgbench -c 8 -P 6 -T 60 -p 5432 postgres
pgbench (15.2 (Ubuntu 15.2-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 684.3 tps, lat 11.650 ms stddev 5.974, 0 failed
progress: 12.0 s, 732.2 tps, lat 10.928 ms stddev 5.715, 0 failed
progress: 18.0 s, 720.8 tps, lat 11.092 ms stddev 5.823, 0 failed
progress: 24.0 s, 712.0 tps, lat 11.238 ms stddev 8.965, 0 failed
progress: 30.0 s, 610.3 tps, lat 13.105 ms stddev 9.489, 0 failed
progress: 36.0 s, 679.3 tps, lat 11.773 ms stddev 6.333, 0 failed
progress: 42.0 s, 680.8 tps, lat 11.752 ms stddev 6.188, 0 failed
progress: 48.0 s, 578.7 tps, lat 13.828 ms stddev 8.191, 0 failed
progress: 54.0 s, 678.0 tps, lat 11.786 ms stddev 6.052, 0 failed
progress: 60.0 s, 497.5 tps, lat 16.094 ms stddev 12.337, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 39452
number of failed transactions: 0 (0.000%)
latency average = 12.165 ms
latency stddev = 7.708 ms
initial connection time = 14.984 ms
tps = 657.481261 (without initial connection time)


Настройки по умолчанию на ВМ2 с HDD
postgres=# SELECT sourceline, name, setting, applied FROM pg_file_settings;
 sourceline |            name            |                setting                 | applied
------------+----------------------------+----------------------------------------+---------
         42 | data_directory             | /var/lib/postgresql/15/main            | t
         44 | hba_file                   | /etc/postgresql/15/main/pg_hba.conf    | t
         46 | ident_file                 | /etc/postgresql/15/main/pg_ident.conf  | t
         50 | external_pid_file          | /var/run/postgresql/15-main.pid        | t
         64 | port                       | 5432                                   | t
         65 | max_connections            | 100                                    | t
         67 | unix_socket_directories    | /var/run/postgresql                    | t
        105 | ssl                        | on                                     | t
        107 | ssl_cert_file              | /etc/ssl/certs/ssl-cert-snakeoil.pem   | t
        110 | ssl_key_file               | /etc/ssl/private/ssl-cert-snakeoil.key | t
        127 | shared_buffers             | 128MB                                  | t
        150 | dynamic_shared_memory_type | posix                                  | t
        241 | max_wal_size               | 1GB                                    | t
        242 | min_wal_size               | 80MB                                   | t
        559 | log_line_prefix            | %m [%p] %q%u@%d                        | t
        597 | log_timezone               | Etc/UTC                                | t
        604 | cluster_name               | 15/main                                | t
        711 | datestyle                  | iso, mdy                               | t
        713 | timezone                   | Etc/UTC                                | t
        727 | lc_messages                | en_US.UTF-8                            | t
        729 | lc_monetary                | en_US.UTF-8                            | t
        730 | lc_numeric                 | en_US.UTF-8                            | t
        731 | lc_time                    | en_US.UTF-8                            | t
        734 | default_text_search_config | pg_catalog.english                     | t
(24 rows)

## Запуск phbench на ВМ2 c HDD после применения целевых настроек


dima@otus-db-pg-vm-2:~$ pgbench -c 8 -P 6 -T 60 -p 5432 postgres
pgbench (15.2 (Ubuntu 15.2-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 346.5 tps, lat 22.980 ms stddev 19.706, 0 failed
progress: 12.0 s, 659.5 tps, lat 12.119 ms stddev 7.683, 0 failed
progress: 18.0 s, 680.0 tps, lat 11.776 ms stddev 7.091, 0 failed
progress: 24.0 s, 697.2 tps, lat 11.483 ms stddev 6.520, 0 failed
progress: 30.0 s, 670.8 tps, lat 11.926 ms stddev 6.532, 0 failed
progress: 36.0 s, 618.0 tps, lat 12.944 ms stddev 9.500, 0 failed
progress: 42.0 s, 781.7 tps, lat 10.230 ms stddev 5.667, 0 failed
progress: 48.0 s, 523.7 tps, lat 15.280 ms stddev 12.515, 0 failed
progress: 54.0 s, 635.2 tps, lat 12.584 ms stddev 7.169, 0 failed
progress: 60.0 s, 676.0 tps, lat 11.844 ms stddev 6.823, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 37739
number of failed transactions: 0 (0.000%)
latency average = 12.717 ms
latency stddev = 9.271 ms
initial connection time = 17.046 ms
tps = 628.951425 (without initial connection time)


postgres=# SHOW config_file;
               config_file
-----------------------------------------
 /etc/postgresql/15/main/postgresql.conf


 # Проверка автовакуума

Создал таблицу test4 с текстовой строкой в 20 случайных символов

CREATE TABLE test4(text VARCHAR);

insert into test4 (select random_string(20) from generate_series(0, 1000000));


postgres=# SHOW data_directory;
        data_directory
-------------------------------
 /var/lib/postgresql/15/main15


-- Смотрим размер файла
SELECT pg_relation_filepath('test3');
pg_relation_filepath
----------------------
 base/5/16564


avc=# SELECT pg_relation_filepath('test4');
 pg_relation_filepath
----------------------
 base/16563/16593

**Размер файла 16593: 50960K**

## Обновляем 5 РАЗ:

update test4 set text4 = concat(text4, '1');

avc=# update test4 set text4 = concat(text4, '1');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, '2');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, '3');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, '4');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, '5');
UPDATE 1000001

## Проверка мертвых туплов и дату автовакуума. :
avc=# SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM
 pg_stat_user_TABLEs WHERE relname = 'test4';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test4   |     110153 |     999921 |    907 | 2023-05-23 18:47:28.234512+00

## Пришел автовакуум:
avc=# SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM pg_stat_user_TABLEs WHERE relname = 'test4';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test4   |    1000001 |          0 |      0 | 2023-05-23 18:48:23.231798+00

**Размер файла 16593: 168608K**

## Снова обновляю 5 раз таблицу:

avc=# update test4 set text4 = concat(text4, 'A');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'B');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'С');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'D');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'E');
UPDATE 1000001

## Размер файла:
235264К
postgres@otus-db-pg-vm-1:~/15/main15/base/16563$ stat 16593
  File: 16593
  Size: 240910336

   **Размер файла 16593: 235264К**

## Данные по автовакууму
avc=# SELECT
  schemaname, relname,
  last_vacuum, last_autovacuum,
  vacuum_count, autovacuum_count  -- not available on 9.0 and earlier
FROM pg_stat_user_tables;
 schemaname | relname | last_vacuum |        last_autovacuum        | vacuum_count | autovacuum_count
------------+---------+-------------+-------------------------------+--------------+------------------
 public     | test4   |             | 2023-05-23 18:56:26.437087+00 |            0 |                9

## Отключил автовакуум на таблице:
avc=# ALTER TABLE test4 SET (autovacuum_enabled = false);
ALTER TABLE
avc=# SELECT reloptions FROM pg_class WHERE relname = 'test4';
         reloptions
----------------------------
 {autovacuum_enabled=false}

-- Общий автовакуум включен:
avc=# SELECT name, setting FROM pg_settings WHERE name LIKE 'autovacuum%';
                 name                  |  setting
---------------------------------------+-----------
 autovacuum                            | on

## Обновил таблицу 10 раз

avc=# update test4 set text4 = concat(text4, 'Г');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'Д');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'Е');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'Ё');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'Ж');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'З');
UPDATE 1000001
avc=# update test4 set text4 = concat(text4, 'И');
UPDATE 1000001
avc=# select * from test4 limit 10;
                  text4
------------------------------------------
 YyvELRcAfLBroVCCrrBW12345ABСDEАБВГДЕЁЖЗИ
 hpTPv5QVQvuAEXHH42t212345ABСDEАБВГДЕЁЖЗИ
 VwLkQ1o5wf6rk4aPmNQI12345ABСDEАБВГДЕЁЖЗИ
 9bNXf0XGCj0iDUTcc64j12345ABСDEАБВГДЕЁЖЗИ
 VdfAHTOG5l6BQV8Dr1js12345ABСDEАБВГДЕЁЖЗИ
 gJFJKGPMgxfxbWvi6v0S12345ABСDEАБВГДЕЁЖЗИ
 vPcp67C6kScmVGiHzYvt12345ABСDEАБВГДЕЁЖЗИ
 RThPoWDdB9gdZNy0JaeB12345ABСDEАБВГДЕЁЖЗИ
 NBzV5KQFK0AqXVPO1jGe12345ABСDEАБВГДЕЁЖЗИ
 pHMIEfLUkLJAFLqEaJEg12345ABСDEАБВГДЕЁЖЗИ
(10 rows)


## Проверка мертвых туплов:
avc=# SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM
 pg_stat_user_TABLEs WHERE relname = 'test4';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test4   |    1000001 |    9996892 |    999 | 2023-05-23 18:56:26.437087+00
(1 row)

## Новый размер файла:
dima@otus-db-pg-vm-1:~$ sudo su postgres
postgres@otus-db-pg-vm-1:/home/dima$  cd /var/lib/postgresql/15/main15/base/16563
postgres@otus-db-pg-vm-1:~/15/main15/base/16563$ stat 16593
  File: 16593
  Size: 808206336       Blocks: 1578536    IO Block: 4096   regular file

 **Размер файла 16593: 789264К**
 ## Объяснение
  При первом обновлении 10 строк размер файла увеличился в 4,62 раза (с 50960K до 235264К). При втором обновлении 10 строк размер файла увеличился в 15,48 раза больше исходного (с 235264К до 789264К). При включенном и выключенном автовакуме мертвые туплы и не отдает из ОС. Т.к. происходили только операции Update размер файла только увеличивался. Чтобы почистить мертвые туплы нужно сделать VACUUM FULL
  


 ## Включение автовакуума

avc=# ALTER TABLE test4 SET (autovacuum_enabled = true);
ALTER TABLE
avc=# SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM
 pg_stat_user_TABLEs WHERE relname = 'test4';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test4   |    1000001 |    9996892 |    999 | 2023-05-23 18:56:26.437087+00

avc=# SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM
 pg_stat_user_TABLEs WHERE relname = 'test4';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test4   |    1000001 |          0 |      0 | 2023-05-23 20:49:15.714229+00


## Размер файла

postgres@otus-db-pg-vm-1:~/15/main15/base/16563$ stat 16593
  File: 16593
  Size: 808206336       Blocks: 1578536    IO Block: 4096   regular file

Размер файла не изменился после автовакуума, т.к. postgre не отдает пустые записи операционной системе.

## Выполнил полный автовакуум

avc=# VACUUM FULL test4;
VACUUM

postgres@otus-db-pg-vm-1:~/15/main15/base/16563$ stat 16593
  File: 16593
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file

  avc=# SELECT pg_relation_filepath('test4');
 pg_relation_filepath
----------------------
 base/16563/16608
postgres@otus-db-pg-vm-1:~/15/main15/base/16563$ stat 16608
  File: 16608
  Size: 84459520        Blocks: 164960     IO Block: 4096   regular file

  **Размер файла уменьшился в 10 раз.**



## Доплнительно

-- посмотрим мертвые туплы и когда был автовакуум.
SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum FROM pg_stat_user_TABLEs WHERE relname = 'test';

-- Посмотреть доп поля таблицы
https://postgrespro.ru/docs/postgrespro/12/pageinspect
CREATE EXTENSION pageinspect; -- расширение
\dx+
SELECT lp as tuple, t_xmin, t_xmax, t_field3 as t_cid, t_ctid FROM heap_page_items(get_raw_page('test',0));
SELECT * FROM heap_page_items(get_raw_page('test',0)) \gx


SELECT * FROM test1 LIMIT 10;


## Функция 
CREATE OR REPLACE FUNCTION random_string(
  num INTEGER,
  chars TEXT default '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  res_str TEXT := '';
BEGIN
  IF num < 1 THEN
      RAISE EXCEPTION 'Invalid length';
  END IF;
  FOR __ IN 1..num LOOP
    res_str := res_str || substr(chars, floor(random() * length(chars))::int + 1, 1);
  END LOOP;
  RETURN res_str;
END $$;




# Анонимная процедура обновления всех строк таблицы 10 раз (черновик)

Do Language 'Plpgsql' - Обновления всех строк таблицы 10 раз
$BODY$ 
BEGIN
	 For counter in 1..10 loop - Start loop
		update test4 set text4 = concat(text4, 'A');
    
    
    UPDATE INSERT INTO mydb.mysc.learn01
			 (statistics_dt - Data Date)
			 , CUST_ID - Customer number
			 , cust_name - Customer Name
			 , AUM_AVG - Asset monthly
			 Age - age
			 , Gender - Gender Sign: 0 Male 1

        RETURNING 

			)
		VALUES(
			 Date'2021-01-31 '- Data Date
			 , Right ('000' || Counter, 4) - Customer number
			 , 'No.' || Right ('000' || Counter, 4) - Customer Name
			 , Cast (random () * 10000 as decimal (16, 2)) - Asset monthly: Random Generate 0-10000 value
			 , CAST (Random () * 89 AS INT) + 1 - Age: Random Generate 1-90 Integer
			 , CAST (CAST (Random () * 2 as int)% 2 as char) - Gender: Random Generation
		);
	END LOOP;
END  
$BODY$;