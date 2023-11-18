Домашнее задание
Нагрузочное тестирование и тюнинг PostgreSQL

Цель:
сделать нагрузочное тестирование PostgreSQL
настроить параметры PostgreSQL для достижения максимальной производительности

Описание/Пошаговая инструкция выполнения домашнего задания:
# развернуть виртуальную машину любым удобным способом поставить на неё PostgreSQL 15 любым способом

    ВМ в Yandex Cloud: otus
    vCPU: 2
    RAM: 4
    SSD: 18 ГБ
    Ubuntu 22.04+1
    PostgreSQL: 15.5-1
    Установил тестовую БД sakila

# настроить кластер PostgreSQL 15 на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины
    Настройки:


# нагрузить кластер через утилиту через утилиту pgbench (https://postgrespro.ru/docs/postgrespro/14/pgbench)

 ## установка pgbench

  ### Установка pgbench
        sudo apt-get install postgresql91-contrib

  ### Инициализация
        pgbench -i postgres -p 5432
        pgbench -i sakila -p 5432

 ## Команда для теста производительности 
    sudo pgbench -c 8 -P 6 -T 60 -j 2 -U postgres -p 5432 sakila
        c - подключения
        P - секунды для отчета
        Т - секунды теста
        о - потоки 2 потока, т.к. 2 CPU

 ## Тест на настройках по умолчанию:

   ## Настройки:
        maintenance_work_mem	65536	kB
        max_connections	100	
        shared_buffers	16384	8kB
        synchronous_commit	on	
        temp_buffers	1024	8kB
        wal_level	replica	
        work_mem	4096	kB

checkpoint_completion_target	0.9	
default_statistics_target	100	
effective_cache_size	524288	8kB
effective_io_concurrency	1	
huge_pages	try	
maintenance_work_mem	65536	kB
max_connections	300	
max_wal_size	1024	MB
min_wal_size	80	MB
random_page_cost	4	
shared_buffers	16384	8kB
temp_buffers	1024	8kB
wal_buffers	512	8kB
work_mem	4096	kB

   ## Тест
        dima-a7@otus:~$ pgbench -c 50 -P 6 -T 60 -j 2 -p 5432 sakila
        pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
        starting vacuum...end.
        progress: 6.0 s, 488.5 tps, lat 97.231 ms stddev 92.749, 0 failed
        progress: 12.0 s, 431.3 tps, lat 114.263 ms stddev 100.705, 0 failed
        progress: 18.0 s, 320.8 tps, lat 158.499 ms stddev 142.102, 0 failed
        progress: 24.0 s, 296.5 tps, lat 169.788 ms stddev 204.855, 0 failed
        progress: 30.0 s, 446.0 tps, lat 112.468 ms stddev 115.023, 0 failed
        progress: 36.0 s, 486.5 tps, lat 101.637 ms stddev 90.683, 0 failed
        progress: 42.0 s, 391.3 tps, lat 128.179 ms stddev 143.203, 0 failed
        progress: 48.0 s, 483.0 tps, lat 103.740 ms stddev 87.106, 0 failed
        progress: 54.0 s, 293.0 tps, lat 171.367 ms stddev 180.190, 0 failed
        progress: 60.0 s, 514.7 tps, lat 97.194 ms stddev 88.235, 0 failed
        transaction type: <builtin: TPC-B (sort of)>
        scaling factor: 1
        query mode: simple
        number of clients: 50
        number of threads: 2
        maximum number of tries: 1
        duration: 60 s
        number of transactions actually processed: 24960
        number of failed transactions: 0 (0.000%)
        latency average = 120.131 ms
        latency stddev = 125.577 ms
        initial connection time = 169.738 ms
        tps = 415.110377 (without initial connection time)

# Установил max_connections = 300

        maintenance_work_mem	65536	kB
        max_connections	300	
        shared_buffers	16384	8kB
        synchronous_commit	off	
        temp_buffers	1024	8kB
        wal_level	replica	
        work_mem	4096	kB

        dima-a7@otus:~$ pgbench -c 50 -P 6 -T 60 -j 2 -p 5432 sakila
        pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
        starting vacuum...end.
        progress: 6.0 s, 1035.0 tps, lat 46.303 ms stddev 31.007, 0 failed
        progress: 12.0 s, 1086.8 tps, lat 46.069 ms stddev 29.443, 0 failed
        progress: 18.0 s, 1074.7 tps, lat 46.478 ms stddev 30.122, 0 failed
        progress: 24.0 s, 1064.2 tps, lat 47.056 ms stddev 30.380, 0 failed
        progress: 30.0 s, 1124.8 tps, lat 44.402 ms stddev 29.010, 0 failed
        progress: 36.0 s, 1083.2 tps, lat 46.186 ms stddev 27.552, 0 failed
        progress: 42.0 s, 1125.3 tps, lat 44.437 ms stddev 28.487, 0 failed
        progress: 48.0 s, 1134.8 tps, lat 44.082 ms stddev 27.976, 0 failed
        progress: 54.0 s, 1116.2 tps, lat 44.733 ms stddev 34.205, 0 failed
        progress: 60.0 s, 1096.3 tps, lat 45.631 ms stddev 34.298, 0 failed
        transaction type: <builtin: TPC-B (sort of)>
        scaling factor: 1
        query mode: simple
        number of clients: 50
        number of threads: 2
        maximum number of tries: 1
        duration: 60 s
        number of transactions actually processed: 65698
        number of failed transactions: 0 (0.000%)
        latency average = 45.581 ms
        latency stddev = 30.476 ms
        initial connection time = 209.070 ms
        tps = 1094.521124 (without initial connection time)


/etc/postgresql/15/main/postgresql.conf	827	30	checkpoint_completion_target	0.9	true	
/etc/postgresql/15/main/postgresql.conf	829	32	default_statistics_target	100	true	
/etc/postgresql/15/main/postgresql.conf	825	28	effective_cache_size	3GB	true	
/etc/postgresql/15/main/postgresql.conf	831	34	effective_io_concurrency	200	true	
/etc/postgresql/15/main/postgresql.conf	833	36	huge_pages	off	false	setting could not be applied
/etc/postgresql/15/main/postgresql.conf	826	29	maintenance_work_mem	256MB	true	
/etc/postgresql/15/main/postgresql.conf	70	7	max_connections	100	false	
/etc/postgresql/15/main/postgresql.conf	823	26	max_connections	100	false	
/var/lib/postgresql/15/main/postgresql.auto.conf	4	40	max_connections	300	true	
/etc/postgresql/15/main/postgresql.conf	247	14	max_wal_size	1GB	false	
/etc/postgresql/15/main/postgresql.conf	835	38	max_wal_size	4GB	true	
/etc/postgresql/15/main/postgresql.conf	834	37	min_wal_size	1GB	true	
/etc/postgresql/15/main/postgresql.conf	248	15	min_wal_size	80MB	false	
/etc/postgresql/15/main/postgresql.conf	830	33	random_page_cost	1.1	true	
/etc/postgresql/15/main/postgresql.conf	824	27	shared_buffers	1GB	false	setting could not be applied
/etc/postgresql/15/main/postgresql.conf	133	12	shared_buffers	128MB	false	
/etc/postgresql/15/main/postgresql.conf	828	31	wal_buffers	16MB	false	setting could not be applied
/etc/postgresql/15/main/postgresql.conf	832	35	work_mem	10485kB	true	

checkpoint_completion_target	0.9	
default_statistics_target	100	
effective_cache_size	393216	8kB
effective_io_concurrency	200	
huge_pages	off	
maintenance_work_mem	262144	kB
max_connections	300	
max_wal_size	4096	MB
min_wal_size	1024	MB
random_page_cost	1.1	
shared_buffers	131072	8kB
temp_buffers	1024	8kB
wal_buffers	2048	8kB
work_mem	10485	kB

max_connections = 100
shared_buffers = 1GB
effective_cache_size = 3GB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10485kB
huge_pages = off
min_wal_size = 1GB
max_wal_size = 4GB


dima-a7@otus:~$ pgbench -c 50 -P 6 -T 60 -j 2 -p 5432 sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 1289.7 tps, lat 37.657 ms stddev 23.568, 0 failed
progress: 12.0 s, 1332.5 tps, lat 37.450 ms stddev 23.017, 0 failed
progress: 18.0 s, 1330.2 tps, lat 37.634 ms stddev 23.924, 0 failed
progress: 24.0 s, 1313.5 tps, lat 38.053 ms stddev 22.631, 0 failed
progress: 30.0 s, 1332.2 tps, lat 37.601 ms stddev 23.047, 0 failed
progress: 36.0 s, 1355.8 tps, lat 36.794 ms stddev 23.701, 0 failed
progress: 42.0 s, 1307.3 tps, lat 38.336 ms stddev 23.860, 0 failed
progress: 48.0 s, 1343.2 tps, lat 37.106 ms stddev 22.456, 0 failed
progress: 54.0 s, 1295.0 tps, lat 38.641 ms stddev 27.885, 0 failed
progress: 60.0 s, 1324.8 tps, lat 37.683 ms stddev 25.330, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 79395
number of failed transactions: 0 (0.000%)
latency average = 37.757 ms
latency stddev = 24.201 ms
initial connection time = 146.985 ms
tps = 1321.169268 (without initial connection time)

dima-a7@otus:~$ pgbench -c 50 -P 6 -T 60 -j 2 -p 5432 sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 1223.8 tps, lat 39.449 ms stddev 24.766, 0 failed
progress: 12.0 s, 1335.0 tps, lat 37.592 ms stddev 25.086, 0 failed
progress: 18.0 s, 1281.8 tps, lat 38.880 ms stddev 22.122, 0 failed
progress: 24.0 s, 1296.7 tps, lat 38.671 ms stddev 25.672, 0 failed
progress: 30.0 s, 1275.0 tps, lat 39.205 ms stddev 23.497, 0 failed
progress: 36.0 s, 1307.5 tps, lat 38.275 ms stddev 24.304, 0 failed
progress: 42.0 s, 1327.8 tps, lat 37.563 ms stddev 22.323, 0 failed
progress: 48.0 s, 1307.7 tps, lat 38.322 ms stddev 24.204, 0 failed
progress: 54.0 s, 1287.5 tps, lat 38.821 ms stddev 22.218, 0 failed
progress: 60.0 s, 1258.3 tps, lat 39.764 ms stddev 24.160, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 77457
number of failed transactions: 0 (0.000%)
latency average = 38.703 ms
latency stddev = 24.083 ms
initial connection time = 156.682 ms
tps = 1288.566560 (without initial connection time)


написать какого значения tps удалось достичь, показать какие параметры в какие значения устанавливали и почему
Задание со *: аналогично протестировать через утилиту https://github.com/Percona-Lab/sysbench-tpcc (требует установки
https://github.com/akopytov/sysbench)

Критерии оценки:
Выполнение ДЗ: 10 баллов

2 балл за красивое решение
2 балл за рабочее решение, и недостатки указанные преподавателем не устранены

