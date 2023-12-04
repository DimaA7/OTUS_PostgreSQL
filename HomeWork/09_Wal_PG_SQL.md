**ДЗ журналы**
# Настройте выполнение контрольной точки раз в 30 секунд.
        postgres=# show checkpoint_timeout;
        postgres=# alter system set checkpoint_timeout = 30;
        ALTER SYSTEM
        sudo pg_ctlcluster 15 main restart
    
    Узнаем текущий lsn записи из буфера:
        sakila=# SELECT pg_current_wal_insert_lsn();
        pg_current_wal_insert_lsn
        ---------------------------
        0/D9106E78
        (1 row)
    Смотрим статистику на начало теста:
        sakila=# SELECT * FROM pg_stat_bgwriter \gx
        -[ RECORD 1 ]---------+------------------------------
        checkpoints_timed     | 1072
        checkpoints_req       | 72
        checkpoint_write_time | 7601836
        checkpoint_sync_time  | 6116
        buffers_checkpoint    | 279179
        buffers_clean         | 557
        maxwritten_clean      | 0
        buffers_backend       | 31440
        buffers_backend_fsync | 0
        buffers_alloc         | 176755
        stats_reset           | 2023-11-19 20:31:51.236066+00
# 10 минут c помощью утилиты pgbench подавайте нагрузку.
        sudo pgbench -c 20 -P 30 -T 600 -j 6 -p 5432 -U postgres postgres
        sudo pgbench -c 20 -P 30 -T 600 -j 6 -p 5432 -U postgres sakila
                c - подключения
                P - секунды для отчета
                Т - секунды теста
                о - потоки 2 потока, т.к. 2 CPU
        sudo pgbench -c 20 -P 20 -T 600 -j 6 -p 5432 -U postgres sakila
                pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
                starting vacuum...end.
                progress: 20.0 s, 399.4 tps, lat 49.915 ms stddev 46.690, 0 failed
                progress: 40.0 s, 445.0 tps, lat 44.932 ms stddev 40.236, 0 failed
                progress: 60.0 s, 354.6 tps, lat 56.284 ms stddev 44.540, 0 failed
                progress: 80.0 s, 409.0 tps, lat 49.068 ms stddev 63.021, 0 failed
                progress: 100.0 s, 479.0 tps, lat 41.634 ms stddev 39.943, 0 failed
                progress: 120.0 s, 518.7 tps, lat 38.512 ms stddev 32.943, 0 failed
                progress: 140.0 s, 367.2 tps, lat 54.637 ms stddev 51.374, 0 failed
                progress: 160.0 s, 322.8 tps, lat 61.991 ms stddev 64.364, 0 failed
                progress: 180.0 s, 536.5 tps, lat 37.206 ms stddev 30.790, 0 failed
                progress: 200.0 s, 387.5 tps, lat 51.657 ms stddev 44.384, 0 failed
                progress: 220.0 s, 266.4 tps, lat 75.080 ms stddev 66.754, 0 failed
                progress: 240.0 s, 517.4 tps, lat 38.631 ms stddev 36.044, 0 failed
                progress: 260.0 s, 383.1 tps, lat 52.219 ms stddev 44.487, 0 failed
                progress: 280.0 s, 432.8 tps, lat 46.278 ms stddev 43.453, 0 failed
                progress: 300.0 s, 473.3 tps, lat 42.125 ms stddev 35.449, 0 failed
                progress: 320.0 s, 323.4 tps, lat 61.936 ms stddev 65.561, 0 failed
                progress: 340.0 s, 319.2 tps, lat 62.782 ms stddev 58.093, 0 failed
                progress: 360.0 s, 441.0 tps, lat 45.186 ms stddev 41.516, 0 failed
                progress: 380.0 s, 353.1 tps, lat 56.821 ms stddev 52.865, 0 failed
                progress: 400.0 s, 366.1 tps, lat 54.659 ms stddev 44.489, 0 failed
                progress: 420.0 s, 679.8 tps, lat 29.350 ms stddev 21.915, 0 failed
                progress: 440.0 s, 473.1 tps, lat 42.365 ms stddev 41.742, 0 failed
                progress: 460.0 s, 358.9 tps, lat 55.684 ms stddev 51.784, 0 failed
                progress: 480.0 s, 547.8 tps, lat 36.452 ms stddev 30.417, 0 failed
                progress: 500.0 s, 430.9 tps, lat 46.313 ms stddev 40.850, 0 failed
                progress: 520.0 s, 369.7 tps, lat 54.318 ms stddev 53.012, 0 failed
                progress: 540.0 s, 469.4 tps, lat 42.456 ms stddev 39.210, 0 failed
                progress: 560.0 s, 394.7 tps, lat 50.833 ms stddev 47.681, 0 failed
                progress: 580.0 s, 502.9 tps, lat 39.815 ms stddev 37.399, 0 failed
                progress: 600.0 s, 672.9 tps, lat 29.661 ms stddev 21.412, 0 failed
                transaction type: <builtin: TPC-B (sort of)>
                scaling factor: 1
                query mode: simple
                number of clients: 20
                number of threads: 6
                maximum number of tries: 1
                duration: 600 s
                number of transactions actually processed: 259926
                number of failed transactions: 0 (0.000%)
                latency average = 46.166 ms
                latency stddev = 44.804 ms
                initial connection time = 25.799 ms
                tps = 433.195834 (without initial connection time)
    Узнаем текущий lsn записи из буфера:
        sakila=# SELECT pg_current_wal_insert_lsn();
        pg_current_wal_insert_lsn
        ---------------------------
        0/F2A78AC0
        (1 row)
    Смотрим статистику после теста:
        sakila=# SELECT * FROM pg_stat_bgwriter \gx
        -[ RECORD 1 ]---------+------------------------------
        checkpoints_timed     | 1133
        checkpoints_req       | 73
        checkpoint_write_time | 8194353
        checkpoint_sync_time  | 6519
        buffers_checkpoint    | 320645
        buffers_clean         | 557
        maxwritten_clean      | 0
        buffers_backend       | 33148
        buffers_backend_fsync | 0
        buffers_alloc         | 181163
        stats_reset           | 2023-11-19 20:31:51.236066+00
# Измерьте, какой объем журнальных файлов был сгенерирован за это время. Оцените, какой объем приходится в среднем на одну контрольную точку.
        Объем журнальных файлов: 0/F2A78AC0 - 0/D9106E78 = 19971C48 = 429333576 байт = 409Мб
        Контрольных точек было:
                checkpoints_timed: 1133 - 1072 = 61
                checkpoints_req: 1
        Объем на одну контрольную точку:
                429333576 / 62 = 6924735 байт = 6762 Кбайт = 6,6Мб
# Проверьте данные статистики: все ли контрольные точки выполнялись точно по расписанию. Почему так произошло?
        Одна точка была не по расписанию. Вероятно из-за нагрузки. В общем кластер справился с подаваемой нагрузкой.
# Сравните tps в синхронном/асинхронном режиме утилитой pgbench. Объясните полученный результат.
        При асинхронном режиме (synchronous_commit = off) 
                tps = 433.195834
                latency average = 46.166 ms
                latency stddev = 44.804 ms
        При асинхронном режиме (synchronous_commit = off) 
                tps = 3243.362332 
                latency average = 6.166 ms
                latency stddev = 2.885 ms
        tps увеличился в 7,4 раза, т.к. после завершения транзакций нет ожидания записи в WAL. WAL пишется асинхронно отдельным процессом.
# Создайте новый кластер с включенной контрольной суммой страниц. Создайте таблицу. Вставьте несколько значений. Выключите кластер. Измените пару байт в таблице. 
  На созданном кластере смотрим настройку контрольных сумм:
        postgres=# SHOW data_checksums;
        data_checksums
        ----------------
        off
        (1 row)
  ## Выключаем кластер
        sudo pg_ctlcluster 15 main2 stop
  ## Проверяем что кластер выключен:
        sudo su - postgres -c '/usr/lib/postgresql/15/bin/pg_controldata -D "/var/lib/postgresql/15/main2"' | grep state
        Database cluster state:               shut down
  ## Включаем контрольные суммы:
        sudo su - postgres -c '/usr/lib/postgresql/15/bin/pg_checksums --enable -D "/var/lib/postgresql/15/main2"'
        Checksum operation completed
        Files scanned:   946
        Blocks scanned:  2807
        Files written:  778
        Blocks written: 2807
        pg_checksums: syncing data directory
        pg_checksums: updating control file
        Checksums enabled in cluster
  ## Защита страниц данных контрольными суммами включена.
  ## Запускаем кластер:
        sudo pg_ctlcluster 15 main2 start
  ## Проверяем что контрольные суммы включены:
        postgres=# SHOW data_checksums;
        data_checksums
        ----------------
        on
        (1 row)
    Так же можно проверить включение контрольных сумм с помощью утилиты pg_controldata:
        sudo su - postgres -c '/usr/lib/postgresql/15/bin/pg_controldata -D "/var/lib/postgresql/15/main2" | grep checksum'
        Data page checksum version:           1
  ## Создадим таблицу и вставим значения:
        postgres=# CREATE TABLE test(i int);
        CREATE TABLE
        postgres=# INSERT INTO test SELECT s.id FROM generate_series(1,5) AS s(id);
        INSERT 0 5
        postgres=#
  ## Смотрим где лежит таблица
        postgres=# SELECT pg_relation_filepath('test');
        pg_relation_filepath
        ----------------------
        base/5/16388
  ## Изменяем файл 
        /var/lib/postgresql/15/main2/base/5/16388
# Включите кластер и сделайте выборку из таблицы. Что и почему произошло? как проигнорировать ошибку и продолжить работу?
  ## Включаем кластер
        sudo pg_ctlcluster 15 main2 start
  ## Запрашиваем таблицу
        postgres=# select * from test;
        WARNING:  page verification failed, calculated checksum 33889 but expected 2676
        ERROR:  invalid page in block 0 of relation base/5/16388
  ## Также можно ошибки запросом
        postgres=# SELECT datname, checksum_failures, checksum_last_failure FROM pg_stat_database WHERE datname IS NOT NULL;
        datname  | checksum_failures |     checksum_last_failure
        -----------+-------------------+-------------------------------
        postgres  |                 1 | 2023-12-04 07:03:45.959185+00
        template1 |                 0 |
        template0 |                 0 |
        (3 rows)
  ## Устанавливаем настройку игнорирования ошибок
   SET ignore_checksum_failure = on;
  ## Запрашиваем данные таблицы
        postgres=# select * from test;
        WARNING:  page verification failed, calculated checksum 33889 but expected 2676
        i
        ----
        2
        3
        4
        5
        6
        7
        8
        9
        10
        11
        12
        13
        14
        15
        16
        17
        18
        19
        20
        21
        22
        23
        24
        25
        26
        27
        28
        29
        30
        (29 rows)
        Видно что значение 1 отсутствует в таблице. Остальные сохранились.