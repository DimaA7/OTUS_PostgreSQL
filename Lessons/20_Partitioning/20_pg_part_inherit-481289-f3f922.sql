drop table if exists table0 cascade;

create table table0 (
	id bigserial primary key,
	name text,
	create_date date,
	some_sum numeric
);

create table table0_2020_03 (like table0 including all) inherits (table0);
alter table table0_2020_03 add check (create_date between date'2020-03-01' and date'2020-04-01' - 1);

create table table0_2020_01 () inherits (table0);
alter table table0_2020_01 add check (create_date between date'2020-01-01' and date'2020-02-01' - 1);

create table table0_2020_02 (check (create_date between date'2020-02-01' and date'2020-03-01' - 1)) inherits (table0);

create or replace function table0_select_part() returns trigger as $$
begin
    if new.create_date between date'2020-01-01' and date'2020-02-01' - 1 then
        insert into table0_2020_01 values (new.*);
    elsif new.create_date between date'2020-02-01' and date'2020-03-01' - 1 then
        insert into table0_2020_02 values (new.*);
    else
        raise exception 'this date not in your partitions. add partition';
    end if;
    return null;
end;
$$ language plpgsql;

create trigger check_date_table0
before insert on table0
for each row execute procedure table0_select_part();

insert into table0 values (1, 'some_text', date'2020-01-02', 100.0);

select * from table0_2020_01;
select * from table0;

explain analyze 
select * from table0 where create_date = '2020-01-02';

insert into table0 values (1, 'some_text', date'2020-05-02', 100.0); -- Ошибка: this date not in your partitions. add partition

update table0 set create_date = date'2020-02-02' where id = 1; -- Перенос данных путем обновления из секции в секцию не получится

insert into table0 (id, create_date) select generate_series, date'2020-02-01' from generate_series(1, 10000);

select pg_size_pretty(pg_table_size('table0')) as main,
       pg_size_pretty(pg_table_size('table0_2020_01')) as january,
       pg_size_pretty(pg_table_size('table0_2020_02')) as february,
       pg_size_pretty(pg_table_size('table0_2020_03')) as march;

-- set enable_partition_pruning = off;
      
set enable_partition_pruning = on;      

explain analyze
select * from table0 where create_date < date'2020-02-01';


explain analyze
select * from table0 where create_date  between date'2020-01-15' and date'2020-02-15';

Append  (cost=0.00..276.72 rows=10005 width=76) (actual time=0.011..1.638 rows=10000 loops=1)
  ->  Seq Scan on table0 table0_1  (cost=0.00..0.00 rows=1 width=76) (actual time=0.002..0.002 rows=0 loops=1)
        Filter: ((create_date >= '2020-01-15'::date) AND (create_date <= '2020-02-15'::date))
  ->  Seq Scan on table0_2020_01 table0_2  (cost=0.00..21.70 rows=4 width=76) (actual time=0.004..0.004 rows=0 loops=1)
        Filter: ((create_date >= '2020-01-15'::date) AND (create_date <= '2020-02-15'::date))
        Rows Removed by Filter: 1
  ->  Seq Scan on table0_2020_02 table0_3  (cost=0.00..205.00 rows=10000 width=76) (actual time=0.004..1.054 rows=10000 loops=1)
        Filter: ((create_date >= '2020-01-15'::date) AND (create_date <= '2020-02-15'::date))
Planning Time: 0.168 ms
Execution Time: 1.982 ms



