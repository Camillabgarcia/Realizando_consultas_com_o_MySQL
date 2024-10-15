-- 02. Variáveis e parâmetros:

-- 2.A Declarando várias variáveis de tipos diferentes

-- Criando Stored Procedure:
-- Cada variável é associada a um tipo de dados que determina quais valores ela pode conter, como números inteiros, números de ponto flutuante, caracteres, strings, datas, entre outros.
USE `insight_places`;
DROP procedure IF EXISTS `tiposDados`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `tiposDados` ()
BEGIN
	DECLARE vAluguel VARCHAR(10) DEFAULT 10001;
    DECLARE vCliente VARCHAR(10) DEFAULT 1002;
    DECLARE vHospedagem VARCHAR(10) DEFAULT 8635;
    DECLARE vDataInicio DATE DEFAULT '2023-03-01';
	DECLARE vDataFinal DATE DEFAULT '2023-05-01';
	DECLARE vPrecoTotal DECIMAL(10, 2) DEFAULT 550.23;
    SELECT vAluguel, vCliente, vHospedagem, vDataInicio, 
    vDataFinal, vPrecoTotal;
END$$

DELIMITER ;

-- Chamando a rotina:
CALL tiposDados;

-- Criando outra Stored Procedure que forneça a data e hora atual do computador:
USE `insight_places`;
DROP procedure IF EXISTS `dataHora`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `dataHora`()
BEGIN
	DECLARE ts DATETIME DEFAULT localtime();
    SELECT ts;
END$$

DELIMITER ;

-- 2.B Manipulando dados

-- Desenvolvendo a procedure que vai lidar com a inclusão dos novos aluguéis na base de dados da Insight Places, onde será mofificada a cada etapa.
-- ETAPA 1
-- 2.1 Procedure que realiza a consulta de dados (matriz inicial):
USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_21`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_21`()
BEGIN
	DECLARE vAluguel VARCHAR(10) DEFAULT 10001;
    DECLARE vCliente VARCHAR(10) DEFAULT 1002;
    DECLARE vHospedagem VARCHAR(10) DEFAULT 8635;
    DECLARE vDataInicio DATE DEFAULT '2023-03-01';
	DECLARE vDataFinal DATE DEFAULT '2023-05-01';
	DECLARE vPrecoTotal DECIMAL(10, 2) DEFAULT 550.23;
    SELECT vAluguel, vCliente, vHospedagem, vDataInicio, 
    vDataFinal, vPrecoTotal;
END$$
DELIMITER ;

-- ETAPA 2
-- 2.2 Inserção de alugueis na tabela:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_22`; -- Garante que qualquer versão anterior da procedure seja removida, evitando conflitos.
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_22`() -- Cria uma nova procedure chamada `novoAluguel_22`.
BEGIN
    -- Declaração de variáveis iniciais com os dados do aluguel:
	DECLARE vAluguel VARCHAR(10) DEFAULT 10001;  -- ID do aluguel.
    DECLARE vCliente VARCHAR(10) DEFAULT 1002;  -- ID do cliente.
    DECLARE vHospedagem VARCHAR(10) DEFAULT 8635;  -- ID da hospedagem.
    DECLARE vDataInicio DATE DEFAULT '2023-03-01';  -- Data de início da hospedagem.
	DECLARE vDataFinal DATE DEFAULT '2023-05-01';  -- Data de fim da hospedagem.
	DECLARE vPrecoTotal DECIMAL(10, 2) DEFAULT 550.23;  -- Preço total do aluguel.

    -- Nova linha adicionada para inserir os dados na tabela de `alugueis`:
    INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal);  
    -- Esse comando insere os valores das variáveis na tabela `alugueis`.
END$$
DELIMITER ;

-- Teste de inserção do novo aluguel:
CALL novoAluguel_22();  -- Chama a procedure recém-criada para adicionar o aluguel.
SELECT * FROM alugueis WHERE aluguel_id = '10001';  -- Consulta o registro de aluguel inserido para verificar se a inserção foi bem-sucedida.

-- 2.C Trabalhando com parâmetros.

-- ETAPA 3
-- Explorando maneiras de incluir novos aluguéis e reutilizar a Procedure para inserções futuras.
-- 2.3 Alterando a procedure para aceitar parâmetros:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_23`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_23`
(vAluguel VARCHAR(10), vCliente VARCHAR(10), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoTotal DECIMAL(10, 2)) 
-- Agora, a procedure aceita parâmetros, permitindo a inserção de aluguéis diferentes a cada execução.
BEGIN
    -- O comando de inserção permanece o mesmo, mas os valores vêm dos parâmetros, tornando a procedure mais flexível:
	INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal);
END$$
DELIMITER ;

-- Inserindo o aluguel 10002:
CALL novoAluguel_23('10002', '1003', '8635', '2023-03-06', '2023-03-10', 600); -- Aqui, você passa os valores diretamente na chamada, e a procedure os insere na tabela `alugueis`.
SELECT * FROM alugueis WHERE aluguel_id = '10002';

-- Portanto, se tivermos que incluir um novo aluguel, não precisamos editar a procedure e modificar a inicialização das variáveis. 
-- Basta executarmos de novo a procedure, passando um novo ID e os demais dados por parâmetros, como a acabamos de fazer. 

-- Façamos um novo exemplo:
CALL novoAluguel_23('10003', '1004', '8635', '2023-03-10', '2023-03-12', 250); -- Novamente, passa-se diferentes valores, e a inserção é feita sem a necessidade de editar o código da procedure.
SELECT * FROM alugueis WHERE aluguel_id IN ('10002', '10003');

-- 2.D Atribuição de valores.

-- ETAPA 4
-- Precisamos modificar a procedure para calcular automaticamente o número de dias entre as datas e multiplicar pelo preço da diária para obter o valor total a ser pago.
-- 2.4  Introduzindo uma lógica de cálculo dinâmico que determina o preço total de um aluguel:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_24`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_24`
(vAluguel VARCHAR(10), vCliente VARCHAR(10), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
	DECLARE vDias INT DEFAULT 0;                    -- Nova variável declarada para armazenar o número de dias de aluguel, calculada a partir da data inicial e final.
    DECLARE vPrecoTotal DECIMAL(10, 2);             -- Nova variável para armazenar o valor total a ser pago, calculado com base no número de dias e no preço da diária.
    SET vDias = (SELECT DATEDIFF (vDataFinal, vDataInicio));           -- Cálculo da quantidade de dias entre as datas fornecidas usando a função `DATEDIFF`.
    SET vPrecoTotal = vDias * vPrecoUnitario;                          -- O valor total é calculado multiplicando o número de dias pelo preço unitário da diária.
	INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal);     -- A inserção na tabela agora inclui o valor total calculado automaticamente.
END$$
DELIMITER ;

-- Inserindo novos dados:
CALL novoAluguel_24('10004', '1004', '8635', '2023-03-13', '2023-03-16', 40);

-- Confirmando a inserção:
SELECT * FROM alugueis where aluguel_id = '10004';

-- 2.E Tratando exceções.

-- ETAPA 5
-- O que queremos é que, ao executar a nossa procedure (procedimento), não recebamos esse erro. Em vez disso, desejamos que seja exibido um alerta ou uma mensagem, sem que ocorra um 
-- erro dentro do banco de dados.
-- Erro de Chave Estrangeira ao Inserir Aluguel:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novoAluguel_25`;
DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_25`
(vAluguel VARCHAR(10), vCliente VARCHAR(10), vHospedagem VARCHAR(10), vDataInicio DATE, vDataFinal DATE, vPrecoUnitario DECIMAL(10, 2)) 

BEGIN
	DECLARE vDias INT DEFAULT 0;                    
    DECLARE vPrecoTotal DECIMAL(10, 2);
    DECLARE VMensagem VARCHAR(100);                    -- Variável para armazenar a mensagem de erro ou sucesso.
    DECLARE EXIT HANDLER FOR 1452                      -- Definição de um manipulador de exceções. O código de erro 1452 refere-se ao erro de chave estrangeira no MySQL.
    BEGIN
		SET vMensagem = 'Problema de chave estrangeira associado a alguma entidade da base.';   -- Quando o erro 1452 ocorrer, será exibida uma mensagem amigável ao invés do erro padrão.
        SELECT vMensagem;
    END;                                               
    SET vDias = (SELECT DATEDIFF (vDataFinal, vDataInicio));         
    SET vPrecoTotal = vDias * vPrecoUnitario;                       
	INSERT INTO alugueis VALUES (vAluguel, vCliente, vHospedagem, vDataInicio, vDataFinal, vPrecoTotal);
    SET vMensagem = 'Aluguel incluido na base com sucesso.';    -- Mensagem de sucesso exibida após a inserção bem-sucedida.
    SELECT vMensagem;
END$$
DELIMITER ;

-- Chamada da rotina (observar a mensagem):
-- Cliente inexistente.
CALL novoAluguel_25('10005', '10001' '8635', '2023-03-17', '2023-03-25', 40);

-- Cliente existente.
CALL novoAluguel_25('10005', '1004', '8635', '2023-03-17', '2023-03-25', 40);









