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

   ## Тест на настройках по умолчанию:
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
      latency average = **58.472** ms
      latency stddev = **47.763** ms
      initial connection time = 28.789 ms
      tps = **341.783949** (without initial connection time)


# настроить кластер PostgreSQL 15 на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины
# нагрузить кластер через утилиту через утилиту pgbench (https://postgrespro.ru/docs/postgrespro/14/pgbench)

   ## Установил оптимизированные настройки, определенные по сайту https://pgtune.leopard.in.ua/:

    * max_connections = 20               - Не менял, т.к. особо не влияет
    * shared_buffers = 1GB               - Увеличил память для буферов в разделяемой памяти с 16384*8kB = 131072 Kb до 1Gb, т.к. рекомендуемое значение 25% от объёма RAM.
    * effective_cache_size = 3GB         - Уменьшил с 4Gb kB до 3Gb как рекомендует https://pgtune.leopard.in.ua/. Пробовал увеличивать до 8GB. Особо ничего не дает.
    * maintenance_work_mem = 256MB       - Увеличил c 65Мб до 256Mb как рекомендует https://pgtune.leopard.in.ua/. Пробовал увеличить до 512GB, но tps уменьшилось.
    * checkpoint_completion_target = 0.9 - Пробовал уменьшать до 0.8. Особо не влияет. Оставил 0.9
    * wal_buffers = 16MB                 - Увеличил до с 4Мб до 16Мб как рекомендует https://pgtune.leopard.in.ua/. Но в моем случае это особо не влияет.
    * random_page_cost = 1.1             - уменьшил с 4 до 1.1, чтобы было больше сканирований по индексам.
    * effective_io_concurrency = 200     - увеличил с 1 до 200, чтобы было больше параллельных операций ввода вывода
    * work_mem = 10485kB                 - увеличил с 4096kB до 10485kB, чтбы увеличить память под внутренние операции. Пробовал увеличовать до 40MB, но стало хуже. Оставил 10MB
    * huge_pages = off                   - изменил с try на off как рекомендует https://pgtune.leopard.in.ua/, но особо не влияет. Видимо нет бользих страниц
    * min_wal_size = 1GB                 - увеличил с 80 MB до 1GB как рекомендует https://pgtune.leopard.in.ua/ чтобы зарезервировать достаточно места для WAL, чтобы справиться с резкими скачками использования WAL
    * max_wal_size = 4GB                 - увеличил c 1024MB до 4GB как рекомендует https://pgtune.leopard.in.ua/, чтобы увеличить Максимальный размер, до которого может вырастать WAL. Пробовал увеличивать до 16GB, но позитивных изменений не наблюдал. кажется tps ухудшалось.
    * log_statement = none               - отключил pfgbcm SQL-команды в журнал.
    * max_wal_senders = 0                - отключил чтения из WAL. Т.е. отключил репликацию. Но т.к. репликация не настроена, то особо не сказалось.

## Тесты после настроек:
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
latency average = **44.260** ms
latency stddev = **35.636** ms
initial connection time = 30.887 ms
tps = **451.703455** (without initial connection time)


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
latency average = **46.101** ms
latency stddev = **40.448** ms
initial connection time = 30.990 ms
tps = **433.509347** (without initial connection time)

# отключил синхронную запись в лог файлы после каждой транзакции. Возможны потери данных, но сильно повысилась производительность. 
synchronous_commit = 'off'

dima-a7@otus:/etc/postgresql/15/main$ sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 2785.7 tps, lat 7.139 ms stddev 3.222, 0 failed
progress: 12.0 s, 2648.0 tps, lat 7.552 ms stddev 3.217, 0 failed
progress: 18.0 s, 2590.5 tps, lat 7.719 ms stddev 3.367, 0 failed
progress: 24.0 s, 2513.7 tps, lat 7.956 ms stddev 3.196, 0 failed
progress: 30.0 s, 2489.2 tps, lat 8.034 ms stddev 3.241, 0 failed
progress: 36.0 s, 2470.8 tps, lat 8.093 ms stddev 3.255, 0 failed
progress: 42.0 s, 2487.5 tps, lat 8.040 ms stddev 3.460, 0 failed
progress: 48.0 s, 2426.8 tps, lat 8.240 ms stddev 3.297, 0 failed
progress: 54.0 s, 2549.0 tps, lat 7.846 ms stddev 3.265, 0 failed
progress: 60.0 s, 2603.3 tps, lat 7.681 ms stddev 3.316, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 153406
number of failed transactions: 0 (0.000%)
latency average = **7.821** ms
latency stddev = **3.308** ms
initial connection time = 28.834 ms
tps = **2556.151231** (without initial connection time)


dima-a7@otus:~$ sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
pgbench (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 2319.8 tps, lat 8.572 ms stddev 12.027, 0 failed
progress: 12.0 s, 2753.1 tps, lat 7.263 ms stddev 3.585, 0 failed
progress: 18.0 s, 2497.0 tps, lat 8.010 ms stddev 3.456, 0 failed
progress: 24.0 s, 2493.0 tps, lat 8.023 ms stddev 3.343, 0 failed
progress: 30.0 s, 2513.7 tps, lat 7.954 ms stddev 3.523, 0 failed
progress: 36.0 s, 2648.5 tps, lat 7.551 ms stddev 3.476, 0 failed
progress: 42.0 s, 2617.5 tps, lat 7.641 ms stddev 3.258, 0 failed
progress: 48.0 s, 2566.0 tps, lat 7.793 ms stddev 3.286, 0 failed
progress: 54.0 s, 2475.0 tps, lat 8.081 ms stddev 3.217, 0 failed
progress: 60.0 s, 2548.3 tps, lat 7.847 ms stddev 3.292, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 20
number of threads: 2
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 152612
number of failed transactions: 0 (0.000%)
latency average = **7.862** ms
latency stddev = **4.878** ms
initial connection time = 28.962 ms
tps = **2542.895321** (without initial connection time)

# написать какого значения tps удалось достичь, показать какие параметры в какие значения устанавливали и почему
Удалось достичь tps = **2542.895321**

Задание со *: аналогично протестировать через утилиту https://github.com/Percona-Lab/sysbench-tpcc (требует установки
https://github.com/akopytov/sysbench)

Критерии оценки:
Выполнение ДЗ: 10 баллов

2 балл за красивое решение
2 балл за рабочее решение, и недостатки указанные преподавателем не устранены

