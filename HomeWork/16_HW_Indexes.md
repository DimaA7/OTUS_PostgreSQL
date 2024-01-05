**ДЗ#16, индексы**

# Создать индекс к какой-либо из таблиц вашей БД
# Прислать текстом результат команды explain, в которой используется данный индекс
 ## Использую тестовую БД sakila, предварительно удалив все индексы кроме индексов на первичные ключи.
		Создаю индекс на поле rental_rate таблицы film для запроса:
			explain (analyse, costs, verbose, buffers, format json)
			select * from film f 
			order by f.rental_rate;
			
			create index idx_film_rental_rate on film using btree (rental_rate);
			drop index idx_film_rental_rate_;
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

 ## Использую тестовую БД bookings (big) от PostgresPro
		Создаю индекс на поле departure_airport таблицы flights для запроса:
			create index idx_flights_departure_airport_btree on flights using btree (departure_airport);
			drop index idx_flights_departure_airport_btree;

		План запросат без индекса:
			Seq Scan on flights f  (cost=0.00..5309.84 rows=18915 width=63)
			Filter: (departure_airport = 'SVO'::bpchar)

		План запроса с индексом:
			Bitmap Heap Scan on flights f  (cost=165.59..3026.02 rows=18915 width=63)
			Recheck Cond: (departure_airport = 'SVO'::bpchar)
			->  Bitmap Index Scan on idx_flights_departure_airport_btree  (cost=0.00..160.86 rows=18915 width=0)
					Index Cond: (departure_airport = 'SVO'::bpchar)

# Реализовать индекс для полнотекстового поиска
  ## Создание полнотекстового индекса на БД demo.bookings (big) от PostgresPro
		Создаю колонку с данными для полнотекстового поля	
		```
			alter table tickets ADD COLUMN passenger_fts tsvector;
			alter table tickets drop COLUMN passenger_fts;
		```
		Заполняю колонку для полнотекстового поиска фильма по имени пассажира
				update tickets 
				set passenger_fts = to_tsvector('english'::regconfig, passenger_name);
		Апдейт занял примеро 2 минуты
		Выполняю запрос без индекса
			explain 
			select * from tickets where passenger_fts @@ to_tsquery('IVANOV' && 'vladimir');
			
				Gather  (cost=1000.00..465053.61 rows=2170 width=140)
				Workers Planned: 2
				->  Parallel Seq Scan on tickets  (cost=0.00..463836.61 rows=904 width=140)
						Filter: (passenger_fts @@ to_tsquery('IVANOV & vladimir'::text))
				JIT:
				Functions: 2
				Options: Inlining false, Optimization false, Expressions true, Deforming true

		Создаю полнотекстовый индекс
				CREATE INDEX idx_tickets_passenger_fts_gin ON tickets USING gin(passenger_fts);
					drop index idx_tickets_passenger_fts_gin;
			Индекс создался достаточно быстро

		Выполняю запрос с использованием индекса

				```
				explain
				select * from tickets where passenger_fts @@ to_tsquery('IVANOV' && 'vladimir');
				```	
		План запроса:
				Bitmap Heap Scan on tickets  (cost=29.17..2941.59 rows=2170 width=140)
				Recheck Cond: (passenger_fts @@ to_tsquery('IVANOV & vladimir'::text))
				->  Bitmap Index Scan on idx_tickets_passenger_fts_gin  (cost=0.00..28.63 rows=2170 width=0)
						Index Cond: (passenger_fts @@ to_tsquery('IVANOV & vladimir'::text))
		Выигрыш очевиден. Стоимость уменьшидась с 465053 до 2941.
# Реализовать индекс на часть таблицы или индекс на поле с функцией
	Создаю индекс по таблице flights для оптимизации запросов по прибытию только в аэропорт Домодедово.
			```
			CREATE INDEX idx_flights_arrival_btree ON flights USING btree(arrival_airport) 
					where arrival_airport = 'DME';	
			drop index idx_flights_arrival_btree;
			```
		План запроса всех прибытий в Домодедово
		Запрос:
			```
			explain
			select * from flights fl
			where fl.arrival_airport = 'DME';
			```
		План запроса:
			Bitmap Heap Scan on flights fl  (cost=131.37..3015.10 rows=20778 width=63) 
			Recheck Cond: (arrival_airport = 'DME'::bpchar) `
			->  Bitmap Index Scan on idx_flights_arrival_btree  (cost=0.00..126.18 rows=20778 width=0)
			
		План запроса по вылету из Шереметьево
		Запрос:
			```
			explain
			select * from flights fl
			where fl.arrival_airport = 'SVO'
			```
		План запроса:
			Seq Scan on flights fl  (cost=0.00..5309.84 rows=19095 width=63)
			Filter: (arrival_airport = 'SVO'::bpchar)

		Поиск записей о прибытии в Шереметьево выполняется путем последовательного сканирования со стоимостью 5309, а в Домодедово по индексу со стоимостью 3015, что быстрее примерно в 1,7 раза.

# Создать индекс на несколько полей

	Создаю индекс для поиска записей по аэропорту Домодедово и дате вылета для реализации табло вылета.
		CREATE INDEX idx_flights_arrival2_btree ON flights USING btree(arrival_airport, scheduled_arrival)
		where arrival_airport = 'DME';
		drop index idx_flights_arrival2_btree;

	План запроса без использования индекса по двум полям:
		Запрос:
			explain 
			select * from flights fl
			where fl.arrival_airport = 'DME'
			and fl.scheduled_arrival >= '2017-08-15'
			and fl.scheduled_arrival <= '2017-08-16'
			order by fl.scheduled_arrival desc;
		План запроса:
			Gather Merge  (cost=5836.68..5840.36 rows=32 width=63)
			Workers Planned: 1
			->  Sort  (cost=4836.67..4836.75 rows=32 width=63)
					Sort Key: scheduled_arrival DESC
					->  Parallel Seq Scan on flights fl  (cost=0.00..4835.87 rows=32 width=63)
						Filter: ((scheduled_arrival >= '2017-08-15 00:00:00+03'::timestamp with time zone) AND (scheduled_arrival <= '2017-08-16 00:00:00+03'::timestamp with time zone) AND (arrival_airport = 'DME'::bpchar))
	
	План запроса с использованием индекса по двум полям:
		Запрос:
			explain 
			select * from flights fl
			where fl.arrival_airport = 'DME'
			and fl.scheduled_arrival >= '2017-08-15'
			and fl.scheduled_arrival <= '2017-08-16'
			order by fl.scheduled_arrival desc;
		План запроса:
			Index Scan Backward using idx_flights_arrival2_btree on flights fl  (cost=0.29..352.50 rows=55 width=63)  
				Index Cond: ((scheduled_arrival >= '2017-08-15 00:00:00+03'::timestamp with time zone) AND (scheduled_arrival <= '2017-08-16 00:00:00+03'::timestamp with time zone))
		
		Задействованы индексы по обоим полям. Поэтому результат гораздо лучше. Стоимость уменьшилась с 5840 до 352.

# Написать комментарии к каждому из индексов
Комментарии есть по тексту
# Описать что и как делали и с какими проблемами столкнулись
Была проблема наполнения БД. Решил использовать готовые БД sakila и demo со схемой booking от PostgresPro.ru.
Освоил загрузку БД на виртуальную машину в Яндекс облаке.