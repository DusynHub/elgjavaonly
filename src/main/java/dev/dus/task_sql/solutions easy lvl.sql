-- задача 2.1.1
--Вывести id всех заявок, в которых суммарная стоимость заказа превышает 1000.

SELECT 	r.id AS request_id
FROM customer c 
INNER JOIN request r ON c.id = r.customer_id
INNER JOIN supplier s ON s.id = r.supplier_id
INNER JOIN request_item ri ON r.id = ri.request_id
INNER JOIN product p ON ri.product_id = p.id
WHERE p.COST * ri.volume > 1000;

--Результат выборки по задаче 2.1.1
--
--request_id|
------------+
--         1|
--         2|
--         4|
--         6|
--         7|
--         8|
--         9|
--        10|
--        10|
--        11|
--        12|
--        13|
--        16|
--        17|
--        18|
--######################################################################################################################

-- задача 2.1.2
--Нужно определить, какой товар каждый из заказчиков заказывал по всем своим заявкам
--чаще всего. Вывести в таблицу: id заказчика, имя заказчика, название товара, количество
--раз (не сумма количества товаров).

WITH requests_view AS (
	SELECT 	c.id 							AS customer_id,
			c.name							AS customer_name,
			c.city,
			p.name							AS product_name,
			count(p.name) 					AS product_requests,
			DENSE_RANK() OVER (
				PARTITION BY c.name
				ORDER BY count(p.name) DESC  
			) 								AS dense_rank_res
	FROM customer c 
	LEFT  JOIN request r ON c.id = r.customer_id
	LEFT JOIN supplier s ON s.id = r.supplier_id
	LEFT JOIN request_item ri ON r.id = ri.request_id
	LEFT JOIN product p ON ri.product_id = p.id
	GROUP BY c.id, c.name, c.city, p.name
	ORDER BY customer_name ASC ,product_requests DESC
)
SELECT 	customer_id				AS "ID заказчика"
		, customer_name 		AS "Имя заказчика"
		, CASE
			WHEN product_name IS NULL THEN '----NO REQUESTS'
			ELSE product_name
		END						AS "Продукт"
		, product_requests 		AS "Количество заказов товара"
FROM requests_view
WHERE dense_rank_res = 1;

--Результат выборки по задаче 2.1.2
--
--ID заказчика|Имя заказчика  |Продукт         |Количество заказов товара|
--------------+---------------+----------------+-------------------------+
--          13|Astarion       |true english tea|                        1|
--          14|Baal           |blood           |                        1|
--           7|Caesar         |----NO REQUESTS |                        0|
--           9|Doctor Who     |big tasty       |                        1|
--           8|Hannibal       |----NO REQUESTS |                        0|
--          12|Harry Potter   |true english tea|                        2|
--           6|Jackie Chan    |----NO REQUESTS |                        0|
--          10|Link           |big tasty       |                        1|
--           1|Lovecraft      |blood           |                        2|
--           4|Nausikaa       |----NO REQUESTS |                        0|
--           5|Onizuka        |viagra          |                        2|
--           3|Peter the Great|health potion   |                        3|
--           2|Sherlock Holmes|true english tea|                        1|
--          15|Shigeo Kagiyama|----NO REQUESTS |                        0|
--          11|Zelda          |true english tea|                        2|
--          11|Zelda          |big tasty       |                        2|

--######################################################################################################################

-- задача 2.1.3
--Вывести имя заказчика, который принес больше всего прибыли по каждому из постав-
--щиков. Результирующая по запросу таблица: id и имя поставщика в формате «[ID: 1]
--Иванов», id и имя заказчика в таком же формате.

WITH requests_view AS (
			SELECT 	
			s.id 											AS supplier_id,
			s.name 											AS supplier_name,
			c.id											AS customer_id,
			c.name											AS customer_name,
			sum(p.COST * ri.volume)  						AS total_revenue_by_customer,
			DENSE_RANK() OVER (
					PARTITION BY s.id
					ORDER BY sum(p.COST * ri.volume) DESC)  AS dense_rank_res
	FROM supplier s
	LEFT JOIN request r ON s.id = r.supplier_id
	LEFT JOIN customer c ON c.id = r.customer_id
	LEFT JOIN request_item ri ON r.id = ri.request_id
	LEFT JOIN product p ON ri.product_id = p.id
	GROUP BY s.id, s.name, c.id, c.name
	ORDER BY supplier_name ASC, dense_rank_res ASC
) 
SELECT 		supplier_id 		AS "ID"
			, supplier_name 	AS "Поставщик"
			, customer_id		AS "ID заказчика"	
			, CASE 
				WHEN customer_name IS NULL THEN '----NO REQUESTS'
				ELSE customer_name
			END		
			AS "Заказчик, принесший макс прибыль"
FROM requests_view
WHERE dense_rank_res = 1;

--Результат выборки по задаче 2.1.3
--
--ID|Поставщик            |ID заказчика|Заказчик, принесший макс прибыль|
----+---------------------+------------+--------------------------------+
-- 6|42 sense supplier    |          11|Zelda                           |
-- 3|Don't look up        |          11|Zelda                           |
-- 1|Hogwar's Express     |           2|Sherlock Holmes                 |
-- 7|Is java verbose???   |            |----NO REQUESTS                 |
-- 4|Moonrise kingdom     |           5|Onizuka                         |
-- 2|Mugiwara in your face|          12|Harry Potter                    |
-- 5|YANGO                |          13|Astarion                        |



