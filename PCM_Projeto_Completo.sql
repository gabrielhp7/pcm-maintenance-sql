-- =============================================================================
-- Projeto de Planejamento e Controle da Manutenção
-- Autor: Gabriel Henrique Pedroso.
-- =============================================================================

-- 1. DDL (Data Definition Language - Linguagem de Definição de Dados)
-- 1. NÚCLEO ORGANIZACIONAL
CREATE TABLE centros_custo (
    id_centro_custo INT PRIMARY KEY AUTO_INCREMENT,
    codigo_contabil VARCHAR(20) UNIQUE NOT NULL,
    descricao VARCHAR(100),
    orcamento_anual DECIMAL(15,2)
);

CREATE TABLE localizacao_tecnica (
    id_localizacao INT PRIMARY KEY AUTO_INCREMENT,
    tag_localizacao VARCHAR(50) UNIQUE NOT NULL, -- Ex: JAG-PROD-MP01 ((nome da cidade)-Produção-Máquina01)
    descricao VARCHAR(255),
    id_centro_custo INT,
    FOREIGN KEY (id_centro_custo) REFERENCES centros_custo(id_centro_custo)
);

-- 2. GESTÃO DE ATIVOS (EQUIPAMENTOS)
CREATE TABLE maquinas (
    id_maquina INT PRIMARY KEY AUTO_INCREMENT,
    tag_equipamento VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    fabricante VARCHAR(100),
    modelo VARCHAR(100),
    data_instalacao DATE,
    id_localizacao INT,
    criticidade ENUM('A', 'B', 'C') NOT NULL, -- Classe A (Vital), B (Essencial), C (Apoio)
    custo_hora_parada DECIMAL(10,2) NOT NULL,
    status_operacional ENUM('Operando', 'Parada', 'Manutenção', 'Reserva') DEFAULT 'Operando',
    FOREIGN KEY (id_localizacao) REFERENCES localizacao_tecnica(id_localizacao)
);

-- 3. CAPITAL HUMANO E MÃO DE OBRA
CREATE TABLE cargos_tecnicos (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    nome_cargo VARCHAR(50),
    valor_hora_padrao DECIMAL(10,2)
);

CREATE TABLE tecnicos (
    id_tecnico INT PRIMARY KEY AUTO_INCREMENT,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    id_cargo INT,
    especialidade ENUM('Mecânica', 'Elétrica', 'Automação', 'Lubrificação', 'Civil'),
    turno ENUM('A', 'B', 'C', 'ADM'),
    FOREIGN KEY (id_cargo) REFERENCES cargos_tecnicos(id_cargo)
);

-- 4. ALMOXARIFADO E MATERIAIS
CREATE TABLE componentes (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    part_number VARCHAR(100) UNIQUE,
    descricao VARCHAR(255) NOT NULL,
    unidade_medida VARCHAR(10) DEFAULT 'UN',
    preco_unitario DECIMAL(10,2),
    estoque_atual INT DEFAULT 0,
    estoque_seguranca INT DEFAULT 10
);

-- 5. PLANEJAMENTO E EXECUÇÃO (PCM)
CREATE TABLE ordens_servico (
    id_os INT PRIMARY KEY AUTO_INCREMENT,
    id_maquina INT,
    id_tecnico_responsavel INT,
    tipo_manutencao ENUM('Preventiva', 'Corretiva', 'Preditiva', 'Melhoria', 'Lubrificação'),
    prioridade ENUM('Emergência', 'Alta', 'Média', 'Baixa'),
    data_abertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_programada DATE,
    data_conclusao DATETIME,
    status_os ENUM('Planejada', 'Aprovada', 'Em Execução', 'Suspensa', 'Encerrada', 'Cancelada'),
    causa_raiz VARCHAR(255), -- Preenchido no encerramento (Método dos 5 Porquês)
    observacoes_tecnicas TEXT,
    CONSTRAINT chk_encerramento CHECK (data_conclusao >= data_abertura OR data_conclusao IS NULL),
    FOREIGN KEY (id_maquina) REFERENCES maquinas(id_maquina),
    FOREIGN KEY (id_tecnico_responsavel) REFERENCES tecnicos(id_tecnico)
);

CREATE TABLE itens_os_materiais (
    id_vinculo INT PRIMARY KEY AUTO_INCREMENT,
    id_os INT,
    id_componente INT,
    quantidade_usada INT NOT NULL,
    FOREIGN KEY (id_os) REFERENCES ordens_servico(id_os),
    FOREIGN KEY (id_componente) REFERENCES componentes(id_componente)
);

-- 6. CONFIABILIDADE E BIG DATA (IoT)
CREATE TABLE historico_falhas (
  id_falha INT PRIMARY KEY AUTO_INCREMENT,
  id_maquina INT,
  id_os INT,
  data_inicio_falha DATETIME NOT NULL,
  data_fim_falha DATETIME,
  descricao_sintoma TEXT,
  -- Adicionamos a palavra GENERATED ALWAYS e VIRTUAL para clareza total
  tempo_total_indisponibilidade_minutos INT GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, data_inicio_falha, data_fim_falha)) VIRTUAL,
  FOREIGN KEY (id_maquina) REFERENCES maquinas(id_maquina),
  FOREIGN KEY (id_os) REFERENCES ordens_servico(id_os)
);

CREATE TABLE telemetria_sensores (
    id_leitura BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_maquina INT,
    data_leitura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    temperatura DECIMAL(6,2),
    vibracao_rms DECIMAL(6,2),
    corrente_eletrica DECIMAL(6,2),
    status_sensor ENUM('Normal', 'Alerta', 'Critico'),
    FOREIGN KEY (id_maquina) REFERENCES maquinas(id_maquina)
);
-------------------------------------------------------------------------------------------------------------------------------------


-- 2. DCL (Data Control Language - Controle de Acesso e Segurança)

-- 1. Criando papéis (Roles) para diferentes níveis de usuários
-- O Gestor tem acesso total, o Técnico apenas insere dados.
--CREATE ROLE IF NOT EXISTS 'gestor_pcm', 'tecnico_manutencao';

-- 2. Atribuindo privilégios ao Gestor (Pode tudo no banco de manutenção)
--GRANT ALL PRIVILEGES ON sistema_manutencao.* TO 'gestor_pcm';

-- 3. Atribuindo privilégios ao Técnico (Apenas leitura e inserção de OS e Sensores)
-- Protege tabelas sensíveis como 'centros_custo' contra alterações indevidas.
--GRANT SELECT ON sistema_manutencao.maquinas TO 'tecnico_manutencao';
--GRANT SELECT, INSERT, UPDATE ON sistema_manutencao.ordens_servico TO 'tecnico_manutencao';
--GRANT INSERT ON sistema_manutencao.telemetria_sensores TO 'tecnico_manutencao';

-- 4. Criando um usuário exemplo para o time de (nome da cidade)
--CREATE USER 'tecnico_nomedacidade'@'localhost' IDENTIFIED BY 'SenhaSegura';
--GRANT 'tecnico_manutencao' TO 'tecnico_nomedacidade';
--FLUSH PRIVILEGES; -- Aplica as mudanças imediatamente
---------------------------------------------------------------------------------------------------------------------------------------


--3. DML (Data Manipulation Language - Linguagem de Manipulação de Dados)


-- 1. NÚCLEO ORGANIZACIONAL (Centros de Custo e Localizações)
INSERT INTO centros_custo (codigo_contabil, descricao, orcamento_anual) VALUES
('1010-PROD', 'Produção de Papel e Celulose', 5000000.00),
('2020-UTIL', 'Utilidades e Caldeiras', 2500000.00),
('3030-MANU', 'Oficina Central de Manutenção', 1200000.00),
('4040-LOGI', 'Logística e Expedição', 800000.00);

--(OBS.: "JAG" é a abreviação do nome da cidade)
INSERT INTO localizacao_tecnica (tag_localizacao, descricao, id_centro_custo) VALUES
('JAG-PROD-MP01', 'Linha da Máquina de Papel 01', 1),
('JAG-PROD-PREP', 'Preparação de Massa e Refinação', 1),
('JAG-UTIL-CALD', 'Área de Caldeiras de Biomassa', 2),
('JAG-LOGI-ALMO', 'Almoxarifado e Docas', 4);

-- 2. GESTÃO DE ATIVOS (As Máquinas da (nome da empresa))
INSERT INTO maquinas (tag_equipamento, nome, fabricante, modelo, data_instalacao, id_localizacao, criticidade, custo_hora_parada, status_operacional) VALUES
('MP01-FORM', 'Seção de Formação MP01', 'Voith', 'MasterFormer', '2015-05-20', 1, 'A', 12000.00, 'Operando'),
('MP01-PREN', 'Seção de Prensas MP01', 'Metso', 'OptiPress', '2015-06-15', 1, 'A', 10000.00, 'Operando'),
('CALD-BIO-01', 'Caldeira de Biomassa B01', 'CBC', 'W-Type', '2010-10-10', 3, 'A', 15000.00, 'Operando'),
('REF-MAS-05', 'Refinador de Massa RM05', 'Andritz', 'TwinFlo', '2018-03-12', 2, 'B', 3500.00, 'Operando'),
('BOMB-HID-12', 'Bomba de Massa de Alta Vazão', 'Sulzer', 'APP-54', '2020-01-05', 2, 'B', 1500.00, 'Manutenção'),
('EST-TRAN-01', 'Esteira Transportadora de Cavacos', 'Metso', 'Conv-200', '2012-08-20', 4, 'C', 500.00, 'Operando');

-- 3. CAPITAL HUMANO (O Time Técnico)
INSERT INTO cargos_tecnicos (nome_cargo, valor_hora_padrao) VALUES
('Mecânico Industrial Especialista', 85.00),
('Eletricista de Manutenção III', 75.00),
('Técnico em Automação e IOT', 95.00),
('Lubrificador de Máquinas', 45.00);

INSERT INTO tecnicos (matricula, nome, id_cargo, especialidade, turno) VALUES
('BP-001', 'Ricardo Oliveira', 1, 'Mecânica', 'A'),
('BP-002', 'Marcos Souza', 2, 'Elétrica', 'B'),
('BP-003', 'Julia Mendes', 3, 'Automação', 'ADM'),
('BP-004', 'Paulo Santos', 4, 'Lubrificação', 'C');

-- 4. ALMOXARIFADO (Peças e Insumos)
INSERT INTO componentes (part_number, descricao, unidade_medida, preco_unitario, estoque_atual, estoque_seguranca) VALUES
('SKF-6312-C3', 'Rolamento de Esferas SKF', 'UN', 450.00, 25, 10),
('VED-VIT-200', 'Vedação em Viton Alta Temperatura', 'UN', 120.00, 8, 15), -- ABAIXO DO ESTOQUE!
('OLE-SYN-I46', 'Óleo Sintético ISO VG 46', 'L', 55.00, 500, 100),
('SENS-VIB-01', 'Sensor de Vibração Wireless', 'UN', 890.00, 12, 5),
('FILT-HID-X1', 'Elemento Filtrante Hidráulico', 'UN', 280.00, 4, 10); -- ABAIXO DO ESTOQUE!

-- 5. HISTÓRICO DE FALHAS E ORDENS (Simulando 3 meses de dados)
INSERT INTO ordens_servico (id_maquina, id_tecnico_responsavel, tipo_manutencao, prioridade, data_abertura, data_conclusao, status_os, causa_raiz) VALUES
(1, 1, 'Corretiva', 'Emergência', '2026-01-10 08:00:00', '2026-01-10 14:00:00', 'Encerrada', 'Fadiga de Material'),
(3, 2, 'Preventiva', 'Média', '2026-01-15 07:00:00', '2026-01-15 17:00:00', 'Encerrada', 'Manutenção Programada'),
(2, 3, 'Preditiva', 'Alta', '2026-02-01 09:30:00', '2026-02-01 11:00:00', 'Encerrada', 'Desalinhamento Detectado via Sensor'),
(5, 1, 'Corretiva', 'Alta', '2026-03-20 14:00:00', NULL, 'Em Execução', NULL);

INSERT INTO itens_os_materiais (id_os, id_componente, quantidade_usada) VALUES
(1, 1, 2), (1, 2, 4), -- Troca de rolamentos e vedações na OS 1
(2, 3, 40),          -- Troca de óleo na OS 2
(3, 4, 1);           -- Substituição de sensor na OS 3

INSERT INTO historico_falhas (id_maquina, id_os, data_inicio_falha, data_fim_falha, descricao_sintoma) VALUES
(1, 1, '2026-01-10 07:45:00', '2026-01-10 14:00:00', 'Ruído excessivo no mancal de acionamento'),
(4, NULL, '2026-02-10 10:00:00', '2026-02-10 12:30:00', 'Travamento de rolo guia por sujeira');

-- 6. BIG DATA (Telemetria de Sensores - Simulando leituras reais)
INSERT INTO telemetria_sensores (id_maquina, temperatura, vibracao_rms, corrente_eletrica, status_sensor) VALUES
(1, 75.4, 2.1, 145.0, 'Normal'),
(1, 76.8, 2.5, 146.2, 'Normal'),
(3, 115.2, 5.8, 210.5, 'Critico'), -- Simulando sobrecarga na caldeira
(3, 118.0, 6.2, 215.0, 'Critico'),
(4, 45.0, 1.2, 88.0, 'Normal'),
(2, 82.1, 4.9, 130.0, 'Alerta');
--------------------------------------------------------------------------------------------------------------------------------------


--4. DQL (Data Query Language - Linguagem de Consulta de Dados)
--📊 Inteligência de Negócio e PCM: Consultas de Alto Impacto

--1. Visão Financeira: O "Top 6" do Prejuízo
--Este comando cruza as falhas com o custo de parada da máquina.
--Identifica quais máquinas estão drenando o caixa da empresa através de paradas.
--Cruza o tempo de indisponibilidade com o custo/hora específico de cada ativo.
SELECT 
    m.nome AS maquina,
    COUNT(h.id_falha) AS total_falhas,
    SUM(h.tempo_total_indisponibilidade_minutos) / 60 AS total_horas_paradas,
    SUM((h.tempo_total_indisponibilidade_minutos / 60) * m.custo_hora_parada) AS custo_total_indisponibilidade
FROM maquinas m
JOIN historico_falhas h ON m.id_maquina = h.id_maquina
GROUP BY m.nome
ORDER BY custo_total_indisponibilidade DESC
LIMIT 5;


--2. Monitoramento de Sensores: Alerta de Preditiva
--Este SELECT atua na telemetria. Ele busca máquinas que estão "febris" ou vibrando demais, permitindo agir antes de quebrar.
--Filtra equipamentos que registraram alertas críticos nas últimas 24 horas.
--Essencial para evitar quebras catastróficas em ativos classe 'A'.
SELECT 
    m.tag_equipamento,
    m.nome,
    MAX(t.temperatura) AS temperatura_pico,
    MAX(t.vibracao_rms) AS vibracao_pico,
    COUNT(*) AS qtd_alertas
FROM telemetria_sensores t
JOIN maquinas m ON t.id_maquina = m.id_maquina
WHERE t.status_sensor = 'Critico' 
  AND t.data_leitura >= NOW() - INTERVAL 1 DAY
GROUP BY m.tag_equipamento, m.nome;


--3. Gestão de Equipe: Backlog e Carga de Trabalho
--O PCM precisa saber se o time está sobrecarregado. Aqui medimos quantas OS estão abertas por técnico.
--Mostra a distribuição de trabalho e o tempo médio que as ordens estão abertas.
--Útil para balancear a carga entre mecânicos, eletricistas e automação.
SELECT 
    t.nome AS tecnico,
    t.especialidade,
    COUNT(os.id_os) AS ordens_ativas,
    ROUND(AVG(DATEDIFF(CURRENT_DATE, os.data_abertura)), 1) AS media_dias_aberta
FROM tecnicos t
LEFT JOIN ordens_servico os ON t.id_tecnico = os.id_tecnico_responsavel
WHERE os.status_os NOT IN ('Encerrada', 'Cancelada')
GROUP BY t.nome, t.especialidade;


--4. Confiabilidade: Cálculo de MTBF e MTTR
--Estes são os KPIs sagrados do PCM.
--MTBF: Tempo médio entre falhas (Quanto maior, mais confiável).
--MTTR: Tempo médio para reparo (Quanto menor, mais eficiente).
-- Calcula os indicadores de confiabilidade (MTBF) e mantibilidade (MTTR).
-- Essencial para avaliar se o plano de manutenção preventiva está sendo eficaz.
SELECT 
    m.nome,
    ROUND(AVG(h.tempo_total_indisponibilidade_minutos), 2) AS mttr_minutos,
    -- Simulação de MTBF: (720h de operação / número de falhas)
    ROUND(720 / COUNT(h.id_falha), 2) AS mtbf_horas_estimado
FROM maquinas m
JOIN historico_falhas h ON m.id_maquina = h.id_maquina
GROUP BY m.nome;


--5. Controle de Estoque: Curva de Consumo
--Evitar que falte peça no meio da noite em (nome da cidade).
--Lista componentes que estão abaixo do estoque de segurança.
--Evita que uma máquina de milhões de reais fique parada por falta de uma peça simples.
SELECT 
    part_number,
    descricao,
    estoque_atual,
    estoque_seguranca,
    (estoque_seguranca - estoque_atual) AS necessidade_compra
FROM componentes
WHERE estoque_atual < estoque_seguranca;


--6. Análise de Causa Raiz: Onde o problema nasce
--Ranking das principais causas de paradas na planta.
--Direciona investimentos em treinamento ou substituição de componentes ruins.
SELECT 
    os.causa_raiz,
    COUNT(DISTINCT os.id_os) AS recorrencia,
    -- Somamos (quantidade usada * preço unitário do componente)
    SUM(iom.quantidade_usada * c.preco_unitario) AS gasto_acumulado_material
FROM ordens_servico os
LEFT JOIN itens_os_materiais iom ON os.id_os = iom.id_os
LEFT JOIN componentes c ON iom.id_componente = c.id_componente
WHERE os.status_os = 'Encerrada' AND os.causa_raiz IS NOT NULL
GROUP BY os.causa_raiz
ORDER BY recorrencia DESC;
-----------------------------------------------------------------------------------------------------------------------------------


-- 5. TCL (Transaction Control Language - Linguagem de controle de dados)

-- Exemplo de encerramento de OS com uso de Transação
-- Objetivo: Garantir que a OS só mude para 'Encerrada' se o estoque for atualizado com sucesso.
--START TRANSACTION;

-- Passo 1: Atualizar o status da Ordem de Serviço
--UPDATE ordens_servico 
--SET status_os = 'Encerrada', data_conclusao = NOW(), causa_raiz = 'Desgaste Natural'
--WHERE id_os = 4;

-- Passo 2: Dar baixa no estoque do componente utilizado (ex: Rolamento id 1)
-- IMPORTANTE: Se o estoque ficar negativo ou o servidor cair aqui, o COMMIT não acontece.
--UPDATE componentes 
--SET estoque_atual = estoque_atual - 2 
--WHERE id_componente = 1;

-- Passo 3: Se tudo correu bem, salvamos permanentemente
--COMMIT;

-- Caso ocorresse algum erro (ex: falta de estoque), usaríamos:
-- ROLLBACK; -- Isso desfaria o Passo 1 e o Passo 2 automaticamente.