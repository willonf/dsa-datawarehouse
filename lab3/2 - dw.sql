-- LAB 3 - AIRBYTE - DATA WAREHOUSE
-- CRIAÇÃO DAS TABELAS DO DW

-- Tabela Dimensão Cliente
CREATE TABLE dim_cliente
(
    sk_cliente SERIAL PRIMARY KEY,
    id_cliente INT,
    nome       VARCHAR(255),
    tipo       VARCHAR(255),
    cidade     VARCHAR(255),
    estado     VARCHAR(50),
    pais       VARCHAR(255)
);

-- Tabela Dimensão Produto
CREATE TABLE dim_produto
(
    sk_produto SERIAL PRIMARY KEY,
    id_produto INT         NOT NULL,
    nome       VARCHAR(50) NOT NULL,
    categoria  VARCHAR(50) NOT NULL
);

-- Tabela Dimensão Canal
CREATE TABLE dim_canal
(
    sk_canal SERIAL PRIMARY KEY,
    id_canal INT,
    nome     VARCHAR(255),
    regiao   VARCHAR(255)
);
-- Tabela Dimensão Data
CREATE TABLE dim_data
(
    sk_data       SERIAL PRIMARY KEY,
    data_completa DATE,
    dia           INT,
    mes           INT,
    ano           INT
);
-- Tabela Fato de Vendas
CREATE TABLE fato_vendas
(
    sk_produto     INT            NOT NULL,
    sk_cliente     INT            NOT NULL,
    sk_canal       INT            NOT NULL,
    sk_data        INT            NOT NULL,
    quantidade     INT            NOT NULL,
    valor_venda    DECIMAL(10, 2) NOT NULL,
    custo_produto  DECIMAL(10, 2) NOT NULL,
    receita_vendas DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (sk_produto, sk_cliente, sk_canal, sk_data),
    FOREIGN KEY (sk_produto) REFERENCES dim_produto (sk_produto),
    FOREIGN KEY (sk_cliente) REFERENCES dim_cliente (sk_cliente),
    FOREIGN KEY (sk_canal) REFERENCES dim_canal (sk_canal),
    FOREIGN KEY (sk_data) REFERENCES dim_data (sk_data)
);



-- INSERÇÃO DOS DADOS NO DW
-- Carrega a tabela dim_data (tempo)
INSERT INTO dim_data (ano, mes, dia, data_completa)
SELECT EXTRACT(YEAR FROM d)::INT, EXTRACT(MONTH FROM d)::INT, EXTRACT(DAY FROM d)::INT, d::DATE
FROM generate_series('2020-01-01'::DATE, '2025-12-31'::DATE, '1 day'::INTERVAL) d;


-- Carrega a tabela dim_cliente no DW a partir da Staging Area

INSERT INTO schema3.dim_cliente (id_cliente, nome, tipo, cidade, estado, pais)
SELECT c.id_cliente,
       c.nome_cliente AS nome,
       t.nome_tipo    AS tipo,
       ci.nome_cidade AS cidade,
       CASE
           WHEN nome_cidade = 'Natal' THEN 'Rio Grande do Norte'
           WHEN nome_cidade = 'Rio de Janeiro' THEN 'Rio de Janeiro'
           WHEN nome_cidade = 'Belo Horizonte' THEN 'Minas Gerais'
           WHEN nome_cidade = 'Salvador' THEN 'Bahia'
           WHEN nome_cidade = 'Blumenau' THEN 'Santa Catarina'
           WHEN nome_cidade = 'Curitiba' THEN 'Paraná'
           WHEN nome_cidade = 'Fortaleza' THEN 'Ceará'
           WHEN nome_cidade = 'Recife' THEN 'Pernambuco'
           WHEN nome_cidade = 'Porto Alegre' THEN 'Rio Grande do Sul'
           WHEN nome_cidade = 'Manaus' THEN 'Amazonas'
           END           estado,
       ca.pais
FROM schema2.st_clientes c
         JOIN
     schema2.st_tipo_cliente t ON c.id_tipo = t.id_tipo
         JOIN
     schema2.st_cidades ci ON c.id_cidade = ci.id_cidade
         JOIN
     schema2.st_canais ca ON ci.id_cidade = ca.id_cidade
WHERE NOT EXISTS (SELECT 1
                  FROM schema3.dim_cliente d
                  WHERE d.id_cliente = c.id_cliente);

-- Carrega a tabela dim_produto no DW a partir da Staging Area

INSERT INTO schema3.dim_produto (id_produto, nome, categoria)
SELECT p.id_produto,
       p.nome_produto   AS nome,
       c.nome_categoria AS categoria
FROM schema2.st_ft_produtos p
         JOIN
     schema2.st_ft_subcategorias s ON p.id_subcategoria = s.id_subcategoria
         JOIN
     schema2.st_ft_categorias c ON s.id_categoria = c.id_categoria
WHERE NOT EXISTS (SELECT 1
                  FROM schema3.dim_produto dp
                  WHERE dp.id_produto = p.id_produto);


-- Nota: Primeiro, vamos verificar se já existe alguma entrada na dim_produto. Se não, então vamos inserir.

-- Carrega a tabela dim_canal no DW a partir da Staging Area

INSERT INTO schema3.dim_canal (id_canal, nome, regiao)
SELECT c.id_canal,
       ci.nome_cidade AS nome,
       c.regiao
FROM schema2.st_ft_canais c
         JOIN
     schema2.st_ft_cidades ci ON c.id_cidade = ci.id_cidade
WHERE NOT EXISTS (SELECT 1
                  FROM schema3.dim_canal dc
                  WHERE dc.id_canal = c.id_canal);


-- Nota: Primeiro, vamos verificar se já existe alguma entrada na dim_canal. Se não, então vamos inserir.


-- Carrega a tabela fato_vendas
-- Query para retornar os dados para a tabela

SELECT sk_produto,
	     sk_cliente,
	     sk_canal,
       sk_data,
       quantidade,
       ROUND(preco_venda, 2) AS preco_venda,
	     ROUND(custo_produto, 2) AS custo_produto,
	     ROUND((CAST(quantidade AS numeric) * CAST(preco_venda AS numeric)), 2) AS receita_vendas
FROM schema2.st_ft_vendas tb1,
     schema2.st_ft_clientes tb2,
	   schema2.st_ft_canais tb3,
	   schema2.st_ft_produtos tb4,
	   schema3.dim_data tb5,
	   schema3.dim_produto tb6,
	   schema3.dim_canal tb7,
	   schema3.dim_cliente tb8
WHERE tb2.id_cliente = tb1.id_cliente
AND tb3.id_canal = tb1.id_localizacao
AND tb4.id_produto = tb1.id_produto
AND tb1.data_transacao = tb5.data_completa
AND tb2.id_cliente = tb8.id_cliente
AND tb3.id_canal = tb7.id_canal
AND tb4.id_produto = tb6.id_produto;


-- Carga de dados:

INSERT INTO schema3.fato_vendas (sk_produto,
	                               sk_cliente,
	                               sk_canal,
	                               sk_data,
	                               quantidade,
	                               valor_venda,
	                               custo_produto,
	                               receita_vendas)
SELECT sk_produto,
	     sk_cliente,
	     sk_canal,
       sk_data,
       quantidade,
       ROUND(preco_venda, 2) AS preco_venda,
	     ROUND(custo_produto, 2) AS custo_produto,
	     ROUND((CAST(quantidade AS numeric) * CAST(preco_venda AS numeric)), 2) AS receita_vendas
FROM schema2.st_ft_vendas tb1,
     schema2.st_ft_clientes tb2,
	   schema2.st_ft_canais tb3,
	   schema2.st_ft_produtos tb4,
	   schema3.dim_data tb5,
	   schema3.dim_produto tb6,
	   schema3.dim_canal tb7,
	   schema3.dim_cliente tb8
WHERE tb2.id_cliente = tb1.id_cliente
AND tb3.id_canal = tb1.id_localizacao
AND tb4.id_produto = tb1.id_produto
AND tb1.data_transacao = tb5.data_completa
AND tb2.id_cliente = tb8.id_cliente
AND tb3.id_canal = tb7.id_canal
AND tb4.id_produto = tb6.id_produto;


-- Recria a tabela fato sem constraints
CREATE TABLE schema3.fato_vendas (
  sk_produto INT NOT NULL,
  sk_cliente INT NOT NULL,
  sk_canal INT NOT NULL,
  sk_data INT NOT NULL,
  quantidade INT NOT NULL,
  valor_venda DECIMAL(10,2) NOT NULL,
  custo_produto DECIMAL(10,2) NOT NULL,
  receita_vendas DECIMAL(10,2) NOT NULL
);


-- Key (sk_produto, sk_cliente, sk_canal, sk_data)=(1, 10, 4, 739)

-- Check - Obs: Os códigos abaixo podem ser diferentes no seu ambiente

SELECT * FROM schema3.fato_vendas where sk_data = 739 and sk_cliente = 10 order by 1;

-- Check - Obs: Os códigos abaixo podem ser diferentes no seu ambiente

SELECT sk_produto,
	     sk_cliente,
	     sk_canal,
       sk_data,
	     SUM(quantidade) AS quantidade,
       SUM(valor_venda) AS valor_venda,
	     SUM(custo_produto) AS custo_produto,
	     SUM(ROUND((CAST(quantidade AS numeric) * CAST(valor_venda AS numeric)), 2)) AS receita_vendas
FROM schema3.fato_vendas
WHERE sk_data = 738 AND sk_cliente = 3
GROUP BY sk_produto, sk_cliente, sk_canal, sk_data;


-- Recria a tabela fato com as constraints

CREATE TABLE schema3.fato_vendas (
  sk_produto INT NOT NULL,
  sk_cliente INT NOT NULL,
  sk_canal INT NOT NULL,
  sk_data INT NOT NULL,
  quantidade INT NOT NULL,
  valor_venda DECIMAL(10,2) NOT NULL,
  custo_produto DECIMAL(10,2) NOT NULL,
  receita_vendas DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (sk_produto, sk_cliente, sk_canal, sk_data),
  FOREIGN KEY (sk_produto) REFERENCES schema3.dim_produto (sk_produto),
  FOREIGN KEY (sk_cliente) REFERENCES schema3.dim_cliente (sk_cliente),
  FOREIGN KEY (sk_canal) REFERENCES schema3.dim_canal (sk_canal),
  FOREIGN KEY (sk_data) REFERENCES schema3.dim_data (sk_data)
);

-- Carrega a tabela fato_vendas (CORRETO)

INSERT INTO schema3.fato_vendas (sk_produto,
	                            sk_cliente,
	                            sk_canal,
	                            sk_data,
	                            quantidade,
	                            valor_venda,
	                            custo_produto,
	                            receita_vendas)
SELECT sk_produto,
	  sk_cliente,
	  sk_canal,
       sk_data,
       ROUND(SUM(quantidade),2) AS quantidade,
       ROUND(SUM(preco_venda),2) AS preco_venda,
	  ROUND(SUM(custo_produto),2) AS custo_produto,
	  SUM(ROUND((CAST(quantidade AS numeric) * CAST(preco_venda AS numeric)), 2)) AS receita_vendas
FROM schema2.st_ft_vendas tb1,
     schema2.st_ft_clientes tb2,
	schema2.st_ft_canais tb3,
	schema2.st_ft_produtos tb4,
	schema3.dim_data,
	schema3.dim_produto,
	schema3.dim_canal,
	schema3.dim_cliente
WHERE tb2.id_cliente = tb1.id_cliente
AND tb3.id_canal = tb1.id_localizacao
AND tb4.id_produto = tb1.id_produto
AND tb1.data_transacao = dim_data.data_completa
AND tb2.id_cliente = dim_cliente.id_cliente
AND tb3.id_canal = dim_canal.id_canal
AND tb4.id_produto = dim_produto.id_produto
GROUP BY sk_produto, sk_cliente, sk_canal, sk_data;