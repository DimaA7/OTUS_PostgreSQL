show lc_collate;
show cpu_tuple_cost;

select * from pg_settings where name='cpu_tuple_cost';

--Свойства метода доступа
select a.amname, p.name, pg_indexam_has_property(a.oid,p.name)
from pg_am a,
unnest(array['can_order','can_unique','can_multi_col','can_exclude']) p(name)
where a.amname = 'btree' order by a.amname;

---список всех существующих классов операторов

SELECT am.amname AS index_method,
       opc.opcname AS opclass_name,
       opc.opcintype::regtype AS indexed_type,
       opc.opcdefault AS is_default
    FROM pg_am am, pg_opclass opc
    WHERE opc.opcmethod = am.oid
    and am.amname = 'btree'
    ORDER BY index_method, opclass_name;

---классы операторов----
SELECT am.amname AS index_method,
       opf.opfname AS opfamily_name,
       amop.amopopr::regoperator AS opfamily_operator
    FROM pg_am am, pg_opfamily opf, pg_amop amop
    WHERE opf.opfmethod = am.oid AND
          amop.amopfamily = opf.oid
          and am.amname = 'btree'
    ORDER BY index_method, opfamily_name, opfamily_operator;


---
drop database otus;

create database otus;

create table test as
select generate_series as id
	, generate_series::text || (random() * 10)::text as col2
    , (array['Yes', 'No', 'Maybe'])[floor(random() * 3 + 1)] as is_okay
from generate_series(1, 50000);
select * from test;


analyse test;

explain
select * from test where id = 1;

select * from pg_settings where name ='seq_page_cost';
select * from pg_settings where name ='cpu_tuple_cost';

-----вычсиление cost-----

analyse test;


explain (buffers,analyse)
select *
from test;

--(число_чтений_диска * seq_page_cost) + (число_просканированных_строк * cpu_tuple_cost)
show seq_page_cost;
show cpu_tuple_cost;
--(383*1)+(50000*0,01)

set seq_page_cost=2;
reset all;

----Смотрим планы выполнения в визуализаторах
explain
select id from test where id = 1;

CREATE INDEX CONCURRENTLY "explain_depesz_com_hint_ORLQ_1" ON test ( id );


EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
select id from test where id = 1;


EXPLAIN (ANALYZE, BUFFERS)
select id from test where id = 1;

drop table test;


--Уникальный индекс
drop table test;

create table test as
select generate_series as id
	, generate_series::text || (random() * 10)::text as col2
    , (array['Yes', 'No', 'Maybe'])[floor(random() * 3 + 1)] as is_okay
from generate_series(1, 50000);
alter table test add constraint uk_test_id unique(id);

---width
explain
select * from test where id = 1;

explain
select id from test where id = 1;

insert into test values (null, 12, 'Yes');
insert into test values (null, 12, 'No');
explain
select * from test where id is null;

alter table test drop constraint uk_test_id;

create unique index idx_test_id on test(id) NULLS  DISTINCT ;

explain
select * from test where id is null;

explain select *
from test
order by id desc;

drop table test;



--Составной индекс
drop table test;
create table test as
select generate_series as id
	, generate_series::text || (random() * 10)::text as col2
    , (array['Yes', 'No', 'Maybe'])[floor(random() * 3 + 1)] as is_okay
from generate_series(1, 50000);

drop index idx_test_id_is_okay;

create index idx_test_id_is_okay on test(id,is_okay);

explain
select * from test where id = 1 and is_okay = 'True';

explain
select * from test where id = 1;

analyse test;

set enable_seqscan='off';

explain analyse
select * from test where is_okay = 'Yes';

968

create index idx_test_is_okay on test(is_okay);

explain analyse
select * from test where is_okay = 'Yes';

explain
select * from test order by id, is_okay;

explain
select * from test order by id desc , is_okay desc;

set enable_seqscan='on';
SET enable_incremental_sort = off;


explain
select * from test order by id,is_okay desc;

drop table test;


--индекс на функцию  ()
drop table test;

create table test as
select generate_series as id
	, generate_series::text || (random() * 10)::text as col2
    , (array['Yes', 'No', 'Maybe'])[floor(random() * 3 + 1)] as is_okay
from generate_series(1, 50000);


create index idx_test_id_is_okay on test(lower(is_okay));

select * from test limit 30;

explain
select * from test where is_okay = 'Yes';

explain
select is_okay from test where lower(is_okay) = 'Yes';

--частичный индекс
drop table test;
create table test as
select generate_series as id
	, generate_series::text || (random() * 10)::text as col2
    , (array['Yes', 'No', 'Maybe'])[floor(random() * 3 + 1)] as is_okay
from generate_series(1, 50000);
create index idx_test_id_100 on test(id) where id < 100;

explain
select * from test where id > 100;

explain
select * from test where id > 20 and id < 60;

--обслуживание индексов
SELECT
    TABLE_NAME,
    pg_size_pretty(table_size) AS table_size,
    pg_size_pretty(indexes_size) AS indexes_size,
    pg_size_pretty(total_size) AS total_size
FROM (
    SELECT
        TABLE_NAME,
        pg_table_size(TABLE_NAME) AS table_size,
        pg_indexes_size(TABLE_NAME) AS indexes_size,
        pg_total_relation_size(TABLE_NAME) AS total_size
    FROM (
        SELECT ('"' || table_schema || '"."' || TABLE_NAME || '"') AS TABLE_NAME
        FROM information_schema.tables
    ) AS all_tables
    ORDER BY total_size DESC

    ) AS pretty_sizes;

select * from pg_stat_user_indexes;



--неиспользуемые индексы
SELECT s.schemaname,
       s.relname AS tablename,
       s.indexrelname AS indexname,
       pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
       s.idx_scan
FROM pg_catalog.pg_stat_all_indexes s
   JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan < 100      -- has never been scanned
  AND 0 <>ALL (i.indkey)  -- no index column is an expression
  AND NOT i.indisunique   -- is not a UNIQUE index
  AND NOT EXISTS          -- does not enforce a constraint
         (SELECT 1 FROM pg_catalog.pg_constraint c
          WHERE c.conindid = s.indexrelid)
ORDER BY pg_relation_size(s.indexrelid) DESC;

SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
ORDER BY
    tablename,
    indexname;

--Индекс на timestamp (between)

drop table if exists orders;
create table orders (
    id int,
    user_id int,
    order_date date,
    status text,
    some_text text
);


insert into orders(id, user_id, order_date, status, some_text)
select generate_series, (random() * 70), date'2019-01-01' + (random() * 300)::int as order_date
        , (array['returned', 'completed', 'placed', 'shipped'])[(random() * 4)::int]
        , concat_ws(' ', (array['go', 'space', 'sun', 'London'])[(random() * 5)::int]
            , (array['the', 'capital', 'of', 'Great', 'Britain'])[(random() * 6)::int]
            , (array['some', 'another', 'example', 'with', 'words'])[(random() * 6)::int]
            )
from generate_series(1,1000000);


select *
from orders;

--cost > jit_above_cost включается JIT
explain
select *
from orders
where id < 1000000;

show jit_above_cost;

drop index idx_orders_id;
create index idx_orders_id on orders(some_text);

explain
select *
from orders
where id <1500000;

explain
select *
from orders
order by id;

explain
select *
from orders
order by id desc;

--Индекс на даты
drop index if exists idx_ord_order_Date;
create index idx_ord_order_Date on orders(order_date);
explain
select *
from orders
where order_date between date'2020-01-01' and date'2020-02-01';

--Индекс include
drop index if exists idx_ord_order_date_inc_status;
create index idx_ord_order_date_inc_status_some_include on orders(order_date,some_text);

create index idx_ord_order_date_inc_status on orders;

explain
select order_date, status,some_text
from orders
where order_date between date'2020-01-01' and date'2020-02-01';

explain
select order_date, status
from orders
where order_date between date'2020-01-01' and date'2020-02-01'
        and status = 'placed';

--Работа с лексемами
explain (analyse,buffers)
select * from orders where some_text ilike 'a%';

select * from orders;

select some_text, to_tsvector(some_text)
from orders;

explain
select some_text, to_tsvector(some_text) @@ to_tsquery('britains')
from orders;

select some_text, to_tsvector(some_text) @@ to_tsquery('london & capital')
from orders;

select some_text, to_tsvector(some_text) @@ to_tsquery('london | capital')
from orders;

alter table orders drop column if exists some_text_lexeme;

alter table orders add column some_text_lexeme tsvector;
update orders set some_text_lexeme = to_tsvector(some_text);

explain
select *
from orders
where some_text_lexeme @@ to_tsquery('britains');

-- Результат без индекса:
		Gather  (cost=1000.00..146813.30 rows=168433 width=62)
		  Workers Planned: 2
		  ->  Parallel Seq Scan on orders  (cost=0.00..128970.00 rows=70180 width=62)
		        Filter: (some_text_lexeme @@ to_tsquery('britains'::text))
		JIT:
		  Functions: 2
		  Options: Inlining false, Optimization false, Expressions true, Deforming true

drop index if exists search_index_ord;
CREATE INDEX search_index_ord ON orders
    USING GIN (some_text_lexeme);
drop index search_index_ord;

explain
select *
from orders
where some_text_lexeme @@ to_tsquery('britains');

-- Результат с индексом:
		Gather  (cost=1000.00..26778.93 rows=9756 width=62) (actual time=4278.703..11800.821 rows=5523 loops=1)
		  Workers Planned: 2
		  Workers Launched: 2
		  Buffers: shared hit=15 read=19580
		  ->  Parallel Seq Scan on orders  (cost=0.00..24803.33 rows=4065 width=62) (actual time=4264.907..11788.591 rows=1841 loops=3)
		        Filter: (some_text ~~* 'a%'::text)
		        Rows Removed by Filter: 331492
		        Buffers: shared hit=15 read=19580
		Planning Time: 0.114 ms
		Execution Time: 11801.225 ms

--Расширения pgstattuple
CREATE EXTENSION pgstattuple;

drop table if exists orders;
create table orders (
    id int,
    user_id int,
    order_date date,
    status text,
    some_text text
);


insert into orders(id, user_id, order_date, status, some_text)
select generate_series, (random() * 70), date'2019-01-01' + (random() * 300)::int as order_date
        , (array['returned', 'completed', 'placed', 'shipped'])[(random() * 4)::int]
        , concat_ws(' ', (array['go', 'space', 'sun', 'London'])[(random() * 5)::int]
            , (array['the', 'capital', 'of', 'Great', 'Britain'])[(random() * 6)::int]
            , (array['some', 'another', 'example', 'with', 'words'])[(random() * 6)::int]
            )
from generate_series(1, 1000000);


create index orders_order_date on orders(order_date);

analyse orders;

select * from pg_stat_user_tables where relname='orders' ;
	relid	schemaname	relname	seq_scan	seq_tup_read	idx_scan	idx_tup_fetch	n_tup_ins	n_tup_upd	n_tup_del	n_tup_hot_upd	n_live_tup	n_dead_tup	n_mod_since_analyze	n_ins_since_vacuum	last_vacuum	last_autovacuum					last_analyze					last_autoanalyze	vacuum_count	autovacuum_count	analyze_count	autoanalyze_count
	17 154	public		orders	4			2 000 000		0			0				1 000 000	0			0			0				1 000 000	0			0					0					[NULL]		2023-12-13 20:17:08.789 +0300	2023-12-13 20:17:01.604 +0300	[NULL]				0				1					1				0

select * from pgstattuple('orders');
	table_len	tuple_count	tuple_len	tuple_percent	dead_tuple_count	dead_tuple_len	dead_tuple_percent	free_space	free_percent
	65 650 688	1 000 000	57 682 158	87,86			0					0				0					216 968		0,33


select * from pgstatindex('orders_order_date');
	version	tree_level	index_size	root_block_no	internal_pages	leaf_pages	empty_pages	deleted_pages	avg_leaf_density	leaf_fragmentation
	4		2			7 086 080	212				6				858			0			0				88,39				0


update orders set order_date='2021-11-01' where id < 500000;

select * from pgstattuple('orders');
	table_len	tuple_count	tuple_len	tuple_percent	dead_tuple_count	dead_tuple_len	dead_tuple_percent	free_space	free_percent
	98 426 880	1 000 000	57 682 158	58,6			499 999				28 843 764		29,3				275 156		0,28

select * from pgstatindex('orders_order_date');
	version	tree_level	index_size	root_block_no	internal_pages	leaf_pages	empty_pages	deleted_pages	avg_leaf_density	leaf_fragmentation
	4		2			10 313 728	212				7				1 117		0			134				67,85				0,18

analyse orders;
vacuum orders;

select * from pgstattuple('orders');
	table_len	tuple_count	tuple_len	tuple_percent	dead_tuple_count	dead_tuple_len	dead_tuple_percent	free_space	free_percent
	98 426 880	1 000 000	57 682 158	58,6			0					0				0					32 404 768	32,92

select * from pgstatindex('orders_order_date');
	version	tree_level	index_size	root_block_no	internal_pages	leaf_pages	empty_pages	deleted_pages	avg_leaf_density	leaf_fragmentation
	4		2			10 313 728	212				7				1 117		0			134				67,85				0,18

vacuum full orders;

select * from pgstattuple('orders');
	table_len	tuple_count	tuple_len	tuple_percent	dead_tuple_count	dead_tuple_len	dead_tuple_percent	free_space	free_percent
	65 650 688	1 000 000	57 682 158	87,86			0					0				0					216 980		0,33

select * from pgstatindex('orders_order_date');
version	tree_level	index_size	root_block_no	internal_pages	leaf_pages	empty_pages	deleted_pages	avg_leaf_density	leaf_fragmentation
4		2			7 077 888	213				6				857			0			0				88,49				0


--Кластеризация
drop table if exists orders;

create table orders (
    id int,
    user_id int,
    order_date date,
    status text,
    some_text text
);

insert into orders(id, user_id, order_date, status, some_text)
select generate_series, (random() * 70), date'2019-01-01' + (random() * 300)::int as order_date
        , (array['returned', 'completed', 'placed', 'shipped'])[(random() * 4)::int]
        , concat_ws(' ', (array['go', 'space', 'sun', 'London'])[(random() * 5)::int]
            , (array['the', 'capital', 'of', 'Great', 'Britain'])[(random() * 6)::int]
            , (array['some', 'another', 'example', 'with', 'words'])[(random() * 6)::int]
            )
from generate_series(1, 1000000);

select * from orders;

show work_mem;
SET work_mem = '64MB';

explain
select * from orders where order_date = '2019-04-26';
	Gather  (cost=1000.00..14551.73 rows=3304 width=34)
	  Workers Planned: 2
	  ->  Parallel Seq Scan on orders  (cost=0.00..13221.33 rows=1377 width=34)
	        Filter: (order_date = '2019-04-26'::date)

drop index if exists order_date_idx;

create index order_date_idx on orders(order_date);

cluster orders using order_date_idx;

analyse orders;

explain
select * from orders where order_date = '2019-04-26';
	Index Scan using order_date_idx on orders  (cost=0.42..88.70 rows=3307 width=34)
	  Index Cond: (order_date = '2019-04-26'::date)

