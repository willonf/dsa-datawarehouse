-- LAB 3 - AIRBYTE - RELATÓRIOS
-- Relatório 1
-- Total de receita por estado, categoria e tipo de cliente

CREATE OR REPLACE VIEW schema3.vw_receita_total
AS
SELECT estado,
       categoria,
       tipo AS tipo_cliente,
       SUM(receita_vendas) AS receita_total
FROM schema3.dim_produto AS tb1,
     schema3.dim_cliente AS tb2,
     schema3.dim_canal AS tb3,
     schema3.dim_data AS tb4,
     schema3.fato_vendas AS tb5
WHERE tb5.sk_produto = tb1.sk_produto
AND tb5.sk_cliente = tb2.sk_cliente
AND tb5.sk_canal = tb3.sk_canal
AND tb5.sk_data = tb4.sk_data
GROUP BY estado, categoria, tipo
ORDER BY estado, categoria, tipo;


SELECT * FROM schema3.vw_receita_total;


-- Relatório 2
-- Margem de lucro por ano, por mês, por tipo cliente, por categoria de produto e por região do canal de vendas
-- somente se a margem for superior a 94% e tipo cliente Corporativo ou Consumidor

CREATE MATERIALIZED VIEW schema3.mv_margem_lucro AS
SELECT
    dd.ano,
    CASE
        WHEN dd.mes = 1 THEN 'Janeiro'
        WHEN dd.mes = 2 THEN 'Fevereiro'
        WHEN dd.mes = 3 THEN 'Março'
        WHEN dd.mes = 4 THEN 'Abril'
        WHEN dd.mes = 5 THEN 'Maio'
        WHEN dd.mes = 6 THEN 'Junho'
        WHEN dd.mes = 7 THEN 'Julho'
        WHEN dd.mes = 8 THEN 'Agosto'
        WHEN dd.mes = 9 THEN 'Setembro'
        WHEN dd.mes = 10 THEN 'Outubro'
        WHEN dd.mes = 11 THEN 'Novembro'
        WHEN dd.mes = 12 THEN 'Dezembro'
        ELSE 'Outro'
    END AS mes_texto,
    dc.tipo AS tipo_cliente,
    dp.categoria AS categoria_produto,
    dca.regiao AS regiao_canal,
    ROUND(((SUM(fv.receita_vendas) - SUM(fv.custo_produto)) / SUM(fv.receita_vendas)) * 100, 2) AS margem_lucro_percentual
FROM
    schema3.fato_vendas fv
JOIN
    schema3.dim_produto dp ON fv.sk_produto = dp.sk_produto
JOIN
    schema3.dim_canal dca ON fv.sk_canal = dca.sk_canal
JOIN
    schema3.dim_data dd ON fv.sk_data = dd.sk_data
JOIN
    schema3.dim_cliente dc ON fv.sk_cliente = dc.sk_cliente
WHERE
     dc.tipo IN ('Corporativo', 'Consumidor')
GROUP BY
    dd.ano,
    dd.mes,
    dc.tipo,
    dp.categoria,
    dca.regiao
HAVING
    ROUND(((SUM(fv.receita_vendas) - SUM(fv.custo_produto)) / SUM(fv.receita_vendas)) * 100, 2) > 94
ORDER BY
    margem_lucro_percentual DESC;


SELECT * FROM schema3.mv_margem_lucro;
