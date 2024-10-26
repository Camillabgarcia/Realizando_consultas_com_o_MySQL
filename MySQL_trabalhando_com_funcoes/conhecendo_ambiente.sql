-- 02. Conhecendo o ambiente.

-- 2.A Funções de agregação.

-- Consulta que retorna a média de avaliações, utilizando a função AVG:
SELECT AVG(nota) FROM avaliacoes;

-- Consulta que agrupa a média (nota) pelo tipo de hospedagem:
SELECT AVG(nota) AS Média, tipo
FROM avaliacoes a
JOIN hospedagens h
ON h.hospedagem_id = a.hospedagem_id
GROUP BY tipo;

-- Consulta que calcula a soma, maior e menor valor de aluguel:
SELECT SUM(preco_total) AS SomaTotal, MAX(preco_total) AS MaiorValor, MIN(preco_total) AS MenorValor 
FROM alugueis;

-- Consulta que calcula a soma, maior e menor preço para cada tipo de hospedagem:
SELECT tipo, SUM(preco_total) AS SomaTotal, MAX(preco_total) AS MaiorValor, MIN(preco_total) AS MenorValor 
FROM alugueis a
JOIN hospedagens h
ON h.hospedagem_id = a.hospedagem_id
GROUP BY tipo;
-- OBS: O resultado identifica qual é o tipo de hospedagem que é mais rentável e procurado pela clientela.

-- 2.B Funções para trabalhar com String.
-- Lidando com inconsistências na base de dados.

-- Consulta que retorna o nome e o contanto do cliente em uma úncio campo, utilizando a função CONCAT para fazer a junção:
SELECT CONCAT('Nome: ', nome, ', E-mail: ',contato) FROM clientes;

-- Retirando os espaços em brancos do campo nome:
SELECT CONCAT(TRIM(nome), ', E-mail: ',contato) AS NomeContato FROM clientes;

-- Padronizando o campo cpf:
SELECT
  TRIM(nome),
  CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS CPF_Mascarado
FROM
  clientes;

-- 2.C Funções para manipular datas.

-- Consulta que retorna o número de diárias por cliente, utilizando a função DATEDIFF::
SELECT c.nome, DATEDIFF(data_fim, data_inicio) AS TotalDias 
FROM alugueis a
JOIN clientes c
ON a.cliente_id = c.cliente_id;

-- Consulta que retorna o número de diárias por tipo de hospedagem:
SELECT h.tipo, SUM(DATEDIFF(data_fim, data_inicio)) AS TotalDias 
FROM alugueis a
JOIN hospedagens h
ON a.hospedagem_id = h.hospedagem_id
GROUP BY h.tipo;
-- OBS: O imóvel mais procura é o hotel.

-- 2.D Funções numéricas e condiconais.

-- Definindo as casas decimais no resultado da consulta, utilizando a função TRUNCATE:
SELECT TRUNCATE(AVG(nota), 2) AS Média, tipo
FROM avaliacoes a
JOIN hospedagens h
ON h.hospedagem_id = a.hospedagem_id
GROUP BY tipo;

-- Fazendo o arrendodamento do resultado da consulta, utilizando a função ROUND:
SELECT ROUND(AVG(nota), 2) AS Média, tipo
FROM avaliacoes a
JOIN hospedagens h
ON h.hospedagem_id = a.hospedagem_id
GROUP BY tipo;

-- Categorização das notas utilizando a função CASE:
SELECT hospedagem_id, nota, 
CASE nota
	WHEN 5 THEN 'Exelente'
    WHEN 4 THEN 'Ótimo'
    WHEN 3 THEN 'Muito Bom'
    WHEN 2 THEN 'Bom'
    ELSE 'Ruim'
END AS StatusNota
FROM avaliacoes;










