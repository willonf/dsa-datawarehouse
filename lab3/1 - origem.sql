-- LAB 3 - AIRBYTE - FONTE DE DADOS
--- CRIAÇÃO E CARGA DO BANCO DE ORIGEM
CREATE TABLE categories
(
    id_categoria   SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(255) NOT NULL
);

INSERT INTO categories (nome_categoria)
VALUES ('Computadores'),
       ('Smartphones'),
       ('Impressoras');

CREATE TABLE subcategorias
(
    id_subcategoria   SERIAL PRIMARY KEY,
    nome_subcategoria VARCHAR(255) NOT NULL,
    id_categoria      INTEGER REFERENCES ft_categorias (id_categoria)
);

INSERT INTO subcategorias (nome_subcategoria, id_categoria)
VALUES ('Notebook', 1),
       ('Desktop', 1),
       ('iPhone', 2),
       ('Samsung Galaxy', 2),
       ('Laser', 3),
       ('Matricial', 3);

CREATE TABLE produtos
(
    id_produto      SERIAL PRIMARY KEY,
    nome_produto    VARCHAR(255)   NOT NULL,
    preco_produto   NUMERIC(10, 2) NOT NULL,
    id_subcategoria INTEGER REFERENCES ft_subcategorias (id_subcategoria)
);

INSERT INTO produtos (nome_produto, preco_produto, id_subcategoria)
VALUES ('Apple MacBook Pro M3', 6589.99, 1),
       ('Desktop Dell 32 GB', 1500.50, 1),
       ('iPhone 15', 4140.00, 2),
       ('Samsung Galaxy', 3500.99, 2),
       ('HP 126A Original LaserJet', 300.90, 3),
       ('Epson LX-300', 350.99, 3);

CREATE TABLE cidades
(
    id_cidade   SERIAL PRIMARY KEY,
    nome_cidade VARCHAR(255) NOT NULL
);

INSERT INTO cidades (nome_cidade)
VALUES ('Recife'),
       ('Rio de Janeiro'),
       ('Belo Horizonte'),
       ('Salvador'),
       ('Blumenau'),
       ('Curitiba'),
       ('Fortaleza'),
       ('Natal'),
       ('Porto Alegre'),
       ('Manaus');

CREATE TABLE canais
(
    id_canal  SERIAL PRIMARY KEY,
    pais      VARCHAR(255) NOT NULL,
    regiao    VARCHAR(255) NOT NULL,
    id_cidade INTEGER REFERENCES ft_cidades (id_cidade)
);

INSERT INTO canais (pais, regiao, id_cidade)
VALUES ('Brasil', 'Nordeste', 1),
       ('Brasil', 'Sudeste', 2),
       ('Brasil', 'Sudeste', 3),
       ('Brasil', 'Nordeste', 4),
       ('Brasil', 'Sul', 5),
       ('Brasil', 'Sul', 6),
       ('Brasil', 'Nordeste', 7),
       ('Brasil', 'Nordeste', 8),
       ('Brasil', 'Sul', 9),
       ('Brasil', 'Norte', 10);

CREATE TABLE tipo_cliente
(
    id_tipo   SERIAL PRIMARY KEY,
    nome_tipo VARCHAR(255) NOT NULL
);

INSERT INTO tipo_cliente (nome_tipo)
VALUES ('Corporativo'),
       ('Consumidor'),
       ('Desativado');

CREATE TABLE clientes
(
    id_cliente    SERIAL PRIMARY KEY,
    nome_cliente  VARCHAR(255) NULL,
    email_cliente VARCHAR(255) NULL,
    id_cidade     INTEGER REFERENCES cidades (id_cidade),
    id_tipo       INTEGER REFERENCES tipo_cliente (id_tipo)
);

INSERT INTO clientes (nome_cliente, email_cliente, id_cidade, id_tipo)
VALUES ('João Silva', 'joao.silva@teste.com', 1, 1),
       ('Maria Santos', 'maria.santos@teste.com', 2, 2),
       ('Pedro Lima', 'pedro.lima@teste.com', 3, 2),
       ('Ana Rodrigues', 'ana.rodrigues@teste.com', 4, 2),
       ('José Oliveira', 'jose.oliveira@teste.com', 1, 2),
       ('Carla Santos', 'carla.santos@teste.com', 4, 1),
       ('Marcos Souza', 'marcos.souza@teste.com', 5, 2),
       ('Julia Silva', 'julia.silva@teste.com', 1, 1),
       ('Lucas Martins', 'lucas.martins@teste.com', 3, 3),
       ('Fernanda Lima', 'fernanda.lima@teste.com', 4, 2);


CREATE TABLE vendas
(
    id_transacao   VARCHAR(50)    NOT NULL,
    id_produto     INT            NOT NULL,
    id_cliente     INT            NOT NULL,
    id_localizacao INT            NOT NULL,
    data_transacao DATE NULL,
    quantidade     INT            NOT NULL,
    preco_venda    DECIMAL(10, 2) NOT NULL,
    custo_produto  DECIMAL(10, 2) NOT NULL
);

-- Gerar valores aleatórios para as colunas
WITH dados AS (SELECT floor(random() * 1000000)::text AS id_transacao, floor(random() * 6 + 1) AS id_produto,
                      floor(random() * 10 + 1)                      AS id_cliente,
                      floor(random() * 4 + 1)                       AS id_localizacao,
                      '2022-01-01'::date + floor(random() * 365)::integer AS data_transacao, floor(random() * 10 + 1) AS quantidade,
                      round(CAST(random() * 100 + 1 AS numeric), 2) AS preco_venda,
                      round(CAST(random() * 50 + 1 AS numeric), 2)  AS custo_produto
               FROM generate_series(1, 1000))
-- Inserir dados na tabela
INSERT
INTO vendas (id_transacao, id_produto, id_cliente, id_localizacao, data_transacao, quantidade, preco_venda, custo_produto)
SELECT 'TRAN-' || id_transacao AS id_transacao,
       id_produto,
       id_cliente,
       id_localizacao,
       data_transacao,
       quantidade,
       round(CAST(preco_venda AS numeric), 2),
       round(CAST(custo_produto AS numeric), 2)
FROM dados;
