CREATE TABLE dim_date
(
    id         SERIAL  NOT NULL,
    date       DATE    NOT NULL,
    year       INTEGER NOT NULL,
    month      INTEGER NOT NULL,
    day        INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (id)
);

CREATE TABLE dim_customer
(
    id       SERIAL       NOT NULL,
    name     VARCHAR(255) NOT NULL,
    address  VARCHAR(255) NOT NULL,
    district VARCHAR(255) NOT NULL,
    city     VARCHAR(255) NOT NULL,
    country  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_dim_customer PRIMARY KEY (id)
);

CREATE TABLE dim_store
(
    id       SERIAL       NOT NULL,
    address  VARCHAR(255) NOT NULL,
    district VARCHAR(255) NOT NULL,
    city     VARCHAR(255) NOT NULL,
    country  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (id)
);

CREATE TABLE dim_staff
(
    id       SERIAL       NOT NULL,
    name     VARCHAR(255) NOT NULL,
    address  VARCHAR(255) NOT NULL,
    district VARCHAR(255) NOT NULL,
    city     VARCHAR(255) NOT NULL,
    country  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_dim_staff PRIMARY KEY (id)
);

CREATE TABLE dim_film
(
    id           SERIAL       NOT NULL,
    title        VARCHAR(255) NOT NULL,
    release_year INTEGER      NOT NULL,
    language     VARCHAR(255) NOT NULL,
    CONSTRAINT pk_dim_film PRIMARY KEY (id)
);

CREATE TABLE dim_category
(
    id   SERIAL       NOT NULL,
    name VARCHAR(255) NOT NULL,
    CONSTRAINT pk_dim_category PRIMARY KEY (id)
);

CREATE TABLE brd_film_category
(
    id          SERIAL  NOT NULL,
    id_film     INTEGER NOT NULL,
    id_category INTEGER NOT NULL,
    CONSTRAINT pk_dim_film_category PRIMARY KEY (id),
    CONSTRAINT fk_film FOREIGN KEY (id_film) REFERENCES dim_film (id),
    CONSTRAINT fk_category FOREIGN KEY (id_category) REFERENCES dim_category (id)
);

CREATE TABLE ft_rental
(
    id              SERIAL         NOT NULL,
    id_rental_date  INTEGER        NOT NULL,
    id_return_date  INTEGER        NOT NULL,
    id_payment_date INTEGER        NOT NULL,
    id_film         INTEGER        NOT NULL,
    id_customer     INTEGER        NOT NULL,
    id_staff        INTEGER        NOT NULL,
    id_store        INTEGER        NOT NULL,
    value           DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_ft_rental PRIMARY KEY (id),
    CONSTRAINT fk_rental_date FOREIGN KEY (id_rental_date) REFERENCES dim_date (id),
    CONSTRAINT fk_return_date FOREIGN KEY (id_return_date) REFERENCES dim_date (id),
    CONSTRAINT fk_payment_date FOREIGN KEY (id_payment_date) REFERENCES dim_date (id),
    CONSTRAINT fk_film FOREIGN KEY (id_film) REFERENCES dim_film (id),
    CONSTRAINT fk_customer FOREIGN KEY (id_customer) REFERENCES dim_customer (id),
    CONSTRAINT fk_staff FOREIGN KEY (id_staff) REFERENCES dim_staff (id),
    CONSTRAINT fk_store FOREIGN KEY (id_store) REFERENCES dim_store (id)
);
