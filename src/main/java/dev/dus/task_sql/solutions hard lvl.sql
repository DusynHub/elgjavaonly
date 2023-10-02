-- задача 3.1.1
--Вывести общим списком всех заказчиков и поставщиков. Колонки id, имя и тип, где тип
--«Заказчик» или «Поставщик», в зависимости от того, из какой таблицы взята запись.
--Отфильтровать и вывести те записи, по которым в заявках в общей сложности заказ
--больше 5000.

SELECT 	c.id 						AS "ID"
		, c.name      				AS "Название"
		, 'Заказчик'  				AS "Тип записи"
FROM customer c
LEFT JOIN  request r 		ON	c.id  = r.customer_id
LEFT JOIN  request_item ri  ON	r.id  = ri.request_id 
LEFT JOIN  product p 		ON	p.id  = ri.product_id
GROUP BY c.id, c.name, r.id
HAVING sum(p.COST * ri.volume) > 5000.0
	UNION ALL 
SELECT 	s.id 						AS "ID"
		, s.name      				AS "Название"
		, 'Поставщик'  				AS "Тип записи"
FROM supplier s
LEFT JOIN  request r 		ON	s.id  = r.supplier_id
LEFT JOIN  request_item ri  ON	r.id  = ri.request_id 
LEFT JOIN  product p 		ON	p.id  = ri.product_id
GROUP BY s.id, s.name, r.id
HAVING sum(p.COST * ri.volume) > 5000.0;

--Результат выборки по задаче 3.1.1
--
-- Пояснение: Оставил только тех заказчиков или поставщиков,
-- которые имели хотя бы одну заявку с общей суммой заказов более 5000
--
--ID|Название             |Тип записи|
----+---------------------+----------+
-- 2|Sherlock Holmes      |Заказчик  |
--13|Astarion             |Заказчик  |
--11|Zelda                |Заказчик  |
--11|Zelda                |Заказчик  |
--12|Harry Potter         |Заказчик  |
-- 3|Don't look up        |Поставщик |
-- 1|Hogwar's Express     |Поставщик |
-- 5|YANGO                |Поставщик |
-- 2|Mugiwara in your face|Поставщик |
-- 3|Don't look up        |Поставщик |

--#########################################################################################################################################


-- задача 3.1.2
--Вывести процентную долю заказов каждого товара по всем заявкам, сгруппировать по
--городу.

--Вариант №1 решения задачи 3.1.2
--долю заказов каждого товара по всем заявкам --> количество запросов товара по всем заявка / общее количество заявок
--группировка по городам

WITH distict_prod_requests AS (
		SELECT 	r.id 																	AS request_id,
				c.name																	AS customer_name,
				c.city																	AS city,
				p.name 																	AS prod_name,
				CAST (count(p.name) OVER (PARTITION BY p.name ) AS DOUBLE PRECISION) 	AS total_product_requests,
				(SELECT count(r.id) FROM request r) AS total_requests,
				((CAST (count(r.id) OVER (PARTITION BY p.name ) AS DOUBLE PRECISION)/
					(SELECT count(r.id) FROM request r) )*100.0)::numeric(5,2) 			AS percentage
		FROM product p 
		LEFT JOIN request_item ri ON p.id = ri.product_id
		LEFT JOIN request r ON	ri.request_id = r.id
		LEFT JOIN customer c ON	c.id  = r.customer_id
		GROUP BY r.id, c.name, c.city, p.name
		ORDER BY request_id
)
SELECT 	city 			AS "Город",
		prod_name		AS "Продукт",
		percentage		AS "Процентная доля заказов"
FROM distict_prod_requests
GROUP BY city,
		prod_name,
		percentage
ORDER BY city;

--Результат выборки по варианту №1
--
--Город        |Продукт                    |Процентная доля заказов|
---------------+---------------------------+-----------------------+
--Baldur's Gate|blood                      |                  16.67|
--Baldur's Gate|true english tea           |                  27.78|
--Capitol      |big tasty                  |                  22.22|
--Hyrule       |true english tea           |                  27.78|
--Hyrule       |big tasty                  |                  22.22|
--Innsmouth    |blood                      |                  16.67|
--London       |true english tea           |                  27.78|
--London       |blood                      |                  16.67|
--Musashino    |viagra                     |                  16.67|
--Musashino    |health potion              |                  22.22|
--Musashino    |bottle of water            |                   5.56|
--Petersburg   |magic wand                 |                   5.56|
--Petersburg   |health potion              |                  22.22|
--Petersburg   |viagra                     |                  16.67|
--             |Marsellus Wallace Briefcase|                   0.00|


--#########################################################################################################################################


--Вариант №2 решения задачи 3.1.2
--
--долю заказов каждого товара по всем заявкам --> количество запросов товара по всем заявкам по городу / общее количество заявок по городу
--группировка по городам
--Пояснение:
--в городе 'Innsmouth' в 100% заявок присутствовал запрос товара 'blood'
--товар 'Marsellus Wallace Briefcase' не был запрошен ни разу ни в одной заявке

WITH 	requests_by_city as(
			SELECT 	c.city 							AS city,
					count(r.id)::double precision 	AS total_requests_by_city
			FROM request r 
			INNER JOIN customer c 		ON r.customer_id = c.id
			GROUP BY c.city 
),
		product_req_by_city AS (
			SELECT 	c.city							AS city,
					r.id 							AS request_id,
					p.name 							AS prod_name
			FROM product p 
			LEFT JOIN request_item ri 	ON  p.id = ri.product_id
			LEFT JOIN request r 		ON	ri.request_id = r.id
			LEFT JOIN customer c 		ON	c.id  = r.customer_id
			GROUP BY r.id, c.city, p.name
),
		count_product_req_by_city AS (
			SELECT 	prod_name
					, city 
					, count(prod_name)::double precision AS count_product_req_by_city
			FROM product_req_by_city
			GROUP BY prod_name, city
) 
SELECT 	cprbc.city				AS "Город"
		, prod_name 			AS "Название продукта"
		, CASE 
			WHEN total_requests_by_city IS NULL THEN 0.00 
			ELSE (count_product_req_by_city*100.0/total_requests_by_city)::numeric(5,2) 
		END 					AS "Процентная доля заказов"
FROM count_product_req_by_city cprbc
LEFT JOIN requests_by_city rbc 			ON cprbc.city = rbc.city
ORDER BY cprbc.city;

--Результат выборки по варианту №2
--
--Город        |Название продукта          |Процентная доля заказов|
---------------+---------------------------+-----------------------+
--Baldur's Gate|true english tea           |                  50.00|
--Baldur's Gate|blood                      |                  50.00|
--Capitol      |big tasty                  |                 100.00|
--Hyrule       |big tasty                  |                  60.00|
--Hyrule       |true english tea           |                  40.00|
--Innsmouth    |blood                      |                 100.00|
--London       |blood                      |                  50.00|
--London       |true english tea           |                 100.00|
--Musashino    |viagra                     |                  66.67|
--Musashino    |bottle of water            |                  33.33|
--Musashino    |health potion              |                  33.33|
--Petersburg   |viagra                     |                  25.00|
--Petersburg   |magic wand                 |                  25.00|
--Petersburg   |health potion              |                  75.00|
--             |Marsellus Wallace Briefcase|                   0.00|



--#########################################################################################################################################

--задача 3.1.3
--Вывести процентную долю заказов каждого товара по заявке в среднем.

WITH percentage_by_requests 		AS (
		SELECT 	p.id				AS p_id
				, p.name			AS p_name 
				, ri.id 			AS ri_id
				, r.id 				AS r_id
				, count(ri.id) OVER (PARTITION BY r.id) AS ri_in_req_count
				, count(ri.id) OVER (PARTITION BY r.id, p.name) prod_ri_in_req_count 
				, CASE 
					WHEN count(ri.id) OVER (PARTITION BY r.id) = 0 THEN 0.0
					ELSE (count(ri.id) OVER (PARTITION BY r.id, p.name)*100.0 / count(ri.id) OVER (PARTITION BY r.id))::NUMERIC (5,2)
				END 				AS percentage
		FROM product p 
		LEFT JOIN request_item ri  		ON p.id = ri.product_id 
		LEFT JOIN request r 			ON r.id = ri.request_id
),
	percentage_prod_by_requests 	AS (
		SELECT 	r_id
				, p_name
				, percentage
		FROM percentage_by_requests
		GROUP BY r_id, p_name, percentage
) SELECT 	p_name 							AS "Название продукта" 
			, avg(percentage)::NUMERIC(5,2) AS "Средняя процентная доля"
FROM percentage_prod_by_requests
GROUP BY p_name;

--результат выборки по задаче 3.1.3
--
--Название продукта          |Средняя процентная доля|
-----------------------------+-----------------------+
--true english tea           |                  93.33|
--viagra                     |                  83.33|
--health potion              |                  87.50|
--Marsellus Wallace Briefcase|                   0.00|
--blood                      |                  77.78|
--big tasty                  |                 100.00|
--bottle of water            |                  50.00|
--magic wand                 |                  50.00|
