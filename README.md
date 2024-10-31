**Visão Geral**

Este repositório contém as práticas e o desenvolvimento de stored procedures em MySQL, focando na gestão de aluguéis para a empresa fictícia Insight Places de hospedagem, onde temos diversos proprietários que cadastram seus imóveis para aluguel de temporada.

**Realizando consultas com MySQL: Executando Procedures**
 
Durante o curso, abordamos desde a configuração inicial da base de dados até a implementação de procedimentos complexos para gerenciar a inclusão de novos aluguéis.

*Conteúdo Aprendido*

Configuração da Base de Dados
Configuração Inicial: Estabelecemos a base de dados necessária para o funcionamento das operações da Insight Places.
Compreensão do Negócio: Analisamos os desafios enfrentados pela empresa, principalmente na gestão de novos aluguéis.

*Identificação do Problema*

Gerenciamento de Aluguéis: Identificamos a dificuldade da empresa em gerenciar eficientemente a entrada de novos aluguéis.

*Conceitos de Stored Procedures*

Introdução: Aprendemos os conceitos fundamentais de stored procedures no MySQL.
Primeira Stored Procedure: Desenvolvemos e executamos nossa primeira procedure: "Alô Mundo".

*Desenvolvimento de Procedures*

Inclusão de Hospedagens: Criamos uma procedure que exibe dados para inclusão de hospedagens na tabela de aluguéis, substituindo a exibição por um comando INSERT para efetivar a inclusão.
Cálculo de Datas: Utilizamos a função DATEDIFF para calcular automaticamente a data final com base no número de dias de hospedagem.
Cálculo de Custos: Alteramos o parâmetro de custo total para um valor diário, permitindo o cálculo total dentro da procedure.

*Tratamento de Erros*

Inserções Duplicadas: Implementamos tratamento de erros para evitar inserções que violassem a chave primária.
Nomes Duplicados: Tratamos erros decorrentes da inclusão de clientes com nomes duplicados.

*Estruturas Condicionais*

IF-THEN-ELSE: Implementamos desvios condicionais com IF-THEN-ELSE, evoluindo para IF-THEN-ELSE-IF para gerenciar múltiplas condições.
Uso de CASE-END CASE: Substituímos IF-THEN-ELSE-IF por CASE-END CASE para um gerenciamento mais eficiente das condições.

*Cálculo Avançado de Datas*

Cálculo de Data Final: Aprimoramos o cálculo da data final utilizando INTERVAL DAY.
Exclusão de Finais de Semana: Adaptamos a procedure para excluir finais de semana do cálculo de dias de hospedagem, usando um loop WHILE DO - END WHILE.

*Otimização do Código*

Subprocedures: Segmentamos a procedure em subprocedures, isolando o cálculo da data final para otimização do código.
Gerenciamento de Identificadores: Melhoramos a obtenção do identificador de aluguel, convertendo valores de texto para inteiro e calculando o próximo identificador.

*Inclusão de Múltiplos Clientes*

Tabela Temporária: Gerenciamos a inclusão de múltiplos clientes em uma hospedagem usando uma tabela temporária devido à limitação estrutural da base de dados.
Uso de Cursor: Utilizamos a estrutura de cursor para iterar sobre os registros da tabela temporária, compreendendo seu funcionamento no MySQL.

*Implementação Final*

Inclusão de Aluguéis: Implementamos a inclusão de aluguéis com base nos dados dos clientes armazenados na tabela temporária.

*Conclusão*

Este projeto é um reflexo do conhecimento adquirido ao longo do curso sobre stored procedures em MySQL, abordando conceitos fundamentais e práticas avançadas para gerenciar a base de dados 
de uma empresa de forma eficiente. O código e as procedures desenvolvidas demonstram a aplicação de conceitos teóricos em um cenário prático, preparando-nos para desafios reais no gerenciamento de dados.

**Realizando consultas com MySQL: Trabalhando com Funções**

*Objetivos*

Esta etapa teve como objetivo capacitar na criação e utilização de funções nativas e personalizadas do MySQL, incluindo triggers e técnicas para lidar com dados complexos, inconsistentes ou que necessitam de transformação.

*Conteúdos Principais*

*Criação e Manipulação de Estrutura de Dados*

Criação de banco de dados e tabelas
Importação de dados para o MySQL

*Funções de Agregação*

Contagem de registros com COUNT

Outras funções de agregação para sumarização e análise de dados

*Manipulação de Dados com Funções de String, Datas e Números*

Padronização de dados textuais e formatação de dados numéricos

Manipulação de datas para relatórios específicos

*Funções Condicionais e Customizadas*

Uso do CASE para classificações dinâmicas

Criação de funções personalizadas com variáveis, parâmetros e retornos compostos

Chamada de funções dentro de outras funções

*Triggers e Tratamento de Erros*

Criação e execução de triggers

Tratamento de erros e boas práticas para alteração e exclusão de funções

*Benefícios*

Essas técnicas tornam a análise de dados mais precisa e acessível, permitindo que gestores tomem decisões com base em dados organizados e padronizados.


