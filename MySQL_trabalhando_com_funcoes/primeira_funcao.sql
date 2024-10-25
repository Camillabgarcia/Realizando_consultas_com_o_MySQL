-- 01. Preparando o ambiente

-- 1.D Consultas e primeira função.

-- Consultado a quantidade de registros na tabela de alugueis:
SELECT COUNT(*) FROM alugueis;

-- Consultado a quantidade de registros na tabela de avaliações:
SELECT COUNT(*) FROM avaliacoes;

-- Consultado a quantidade de registros na tabela de clientes:
SELECT COUNT(*) FROM clientes;

-- Consultado a quantidade de registros na tabela de endereços:
SELECT COUNT(*) FROM enderecos;

-- Consultado a quantidade de registros na tabela de hospedagens:
SELECT COUNT(*) FROM hospedagens;

-- Consultado a quantidade de registros na tabela de proprietários:
SELECT COUNT(*) FROM proprietarios;

-- Resultado da contagem de registros das seis tabelas em uma única consulta:
SELECT
	(SELECT COUNT(*) FROM alugueis) AS Alugueis,
	(SELECT COUNT(*) FROM avaliacoes) AS Avaliações,
	(SELECT COUNT(*) FROM clientes) AS Clientes,
	(SELECT COUNT(*) FROM enderecos) AS Endereços,
	(SELECT COUNT(*) FROM hospedagens) AS Hospedagens,
	(SELECT COUNT(*) FROM proprietarios) AS Proprietários;

