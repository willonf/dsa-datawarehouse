INSERT INTO dim_date (date, year, month, day, is_weekend)
SELECT d::DATE,
       EXTRACT(YEAR FROM d)::INT,
       EXTRACT(MONTH FROM d)::INT,
       EXTRACT(DAY FROM d)::INT,
       CASE
           WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE
           ELSE FALSE
           END AS is_weekend
FROM generate_series('2005-05-01'::DATE, '2025-07-20'::DATE, '1 day'::INTERVAL) d;

INSERT INTO dim_customer (name, address, district, city, country)
SELECT concat(c.first_name, ' ', c.last_name),
       concat(a.address, ' ', a.address2),
       a.district,
       ci.city,
       co.country
FROM public.customer c
         INNER JOIN public.address a on a.address_id = C.address_id
         INNER JOIN public.city ci on ci.city_id = a.city_id
         INNER JOIN public.country co on co.country_id = ci.country_id;

INSERT INTO dim_store (address, district, city, country)
SELECT concat(a.address, ' ', a.address2),
       a.district,
       ci.city,
       co.country
FROM public.store s
         INNER JOIN public.address a on a.address_id = s.address_id
         INNER JOIN public.city ci on ci.city_id = a.city_id
         INNER JOIN public.country co on co.country_id = ci.country_id;

INSERT INTO dim_staff (name, address, district, city, country)
SELECT concat(s.first_name, ' ', s.last_name),
       concat(a.address, ' ', a.address2),
       a.district,
       ci.city,
       co.country
FROM public.staff s
         INNER JOIN public.address a on a.address_id = s.address_id
         INNER JOIN public.city ci on ci.city_id = a.city_id
         INNER JOIN public.country co on co.country_id = ci.country_id;


INSERT INTO dim_category (name)
SELECT DISTINCT c.name
FROM public.category c;

INSERT INTO dim_film (title, release_year, language)
SELECT f.title,
       f.release_year,
       l.name
FROM public.film f
         INNER JOIN public.language l on l.language_id = f.language_id;

-- Data integrity guarantee:
-- Isso serve para garantir que cada film_id (ou category_id)
-- que está na public.film_category realmente
-- corresponde a um filme (ou categoria) existente na tabela public.film (ou public.category).
-- Embora geralmente isso seja garantido por
-- chaves estrangeiras no OLTP, é uma boa prática para validação durante o ETL (Extração, Transformação, Carga).
-- Poderia ser omitido se você tiver certeza da integridade dos dados.

INSERT INTO brd_film_category (id_film, id_category)
SELECT dim_film.id, dim_category.id
FROM public.film_category staging_fc -- Staging film category
         INNER JOIN public.film staging_film ON staging_film.film_id = staging_fc.film_id
         INNER JOIN public.category sc ON sc.category_id = staging_fc.film_id
-- Utilização das novas chaves primárias no OLAP:
         INNER JOIN dim_category ON dim_category.id = sc.category_id
-- Utilização das novas chaves primárias no OLAP:
         INNER JOIN dim_film ON dim_film.id = staging_film.film_id;

-- INSERT INTO ft_rental (
-- id_rental_date, id_return_date, id_payment_date, id_film,
-- id_customer, id_staff, id_store, value)

SELECT r.rental_date, r.return_date, p.payment_date, f.film_id, c.customer_id, s.staff_id, p.amount
FROM public.payment p
         INNER JOIN public.rental r ON r.rental_id = p.rental_id
         INNER JOIN public.inventory i ON i.inventory_id = r.inventory_id
         INNER JOIN public.store st ON st.store_id = i.store_id
         INNER JOIN public.film f ON f.film_id = i.film_id
         INNER JOIN public.customer c on p.customer_id = c.customer_id
         INNER JOIN public.staff s ON s.staff_id = p.staff_id

         INNER JOIN dim_store ds ON ds.id = ;
