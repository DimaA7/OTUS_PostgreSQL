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
            max_connections	20	 - задает максимальное количество подключений к БД. Уменьшено относительно значения по умолчанию        
            checkpoint_completion_target	0.9	    - коэффициэнт интервала между контрольными точками. Обычно 0.9. Можно уменьшить.
            default_statistics_target	100	        - 
            effective_cache_size	524288	8kB     - Этот параметр соответствует максимальному размеру объекта, который может поместиться в системный кэш. Это значение используется только для оценки. effective_cache_size можно установить в 1/2 - 2/3 от объёма имеющейся в наличии оперативной памяти, если вся она отдана в распоряжение PostgreSQL. 
            effective_io_concurrency	1	
            huge_pages	try	
            maintenance_work_mem	65536	kB
            max_wal_size	1024	MB
            min_wal_size	80	MB
            random_page_cost	4	
            shared_buffers	16384	8kB             - определяет количество памяти, которое будет выделено postgres для кеширования данных. устанавливают 25% от всей памяти.
            temp_buffers	1024	8kB             - 
            wal_buffers	512	8kB
            work_mem	4096	kB
            synchronous_commit	on	
            wal_level	replica	


* effective_cache_size = 3GB		#Этот параметр помогает планировщику postgres определить количество доступной памяти для дискового кеширования. На основе того, доступна память или нет, планировщик будет делать выбор между использованием индексов и использованием сканирования таблицы. Это значение следует устанавливать в 50%…75% всей доступной оперативной памяти, в зависимости от того, сколько памяти доступно для системного кеша. Этот параметр не влияет на выделяемые ресурсы – это оценочная информация для планировщика.
* maintenance_work_mem = 256MB		#Задаёт максимальный объём памяти для операций обслуживания БД, в частности VACUUM, CREATE INDEX и ALTER TABLE ADD FOREIGN KEY. Чтобы операции выполнялись максимально быстро, нужно устанавливать этот параметр тем выше, чем больше размер таблиц в БД. Неплохо бы устанавливать его значение от 50 до 75% размера самой большой таблицы или индекса или, если точно определить невозможно, от 32 до 256 МБ. Например, при памяти 1–4 ГБ рекомендуется устанавливать 128–512 МБ.
* checkpoint_completion_target = 0.9	#Задаёт целевое время для завершения процедуры контрольной точки, как коэффициент для общего времени между контрольными точками. Обычно рекомендуется устанавливать данный параметр равным 0.9.
* wal_buffers = 16MB			#Задаёт объём разделяемой памяти, который будет использоваться для буферизации данных WAL, ещё не записанных на диск. Этот параметр стоит увеличивать в системах с большим количеством записей. Значение в 1Мб рекомендуют разработчики postgres даже для очень больших систем. Однако, сайт https://pgtune.leopard.in.ua предложил для моей конфигурации размер 16MB, поэтому я и применил это значение.
* default_statistics_target = 100	#Устанавливает значение ориентира статистики по умолчанию, распространяющееся на столбцы, для которых командой ALTER TABLE SET STATISTICS не заданы отдельные ограничения. Данное знакчение в целом является оптимальным для большинства БД, т.к. позволяет просматривать вполне адекватное количество записей для статистики. В случае необходимости этот параметр можно увеличить.
* random_page_cost = 1.1		#Задаёт приблизительную стоимость чтения одной произвольной страницы с диска. Общие рекомендации: 1.1~1.2 для NVME-SSD дисков; 1.3~1.5 для SATA-SSD дисков; 2.0~2.5 для HDD\SAS RAID; 4.0 (по умолчанию) для медленного одиночного HDD диска.
* effective_io_concurrency = 200	#Задаёт допустимое число параллельных операций ввода/вывода, которое говорит PostgreSQL о том, сколько операций ввода/вывода могут быть выполнены одновременно. Не нашёл в сети рекомендаций для этого параметра, но сайт https://pgtune.leopard.in.ua предложил установить значение 200.
* work_mem = 2621kB			#Задаёт объём памяти, который будет использоваться для внутренних операций сортировки и хеш-таблиц, прежде чем будут задействованы временные файлы на диске. Рекомендуют ставить RAM/32.
* min_wal_size = 1GB			#Пока WAL занимает на диске меньше этого объёма, старые файлы WAL в контрольных точках всегда перерабатываются, а не удаляются. Рекомендаций не нашёл, поэтому поставил значения с сайта https://pgtune.leopard.in.ua.
* max_wal_size = 4GB			#Задаёт максимальный размер, до которого может вырастать WAL между автоматическими контрольными точками в WAL. Рекомендаций не нашёл, поэтому поставил значения с сайта https://pgtune.leopard.in.ua.
* synchronous_commit = 'off'		#Включает/выключает синхронную запись в лог файлы после каждой транзакции. Это защищает от возможной потери данных. Но это накладывает ограничение на пропускную способность сервера. Т.е., установка значения off для данного параметра даёт возможность завершать транзакции быстрее, ценой того, что в случае краха СУБД последние транзакции могут быть потеряны.







   ## Тест #1
        dima@otus:~$ sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
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

   ## Оптимизированные настройки определенные по сайту https://pgtune.leopard.in.ua/:

            max_connections = 20
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


dima@otus:~$ sudo pgbench -c 20 -P 6 -T 60 -j 2 -p 5432 -U postgres sakila
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


Изменил настройки:

synchronous_commit = 'off' # 


dima@otus:~$ pgbench -c 50 -P 6 -T 60 -j 2 -p 5432 sakila
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

