**Домашнее задание Триггеры, поддержка заполнения витрин**
Цель:
Создать триггер для поддержки витрины в актуальном состоянии.

Скрипт и развернутое описание задачи – в ЛК (файл hw_triggers.sql) или по ссылке: https://disk.yandex.ru/d/l70AvknAepIJXQ
В БД создана структура, описывающая товары (таблица goods) и продажи (таблица sales).
Есть запрос для генерации отчета – сумма продаж по каждому товару.
БД была денормализована, создана таблица (витрина), структура которой повторяет структуру отчета.
Создать триггер на таблице продаж, для поддержки данных в витрине в актуальном состоянии (вычисляющий при каждой продаже сумму и записывающий её в витрину)
Подсказка: не забыть, что кроме INSERT есть еще UPDATE и DELETE

# Создание схемы

DROP SCHEMA IF EXISTS pract_functions CASCADE;
CREATE SCHEMA pract_functions;

SET search_path = pract_functions, publ

-- товары:
CREATE TABLE goods
(
    goods_id    integer PRIMARY KEY,
    good_name   varchar(63) NOT NULL,
    good_price  numeric(12, 2) NOT NULL CHECK (good_price > 0.0)
);
INSERT INTO goods (goods_id, good_name, good_price)
VALUES 	(1, 'Спички хозайственные', .50),
		(2, 'Автомобиль Ferrari FXX K', 185000000.01);

-- Продажи
CREATE TABLE sales
(
    sales_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    good_id     integer REFERENCES goods (goods_id),
    sales_time  timestamp with time zone DEFAULT now(),
    sales_qty   integer CHECK (sales_qty > 0)
);

INSERT INTO sales (good_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);

-- отчет:
SELECT G.good_name, sum(G.good_price * S.sales_qty)
FROM goods G
INNER JOIN sales S ON S.good_id = G.goods_id
GROUP BY G.good_name;

-- с увеличением объёма данных отчет стал создаваться медленно
-- Принято решение денормализовать БД, создать таблицу
CREATE TABLE good_sum_mart
(
	good_name   varchar(63) NOT NULL,
	sum_sale	numeric(16, 2)NOT NULL
);

# Создать триггер (на таблице sales) для поддержки.
  -- Подсказка: не забыть, что кроме INSERT есть еще UPDATE и DELETE


# Функция 

CREATE OR REPLACE FUNCTION update_mart() RETURNS TRIGGER AS $$

DECLARE
	q int;
	id int;
	-- sum numeric(16, 2);
BEGIN
	IF (TG_OP = 'INSERT') THEN
		q = NEW.sales_qty;
		id = NEW.good_id;
	ELSIF (TG_OP = 'UPDATE' and NEW.sales_qty != OLD.sales_qty) THEN
		q = NEW.sales_qty - OLD.sales_qty;
	 	id = OLD.good_id;
	ELSIF (TG_OP = 'DELETE') THEN
		q = -1 * OLD.sales_qty;
		id = OLD.good_id;
	END IF;
	INSERT INTO good_sum_mart
	SELECT good_name, good_price * q
	FROM goods WHERE goods_id = id;
	
	RETURN null;
END;
$$ LANGUAGE plpgsql;


 ## Триггер update_mart будет срабатывать при изменении таблицы sales. Будет запускать функцию update_mart(), которая в зависимости от типа операции будет обновлять витрину.
        CREATE TRIGGER tr
        AFTER INSERT OR UPDATE OR DELETE ON sales
        FOR EACH ROW EXECUTE FUNCTION update_mart();


 ## Получение значений таблицы
        SELECT G.good_name, sum(G.good_price * S.sales_qty)
        FROM goods G
        JOIN sales S ON S.good_id = G.goods_id

                good_name         |     sum
        --------------------------+--------------
        Автомобиль Ferrari FXX K | 185000000.01
        Спички хозайственные     |        65.50
        (2 rows)

 ## Проверка на добавление данных
        
        INSERT INTO sales (good_id, sales_qty) VALUES (2, 6);

        functions=# select good_name, sum(sum_sale)
        from good_sum_mart
        group by good_name;
                good_name         |      sum
        --------------------------+---------------
        Автомобиль Ferrari FXX K | 1110000000.06
        (1 row)

 ## Проверка на изменение
        functions=# update sales
        set sales_qty = 3
        where sales_id = 7;
        UPDATE 1
        functions=# select good_name, sum(sum_sale)
        from good_sum_mart
        group by good_name;
                good_name         |     sum
        --------------------------+--------------
        Автомобиль Ferrari FXX K | 925000000.05
        Спички хозайственные     |         0.00
        (2 rows)

## Проверка на удаление

        functions=# delete from sales
        where sales_id = 7;
        DELETE 1
        functions=# select good_name, sum(sum_sale)
        from good_sum_mart
        group by good_name;
                good_name         |     sum
        --------------------------+--------------
        Автомобиль Ferrari FXX K | 370000000.02
        Спички хозайственные     |         0.00
        (2 rows)

# -- Чем такая схема (витрина+триггер) предпочтительнее отчета, создаваемого "по требованию" (кроме производительности)?
-- Подсказка: В реальной жизни возможны изменения цен.
    
    Цена определяется на момент продажи, а не по последнему значению.
