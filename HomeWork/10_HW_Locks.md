**Домашнее задание "Механизм блокировок"**
Цель:
понимать как работает механизм блокировок объектов и строк

# Настройте сервер так, чтобы в журнал сообщений сбрасывалась информация о блокировках, удерживаемых более 200 миллисекунд. Воспроизведите ситуацию, при которой в журнале появятся такие сообщения.

    locks=# ALTER SYSTEM SET log_lock_waits = on;
    ALTER SYSTEM
    locks=# ALTER SYSTEM SET deadlock_timeout = 200;
    ALTER SYSTEM

    sudo pg_ctlcluster 15 main restart
    dima@otus:~$ sudo -u postgres psql -p5432
    psql (16.1 (Ubuntu 16.1-1.pgdg22.04+1), server 15.5 (Ubuntu 15.5-1.pgdg22.04+1))
    Type "help" for help.

    postgres=# show deadlock_timeout;
    deadlock_timeout
    ------------------
    200ms
    (1 row)

    Создаю таблицу для тестов
        \c locks
        drop table accpunts;
        CREATE TABLE accounts(
        acc_no integer PRIMARY KEY,
        amount numeric
        );
        INSERT INTO accounts VALUES (1,1000.00), (2,2000.00), (3,3000.00);

 ## Гнерация блокировок вручную из несольких консолей
    В сессии 1 выполняю пополнение первого счета на 100р.
        locks=# begin;
        BEGIN
        locks=*# UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;

    В сессии 2 выполняю уменьшение второго счета на 10р.
        locks=# begin;
        BEGIN
        locks=*# UPDATE accounts SET amount = amount - 10.00 WHERE acc_no = 2;
        UPDATE 1

    В сессии 1 выполняю пополнение счета 2 на 200р. При этом, транзакция 1 блокируется.
        locks=*# UPDATE accounts SET amount = amount + 200 WHERE acc_no = 2;

    В сессии 2 выполняю уменьшение первого счета на 20р.
        locks=*# UPDATE accounts SET amount = amount - 20.00 WHERE acc_no = 1;
        ERROR:  deadlock detected
        DETAIL:  Process 1528 waits for ShareLock on transaction 5524412; blocked by process 1518.
        Process 1518 waits for ShareLock on transaction 5524413; blocked by process 1528.
        HINT:  See server log for query details.
        CONTEXT:  while updating tuple (0,1) in relation "accounts"
        locks=!#

    В сессии 3 смотрю логи
        sudo tail -n 30 /var/log/postgresql/postgresql-15-main.log


        Есть запись о первой блокировке, которая длилась более 200мс: 

            2024-02-03 08:47:54.283 UTC [1518] postgres@locks LOG:  process 1518 still waiting for ShareLock on transaction 5524413 after **200.113 ms**
            2024-02-03 08:47:54.283 UTC [1518] postgres@locks DETAIL:  Process holding the lock: 1528. Wait queue: 1518.
            2024-02-03 08:47:54.283 UTC [1518] postgres@locks CONTEXT:  while updating tuple (0,2) in relation "accounts"
            2024-02-03 08:47:54.283 UTC [1518] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 200 WHERE acc_no = 2;

        Есть запись о второй взаимной блокировке, которая длилась более 200мс

            2024-02-03 08:48:22.957 UTC [1528] postgres@locks LOG:  process 1528 detected deadlock while waiting for ShareLock on transaction 5524412 after **200.097 ms**
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks DETAIL:  Process holding the lock: 1518. Wait queue: .
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks CONTEXT:  while updating tuple (0,1) in relation "accounts"
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount - 20.00 WHERE acc_no = 1;


        Есть запись об ошибке о взаимной блокировке:  

            2024-02-03 08:48:22.957 UTC [1528] postgres@locks ERROR:  deadlock detected
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks DETAIL:  Process 1528 waits for ShareLock on transaction 5524412; blocked by process 1518.
            Process 1518 waits for ShareLock on transaction 5524413; blocked by process 1528.
            Process 1528: UPDATE accounts SET amount = amount - 20.00 WHERE acc_no = 1;
            Process 1518: UPDATE accounts SET amount = amount + 200 WHERE acc_no = 2;
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks HINT:  See server log for query details.
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks CONTEXT:  while updating tuple (0,1) in relation "accounts"
            2024-02-03 08:48:22.957 UTC [1528] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount - 20.00 WHERE acc_no = 1;

        После того как дедлок был снят

            2024-02-03 08:48:22.957 UTC [1518] postgres@locks LOG:  process 1518 acquired ShareLock on transaction 5524413 after 28873.682 ms
            2024-02-03 08:48:22.957 UTC [1518] postgres@locks CONTEXT:  while updating tuple (0,2) in relation "accounts"
            2024-02-03 08:48:22.957 UTC [1518] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 200 WHERE acc_no = 2;


 ## Альтернатиный вариант генерации блокировок с помощью утилиты pgbench и файла со скриптом
    
    Чтобы создать блокировки, можно использую таблицу accounts, созданную ранее. Делаю скрипт locks_script вкотором запросы к одним и тем же строкам таблицы из прошлого примера:

        BEGIN;
        UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;
        UPDATE accounts SET amount = amount - 10.00 WHERE acc_no = 2;
        UPDATE accounts SET amount = amount + 200 WHERE acc_no = 2;
        UPDATE accounts SET amount = amount - 20.00 WHERE acc_no = 1;
        END;

    Запускаю pgbench
        sudo pgbench -c3 -P3 -T2 -p 5432 -U postgres -f locks_script locks

    Смотрю лог командой
        sudo tail -n 20 /var/log/postgresql/postgresql-15-main.log

    В логе множество блокировок, длящихся боле 200 мс

        2024-02-03 10:37:55.049 UTC [5184] postgres@locks LOG:  process 5184 still waiting for ExclusiveLock on tuple (0,1) of relation 22849 of database 22833 after 200.056 ms
        2024-02-03 10:37:55.049 UTC [5184] postgres@locks DETAIL:  Process holding the lock: 5183. Wait queue: 5184, 5185.
        2024-02-03 10:37:55.049 UTC [5184] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;

        2024-02-03 10:37:55.049 UTC [5185] postgres@locks LOG:  process 5185 still waiting for ExclusiveLock on tuple (0,1) of relation 22849 of database 22833 after 200.036 ms
        2024-02-03 10:37:55.049 UTC [5185] postgres@locks DETAIL:  Process holding the lock: 5183. Wait queue: 5184, 5185.
        2024-02-03 10:37:55.049 UTC [5185] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;

        ...

# Смоделируйте ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах. Изучите возникшие блокировки в представлении pg_locks и убедитесь, что все они понятны. Пришлите список блокировок и объясните, что значит каждая.

    Сессия 1
        sudo -u postgres psql -p5432 -d locks
        BEGIN;
        UPDATE accounts SET amount = amount + 10 WHERE acc_no = 1;

        Из сесии 5 смотрю блокирови, которые захватила транзакция №1 (Т1):
        locks=# select * FROM pg_locks;
        locks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart
        FROM pg_locks WHERE pid = 4629;

            FROM pg_locks;
   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted | waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+-----------
 relation      | accounts_pkey |       |         |         | 3/2504             | 4629 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 3/2504             | 4629 | RowExclusiveLock | t       |
 virtualxid    |               |       | 3/2504  |         | 3/2504             | 4629 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536451 | 3/2504             | 4629 | ExclusiveLock    | t       |

        Описание блокировок транзакции Т1:
            Тип virtualxid, режим ExclusiveLock - эксклюзивная блокировка транзакцией своего виртуального номера транзакции (3/2504).
            Тип transactionid, режим ExclusiveLock - это блокировка транзакцией номера транзакции (5536451).
            Тип relation, режим RowExclusiveLock, таблица accounts - это команда UPDATE получила блокировку, чтобы работать с таблицей accounts. 
            Тип relation, режим RowExclusiveLock, индекс accounts_pkey - это команда UPDATE получила блокировку, чтобы работать с индексом accounts_pkey.

    Сессия 2
        sudo -u postgres psql -p5432 -d locks
        BEGIN;
        UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;

        Из сесии 5 смотрю блокирови, которые захватила транзакция Т2
        locks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart
        FROM pg_locks WHERE pid = 4633;

   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted |           waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+-------------------------------
 relation      | accounts_pkey |       |         |         | 4/2                | 4633 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 4/2                | 4633 | RowExclusiveLock | t       |
 virtualxid    |               |       | 4/2     |         | 4/2                | 4633 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536452 | 4/2                | 4633 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536451 | 4/2                | 4633 | ShareLock        | f       | 2024-02-03 19:33:30.886391+00
 tuple         | accounts      |     1 |         |         | 4/2                | 4633 | ExclusiveLock    | t       |
(6 rows)

        Описание блокировок транзакции Т2:
            Т2 получила блокировки таблицы и индекса в режиме RowExclusiveLock
            Т2 также получила блокировку виртуального номера транзации virtualxid в режиме ExclusiveLock
            Т2 получила блокировку своего номера транзакции 5536451 в режиме ExclusiveLock
            Т2 захватила блокировку версии строки tuple в режиме ExclusiveLock, но была вынуждена запросить блокировку номера (transactionid) первой транзакции 5536451 и на этом повисла.
    
    Сессия 3
        sudo -u postgres psql -p5432 -d locks
        BEGIN;
        UPDATE accounts SET amount = amount + 1000 WHERE acc_no = 1;

        Из сесии 5 смотрю блокирови, которые захватила транзакция №3 (Т3):
locks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart
        FROM pg_locks WHERE pid = 4692;
   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted |           waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+-------------------------------
 relation      | accounts_pkey |       |         |         | 6/33               | 4692 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 6/33               | 4692 | RowExclusiveLock | t       |
 virtualxid    |               |       | 6/33    |         | 6/33               | 4692 | ExclusiveLock    | t       |
 tuple         | accounts      |     1 |         |         | 6/33               | 4692 | ExclusiveLock    | f       | 2024-02-03 20:16:46.969453+00
 transactionid |               |       |         | 5536453 | 6/33               | 4692 | ExclusiveLock    | t       |
(5 rows)

        Описание блокировок транзакции Т3:
            Т3 получила блокировки таблицы и индекса в режиме RowExclusiveLock
            Т3 также получила блокировку виртуального номера транзации 6/33 virtualxid в режиме ExclusiveLock
            Т3 получила блокировку своего номера транзакции 5536453 в режиме ExclusiveLock
            Т3 попыталась захватить блокировку версии строки tuple в режиме ExclusiveLock и повисла же на этом щаге.

    Сессия 4
         SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart
         FROM pg_locks WHERE pid = 4697;
     
     Из сесии 5 смотрю блокирови, которые захватила транзакция №3 (Т4):
     locks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart

        FROM pg_locks WHERE pid = 6597;
   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted |          waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+------------------------------
 relation      | accounts_pkey |       |         |         | 7/1218             | 6597 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 7/1218             | 6597 | RowExclusiveLock | t       |
 virtualxid    |               |       | 7/1218  |         | 7/1218             | 6597 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536454 | 7/1218             | 6597 | ExclusiveLock    | t       |
 tuple         | accounts      |     1 |         |         | 7/1218             | 6597 | ExclusiveLock    | f       | 2024-02-03 20:27:25.01356+00
(5 rows)
     
     Описание блокировок транзакции Т4:
            Т4 получила блокировки таблицы и индекса в режиме RowExclusiveLock
            Т4 также получила блокировку виртуального номера транзации 7/1218 virtualxid в режиме ExclusiveLock
            Т4 получила блокировку своего номера транзакции 5536453 в режиме ExclusiveLock
            Т4 попыталась захватить блокировку версии строки tuple в режиме ExclusiveLock и повисла же на этом щаге.
     
     Сессия 5
          
        Запрос блокировок

            locks=# SELECT pid, wait_event_type, wait_event, pg_blocking_pids(pid)
            FROM pg_stat_activity
            WHERE backend_type = 'client backend';
            pid  | wait_event_type |  wait_event   | pg_blocking_pids
            ------+-----------------+---------------+------------------
            4629 | Client          | ClientRead    | {}
            4633 | Lock            | transactionid | {4629}
            4639 |                 |               | {}
            4692 | Lock            | tuple         | {4633}
            6597 | Lock            | tuple         | {4633,4692}

Получается своеобразная «очередь», в которой есть первый (тот, кто удерживает блокировку версии строки) это транзация  Т2 (4633) и остальные, выстроившиеся за первым (транзакции Т3 4692, Т4 6597).

# Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

    Сценарий взаимоблокировки трех транзакций через консоль:
        Транзакция 1    Пополнение счета 1
        Транзакция 2    Пополнение счета 2 
        Транзакция 3    Пополнение счета 3
        Транзакция 1    Пополнение счета 3 - блокировка транзакцией 3
        Транзакция 2    Пополнение счета 1 - блокировка транзакцией 1
        Транзакция 3    Пополнение счета 2 - взаимная блокировка

    Сессия 1 (process 1637)
        locks=# begin;
        BEGIN
        locks=*# UPDATE accounts SET amount = amount + 10 WHERE acc_no = 1;
        UPDATE 1
    Сессия 2 (process 1646)
        locks=# begin;
        BEGIN
        locks=*# UPDATE accounts SET amount = amount + 100 WHERE acc_no = 2;
        UPDATE 1
    Сессия 3 (process 1654)
        locks=# begin;
        BEGIN
        locks=*# UPDATE accounts SET amount = amount + 1000 WHERE acc_no = 3;
        UPDATE 1
    Сессия 1 (process 1637)
        locks=*# UPDATE accounts SET amount = amount + 1001 WHERE acc_no = 3;
        UPDATE 1
        locks=*#
    Сессия 2 (process 1646)
        locks=*# UPDATE accounts SET amount = amount + 11 WHERE acc_no = 1;
        Зависла
    Сессия 3 (process 1654)
        locks=*# UPDATE accounts SET amount = amount + 101 WHERE acc_no = 2;
        ERROR:  deadlock detected
        DETAIL:  Process 1654 waits for ShareLock on transaction 5536467; blocked by process 1646.
        Process 1646 waits for ShareLock on transaction 5536465; blocked by process 1637.
        Process 1637 waits for ShareLock on transaction 5536468; blocked by process 1654.
        HINT:  See server log for query details.
        CONTEXT:  while updating tuple (0,2) in relation "accounts"
        locks=!#

    Сессия 1
        locks=*# commit;
        COMMIT
        locks=#


    Запрос логов
        sudo tail -n 40 /var/log/postgresql/postgresql-15-main.log
            2024-02-05 18:23:41.849 UTC [1646] postgres@locks LOG:  process 1646 still waiting for ShareLock on transaction 5536465 after 200.057 ms
            2024-02-05 18:23:41.849 UTC [1646] postgres@locks DETAIL:  Process holding the lock: 1637. Wait queue: 1646.
            2024-02-05 18:23:41.849 UTC [1646] postgres@locks CONTEXT:  while updating tuple (0,32) in relation "accounts"
            2024-02-05 18:23:41.849 UTC [1646] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;
            2024-02-05 18:24:00.342 UTC [1646] postgres@locks ERROR:  canceling statement due to user request
            2024-02-05 18:24:00.342 UTC [1646] postgres@locks CONTEXT:  while updating tuple (0,32) in relation "accounts"
            2024-02-05 18:24:00.342 UTC [1646] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;
            2024-02-05 18:24:11.231 UTC [923] LOG:  checkpoint starting: time
            2024-02-05 18:24:11.252 UTC [923] LOG:  checkpoint complete: wrote 1 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.007 s, sync=0.003 s, total=0.021 s; sync files=1, longest=0.003 s, average=0.003 s; distance=0 kB, estimate=1 kB
            2024-02-05 18:25:11.303 UTC [923] LOG:  checkpoint starting: time
            2024-02-05 18:25:11.420 UTC [923] LOG:  checkpoint complete: wrote 1 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.106 s, sync=0.004 s, total=0.118 s; sync files=1, longest=0.004 s, average=0.004 s; distance=1 kB, estimate=1 kB
            2024-02-05 18:25:41.450 UTC [923] LOG:  checkpoint starting: time
            2024-02-05 18:25:41.568 UTC [923] LOG:  checkpoint complete: wrote 1 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.105 s, sync=0.006 s, total=0.118 s; sync files=1, longest=0.006 s, average=0.006 s; distance=1 kB, estimate=1 kB
            2024-02-05 18:26:13.743 UTC [1637] postgres@locks LOG:  process 1637 still waiting for ShareLock on transaction 5536468 after 200.145 ms
            2024-02-05 18:26:13.743 UTC [1637] postgres@locks DETAIL:  Process holding the lock: 1654. Wait queue: 1637.
            2024-02-05 18:26:13.743 UTC [1637] postgres@locks CONTEXT:  while updating tuple (0,3) in relation "accounts"
            2024-02-05 18:26:13.743 UTC [1637] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 1001 WHERE acc_no = 3;
            2024-02-05 18:26:43.003 UTC [1646] postgres@locks LOG:  process 1646 still waiting for ShareLock on transaction 5536465 after 200.142 ms
            2024-02-05 18:26:43.003 UTC [1646] postgres@locks DETAIL:  Process holding the lock: 1637. Wait queue: 1646.
            2024-02-05 18:26:43.003 UTC [1646] postgres@locks CONTEXT:  while updating tuple (0,32) in relation "accounts"
            2024-02-05 18:26:43.003 UTC [1646] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 11 WHERE acc_no = 1;
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks LOG:  process 1654 detected deadlock while waiting for ShareLock on transaction 5536467 after 200.077 ms
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks DETAIL:  Process holding the lock: 1646. Wait queue: .
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks CONTEXT:  while updating tuple (0,2) in relation "accounts"
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 101 WHERE acc_no = 2;
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks ERROR:  deadlock detected
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks DETAIL:  Process 1654 waits for ShareLock on transaction 5536467; blocked by process 1646.
                    Process 1646 waits for ShareLock on transaction 5536465; blocked by process 1637.
                    Process 1637 waits for ShareLock on transaction 5536468; blocked by process 1654.
                    Process 1654: UPDATE accounts SET amount = amount + 101 WHERE acc_no = 2;
                    Process 1646: UPDATE accounts SET amount = amount + 11 WHERE acc_no = 1;
                    Process 1637: UPDATE accounts SET amount = amount + 1001 WHERE acc_no = 3;
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks HINT:  See server log for query details.
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks CONTEXT:  while updating tuple (0,2) in relation "accounts"
            2024-02-05 18:26:56.758 UTC [1654] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 101 WHERE acc_no = 2;
            2024-02-05 18:26:56.759 UTC [1637] postgres@locks LOG:  process 1637 acquired ShareLock on transaction 5536468 after 43216.058 ms
            2024-02-05 18:26:56.759 UTC [1637] postgres@locks CONTEXT:  while updating tuple (0,3) in relation "accounts"
            2024-02-05 18:26:56.759 UTC [1637] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 1001 WHERE acc_no = 3;
            2024-02-05 19:35:18.544 UTC [1646] postgres@locks LOG:  process 1646 acquired ShareLock on transaction 5536465 after 4115741.361 ms
            2024-02-05 19:35:18.544 UTC [1646] postgres@locks CONTEXT:  while updating tuple (0,32) in relation "accounts"
            2024-02-05 19:35:18.544 UTC [1646] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 11 WHERE acc_no = 1;
            

        По логу видно что в ходе выполнения транзакции 3 (процесс 1654) был дедлок из-за того что
            Транзакция 1 (процесс 1637) была заблокирован транзакцией 3 (процесс 1654)
                Process 1637 waits for ShareLock on transaction 5536468; blocked by process 1654.
            Транзакция 2 (процесс 1646) была заблокирована транзакцией 1 (процесс 1637)
                Process 1646 waits for ShareLock on transaction 5536465; blocked by process 1637.
            Транзакция 3 (процесс 1654) была заблокирована транзакцией 2 (процесс 1646)
                Process 1654 waits for ShareLock on transaction 5536467; blocked by process 1646.
        
        Также видно что после дедлока 
            Процессу 1637 удалось получить блокировку. Значит был снят процесс 1654. Он откатился.
                process 1637 acquired ShareLock on transaction 5536468 after 43216.058 ms
            Процессу 1646 удалось получить блокировку. Завершился процесс 1637
                rocess 1646 acquired ShareLock on transaction 5536465 after 4115741.361 ms

# Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?

Теоретически это возможно если одна команда будет обновлять строки таблицы в прямом порядке, а другая в обратном.


# Задание со звездочкой*
  Воспроизвести не получилоь.

Критерии оценки:
Выполнение ДЗ: 10 баллов
плюс 2 балла за задание со *
плюс 2 балла за красивое решение
минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены