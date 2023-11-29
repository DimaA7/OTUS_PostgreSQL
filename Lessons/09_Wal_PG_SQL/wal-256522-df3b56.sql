SELECT setting, unit FROM pg_settings WHERE name = 'shared_buffers'; 
-- уменьшим количество буферов для наблюдения
ALTER SYSTEM SET shared_buffers = 200;

CREATE DATABASE buffer_temp;
\c buffer_temp
CREATE TABLE test(i int);
-- сгенерируем значения
INSERT INTO test SELECT s.id FROM generate_series(1,100) AS s(id); 
SELECT * FROM test limit 100;

-- создадим расширение для просмотра кеша
CREATE EXTENSION pg_buffercache; 

\dx+

CREATE VIEW pg_buffercache_v AS
SELECT bufferid,
       (SELECT c.relname FROM pg_class c WHERE  pg_relation_filenode(c.oid) = b.relfilenode ) relname,
       CASE relforknumber
         WHEN 0 THEN 'main'
         WHEN 1 THEN 'fsm'
         WHEN 2 THEN 'vm'
       END relfork,
       relblocknumber,
       isdirty,
       usagecount
FROM   pg_buffercache b
WHERE  b.relDATABASE IN (    0, (SELECT oid FROM pg_DATABASE WHERE datname = current_database()) )
AND    b.usagecount is not null;

select * from pg_buffercache;

SELECT * FROM pg_buffercache_v WHERE relname='test';

SELECT * FROM test limit 10;

UPDATE test set i = 2 WHERE i = 1;

-- увидим грязную страницу
SELECT * FROM pg_buffercache_v WHERE relname='test';


-- даст пищу для размышлений над использованием кеша -- usagecount > 3
SELECT c.relname,
  count(*) blocks,
  round( 100.0 * 8192 * count(*) / pg_TABLE_size(c.oid) ) "% of rel",
  round( 100.0 * 8192 * count(*) FILTER (WHERE b.usagecount > 3) / pg_TABLE_size(c.oid) ) "% hot"
FROM pg_buffercache b
  JOIN pg_class c ON pg_relation_filenode(c.oid) = b.relfilenode
WHERE  b.relDATABASE IN (
         0, (SELECT oid FROM pg_DATABASE WHERE datname = current_database())
       )
AND    b.usagecount is not null
GROUP BY c.relname, c.oid
ORDER BY 2 DESC
LIMIT 10;

//сгенерируем значения с текстовыми полями - чтобы занять больше страниц
drop table test_text
CREATE TABLE test_text(t text);
INSERT INTO test_text SELECT 'строка '||s.id FROM generate_series(1,500) AS s(id); 
SELECT * FROM test_text limit 10;
SELECT * FROM test_text;
SELECT * FROM pg_buffercache_v WHERE relname='test_text';

-- интересный эффект
vacuum test_text;


-- посмотрим на прогрев кеша
-- рестартуем кластер для очистки буферного кеша
sudo pg_ctlcluster 14 main restart


\c buffer_temp
SELECT * FROM pg_buffercache_v WHERE relname='test_text';
CREATE EXTENSION pg_prewarm;
SELECT pg_prewarm('test_text');
SELECT * FROM pg_buffercache_v WHERE relname='test_text';



SELECT * FROM pg_ls_waldir() LIMIT 10;


drop table wal;
CREATE TABLE wal(id integer);
INSERT INTO wal VALUES (1);
select * from wal;

start transaction;
SELECT pg_current_wal_insert_lsn(); -- 0/F2AF95B8
UPDATE wal set id = id + 1;
SELECT pg_current_wal_insert_lsn(); -- 0/F2AF9600
SELECT lsn FROM page_header(get_raw_page('wal',0)); -- 0/F2AF9600
commit;

SELECT pg_current_wal_lsn(), pg_current_wal_insert_lsn();

-- Размер журнальных записей между ними (в байтах):
SELECT '0/1672DB8'::pg_lsn - '0/1670928'::pg_lsn;

-- Посмотреть что за запись:
SELECT * FROM pg_ls_waldir() LIMIT 10;
-- sudo /usr/lib/postgresql/14/bin/pg_waldump -p /var/lib/postgresql/14/main/pg_wal -s 0/F2AF95B8 -e 0/F2AF9600 0000000100000000000000F2

INSERT INTO wal values(100);

-- sudo pg_ctlcluster 14 main stop -m immediate
-- sudo /usr/lib/postgresql/14/bin/pg_controldata /var/lib/postgresql/14/main/
-- sudo pg_ctlcluster 14 main start


SELECT * FROM pg_buffercache_v;
SELECT pg_prewarm('test_text');
SELECT * FROM pg_buffercache_v WHERE relname='test_text';

SELECT * FROM pg_ls_waldir(); -- 0000000100000000000000F2

drop table wal;
CREATE TABLE wal(id integer);
INSERT INTO wal VALUES (1);
select * from wal;

SELECT pg_current_wal_insert_lsn(); -- 0/F2C0EC70
UPDATE wal set id = id + 1;
SELECT pg_current_wal_insert_lsn(); -- 0/F2C0ED60
SELECT pg_current_wal_lsn(); -- 0/F2C0ED60
SELECT lsn FROM page_header(get_raw_page('wal',0)); -- 0/F2C0ED00

drop table wal;
CREATE TABLE wal(id integer);
INSERT INTO wal VALUES (1);
select * from wal;

start transaction;
SELECT pg_current_wal_insert_lsn(); -- 0/F2C105E0
UPDATE wal set id = id + 1;
SELECT pg_current_wal_insert_lsn(); -- 0/F2C10628
SELECT lsn FROM page_header(get_raw_page('wal',0)); -- 0/F2C10628
commit;

SELECT pg_current_wal_lsn(), pg_current_wal_insert_lsn();

-- Размер журнальных записей между ними (в байтах):
SELECT '0/F2C10628'::pg_lsn - '0/F2C105E0'::pg_lsn;

-- Посмотреть что за запись:
SELECT * FROM pg_ls_waldir() LIMIT 10;
-- sudo /usr/lib/postgresql/14/bin/pg_waldump -p /var/lib/postgresql/14/main/pg_wal -s 0/F2AF95B8 -e 0/F2AF9600 0000000100000000000000F2

INSERT INTO wal values(100);

-- sudo pg_ctlcluster 14 main stop -m immediate
-- sudo /usr/lib/postgresql/14/bin/pg_controldata /var/lib/postgresql/14/main/
-- sudo pg_ctlcluster 14 main start

CREATE TABLE test_pg(i int);
-- сгенерируем значения
INSERT INTO test_pg SELECT s.id FROM generate_series(1,10000) AS s(id); 
SELECT * FROM test_pg limit 10;

checkpoint;

SELECT * FROM pg_buffercache_v WHERE relname='test_pg';

checkpoint;

SELECT * FROM pg_stat_bgwriter 

show fsync;
show wal_sync_method;
pg_test_fsync;

show data_checksums;
