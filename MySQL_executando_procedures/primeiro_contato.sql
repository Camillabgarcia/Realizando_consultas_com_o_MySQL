-- Desafio 01. Incluindo um aluguel nova dentro da base de dados:
-- Criando uma Procedure:
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
