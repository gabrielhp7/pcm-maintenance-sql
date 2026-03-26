--2. DML (Data Manipulation Language - Linguagem de Manipulação de Dados)


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