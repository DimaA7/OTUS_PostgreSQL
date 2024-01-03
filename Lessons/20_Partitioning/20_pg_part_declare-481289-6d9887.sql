create database pg_part_less;
drop database pg_part_less;

-- SELECT current_database();

create schema if not exists no_part;
create schema if not exists by_hash;
create schema if not exists by_list;
create schema if not exists by_range;

show max_connections;

do $$
declare
	clients	constant varchar(63)[] = array['Иван Васильевич', 'Борис Фёдорович', 'Василий Иванович',  'Алексей Михайлович', 'Пётр Алексеевич', 'Александр Павлович', 'Николай Павлович.', 'Александр Николаевич'];
	wrk_date date;
	client_theonly varchar(63);
	client_mark	integer := 0;

	range_fr1 text;
	range_to1 text;
	range_fr2 text;
	range_to2 text;
	range_fr3 text;
	range_to3 text;
	range_fr4 text;
	range_to4 text;	
begin
	drop table if exists no_part.orders cascade;
	drop table if exists by_hash.orders cascade;
	drop table if exists by_list.orders cascade;
	drop table if exists by_range.orders cascade;
	
	-- no parts
	create table no_part.orders
	(
		order_id	bigint generated always as identity primary key,
		client		varchar(63) not null,
		order_date	date not null,
		order_total	numeric(12, 2)
	);

	-- by range
	create table by_range.orders
	(
		order_id	bigint generated always as identity,
		client		varchar(63) not null,
		order_date	date not null,
		order_total	numeric(12, 2),
		primary key (order_id, order_date) -- !!!
	) partition by range (order_date);

	for the_year in 2010 .. 2022
	loop
		
		range_fr1 = the_year::text || '-01-01';
		range_to1 = the_year::text || '-04-01';
		range_fr2 = the_year::text || '-04-01';
		range_to2 = the_year::text || '-07-01';
		range_fr3 = the_year::text || '-07-01';
		range_to3 = the_year::text || '-10-01';
		range_fr4 = the_year::text || '-10-01';	
		range_to4 = (the_year+1)::text || '-01-01';	

		execute format('create table by_range.orders_%s_1 partition of by_range.orders for values from (%s) to (%s);', the_year, quote_literal(range_fr1), quote_literal(range_to1));
	
		execute format('create table by_range.orders_%s_2 partition of by_range.orders for values from (%s) to (%s);', the_year, quote_literal(range_fr2), quote_literal(range_to2));
	
		execute format('create table by_range.orders_%s_3 partition of by_range.orders for values from (%s) to (%s);', the_year, quote_literal(range_fr3), quote_literal(range_to3));

		execute format('create table by_range.orders_%s_4 partition of by_range.orders for values from (%s) to (%s);', the_year, quote_literal(range_fr4), quote_literal(range_to4));

	end loop;

	-- by list
	create table by_list.orders
	(
		order_id	bigint generated always as identity,
		client		varchar(63) not null,
		order_date	date not null,
		order_total	numeric(12, 2),
		primary key (order_id, client) -- !!!
	) partition by list (client);

	foreach client_theonly in array clients
	loop
		execute format('create table by_list.orders_%s partition of by_list.orders for values in (%s);', client_mark, quote_literal(client_theonly));
		client_mark := client_mark + 1;	
	end loop;


	-- by hash
	create table by_hash.orders
	(
		order_id	bigint generated always as identity primary key,
		client		varchar(63) not null,
		order_date	date not null,
		order_total	numeric(12, 2)
	) partition by hash (order_id);

	for i in 0 .. 15
	loop
		execute format('create table by_hash.orders_%s partition of by_hash.orders for values with (modulus 16, remainder %s);', i, i);
	end loop;

	with src_data
	as	(
		select clients[(random()*7)::integer+1] as cl, '2010-01-01'::date + (random() * 365 * 12)::integer as dt, random() * 25000 + 10. as tl
		from generate_series (1, 10000000)
		), 
	ins_np
	as	(
		insert into no_part.orders (client, order_date, order_total)
		select cl, dt, tl from src_data
		),
	ins_br
	as	(
		insert into by_range.orders (client, order_date, order_total)
		select cl, dt, tl from src_data
		),
	ins_bl
	as	(
		insert into by_list.orders (client, order_date, order_total)
		select cl, dt, tl from src_data
		)
	insert into by_hash.orders (client, order_date, order_total)
	select cl, dt, tl from src_data;
end;
$$ language plpgsql;


select * from no_part.orders order by order_id limit 100;
select * from by_list.orders order by order_id limit 100;
select * from by_range.orders order by order_id limit 100;
select * from by_hash.orders order by order_id limit 100;

select * from no_part.orders order by order_id limit 10;
select * from by_list.orders order by order_id limit 10;
select * from by_range.orders order by order_id limit 10;
select * from by_hash.orders order by order_id limit 10;


select count(*) from no_part.orders;
select count(*) from by_range.orders;
select count(*) from by_list.orders;
select count(*) from by_hash.orders;






do $$
declare
	cur cursor for select * from information_schema.tables where table_schema = 'by_hash' and table_name like 'orders_%' order by substring(table_name from '\d+')::int;
	row_count integer;
begin
	for x in cur
	loop
		execute format('select count(*) from %I.%I', x.table_schema, x.table_name) into row_count;
		raise notice 'table_name: %, row_count: %', x.table_name, row_count;
	end loop;	
end;
$$ language plpgsql; -- распределение записей в партициях по hash


explain analyze
select * from by_list.orders where order_id in (10, 20, 1) and client = 'Василий Иванович' order by order_id;
-- Execution Time: 0.074 ms

Index Scan using orders_2_pkey on orders_2 orders  (cost=0.43..6.71 rows=3 width=52) (actual time=0.026..0.030 rows=1 loops=1)
  Index Cond: ((order_id = ANY ('{10,20,1}'::bigint[])) AND ((client)::text = 'Василий Иванович'::text))
Planning Time: 0.128 ms
Execution Time: 0.044 ms


explain analyze
select * from by_list.orders where order_id in (10, 20, 1) order by order_id;
-- Execution Time: 1049.781 ms


Merge Append  (cost=3.54..54.16 rows=24 width=53) (actual time=0.098..0.104 rows=3 loops=1)
  Sort Key: orders.order_id
  ->  Index Scan using orders_7_pkey on orders_7 orders_1  (cost=0.42..6.69 rows=3 width=60) (actual time=0.024..0.025 rows=0 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_5_pkey on orders_5 orders_2  (cost=0.43..6.70 rows=3 width=56) (actual time=0.010..0.010 rows=0 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_3_pkey on orders_3  (cost=0.43..6.70 rows=3 width=56) (actual time=0.009..0.009 rows=0 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_1_pkey on orders_1 orders_4  (cost=0.43..6.70 rows=3 width=50) (actual time=0.012..0.013 rows=1 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_2_pkey on orders_2 orders_5  (cost=0.43..6.70 rows=3 width=52) (actual time=0.009..0.011 rows=1 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_0_pkey on orders_0 orders_6  (cost=0.42..6.69 rows=3 width=50) (actual time=0.009..0.010 rows=0 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_6_pkey on orders_6 orders_7  (cost=0.43..6.70 rows=3 width=53) (actual time=0.010..0.011 rows=0 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
  ->  Index Scan using orders_4_pkey on orders_4 orders_8  (cost=0.43..6.70 rows=3 width=50) (actual time=0.011..0.012 rows=1 loops=1)
        Index Cond: (order_id = ANY ('{10,20,1}'::bigint[]))
Planning Time: 0.209 ms
Execution Time: 0.135 ms

explain analyze
select * from by_list.orders where client = 'Василий Иванович' order by order_id;

Index Scan using orders_2_pkey on orders_2 orders  (cost=0.43..51661.27 rows=1429170 width=52) (actual time=0.024..19468.888 rows=1429170 loops=1)
  Index Cond: ((client)::text = 'Василий Иванович'::text)
Planning Time: 0.104 ms
Execution Time: 19512.877 ms