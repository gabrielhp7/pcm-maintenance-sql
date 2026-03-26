--3. DQL (Data Query Language - Linguagem de Consulta de Dados)
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