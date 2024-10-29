-- 04. Funções e outras rotinas.

-- 4.A Criando um novo relatório.

-- Consulta que traz o desconto para atrair novos clientes e manter o que já existem.
-- Menos de 4 dias = 0% de desconto.
-- 4 a 6 dias = 5% de desconto.
-- 7 a 9 dias = 10% de desconto.
-- 10 ou mais dias = 15% de desconto.

SELECT 
	cliente_id,
	data_inicio,
	data_fim, 
	DATEDIFF(data_fim, data_inicio) AS TotalDias,
    CASE
		WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 4 AND 6 THEN 5
        WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 7 AND 9 THEN 10
        WHEN DATEDIFF(data_fim, data_inicio) >= 10 THEN 15
        ELSE 0
	END AS DescontoPercentual
FROM alugueis;

-- Transformaçando a consulta acima em uma função:
DELIMITER $$

CREATE FUNCTION CalcularDescontoPorDias(aluguelID INT)        -- Cria a função para calcular o percentual de desconto com base no número de dias do aluguel.
RETURNS INT DETERMINISTIC                                     -- Define o tipo de retorno como INT, garantindo que sempre retorne o mesmo valor para a mesma entrada.

BEGIN

    DECLARE desconto INT;                                     -- Declara a variável para armazenar o percentual de desconto.

    SELECT 
        CASE                                                 -- Avalia o número de dias para determinar o desconto.
            WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 4 AND 6 THEN 5      -- 5% de desconto para aluguéis de 4 a 6 dias.
            WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 7 AND 9 THEN 10     -- 10% de desconto para aluguéis de 7 a 9 dias.
            WHEN DATEDIFF(data_fim, data_inicio) >= 10 THEN 15               -- 15% de desconto para aluguéis de 10 dias ou mais.
            ELSE 0                                                          -- Sem desconto para aluguéis com menos de 4 dias.
        END INTO desconto
    FROM alugueis
    WHERE aluguel_id = aluguelID;                             -- Busca o aluguel específico pelo ID fornecido.

    RETURN desconto;                                          -- Retorna o percentual de desconto calculado.

END$$

DELIMITER ;

-- Chamando a função:
SELECT CalcularDescontoPorDias(1);                            -- Exemplo: calcula o desconto para o aluguel com ID 1.

-- Consulta que cria uma função que calcula o valor final com desconto:
DELIMITER $$

CREATE FUNCTION CalcularValorFinalComDesconto(aluguelID INT)  -- Cria a função que calcula o valor final com desconto, recebendo o ID do aluguel.
RETURNS DECIMAL(10, 2) DETERMINISTIC                          -- Define o tipo de retorno como DECIMAL com 2 casas decimais.

BEGIN

    DECLARE ValorTotal DECIMAL(10, 2);                        -- Declara a variável para armazenar o valor total do aluguel.
    DECLARE Desconto INT;                                     -- Declara a variável para armazenar o percentual de desconto.
    DECLARE ValorFinal DECIMAL(10, 2);                        -- Declara a variável para armazenar o valor final após o desconto.

    SELECT 
        preco_total INTO ValorTotal                           -- Armazena o preço total do aluguel na variável ValorTotal.
    FROM alugueis
    WHERE aluguel_id = aluguelID;                             -- Encontra o aluguel específico com base no ID fornecido.

    SET Desconto = CalcularDescontoPorDias(aluguelID);        -- Chama a função CalcularDescontoPorDias para obter o percentual de desconto.

    SET ValorFinal = ValorTotal - (ValorTotal * Desconto / 100); -- Calcula o valor final subtraindo o desconto do valor total.

    RETURN ValorFinal;                                        -- Retorna o valor final com o desconto aplicado.

END$$

DELIMITER ;

-- Chamando a função:
SELECT CalcularValorFinalComDesconto(1);

-- 2.C Criando um nova tabela

-- Criando uma tabela com o resumo do aluguel do cliente. Nela, teremos a porcentagem de desconto que a pessoa cliente recebeu, o valor final e o valor sem o desconto.
CREATE TABLE resumo_aluguel (
    aluguel_id VARCHAR(255),
    cliente_id VARCHAR(255),
    valortotal DECIMAL(10,2),
    descontoaplicado DECIMAL(10,2),
    valorfinal DECIMAL(10,2),
	PRIMARY KEY (aluguel_id, cliente_id),
    FOREIGN KEY (aluguel_id) REFERENCES alugueis(aluguel_id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- 2.D Trabalhando com Trigger.

-- Criando uma trigger para atualizar automaticamente a tabela resumo_aluguel, sempre que um novo aluguel é inserido na tabela alugueis.
DELIMITER $$

CREATE TRIGGER AtualizarResumoAluguel
AFTER INSERT ON alugueis                             -- Trigger executa após uma inserção na tabela alugueis.
FOR EACH ROW                                         -- Executa para cada nova linha inserida.
BEGIN

    DECLARE Desconto INT;                            -- Declara a variável para armazenar o percentual de desconto.
    DECLARE ValorFinal DECIMAL(10, 2);               -- Declara a variável para armazenar o valor final do aluguel.

    SET Desconto = CalcularDescontoPorDias(NEW.aluguel_id);        -- Chama a função para calcular o desconto.
    SET ValorFinal = CalcularValorFinalComDesconto(NEW.aluguel_id); -- Chama a função para calcular o valor final.

    -- Insere o resumo do aluguel na tabela resumo_aluguel com os dados do novo aluguel.
    INSERT INTO resumo_aluguel(aluguel_id, cliente_id, valortotal, descontoaplicado, valorfinal)
    VALUES (NEW.aluguel_id, NEW.cliente_id, NEW.preco_total, Desconto, ValorFinal);

END$$

DELIMITER ;

-- Visuzaliando a nova tabela criada:
SELECT * FROM resumo_aluguel;
-- OBS: A tabela se encontra vazia.

-- Inserindo um novo registro: 
INSERT INTO alugueis (aluguel_id, cliente_id, hospedagem_id, data_inicio, data_fim, preco_total)
VALUES (10050, 42, 15, '2024-01-01', '2024-01-08', 3000.00);
-- OBS: Foi criado duas funções, a calcularDescontoPorDias baseada no tempo que o cliente passou hospedado, mas também uma função para calcular o valorFinalComDesconto.
-- E criamos a Trigger que aciona essas duas funções e armazena essas informações em uma tabela.
