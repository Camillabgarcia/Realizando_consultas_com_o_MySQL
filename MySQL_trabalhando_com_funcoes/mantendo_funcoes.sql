-- 05. Mantendo funções.

-- 5.B Modificando funções.

-- Editando a função, caso o retorno seja NULL, através de um tratamento para que seja um valor:

USE `insight_places`;
DROP function IF EXISTS `InfoAluguel`;

USE `insight_places`;
DROP function IF EXISTS `insight_places`.`InfoAluguel`;
;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `InfoAluguel`(IdAluguel INT) RETURNS varchar(255) CHARSET utf8mb3 COLLATE utf8mb3_unicode_ci
    DETERMINISTIC
BEGIN
    DECLARE nomeCliente VARCHAR(100);     
    DECLARE precoTotal DECIMAL(10, 2);    
    DECLARE Dias INT;                     
    DECLARE valorDiaria DECIMAL(10, 2);    
    DECLARE resultado VARCHAR(255);        

    -- Consulta SQL que busca o nome do cliente, o preço total e o número de dias do aluguel
    SELECT c.nome, a.preco_total, DATEDIFF(a.data_fim, a.data_inicio)
        INTO nomeCliente, precoTotal, Dias
        FROM alugueis a
        JOIN clientes c 
        ON a.cliente_id = c.cliente_id
        WHERE a.aluguel_id = IdAluguel;
    
    -- Verifica se `Dias` é nulo ou menor/igual a zero. Se for, retorna '0' para evitar cálculos inválidos.
    IF Dias IS NULL OR Dias <= 0 THEN
		RETURN 0;
	ELSE 
		-- Calcula o valor diário do aluguel
		SET valorDiaria = precoTotal / Dias;
		
		-- Concatena as informações do cliente e o valor da diária em uma string
		SET resultado = CONCAT('Nome: ', nomeCliente, ' | Valor Diária: R$ ', FORMAT(valorDiaria, 2));
	END IF;
    -- Retorna a string formatada com as informações
    RETURN resultado;
END$$

DELIMITER ;
;

-- Testando a função novamente:
SELECT InfoAluguel(0);

-- 5.C Excluindo funções.
DROP FUNCTION IF EXISTS CalcularValorFinalComDesconto;

