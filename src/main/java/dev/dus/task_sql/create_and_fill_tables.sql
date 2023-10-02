--Use drop tables for totally clean and fresh multiple runs at the same db 
--To use drop scripts please uncomment drop queries below

DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS request CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS request_item CASCADE;


--DDL scrips to create tables

CREATE TABLE IF NOT EXISTS customer
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	name 				VARCHAR(300) UNIQUE NOT NULL,
	city 				VARCHAR(500) NOT NULL,
	CONSTRAINT pk_customer PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS supplier
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	name 				VARCHAR(300) UNIQUE NOT NULL,
	CONSTRAINT pk_supplier PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS request
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	customer_id 		BIGINT NOT NULL,
	supplier_id 		BIGINT NOT NULL,
	CONSTRAINT pk_request PRIMARY KEY (id),
	CONSTRAINT fk_request_to_customer
		FOREIGN KEY (customer_id)
			REFERENCES Customer (id) ON DELETE CASCADE,
	CONSTRAINT fk_request_to_supplier
		FOREIGN KEY (supplier_id)
			REFERENCES Supplier (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	name 				VARCHAR(300) UNIQUE NOT NULL,
	cost  				DOUBLE PRECISION NOT NULL,
	CONSTRAINT pk_product PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS request_item
(
	id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
	product_id 			BIGINT NOT NULL,
	volume     			DOUBLE PRECISION NOT NULL,
	request_id 			BIGINT NOT NULL,
	CONSTRAINT pk_request_item PRIMARY KEY (id),
	CONSTRAINT fk_request_item_to_product
		FOREIGN KEY (product_id)
			REFERENCES Product (id) ON DELETE CASCADE,
	CONSTRAINT fk_request_item_to_request
		FOREIGN KEY (request_id)
			REFERENCES Request (id) ON DELETE CASCADE
);

--customers data
INSERT INTO customer (name, city)
VALUES	('Lovecraft', 'Innsmouth'),
		('Sherlock Holmes', 'London'),
		('Peter the Great', 'Petersburg'),
		('Nausikaa', 'The Valley of the Wind'),
		('Onizuka', 'Musashino'),
		('Jackie Chan','Beijing'),
		('Caesar','Rome'),
		('Hannibal', 'Karfagen'),
		('Doctor Who','Capitol'),
		('Link', 'Hyrule'),
		('Zelda', 'Hyrule'),
		('Harry Potter', 'London'),
		('Astarion','Baldur''s Gate'),
		('Baal','Baldur''s Gate'),
		('Shigeo Kagiyama','Seasoning City');

--SELECT 	c.id,
--		c.name,
--		c.city
--FROM customer c;

--suppliers data
INSERT INTO supplier (name)
VALUES 	('Hogwar''s Express'),
		('Mugiwara in your face'),
		('Don''t look up'),
		('Moonrise kingdom'),
		('YANGO'),
		('42 sense supplier'),
		('Is java verbose???');
	
--SELECT 	s.id,
--		s.name
--FROM supplier s;

--products data
INSERT INTO product (name, cost)
VALUES 	('magic wand',500.50),
		('viagra',10.10),
		('true english tea', 1000.00),
		('blood', 0.05),
		('big tasty', 100.00),
		('health potion', 75.00),
		('bottle of water', 5.65),
		('Marsellus Wallace Briefcase', 1000000000.00);

--SELECT 	p.id,
--		p.name,
--		p.cost
--FROM product p;

--requests data
INSERT INTO request (customer_id, supplier_id)
VALUES 	(3,1),
		(2,1),
		(1,1),
		(5,4),
		(14,6),
		(13,5),
		(10,3),
		(9,2),
		(11, 6),
		(12, 2),
		(3,2),
		(3,2),
		(3,2),
		(5,5),
		(5,5),
		(11,6),
		(11,3),
		(11,3);
	
--SELECT 	c.name,
--		c.city,
--		s.name
--FROM customer c 
--LEFT JOIN request r ON c.id = r.customer_id
--LEFT JOIN supplier s ON s.id = r.supplier_id;


--request_items data
INSERT INTO request_item (product_id, volume, request_id)
VALUES 	(1, 2.0, 1),
		(2, 10.0, 1),
		(3, 70.0, 2),
		(4, 5.0, 3),
		(4, 5.0, 3),
		(7, 4.0, 4),
		(6, 50.0, 4),
		(4, 50.0, 5),
		(3, 21.0, 6),
		(5, 50.0, 7),
		(5, 50.0, 8),
		(5, 50.0, 9),
		(4, 100.0, 10),
		(3, 10.0, 10),
		(3, 5.0, 10),
		(6, 25.0, 11),
		(6, 35.0, 12),
		(6, 65.0, 13),
		(2, 10.0, 14),
		(2, 10.0, 15),
		(5, 50.0, 16),
		(3, 20.0, 17),
		(3, 20.0, 18);