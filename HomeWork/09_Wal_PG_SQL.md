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
alter system set data_checksums = on;
initdb --locale=ru_RU.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data --data-checksums

su - postgres -c '/usr/lib/postgresql/15/bin/pg_checksums --enable -D "/var/lib/postgresql/15/main2"'

# Включите кластер и сделайте выборку из таблицы. Что и почему произошло? как проигнорировать ошибку и продолжить работу?








sudo pgbench -c 20 -P 6 -T 600 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 357.3 tps, lat 55.494 ms stddev 65.920, 0 failed
progress: 12.0 s, 427.0 tps, lat 46.921 ms stddev 46.045, 0 failed
progress: 18.0 s, 709.2 tps, lat 28.085 ms stddev 20.869, 0 failed
progress: 24.0 s, 549.2 tps, lat 36.557 ms stddev 27.099, 0 failed
progress: 30.0 s, 705.3 tps, lat 28.255 ms stddev 24.272, 0 failed
progress: 36.0 s, 375.7 tps, lat 53.255 ms stddev 40.649, 0 failed
progress: 42.0 s, 593.2 tps, lat 33.527 ms stddev 26.176, 0 failed
progress: 48.0 s, 614.7 tps, lat 32.669 ms stddev 23.625, 0 failed
progress: 54.0 s, 505.5 tps, lat 39.715 ms stddev 35.391, 0 failed
progress: 60.0 s, 546.2 tps, lat 35.836 ms stddev 32.628, 0 failed
progress: 66.0 s, 355.8 tps, lat 57.414 ms stddev 58.253, 0 failed
progress: 72.0 s, 482.0 tps, lat 41.453 ms stddev 33.504, 0 failed
progress: 78.0 s, 578.0 tps, lat 34.611 ms stddev 33.474, 0 failed
progress: 84.0 s, 768.3 tps, lat 26.058 ms stddev 17.445, 0 failed
progress: 90.0 s, 598.3 tps, lat 33.056 ms stddev 32.212, 0 failed
progress: 96.0 s, 494.5 tps, lat 40.807 ms stddev 41.924, 0 failed
progress: 102.0 s, 499.7 tps, lat 39.717 ms stddev 33.710, 0 failed
progress: 108.0 s, 492.5 tps, lat 40.939 ms stddev 38.317, 0 failed
progress: 114.0 s, 631.5 tps, lat 31.666 ms stddev 25.811, 0 failed
progress: 120.0 s, 551.7 tps, lat 35.930 ms stddev 32.330, 0 failed
progress: 126.0 s, 359.7 tps, lat 56.188 ms stddev 48.336, 0 failed
progress: 132.0 s, 564.8 tps, lat 35.401 ms stddev 31.368, 0 failed
progress: 138.0 s, 607.5 tps, lat 32.863 ms stddev 26.219, 0 failed
progress: 144.0 s, 620.2 tps, lat 32.135 ms stddev 27.732, 0 failed
progress: 150.0 s, 401.7 tps, lat 49.716 ms stddev 52.850, 0 failed
progress: 156.0 s, 485.5 tps, lat 41.441 ms stddev 35.155, 0 failed
progress: 162.0 s, 519.0 tps, lat 38.509 ms stddev 38.652, 0 failed
progress: 168.0 s, 543.0 tps, lat 36.931 ms stddev 27.404, 0 failed
progress: 174.0 s, 424.8 tps, lat 47.027 ms stddev 40.922, 0 failed
progress: 180.0 s, 543.5 tps, lat 36.586 ms stddev 37.327, 0 failed
progress: 186.0 s, 431.5 tps, lat 46.639 ms stddev 46.162, 0 failed
progress: 192.0 s, 522.5 tps, lat 38.292 ms stddev 31.072, 0 failed
progress: 198.0 s, 319.0 tps, lat 62.259 ms stddev 58.004, 0 failed
progress: 204.0 s, 396.2 tps, lat 50.754 ms stddev 39.176, 0 failed
progress: 210.0 s, 227.0 tps, lat 86.414 ms stddev 66.487, 0 failed
progress: 216.0 s, 199.2 tps, lat 100.519 ms stddev 64.458, 0 failed
progress: 222.0 s, 540.3 tps, lat 37.697 ms stddev 34.956, 0 failed
progress: 228.0 s, 584.7 tps, lat 34.201 ms stddev 27.966, 0 failed
progress: 234.0 s, 584.2 tps, lat 34.265 ms stddev 27.081, 0 failed
progress: 240.0 s, 629.7 tps, lat 31.490 ms stddev 28.471, 0 failed
progress: 246.0 s, 426.8 tps, lat 47.243 ms stddev 44.431, 0 failed
progress: 252.0 s, 600.2 tps, lat 33.307 ms stddev 26.982, 0 failed
progress: 258.0 s, 642.0 tps, lat 31.114 ms stddev 25.192, 0 failed
progress: 264.0 s, 660.2 tps, lat 30.359 ms stddev 25.147, 0 failed
progress: 270.0 s, 459.7 tps, lat 42.787 ms stddev 40.982, 0 failed
progress: 276.0 s, 533.2 tps, lat 38.046 ms stddev 37.097, 0 failed
progress: 282.0 s, 650.5 tps, lat 30.814 ms stddev 24.342, 0 failed
progress: 288.0 s, 573.2 tps, lat 34.912 ms stddev 27.247, 0 failed
progress: 294.0 s, 643.0 tps, lat 30.913 ms stddev 25.054, 0 failed
progress: 300.0 s, 497.3 tps, lat 39.998 ms stddev 36.694, 0 failed
progress: 306.0 s, 446.2 tps, lat 45.038 ms stddev 42.100, 0 failed
progress: 312.0 s, 432.5 tps, lat 46.524 ms stddev 46.685, 0 failed
progress: 318.0 s, 612.8 tps, lat 32.440 ms stddev 27.709, 0 failed
progress: 324.0 s, 310.7 tps, lat 64.793 ms stddev 84.148, 0 failed
progress: 330.0 s, 549.3 tps, lat 35.959 ms stddev 36.684, 0 failed
progress: 336.0 s, 406.8 tps, lat 49.674 ms stddev 44.015, 0 failed
progress: 342.0 s, 599.3 tps, lat 33.390 ms stddev 31.334, 0 failed
progress: 348.0 s, 659.3 tps, lat 30.376 ms stddev 20.966, 0 failed
progress: 354.0 s, 659.8 tps, lat 30.170 ms stddev 27.841, 0 failed
progress: 360.0 s, 550.3 tps, lat 36.357 ms stddev 31.683, 0 failed
progress: 366.0 s, 399.3 tps, lat 50.268 ms stddev 47.455, 0 failed
progress: 372.0 s, 643.2 tps, lat 31.046 ms stddev 29.583, 0 failed
progress: 378.0 s, 659.0 tps, lat 30.362 ms stddev 23.476, 0 failed
progress: 384.0 s, 665.3 tps, lat 30.043 ms stddev 25.755, 0 failed
progress: 390.0 s, 509.2 tps, lat 38.904 ms stddev 39.353, 0 failed
progress: 396.0 s, 456.0 tps, lat 44.293 ms stddev 36.443, 0 failed
progress: 402.0 s, 573.0 tps, lat 34.929 ms stddev 26.511, 0 failed
progress: 408.0 s, 658.2 tps, lat 30.293 ms stddev 21.056, 0 failed
progress: 414.0 s, 402.7 tps, lat 49.770 ms stddev 46.976, 0 failed
progress: 420.0 s, 609.7 tps, lat 32.611 ms stddev 26.599, 0 failed
progress: 426.0 s, 269.3 tps, lat 74.818 ms stddev 61.952, 0 failed
progress: 432.0 s, 407.7 tps, lat 49.006 ms stddev 61.245, 0 failed
progress: 438.0 s, 697.8 tps, lat 28.696 ms stddev 21.252, 0 failed
progress: 444.0 s, 715.5 tps, lat 27.950 ms stddev 20.388, 0 failed
progress: 450.0 s, 559.5 tps, lat 34.722 ms stddev 33.461, 0 failed
progress: 456.0 s, 486.0 tps, lat 42.321 ms stddev 57.539, 0 failed
progress: 462.0 s, 575.5 tps, lat 34.588 ms stddev 36.677, 0 failed
progress: 468.0 s, 581.8 tps, lat 34.508 ms stddev 27.400, 0 failed
progress: 474.0 s, 413.3 tps, lat 48.266 ms stddev 37.632, 0 failed
progress: 480.0 s, 513.7 tps, lat 38.439 ms stddev 34.325, 0 failed
progress: 486.0 s, 374.7 tps, lat 54.112 ms stddev 57.541, 0 failed
progress: 492.0 s, 251.2 tps, lat 79.492 ms stddev 68.347, 0 failed
progress: 498.0 s, 253.0 tps, lat 79.250 ms stddev 63.924, 0 failed
progress: 504.0 s, 541.8 tps, lat 36.799 ms stddev 30.328, 0 failed
progress: 510.0 s, 522.3 tps, lat 37.506 ms stddev 40.925, 0 failed
progress: 516.0 s, 332.7 tps, lat 61.572 ms stddev 91.279, 0 failed
progress: 522.0 s, 563.7 tps, lat 35.423 ms stddev 28.806, 0 failed
progress: 528.0 s, 555.2 tps, lat 34.815 ms stddev 31.370, 0 failed
progress: 534.0 s, 597.5 tps, lat 34.669 ms stddev 33.782, 0 failed
progress: 540.0 s, 597.5 tps, lat 33.372 ms stddev 35.026, 0 failed
progress: 546.0 s, 363.2 tps, lat 54.955 ms stddev 48.618, 0 failed
progress: 552.0 s, 514.3 tps, lat 38.945 ms stddev 40.118, 0 failed
progress: 558.0 s, 654.5 tps, lat 30.630 ms stddev 21.511, 0 failed
progress: 564.0 s, 704.3 tps, lat 28.445 ms stddev 21.185, 0 failed
progress: 570.0 s, 569.2 tps, lat 34.391 ms stddev 33.147, 0 failed
progress: 576.0 s, 376.7 tps, lat 54.067 ms stddev 51.122, 0 failed
progress: 582.0 s, 517.5 tps, lat 38.726 ms stddev 41.442, 0 failed
progress: 588.0 s, 743.0 tps, lat 26.924 ms stddev 20.066, 0 failed
progress: 594.0 s, 548.0 tps, lat 36.440 ms stddev 25.447, 0 failed
progress: 600.0 s, 342.8 tps, lat 57.919 ms stddev 52.795, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 600 s
number of transactions actually processed: 311847
number of failed transactions: 0 (0.000%)
latency average = 38.481 ms
latency stddev = 38.097 ms
initial connection time = 26.982 ms
tps = 519.697267 (without initial connection time)




pgbench -c 20 -P 20 -T 600 -j 6 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 20.0 s, 3217.4 tps, lat 6.206 ms stddev 2.760, 0 failed
progress: 40.0 s, 3236.9 tps, lat 6.177 ms stddev 3.024, 0 failed
progress: 60.0 s, 3222.9 tps, lat 6.206 ms stddev 3.045, 0 failed
progress: 80.0 s, 3234.0 tps, lat 6.183 ms stddev 2.692, 0 failed
progress: 100.0 s, 3228.4 tps, lat 6.195 ms stddev 2.719, 0 failed
progress: 120.0 s, 3318.8 tps, lat 6.023 ms stddev 3.113, 0 failed
progress: 140.0 s, 3296.4 tps, lat 6.070 ms stddev 2.878, 0 failed
progress: 160.0 s, 3299.4 tps, lat 6.061 ms stddev 2.785, 0 failed
progress: 180.0 s, 3268.6 tps, lat 6.119 ms stddev 2.999, 0 failed
progress: 200.0 s, 3220.3 tps, lat 6.210 ms stddev 2.774, 0 failed
progress: 220.0 s, 3244.0 tps, lat 6.164 ms stddev 2.746, 0 failed
progress: 240.0 s, 3248.8 tps, lat 6.156 ms stddev 3.125, 0 failed
progress: 260.0 s, 3286.3 tps, lat 6.085 ms stddev 2.625, 0 failed
progress: 280.0 s, 3296.7 tps, lat 6.065 ms stddev 2.730, 0 failed
progress: 300.0 s, 3240.7 tps, lat 6.172 ms stddev 3.222, 0 failed
progress: 320.0 s, 3264.2 tps, lat 6.126 ms stddev 2.747, 0 failed
progress: 340.0 s, 3262.3 tps, lat 6.129 ms stddev 2.831, 0 failed
progress: 360.0 s, 3251.5 tps, lat 6.151 ms stddev 3.128, 0 failed
progress: 380.0 s, 3185.0 tps, lat 6.279 ms stddev 2.622, 0 failed
progress: 400.0 s, 3204.9 tps, lat 6.238 ms stddev 2.747, 0 failed
progress: 420.0 s, 3201.8 tps, lat 6.247 ms stddev 3.193, 0 failed
progress: 440.0 s, 3254.8 tps, lat 6.144 ms stddev 2.680, 0 failed
progress: 460.0 s, 3244.0 tps, lat 6.164 ms stddev 2.780, 0 failed
progress: 480.0 s, 3216.5 tps, lat 6.218 ms stddev 3.076, 0 failed
progress: 500.0 s, 3240.5 tps, lat 6.172 ms stddev 2.668, 0 failed
progress: 520.0 s, 3228.8 tps, lat 6.193 ms stddev 2.753, 0 failed
progress: 540.0 s, 3198.5 tps, lat 6.253 ms stddev 3.075, 0 failed
progress: 560.0 s, 3264.3 tps, lat 6.126 ms stddev 2.660, 0 failed
progress: 580.0 s, 3225.9 tps, lat 6.199 ms stddev 2.734, 0 failed
progress: 600.0 s, 3199.5 tps, lat 6.251 ms stddev 3.368, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 6
maximum number of tries: 1
duration: 600 s
number of transactions actually processed: 1946064
number of failed transactions: 0 (0.000%)
latency average = 6.166 ms
latency stddev = 2.885 ms
initial connection time = 26.908 ms
tps = 3243.362332 (without initial connection time)