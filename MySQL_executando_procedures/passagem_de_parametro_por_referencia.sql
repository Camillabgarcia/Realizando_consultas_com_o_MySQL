-- 0.4 Passagem de parâmetros por referência.

-- 4.A Usando o número de dias.

-- 4.1 Alteração significativa feita na maneira de calcular a data final do aluguel, dado o número de dias de aluguel e a data de início:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_41`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_41`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDias INT, vPrecoUnitario DECIMAL(10, 2))   -- vDias agora é parâmetro.

BEGIN
    DECLARE vCliente VARCHAR(10); 
    DECLARE vDataFinal DATE;       -- vDataFinal agora é variável.
    DECLARE VNumCliente INT; 
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    CASE                               
    WHEN VNumCliente = 0 THEN 
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
	WHEN VNumCliente = 1 THEN
        SET vDataFinal = (SELECT vDataInicio + INTERVAL vDias DAY);         -- Calcula a data final do aluguel com base no número de dias fornecido.
		SET vPrecoTotal = vDias * vPrecoUnitario;     
		SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;
		INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
		SET vMensagem = 'Aluguel incluído na base com sucesso.';    
		SELECT vMensagem;  -- Processa o aluguel se houver exatamente 1 cliente encontrado.
	WHEN VNumCliente > 1 THEN
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
	END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- Fazendo teste:
CALL novoAluguel_41('10008', 'Rafael Peixoto', '8635', '2023-04-05', 5, 40); -- Mensagem: 'Aluguel incluído na base com sucesso.'

-- Verificando se foi adicionado:
SELECT * FROM alugueis WHERE aluguel_id = '10008';

-- 4.B Aplicando o LOOPING condicional.

-- Promoção do setor de marketing: A pessoa ficará sete dias no apartamento, mas pagará apenas por cinco, porque sábados e domingos não vão contar como diárias.:

--  Consulta nos dirá qual é o dia da semana do dia 1º de janeiro de 2023 (domingo):
SELECT DAYOFWEEK(STR_TO_DATE('2023-01-01', '%Y-%m-%d'));

-- OBS: Então, no nosso looping, se o dia da semana for 1 ou 7, ou seja, domingo ou sábado, não incrementaremos o contador. Se for diferente de 1 e 7, incrementamos.

-- 4.2 Implementando o LOOPING dentro da Stored Procedure:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_42`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_42`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDias INT, vPrecoUnitario DECIMAL(10, 2))   -- vDias agora é parâmetro.

BEGIN
    DECLARE vCliente VARCHAR(10);
    DECLARE vContador INT;             -- Criação da váriavel que fará o papel do contador para o looping.
    DECLARE vDiaSemana INT;            -- Criação da variável que armazenará o dia da semana.
    DECLARE vDataFinal DATE;       
    DECLARE VNumCliente INT; 
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    CASE                               
    WHEN VNumCliente = 0 THEN 
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
	WHEN VNumCliente = 1 THEN
        SET vContador = 1;                                      -- Inicializando o contador.     
        SET vDataFinal = vDataInicio;                           -- Inicializando a data final que será igual a data inicial.
        WHILE vContador < vDias                                 -- Inicilaizando o looping pela condição.
        DO
			SET vDiaSemana = (SELECT DAYOFWEEK(STR_TO_DATE(vDataFinal, '%Y-%m-%d')));      -- Testando o dia da semana.
            IF (vDiaSemana <> 7 AND vDiaSemana <> 1) THEN
				SET vContador = vContador + 1;                              -- Incrementa o contador se não for sábado ou domingo.
            END IF;
			SET	vDataFinal = (SELECT vDataFinal + INTERVAL 1 DAY);		-- Avança a data final em um dia a cada iteração. 
        END WHILE;
		SET vPrecoTotal = vDias * vPrecoUnitario;     
		SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;
		INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
		SET vMensagem = 'Aluguel incluído na base com sucesso.';    
		SELECT vMensagem;  -- Processa o aluguel se houver exatamente 1 cliente encontrado.
	WHEN VNumCliente > 1 THEN
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
	END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- Testando:
-- A data final será 2023-04-18, pois sábado e domingo não é considerado.
CALL novoAluguel_42('10010', 'Gabriela Pires', '8635', '2023-04-12', 5, 40); -- Mensagem: 'Aluguel incluído na base com sucesso.'

-- Verificando se o aluguel foi adicionado:
SELECT * FROM alugueis WHERE aluguel_id = '10010';

-- 4.C Entendendo a passagem de parâmetro como referência.

-- Para melhorar o código, podemos segmentar a procedure em partes.
-- Criando uma procedure isolada:

USE `insight_places`;
DROP PROCEDURE IF EXISTS `calculaDataFinal_43`;  -- Removendo a procedure anterior se existir.

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `calculaDataFinal_43` 
(vDataInicio DATE, INOUT vDataFinal DATE, vDias INT)  -- Passando a variável vDataFinal como referência.
BEGIN
    DECLARE vContador INT;  -- Declarando o contador que será usado para contar os dias úteis.
    DECLARE vDiaSemana INT;  -- Declarando a variável para armazenar o dia da semana.
    
    SET vContador = 1;  -- Inicializando o contador.
    SET vDataFinal = vDataInicio;  -- Inicializando vDataFinal com vDataInicio.
    
    -- Loop para calcular a data final considerando apenas dias úteis
    WHILE vContador < vDias DO
        SET vDiaSemana = (SELECT DAYOFWEEK(vDataFinal));  -- Obtendo o dia da semana da data atual.
        
        -- Verifica se o dia não é sábado (7) nem domingo (1)
        IF (vDiaSemana <> 7 AND vDiaSemana <> 1) THEN
            SET vContador = vContador + 1;  -- Incrementa o contador se for um dia útil.
        END IF;
        
        SET vDataFinal = DATE_ADD(vDataFinal, INTERVAL 1 DAY);  -- Avança a data final em um dia.
    END WHILE;
        
END$$

DELIMITER ;

-- 4.3 Mudando o trecho da procedure principal utilizando a procedure isolada criada anteriormente:

USE `insight_places`;
DROP PROCEDURE IF EXISTS `insight_places`.`novoAluguel_43`;  -- Removendo a procedure anterior se existir.
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_43`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDias INT, vPrecoUnitario DECIMAL(10, 2))   

BEGIN
    DECLARE vCliente VARCHAR(10);  -- Declaração da variável que armazenará o ID do cliente.
    DECLARE vDataFinal DATE;  -- Declaração da variável para armazenar a data final.
    DECLARE vNumCliente INT;  -- Declaração da variável para contar o número de clientes.
    DECLARE vPrecoTotal DECIMAL(10, 2);  -- Declaração da variável para armazenar o preço total.
    DECLARE vMensagem VARCHAR(100);  -- Declaração da variável para mensagens.
    
    -- Tratamento de erro para problemas de chave estrangeira.
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;  -- Mensagem de erro se houver problemas de chave estrangeira.
    END;
    
    -- Conta o número de clientes com o nome fornecido.
    SET vNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    -- Estrutura CASE para verificar a quantidade de clientes encontrados
    CASE                               
    WHEN vNumCliente = 0 THEN 
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
        
    WHEN vNumCliente = 1 THEN
        -- Chama a procedure isolada para calcular a data final
        CALL calculaDataFinal_43(vDataInicio, vDataFinal, vDias);  -- Calcula a data final com base em dias úteis.
        
        SET vPrecoTotal = vDias * vPrecoUnitario;  -- Cálculo do preço total.
        SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;  -- Obtém o ID do cliente.
        
        -- Insere os dados do aluguel na tabela
        INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
        SET vMensagem = 'Aluguel incluído na base com sucesso.';    
        SELECT vMensagem;  -- Mensagem de sucesso ao incluir o aluguel.
        
    WHEN vNumCliente > 1 THEN
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
    END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- Incluindo mais um aluguel:
CALL novoAluguel_43('10011', 'Lívia Fogaça', '8635', '2023-04-20', 10, 40); -- Mensagem: 'Aluguel incluído na base com sucesso.

-- Verificando se o aluguel foi adicionado:
SELECT * FROM alugueis WHERE aluguel_id = '10011';

-- Criando outra procedure isolada para encapsular o processo de cálculo do preço total e inserção na tabela de aluguéis:

USE `insight_places`;
DROP procedure IF EXISTS `inclusao_cliente_43`;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inclusao_cliente_43`(
    vAluguel VARCHAR(10), 
    vCliente VARCHAR(10), 
    vHospedagem VARCHAR(10), 
    vDataInicio DATE, 
    vDataFinal DATE, 
    vDias INTEGER, 
    vPrecoUnitario DECIMAL(10,2))
BEGIN
    DECLARE VPrecoTotal DECIMAL(10,2);
    SET VPrecoTotal = vDias * vPrecoUnitario;
    INSERT INTO alugueis 
    VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, VPrecoTotal);
END$$

DELIMITER ;

 -- Procedure novoAluguel_43_nova modificada:
 
 USE `insight_places`;
DROP PROCEDURE IF EXISTS `insight_places`.`novoAluguel_43_nova`; 
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_43_nova`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDias INT, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10);  
    DECLARE vDataFinal DATE;  
    DECLARE vNumCliente INT;  
    DECLARE vPrecoTotal DECIMAL(10, 2);  
    DECLARE vMensagem VARCHAR(100); 
    
    -- Tratamento de erro para problemas de chave estrangeira.
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;  -- Mensagem de erro se houver problemas de chave estrangeira.
    END;
    
    SET vNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    -- Estrutura CASE para verificar a quantidade de clientes encontrados
    CASE                               
    WHEN vNumCliente = 0 THEN 
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
        
    WHEN vNumCliente = 1 THEN
        -- Chama a procedure isolada para calcular a data final
        CALL calculaDataFinal_43(vDataInicio, vDataFinal, vDias);
        
        SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome; 
        
        -- Chama a procedure isolada para calcular o preço total
        CALL inclusao_cliente_43(vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vDias, vPrecoUnitario);
        
        SET vMensagem = 'Aluguel incluído na base com sucesso.';    
        SELECT vMensagem;  -- Mensagem de sucesso ao incluir o aluguel.
        
    WHEN vNumCliente > 1 THEN
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
    END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- 4.D Calculando automaticamente o ID do aluguel.

-- Implementando uma lógica que verificasse o maior número do identificador do aluguel, somasse 1 e o usasse como código na inclusão de um novo aluguel.
-- A cada novo exemplo, temos que adicionar um a mais, pois o identificador do aluguel é uma chave primária da tabela de aluguel. Portanto, não pode ser repetido.

-- O novo script buscará a coluna de identificadores dos aluguéis, converterá os valores para numéricos, identificará o maior número, somará 1 e, por fim, 
-- converterá o resultado de volta para string, garantindo que o aluguel_id final esteja no formato correto para inclusão na tabela:

-- Seleciona o identificador do aluguel (aluguel_id) e converte os valores de aluguel_id para um tipo numérico (unsigned).
SELECT aluguel_id, CAST(aluguel_id AS UNSIGNED) FROM alugueis;

-- Seleciona o maior valor do identificador do aluguel (aluguel_id) original e o maior valor convertido para numérico, para verificar ambos.
SELECT MAX(aluguel_id), MAX(CAST(aluguel_id AS UNSIGNED)) FROM alugueis;

-- Calcula o próximo identificador do aluguel ao somar 1 ao maior valor encontrado na conversão de aluguel_id para numérico.
SELECT MAX(CAST(aluguel_id AS UNSIGNED)) + 1 FROM alugueis;

-- Converte o próximo identificador do aluguel (resultado anterior) de volta para uma string (CHAR), preparando-o para inclusão na tabela.
SELECT CAST(MAX(CAST(aluguel_id AS UNSIGNED)) + 1 AS CHAR) FROM alugueis;

-- 4.4 Modificação na procedure pata que não seja mais necessário informar o ID do aluguel :
USE `insight_places`;
DROP PROCEDURE IF EXISTS `insight_places`.`novoAluguel_44`; 
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_44`
(vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDias INT, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
	DECLARE vAluguel VARCHAR(10);           -- Criação da variável que será cálculada dentro da procedure para ser o próximo ID do aluguel.
    DECLARE vCliente VARCHAR(10);  
    DECLARE vDataFinal DATE;  
    DECLARE vNumCliente INT;  
    DECLARE vPrecoTotal DECIMAL(10, 2);  
    DECLARE vMensagem VARCHAR(100); 
    
    -- Tratamento de erro para problemas de chave estrangeira.
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;  -- Mensagem de erro se houver problemas de chave estrangeira.
    END;
    
    SET vNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    -- Estrutura CASE para verificar a quantidade de clientes encontrados
    CASE                               
    WHEN vNumCliente = 0 THEN 
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
        
    WHEN vNumCliente = 1 THEN
		-- Cácula o próximo id do aluguel
        SELECT CAST(MAX(CAST(aluguel_id AS UNSIGNED)) + 1 AS CHAR) INTO vAluguel FROM alugueis;

        -- Chama a procedure isolada para calcular a data final
        CALL calculaDataFinal_43(vDataInicio, vDataFinal, vDias);
        
        SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome; 
        
        -- Chama a procedure isolada para calcular o preço total
        CALL inclusao_cliente_43(vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vDias, vPrecoUnitario);
        
        SET vMensagem = CONCAT('Aluguel incluído na base com sucesso - ID ', vAluguel);    -- Mostrando no novo ID gerado automaticamente com o novo registro de aluguel.
        SELECT vMensagem;  -- Mensagem de sucesso ao incluir o aluguel.
        
    WHEN vNumCliente > 1 THEN
        SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
    END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- Testando a modificação na procedure, agora com a informação do ID gerado:
CALL novoAluguel_44('Lívia Fogaça', '8635', '2023-05-15', 5, 45); -- Mensagem: 'Aluguel incluído na base com sucesso - ID 10012'.

-- Testando a modificação na procedure, agora com a informação do ID gerado:
CALL novoAluguel_44('Lívia Fogaça', '8635', '2023-05-29', 5, 45); -- Mensagem: 'Aluguel incluído na base com sucesso - ID 10013'.






