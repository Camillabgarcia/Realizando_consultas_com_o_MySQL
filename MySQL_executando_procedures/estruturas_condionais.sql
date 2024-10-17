-- 03. Estruturas condicionais

-- 3.A Atribuindo valor usando SELECT.

-- Atribuindo à variável o resultado de uma consulta em outra tabela.
-- Registrando um aluguel através do nome em vez do código da pessoa cliente.
-- 3.1 Na Procedure, vamos procurar o código na tabela pelo nome e incluí-lo na tabela de aluguéis:

SELECT * FROM clientes WHERE nome = 'Luana Moura';

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_31`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_31`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10); -- Variável para armazenar o cliente_id
    DECLARE vDias INT DEFAULT 0;                    
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;                                               
    SET vDias = (SELECT DATEDIFF(vDataFinal, vDataInicio));         
    SET vPrecoTotal = vDias * vPrecoUnitario;     
    SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome; -- Busca o cliente_id pelo nome e armazena em vCliente
    INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); -- Usa vCliente no INSERT
    SET vMensagem = 'Aluguel incluído na base com sucesso.';    
    SELECT vMensagem;
END$$
DELIMITER ;


-- Chamada da procedure:
CALL novoAluguel_31('10006', 'Luana Moura', '8635', '2023-03-26', '2023-03-30', 40);
SELECT * FROM alugueis WHERE aluguel_id = '10006';

-- 3.B Entendendo o IF-THEN-ELSE

-- Incluindo um novo aluguel usando a Procedure versão 3.1:
CALL novoAluguel_31('10007', 'Júlia Pires', '8635', '2023-03-30', '2023-04-04', 40);

-- Ocasionou um erro, porque a pessoa cliente Júlia Pires tem mais de um registro na tabela de clientes.

SELECT * FROM clientes
WHERE nome = 'Júlia Pires';
-- São dois clientes diferentes, porém possuem o mesmo nome. Só podemos incluir uma pessoa cliente que tenha uma identificação única. 
 
-- 3.2 Testando o número de clientes e se este for maior do que 1, não faremos nada, apenas exibiremos a mensagem. Se for igual a 1, incluiremos a pessoa cliente.

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_32`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_32`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10); 
    DECLARE vDias INT DEFAULT 0;    
    DECLARE VNumCliente INT; -- Adicionada variável para contar o número de clientes
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome); -- Consulta para contar clientes com o nome fornecido
    IF VNumCliente > 1 THEN
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem; -- Mensagem exibida se houver mais de um cliente com o mesmo nome
	ELSE
		SET vDias = (SELECT DATEDIFF(vDataFinal, vDataInicio));         
		SET vPrecoTotal = vDias * vPrecoUnitario;     
		SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;
		INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
		SET vMensagem = 'Aluguel incluído na base com sucesso.';    
		SELECT vMensagem;
    END IF;
END$$
DELIMITER ;

-- Incluindo novamente um novo aluguel usando a Procedure versão 3.1:
CALL novoAluguel_32('10007', 'Júlia Pires', '8635', '2023-03-30', '2023-04-04', 40); -- Obs: Agora aparece a mensagem ao invés do erro 1172.

-- 3.C Aprendendo o IF THEN ELSEIF.

-- Melhorando o IF:

-- Incluindo um novo aluguel:
CALL novoAluguel_32('10007', 'Victorino Vila', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Aluguel incluído na base com sucesso.'

-- Esse não existe na tabela de clientes:
SELECT * FROM clientes WHERE NOME = 'Victorino Vila'; -- Retorna NULL.

-- Checando, onde o cliente_id é NULL.
SELECT * FROM alugueis WHERE aluguel_id = '10007';

-- Apagando o registro:
DELETE FROM alugueis where aluguel_id = '10007';

-- 3.3 Melhorando a Procedure:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_33`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_33`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10); 
    DECLARE vDias INT DEFAULT 0;    
    DECLARE VNumCliente INT; 
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    IF VNumCliente > 1 THEN
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem; 
	ELSEIF VNumCliente = 0 THEN                     -- Adicionada condição para verificar se não há clientes com o nome fornecido
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;                           -- Mensagem exibida se não houver cliente encontrado
	ELSE
		SET vDias = (SELECT DATEDIFF(vDataFinal, vDataInicio));         
		SET vPrecoTotal = vDias * vPrecoUnitario;     
		SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;
		INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
		SET vMensagem = 'Aluguel incluído na base com sucesso.';    
		SELECT vMensagem;
    END IF;
END$$
DELIMITER ;

-- Incluindo o aluguel novamente:
CALL novoAluguel_33('10007', 'Victorino Vila', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Este cliente não pode ser usado para incluir o aluguel porque não existe.'

-- 3.D Tratando o CASE-END CASE

-- 3.4 Reconstruindo a Procedure, usando a estrutura do CASE para substituir o IF, ELSEIF E ELSE:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_34`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_34`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10); 
    DECLARE vDias INT DEFAULT 0;    
    DECLARE VNumCliente INT; 
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    CASE VNumCliente  -- Alterado para usar a estrutura CASE ao invés de IF-ELSEIF.
    WHEN 0 THEN 
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
	WHEN 1 THEN
		SET vDias = (SELECT DATEDIFF(vDataFinal, vDataInicio));         
		SET vPrecoTotal = vDias * vPrecoUnitario;     
		SELECT cliente_id INTO vCliente FROM clientes WHERE nome = vClienteNome;
		INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal); 
		SET vMensagem = 'Aluguel incluído na base com sucesso.';    
		SELECT vMensagem;  -- Processa o aluguel se houver exatamente 1 cliente encontrado.
	ELSE
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel pelo nome.';   
        SELECT vMensagem;  -- Exibe mensagem se houver mais de um cliente com o mesmo nome.
	END CASE;  -- Fechamento do CASE.
END$$
DELIMITER ;

-- Incluindo um aluguel:
CALL novoAluguel_34('10007', 'Victorino Vila', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Este cliente não pode ser usado para incluir o aluguel porque não existe.'

-- Incluindo outro aluguel:
CALL novoAluguel_34('10007', 'Luana Moura ', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Aluguel incluído na base com sucesso.'

-- 3.E Implementando o CASE-END CASE

-- 3.5 Colocando uma condição de teste diretamente com o CASE condicional

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_35`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_35`
(vAluguel VARCHAR(10), vClienteNome VARCHAR(150), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
    DECLARE vCliente VARCHAR(10); 
    DECLARE vDias INT DEFAULT 0;    
    DECLARE VNumCliente INT; 
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE vMensagem VARCHAR(100);                    
    DECLARE EXIT HANDLER FOR 1452                     
    BEGIN
        SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   
        SELECT vMensagem;
    END;
    
    SET VNumCliente = (SELECT COUNT(*) FROM clientes WHERE nome = vClienteNome);
    
    CASE                                 -- Foi necessário retirar a variável da estrutura principal do CASE, por isso, adicionamos condições explícitas dentro dos WHEN.
    WHEN VNumCliente = 0 THEN 
		SET vMensagem = 'Este cliente não pode ser usado para incluir o aluguel porque não existe.';   
        SELECT vMensagem;  -- Exibe mensagem se nenhum cliente for encontrado.
	WHEN VNumCliente = 1 THEN
		SET vDias = (SELECT DATEDIFF(vDataFinal, vDataInicio));         
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

-- Incluindo um aluguel por um cliente que não existe na base:
CALL novoAluguel_35('10007', 'Victorino Vila', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Este cliente não pode ser usado para incluir o aluguel porque não existe.'

-- Incluindo o aluguel por um nome da tabela de clientes, que ainda não possui registro:
CALL novoAluguel_35('10007', 'Luana Moura ', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Aluguel incluído na base com sucesso.'

-- Incluindo o aluguel por um cliente que possui mais de 1 registro na base:
CALL novoAluguel_35('10007', 'Júlia Pires ', '8635', '2023-03-30', '2023-04-04', 40); -- Mensagem: 'Este cliente não pode ser usado para incluir o aluguel pelo nome.'





