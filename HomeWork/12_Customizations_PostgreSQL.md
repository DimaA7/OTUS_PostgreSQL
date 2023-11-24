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
        sudo pgbench -i postgres -p 5432 -U postgres
        pgbench -i sakila -p 5432
        sudo pgbench -i sakila -p 5432 -U postgres

 ## Команда для теста производительности 
    sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
        c - подключения
        P - секунды для отчета
        Т - секунды теста
        о - потоки 2 потока, т.к. 2 CPU

 ## Тест на настройках по умолчанию:

   ## Настройки по умолчанию:
   * max_connections	20	              - задает максимальное количество подключений к БД. Уменьшено относительно значения по умолчанию        
   * checkpoint_completion_target	0.9	  - коэффициэнт интервала между контрольными точками. Обычно 0.9. Можно уменьшить.
   * default_statistics_target	100	      - станавливает значение ориентира статистики по умолчанию
   * effective_cache_size	524288	8kB   - Этот параметр соответствует максимальному размеру объекта, который может поместиться в системный кэш. Это значение используется только для оценки. effective_cache_size можно установить в 1/2 - 2/3 от объёма имеющейся в наличии оперативной памяти, если вся она отдана в распоряжение PostgreSQL. 
   * effective_io_concurrency	1	      - задаёт допустимое число параллельных операций ввода/вывода
   * huge_pages	try	                      - 
   * maintenance_work_mem	65536	kB    - задаёт максимальный объём памяти для операций обслуживания БД. Устанавливать значение от 50 - 75% от размера самой большой таблицы или индекса
   * max_wal_size	1024	MB            - максимальный размер, до которого может вырастать WAL между автоматическими контрольными точками в WAL
   * min_wal_size	80	MB                - ограничивает снизу число файлов WAL, которые будут переработаны для будущего использования
   * random_page_cost	4	              - Задаёт приблизительную стоимость чтения одной произвольной страницы с диска. 
   * shared_buffers	16384	8kB           - определяет количество памяти, которое будет выделено postgres для кеширования данных. устанавливают 25% от всей памяти.
   * temp_buffers	1024	8kB           - максимальный объём памяти, выделяемой для временных буферов в каждом сеансе
   * wal_buffers	512	8kB               - объём разделяемой памяти, который будет использоваться для буферизации данных WAL, ещё не записанных на диск.
   * work_mem	4096	kB                - объём памяти, который будет использоваться для внутренних операций сортировки и хеш-таблиц, прежде чем будут задействованы временные файлы на диске.
   * synchronous_commit	on	              - Включает/выключает синхронную запись в лог файлы после каждой транзакции. Защищает от возможной потери данных. При установке значения off для * данного параметра транзакция завершается быстрее.    
   * wal_level	replica	*                 - со значением replica (по умолчанию) в журнал записываются данные, необходимые для поддержки архивирования WAL и репликации, включая запросы только на чтение на ведомом сервере. Вариант minimal оставляет только информацию, необходимую для восстановления после сбоя или аварийного отключения.
   * synchronous_commit = 'off'		

   ## Тест #1
        sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
        pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
        starting vacuum...end.
        progress: 6.0 s, 392.3 tps, lat 50.482 ms stddev 32.639, 0 failed
        progress: 12.0 s, 299.3 tps, lat 66.680 ms stddev 58.172, 0 failed
        progress: 18.0 s, 358.0 tps, lat 56.042 ms stddev 37.977, 0 failed
        progress: 24.0 s, 370.5 tps, lat 53.839 ms stddev 37.356, 0 failed
        progress: 30.0 s, 444.2 tps, lat 44.913 ms stddev 30.593, 0 failed
        progress: 36.0 s, 220.3 tps, lat 90.989 ms stddev 67.060, 0 failed
        progress: 42.0 s, 213.8 tps, lat 92.414 ms stddev 71.512, 0 failed
        progress: 48.0 s, 286.8 tps, lat 70.504 ms stddev 63.994, 0 failed
        progress: 54.0 s, 418.2 tps, lat 48.047 ms stddev 34.361, 0 failed
        progress: 60.0 s, 413.8 tps, lat 48.012 ms stddev 31.565, 0 failed
        transaction type: <builtin: TPC-B (sort of)>
        scaling factor: 1
        query mode: simple
        number of clients: 20
        number of threads: 2
        maximum number of tries: 1
        duration: 60 s
        number of transactions actually processed: 20524
        number of failed transactions: 0 (0.000%)
        latency average = 58.472 ms
        latency stddev = 47.763 ms
        initial connection time = 28.789 ms
        tps = 341.783949 (without initial connection time)

   ## Установил оптимизированные настройки, определенные по сайту https://pgtune.leopard.in.ua/:

 * max_connections	20	              - задает максимальное количество подключений к БД. Уменьшено относительно значения по умолчанию        
   * checkpoint_completion_target	0.9	  - коэффициэнт интервала между контрольными точками. Обычно 0.9. Можно уменьшить.
   * default_statistics_target	100	      - станавливает значение ориентира статистики по умолчанию
   * effective_cache_size	524288	8kB   - Этот параметр соответствует максимальному размеру объекта, который может поместиться в системный кэш. Это значение используется только для оценки. effective_cache_size можно установить в 1/2 - 2/3 от объёма имеющейся в наличии оперативной памяти, если вся она отдана в распоряжение PostgreSQL. 
   * effective_io_concurrency	1	      - задаёт допустимое число параллельных операций ввода/вывода
   * huge_pages	try	                      - 
   * maintenance_work_mem	65536	kB    - задаёт максимальный объём памяти для операций обслуживания БД. Устанавливать значение от 50 - 75% от размера самой большой таблицы или индекса
   * max_wal_size	1024	MB            - максимальный размер, до которого может вырастать WAL между автоматическими контрольными точками в WAL
   * min_wal_size	80	MB                - ограничивает снизу число файлов WAL, которые будут переработаны для будущего использования
   * random_page_cost	4	              - Задаёт приблизительную стоимость чтения одной произвольной страницы с диска. 
   * shared_buffers	16384	8kB           - определяет количество памяти, которое будет выделено postgres для кеширования данных. устанавливают 25% от всей памяти.
   * temp_buffers	1024	8kB           - максимальный объём памяти, выделяемой для временных буферов в каждом сеансе
   * wal_buffers	512	8kB               - объём разделяемой памяти, который будет использоваться для буферизации данных WAL, ещё не записанных на диск.
   * work_mem	4096	kB                - объём памяти, который будет использоваться для внутренних операций сортировки и хеш-таблиц, прежде чем будут задействованы временные файлы на диске.
   * synchronous_commit	on	#Включает/выключает синхронную запись в лог файлы после каждой транзакции. Защищает от возможной потери данных. При установке значения off для * данного параметра транзакция завершается быстрее. 


    * max_connections = 20               - 
    * shared_buffers = 1GB               - Увеличил кэш с 16384*8kB = 131072 Kb до 1Gb
    * effective_cache_size = 3GB         - Увеличил с 524288*8kB = 
    * maintenance_work_mem = 256MB       - 
    * checkpoint_completion_target = 0.9
    * wal_buffers = 16MB
    * default_statistics_target = 100
    * random_page_cost = 1.1
    * effective_io_concurrency = 200
    * work_mem = 10485kB
    * huge_pages = off
    * min_wal_size = 1GB
    * max_wal_size = 4GB


sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 280.7 tps, lat 70.351 ms stddev 91.135, 0 failed
progress: 12.0 s, 372.8 tps, lat 53.648 ms stddev 34.324, 0 failed
progress: 18.0 s, 376.5 tps, lat 53.235 ms stddev 40.739, 0 failed
progress: 24.0 s, 339.8 tps, lat 58.909 ms stddev 38.643, 0 failed
progress: 30.0 s, 415.2 tps, lat 47.214 ms stddev 44.201, 0 failed
progress: 36.0 s, 422.7 tps, lat 48.308 ms stddev 51.533, 0 failed
progress: 42.0 s, 506.5 tps, lat 39.413 ms stddev 26.397, 0 failed
progress: 48.0 s, 385.0 tps, lat 52.073 ms stddev 31.160, 0 failed
progress: 54.0 s, 375.8 tps, lat 53.140 ms stddev 35.165, 0 failed
progress: 60.0 s, 520.7 tps, lat 37.922 ms stddev 37.322, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 23994
number of failed transactions: 0 (0.000%)
latency average = 50.051 ms
latency stddev = 45.072 ms
initial connection time = 32.223 ms
tps = 399.150588 (without initial connection time)

sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 481.5 tps, lat 41.084 ms stddev 27.672, 0 failed
progress: 12.0 s, 379.7 tps, lat 52.819 ms stddev 53.348, 0 failed
progress: 18.0 s, 548.2 tps, lat 36.435 ms stddev 22.344, 0 failed
progress: 24.0 s, 531.3 tps, lat 37.502 ms stddev 24.406, 0 failed
progress: 30.0 s, 393.0 tps, lat 50.043 ms stddev 41.016, 0 failed
progress: 36.0 s, 388.0 tps, lat 52.575 ms stddev 42.951, 0 failed
progress: 42.0 s, 356.0 tps, lat 56.162 ms stddev 47.871, 0 failed
progress: 48.0 s, 436.5 tps, lat 45.770 ms stddev 30.464, 0 failed
progress: 54.0 s, 512.7 tps, lat 39.032 ms stddev 27.870, 0 failed
progress: 60.0 s, 488.0 tps, lat 41.049 ms stddev 32.025, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 27109
number of failed transactions: 0 (0.000%)
latency average = 44.260 ms
latency stddev = 35.636 ms
initial connection time = 30.887 ms
tps = 451.703455 (without initial connection time)

Изменил настройки:
max_wal_senders = 0

sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 430.0 tps, lat 45.853 ms stddev 41.500, 0 failed
progress: 12.0 s, 541.2 tps, lat 37.050 ms stddev 26.234, 0 failed
progress: 18.0 s, 483.8 tps, lat 41.260 ms stddev 27.458, 0 failed
progress: 24.0 s, 340.0 tps, lat 58.951 ms stddev 38.964, 0 failed
progress: 30.0 s, 243.3 tps, lat 81.951 ms stddev 89.597, 0 failed
progress: 36.0 s, 435.2 tps, lat 46.223 ms stddev 32.422, 0 failed
progress: 42.0 s, 506.3 tps, lat 39.519 ms stddev 29.789, 0 failed
progress: 48.0 s, 518.0 tps, lat 38.576 ms stddev 28.818, 0 failed
progress: 54.0 s, 482.5 tps, lat 41.391 ms stddev 26.952, 0 failed
progress: 60.0 s, 355.7 tps, lat 56.181 ms stddev 51.262, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 26036
number of failed transactions: 0 (0.000%)
latency average = 46.101 ms
latency stddev = 40.448 ms
initial connection time = 30.990 ms
tps = 433.509347 (without initial connection time)



Изменил настройки:
synchronous_commit = 'off' - отключил синхронную запись в лог файлы после каждой транзакции. Возможны потери данных, но повысилась производительность. 

sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 2313.3 tps, lat 8.595 ms stddev 3.904, 0 failed
progress: 12.0 s, 2303.8 tps, lat 8.679 ms stddev 3.659, 0 failed
progress: 18.0 s, 2283.2 tps, lat 8.760 ms stddev 3.589, 0 failed
progress: 24.0 s, 2389.2 tps, lat 8.370 ms stddev 3.624, 0 failed
progress: 30.0 s, 2390.0 tps, lat 8.367 ms stddev 3.630, 0 failed
progress: 36.0 s, 2418.5 tps, lat 8.269 ms stddev 3.826, 0 failed
progress: 42.0 s, 2367.6 tps, lat 8.445 ms stddev 3.690, 0 failed
progress: 48.0 s, 2423.9 tps, lat 8.252 ms stddev 3.540, 0 failed
progress: 54.0 s, 2328.3 tps, lat 8.588 ms stddev 3.505, 0 failed
progress: 60.0 s, 2406.3 tps, lat 8.311 ms stddev 3.533, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 141764
number of failed transactions: 0 (0.000%)
latency average = 8.463 ms
latency stddev = 3.666 ms
initial connection time = 29.738 ms
tps = 2362.006937 (without initial connection time)

sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 2487.5 tps, lat 7.993 ms stddev 4.028, 0 failed
progress: 12.0 s, 2481.7 tps, lat 8.059 ms stddev 3.976, 0 failed
progress: 18.0 s, 2501.1 tps, lat 7.995 ms stddev 3.700, 0 failed
progress: 24.0 s, 2377.5 tps, lat 8.410 ms stddev 4.128, 0 failed
progress: 30.0 s, 2478.7 tps, lat 8.069 ms stddev 3.687, 0 failed
progress: 36.0 s, 2598.5 tps, lat 7.696 ms stddev 4.129, 0 failed
progress: 42.0 s, 2588.7 tps, lat 7.725 ms stddev 3.564, 0 failed
progress: 48.0 s, 2540.2 tps, lat 7.873 ms stddev 3.316, 0 failed
progress: 54.0 s, 2568.7 tps, lat 7.784 ms stddev 3.547, 0 failed
progress: 60.0 s, 2558.8 tps, lat 7.816 ms stddev 3.306, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 151107
number of failed transactions: 0 (0.000%)
latency average = 7.939 ms
latency stddev = 3.760 ms
initial connection time = 31.047 ms
tps = 2517.841396 (without initial connection time)


Удалось достичь tps = 2517.841396


написать какого значения tps удалось достичь, показать какие параметры в какие значения устанавливали и почему
Задание со *: аналогично протестировать через утилиту https://github.com/Percona-Lab/sysbench-tpcc (требует установки
https://github.com/akopytov/sysbench)

Критерии оценки:
Выполнение ДЗ: 10 баллов

2 балл за красивое решение
2 балл за рабочее решение, и недостатки указанные преподавателем не устранены

