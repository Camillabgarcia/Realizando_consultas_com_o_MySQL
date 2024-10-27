-- 04. Trabalhando com variáveis e parâmetros.

-- 4.A Funções criadas pelo usuário.
DELIMITER $$                       -- Muda o delimitador para $$.

CREATE FUNCTION RetornoConstante() -- Cria a função RetornoConstante.
RETURNS VARCHAR(50) DETERMINISTIC  -- Define o retorno como VARCHAR(50) e determina que sempre retorna o mesmo valor.
BEGIN

RETURN 'Seja bem-vindo(a)';        -- Retorna a mensagem 'Seja bem-vindo(a)'.

END$$                               -- Finaliza a definição da função.

DELIMITER ;                         -- Restaura o delimitador para o padrão (;).

-- Chamando a função:
SELECT RetornoConstante();          -- Executa a função e exibe o retorno.

-- 4.B Declarando variáveis.

-- Função que calcula a média das notas.
-- Consulta para calcular a média:
SELECT ROUND(AVG(nota), 2) AS MediaNotas  -- Calcula a média e arredonda para 2 casas decimais.
FROM avaliacoes;

DELIMITER $$                           -- Muda o delimitador para $$.

CREATE FUNCTION MediaAvaliacoes()      -- Cria a função MediaAvaliacoes.
RETURNS FLOAT DETERMINISTIC             -- Define o retorno como FLOAT e determina que sempre retorna o mesmo valor.
BEGIN

DECLARE media FLOAT;                   -- Declara a variável para armazenar a média.

SELECT ROUND(AVG(nota), 2) AS MediaNotas  -- Consulta encapsulada que calcula a média.
INTO media                               -- Armazena o resultado na variável 'media'.
FROM avaliacoes;

RETURN media;                          -- Retorna a média calculada.
END$$                                   -- Finaliza a definição da função.

DELIMITER ;                             -- Restaura o delimitador para o padrão (;).

-- Chamando a função criada:
SELECT MediaAvaliacoes();              -- Executa a função e exibe o resultado da média.


-- 2.C Utilizando parâmetros.

-- Padronizando o cpf.
-- Consulta que será transformada em função:
SELECT
  TRIM(nome) AS Nome,
  CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS CPF_Mascarado
FROM
  clientes;

-- Criando a função que irá padronizar os campos de cpf:
DELIMITER $$

CREATE FUNCTION FormatandoCPF(ClienteID INT)
RETURNS VARCHAR(14) DETERMINISTIC
BEGIN
    DECLARE NovoCPF VARCHAR(14);

    -- Atribui o CPF formatado ao NovoCPF:
    SET NovoCPF = (
        SELECT CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2))
        FROM clientes
        WHERE cliente_id = ClienteID
        LIMIT 1
    );

    RETURN NovoCPF;
END$$

DELIMITER ;


-- Chamando a função criada com um ID escolhido:
SELECT formatandoCPF(1) AS CPF;

-- Chamando a nova função junto com a tabela de clientes:
SELECT TRIM(nome) AS Nome, formatandoCPF(1) AS CPF 
FROM clientes 
WHERE cliente_id = 1;
-- Retorna o nome e o cpf formatado.

-- 2.D Retornando mais de um valor.

-- Criação da função InfoAluguel para buscar informações sobre um aluguel específico, retornando o nome do cliente e o valor diário do aluguel
DELIMITER $$

CREATE FUNCTION InfoAluguel(IdAluguel INT)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    DECLARE nomeCliente VARCHAR(100);      -- Variável para armazenar o nome do cliente
    DECLARE precoTotal DECIMAL(10, 2);     -- Variável para armazenar o preço total do aluguel
    DECLARE Dias INT;                      -- Variável para armazenar a quantidade de dias do aluguel
    DECLARE valorDiaria DECIMAL(10, 2);    -- Variável para armazenar o valor diário calculado
    DECLARE resultado VARCHAR(255);        -- Variável para armazenar o resultado final da função

    -- Consulta SQL que busca o nome do cliente, o preço total e o número de dias do aluguel
    SELECT c.nome, a.preco_total, DATEDIFF(a.data_fim, a.data_inicio)
        INTO nomeCliente, precoTotal, Dias
        FROM alugueis a
        JOIN clientes c 
        ON a.cliente_id = c.cliente_id
        WHERE a.aluguel_id = IdAluguel;
    
    -- Calcula o valor diário do aluguel
    SET valorDiaria = precoTotal / Dias;
    
    -- Concatena as informações do cliente e o valor da diária em uma string
    SET resultado = CONCAT('Nome: ', nomeCliente, ' | Valor Diária: R$ ', FORMAT(valorDiaria, 2));

    -- Retorna a string formatada com as informações
    RETURN resultado;
END$$

DELIMITER ;

-- Chamando a função:
SELECT InfoAluguel(1);


