**ДЗ#16, индексы**
# Создать индекс к какой-либо из таблиц вашей БД
	Использую тестовую БД sakila, предварительно удалив все индексы кроме индексов на первичные ключи.
	Создаю индекс на поле rental_rate таблицы film для запроса:
		explain (analyse, costs, verbose, buffers, format json)
		select * from film f 
		order by f.rental_rate;
		
		create index idx_film_rental_rate on film(rental_rate);
		drop index idx_film_rental_rate_;
# Прислать текстом результат команды explain, в которой используется данный индекс
	План запроса до построения индекса: 
		Sort  (cost=114.83..117.33 rows=1000 width=390) (actual time=0.579..0.620 rows=1000 loops=1)
		  Sort Key: rental_rate
		  Sort Method: quicksort  Memory: 462kB
		  Buffers: shared hit=55
		  ->  Seq Scan on film f  (cost=0.00..65.00 rows=1000 width=390) (actual time=0.009..0.111 rows=1000 loops=1)
		        Buffers: shared hit=55
		Planning Time: 0.057 ms
		Execution Time: 0.672 ms

	План запроса после создания индекса:
		Index Scan using idx_film_rental_rate on film f  (cost=0.28..80.72 rows=1000 width=390) (actual time=0.011..0.271 rows=1000 loops=1)
		  Buffers: shared hit=169
		Planning:
		  Buffers: shared hit=17
		Planning Time: 0.143 ms
		Execution Time: 0.321 ms
 	Как видно время работы запроса уменьшилось.

# Реализовать индекс для полнотекстового поиска

	## Создание  полнотекстового индекса вместе с B-Tree индексом на таблице film
	Добавляется расширение pg_trgm 
	CREATE EXTENSION pg_trgm;
	drop EXTENSION pg_trgm;

	Создаю колонку с данными для полнотекстового поля
	
	alter table film ADD COLUMN fulltextsh tsvector;
	
	alter table film drop COLUMN fulltextsh;

	
	Заполняем колонку для полнотекстового поиска фильма по названию и описанию
	update film 
	set fulltextsh = to_tsvector('english'::regconfig, title) || to_tsvector('english'::regconfig, description);

	select * from film;
	
	Создаем индекс для полнотекстового поиска и фильтра по рейтингу
	
	Создаем B3-индекс для фильтрации фильмов по рейтингу
	CREATE INDEX idx_film_rental_rate_btree ON film USING btree (rental_rate);
    drop index idx_film_rental_rate_btree;
     
	Создаем индекс для полнотекстового поиска и фильтра по названию и описанию
	CREATE INDEX idx_film_fulltextsh_gin ON film USING gin(fulltextsh);
	drop index idx_film_fulltextsh_gin;

	Выполняем запрос с полнотекстовым индексом и фильтром по рейтингу
	
	explain
	select * from film where fulltext @@ to_tsquery('drama')
	and rental_rate > 4.5;

	analyze film;

			select * from film;

		До индексации
Seq Scan on film  (cost=0.00..420.00 rows=36 width=567)
  Filter: ((rental_rate > 4.5) AND (fulltext @@ to_tsquery('drama'::text)))
		
  Index Scan using idx_film_rental_rate_btree on film  (cost=0.28..251.40 rows=36 width=567)
  Index Cond: (rental_rate > 4.5)
  Filter: (fulltext @@ to_tsquery('drama'::text))
  
  
Bitmap Heap Scan on film  (cost=5.00..249.04 rows=36 width=567)
  Recheck Cond: (rental_rate > 4.5)
  Filter: (fulltext @@ to_tsquery('drama'::text))
  ->  Bitmap Index Scan on idx_film_rental_rate_btree  (cost=0.00..5.00 rows=336 width=0)
        Index Cond: (rental_rate > 4.5)
		
# Реализовать индекс на часть таблицы или индекс на поле с функцией

# Создать индекс на несколько полей
лик н

# Написать комментарии к каждому из индексов


# Описать что и как делали и с какими проблемами столкнулись



