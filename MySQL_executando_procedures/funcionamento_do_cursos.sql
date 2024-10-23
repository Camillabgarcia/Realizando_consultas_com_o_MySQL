-- 05. Como funciona o CURSOR

-- 5.B Aplicando a inclusão da lista na tabela.

-- Desafio: Registrando mais de uma pessoa na hospedagem.
-- 5.2 Elaborando uma procedure para inserir uma lista de nomes em uma tabela temporária:

USE `insight_places`;
DROP PROCEDURE IF EXISTS `inclui_usuarios_listaaa_52`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inclui_usuarios_listaaa_52`(lista VARCHAR(255))
BEGIN
    DECLARE nome VARCHAR(255);
    DECLARE restante VARCHAR(255);
    DECLARE pos INT;

    SET restante = lista;

    -- Enquanto houver vírgulas na string 'restante', continua o processamento.
    WHILE INSTR(restante, ',') > 0 DO
        SET pos = INSTR(restante, ','); -- Encontra a posição da primeira vírgula.
        SET nome = LEFT(restante, pos - 1); -- Extrai o nome até a vírgula.
        INSERT INTO temp_nomes VALUES (nome); -- Insere o nome na tabela temporária.
        SET restante = SUBSTRING(restante, pos + 1); -- Atualiza 'restante' para remover o nome processado.
    END WHILE;

    -- Insere o último nome se 'restante' não estiver vazio.
    IF TRIM(restante) <> '' THEN
        INSERT INTO temp_nomes VALUES (TRIM(restante)); -- Insere o último nome.
    END IF;
END$$

DELIMITER ;


-- Criação da tabela temporária antes da chamada da procedure.
DROP TEMPORARY TABLE IF EXISTS temp_nomes; -- Remove a tabela temporária, se existir.
CREATE TEMPORARY TABLE temp_nomes (nome VARCHAR(255)); -- Cria a tabela temporária.

-- Testando a procedure `inclui_usuarios_lista_52`:
CALL inclui_usuarios_listaaa_52('Luana Moura, Enrico Correia, Paulo Vieira, Marina Nunes');

-- Verificando os dados inseridos:
SELECT * FROM temp_nomes;

-- 5.D Fazendo o looping com o cursor.

-- 5.4 Criando o primeiro cursos onde vamos percorrer todas as linhas da tabela temp_nomes e mostrar elemento a elemento dentro de um loop:

USE `insight_places`;
DROP procedure IF EXISTS `looping_cursor_54`;

DELIMITER $$
USE `insight_places`$$
CREATE PROCEDURE `looping_cursor_54` ()  -- Inicia a criação da procedure `looping_cursor_54` sem parâmetros.
BEGIN
    DECLARE fimCursor INT DEFAULT 0;  -- Declara a variável `fimCursor` para controlar o fim do loop, inicializando como 0.
    DECLARE vnome VARCHAR(255);  -- Declara a variável `vnome` para armazenar os nomes recuperados pelo cursor.
    
    DECLARE cursor1 CURSOR FOR SELECT nome FROM temp_nomes;  -- Cria um cursor chamado `cursor1` que irá buscar os nomes da tabela temporária `temp_nomes`.

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fimCursor = 1;  -- Define um manipulador que muda `fimCursor` para 1 quando não há mais registros a serem lidos (end of data).

    OPEN cursor1;  -- Abre o cursor para iniciar a leitura dos dados.
	FETCH cursor1 INTO vnome;  -- Recupera o próximo nome do cursor e armazena em `vnome`.
    WHILE fimCursor = 0 DO  -- Inicia um loop que continuará enquanto `fimCursor` for 0.
        SELECT vnome;  -- Exibe o nome armazenado em `vnome`.
        FETCH cursor1 INTO vnome;
    END WHILE;  -- Finaliza o loop quando não há mais nomes a serem processados.

    CLOSE cursor1;  -- Fecha o cursor após a leitura de todos os dados.
END$$  -- Finaliza a definição da procedure.

DELIMITER ; 

-- Abaixo, remove a tabela temporária `temp_nomes` se existir, para garantir que a tabela esteja limpa para a nova criação.
DROP TEMPORARY TABLE IF EXISTS temp_nomes;

-- Cria uma tabela temporária `temp_nomes` para armazenar os nomes.
CREATE TEMPORARY TABLE temp_nomes (nome VARCHAR(255));

-- Chama a procedure `inclui_usuarios_listaaa_52` para inserir uma lista de nomes na tabela temporária.
CALL inclui_usuarios_listaaa_52('João, Pedro, Maria, Lucia, Joana, Beatriz');

-- Seleciona todos os registros da tabela `temp_nomes` para verificar se os nomes foram inseridos corretamente.
SELECT * FROM temp_nomes;

-- Chama a procedure `looping_cursor_54` para executar o cursor e exibir os nomes armazenados na tabela temporária.
CALL looping_cursor_54();

-- 5.E Aplicando o cursor na inclusão de múltiplos aluguéis.

-- 5.5 Montando a stored procedure final:

USE `insight_places`;
DROP procedure IF EXISTS `insight_places`.`novosAlugueis_55`;
;

DELIMITER $$
USE `insight_places`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novosAlugueis_55`(lista VARCHAR(255), 
vHospedagem VARCHAR(10), vDataInicio DATE, 
vDias INT, vPrecoUnitario DECIMAL(10, 2))
BEGIN
    -- Declaração de variáveis.
    DECLARE vClienteNome VARCHAR(150);  -- Variável para armazenar o nome do cliente.
    DECLARE fimCursor INT DEFAULT 0;  -- Controlador de loop para verificar o fim da leitura do cursor.
    DECLARE vnome VARCHAR(255);  -- Variável para armazenar os nomes recuperados pelo cursor.

    -- Define o cursor para selecionar os nomes da tabela temporária `temp_nomes`.
    DECLARE cursor1 CURSOR FOR SELECT nome FROM temp_nomes;  
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fimCursor = 1;  -- Manipulador para sinalizar que não há mais registros.

    -- Remove a tabela temporária `temp_nomes` se existir para garantir que não haja conflitos.
    DROP TEMPORARY TABLE IF EXISTS temp_nomes;  
    -- Cria a tabela temporária `temp_nomes` para armazenar os nomes.
    CREATE TEMPORARY TABLE temp_nomes (nome VARCHAR(255));  
    -- Chama a procedure `inclui_usuarios_listaaa_52` para inserir os nomes na tabela temporária.
    CALL inclui_usuarios_listaaa_52(lista);  

    OPEN cursor1;  -- Abre o cursor para iniciar a leitura dos dados.
    
    -- Recupera o primeiro nome do cursor antes do loop.
    FETCH cursor1 INTO vnome;  
    -- Inicia o loop que continuará enquanto `fimCursor` for 0.
    WHILE fimCursor = 0 DO
        SET vClienteNome = vnome;  -- Armazena o nome atual na variável `vClienteNome`.
        -- Chama a procedure `novoAluguel_44` com os dados do cliente e informações do aluguel.
        CALL novoAluguel_44(vClienteNome, vHospedagem, vDataInicio, vDias, vPrecoUnitario);  
        FETCH cursor1 INTO vnome;  -- Recupera o próximo nome do cursor.
    END WHILE;  -- Finaliza o loop quando não há mais nomes a serem processados.

    CLOSE cursor1;  -- Fecha o cursor após a leitura de todos os dados.
    DROP TEMPORARY TABLE IF EXISTS temp_nomes;  -- Remove a tabela temporária após o uso.
END$$

DELIMITER ;

-- Chamando a rotina:
CALL novosAlugueis_55('Gabriel Carvalho,Erick Oliveira,Catarina Correia,Lorena Jesus', '8635', '2023-06-03', 7, 45); 
-- Mensagem: 'Aluguel incluído na base com sucesso - ID 10014, 10015, 10016, 10017'.

-- Conferindo os novos registros:
SELECT * FROM alugueis WHERE aluguel_id IN ('10014', '10015', '10016', '10017');





