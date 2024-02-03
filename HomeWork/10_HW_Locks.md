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
# 10 минут c помощью утилиты pgbench подавайте нагрузку.
    
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

        Из сесии 4 смотрю блокирови, которые захватила транзакция №1
        locks=# select * FROM pg_locks;
        locks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart

            FROM pg_locks;
   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted | waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+-----------
 relation      | pg_locks      |       |         |         | 6/28               | 4692 | AccessShareLock  | t       |
 virtualxid    |               |       | 6/28    |         | 6/28               | 4692 | ExclusiveLock    | t       |
 relation      | accounts_pkey |       |         |         | 3/2504             | 4629 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 3/2504             | 4629 | RowExclusiveLock | t       |
 virtualxid    |               |       | 3/2504  |         | 3/2504             | 4629 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536451 | 3/2504             | 4629 | ExclusiveLock    | t       |

        Транзакция №1 захватила блокировки:
      
            Тип virtualxid, режим ExclusiveLock - эксклюзивная блокировка транзакцией своего виртуального номера транзакции
            Тип transactionid, режим ExclusiveLock - это блокировка транзакцией номера транзакции (5536451).
            Тип reltion, режим RowExclusiveLock, таблица accounts - это команда UPDATE получила блокировку, чтобы работать с таблицей accounts. 
            Тип reltion, режим RowExclusiveLock, индекс accounts_pkey - это команда UPDATE получила блокировку, чтобы работать с индексом accounts_pkey.
            Тип 
        



    Сессия 2
        sudo -u postgres psql -p5432 -d locks
        BEGIN;
        UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;

        Проверяем блокировки
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


        На версии строки (tuple) таблицы accounts это блокировка строки


    Сессия 3
        
        
        sudo -u postgres psql -p5432 -d locks
        BEGIN;
        UPDATE accounts SET amount = amount + 1000 WHERE acc_no = 1;

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



    Сессия 4
     

     SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart
        FROM pg_locks WHERE pid = 4697;
     
     
     ocks=# SELECT locktype, relation::REGCLASS, tuple, virtualxid AS virtxid, transactionid AS xid, virtualtransaction, pid,   mode, granted, waitstart

        FROM pg_locks WHERE pid = 6597;
   locktype    |   relation    | tuple | virtxid |   xid   | virtualtransaction | pid  |       mode       | granted |          waitstart
---------------+---------------+-------+---------+---------+--------------------+------+------------------+---------+------------------------------
 relation      | accounts_pkey |       |         |         | 7/1218             | 6597 | RowExclusiveLock | t       |
 relation      | accounts      |       |         |         | 7/1218             | 6597 | RowExclusiveLock | t       |
 virtualxid    |               |       | 7/1218  |         | 7/1218             | 6597 | ExclusiveLock    | t       |
 transactionid |               |       |         | 5536454 | 7/1218             | 6597 | ExclusiveLock    | t       |
 tuple         | accounts      |     1 |         |         | 7/1218             | 6597 | ExclusiveLock    | f       | 2024-02-03 20:27:25.01356+00
(5 rows)
     
     
     
     Сессия 5
          
     
        Смотрю логи
        sudo tail -n 10 /var/log/postgresql/postgresql-15-main.log

            2024-02-03 12:07:09.599 UTC [1739] postgres@locks LOG:  process 1739 still waiting for ShareLock on transaction 5536448 after 200.056 ms
            2024-02-03 12:07:09.599 UTC [1739] postgres@locks DETAIL:  Process holding the lock: 1680. Wait queue: 1739.
            2024-02-03 12:07:09.599 UTC [1739] postgres@locks CONTEXT:  while updating tuple (0,1) in relation "accounts"
            2024-02-03 12:07:09.599 UTC [1739] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 100 WHERE acc_no = 1;
            2024-02-03 12:07:25.081 UTC [1737] postgres@locks LOG:  process 1737 still waiting for ExclusiveLock on tuple (0,1) of relation 22849 of database 22833 after 200.059 ms
            2024-02-03 12:07:25.081 UTC [1737] postgres@locks DETAIL:  Process holding the lock: 1739. Wait queue: 1737.
            2024-02-03 12:07:25.081 UTC [1737] postgres@locks STATEMENT:  UPDATE accounts SET amount = amount + 1000 WHERE acc_no = 1;


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


Получается своеобразная «очередь», в которой есть первый (тот, кто удерживает блокировку версии строки) и все остальные, выстроившиеся за первым.


locks=# SELECT * FROM pg_stat_activity WHERE pid = ANY(pg_blocking_pids(1737)) \gx




# Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

# Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?

# Задание со звездочкой*
  Попробуйте воспроизвести такую ситуацию.

Критерии оценки:
Выполнение ДЗ: 10 баллов
плюс 2 балла за задание со *
плюс 2 балла за красивое решение
минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены