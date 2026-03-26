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