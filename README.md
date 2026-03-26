# ⚙️ Industrial Maintenance Management System (PCM)

This repository contains the data structure and analytical intelligence for a **Maintenance Planning and Control (PCM)** system. The project focuses on reducing machine downtime and optimizing operational costs in an industrial plant.

## 📊 Architecture and Modeling
The database was designed to integrate everything from the organizational core to sensor telemetry (IoT).

```mermaid
erDiagram
    CENTROS-CUSTO ||--o{ LOCALIZACAO-TECNICA : aloca
    LOCALIZACAO-TECNICA ||--o{ MAQUINAS : contem
    MAQUINAS ||--o{ ORDENS-SERVICO : gera
    MAQUINAS ||--o{ TELEMETRIA-SENSORES : monitora
    TECNICOS ||--o{ ORDENS-SERVICO : executa
    ORDENS-SERVICO ||--o{ ITENS-OS-MATERIAIS : consome
    COMPONENTES ||--o{ ITENS-OS-MATERIAIS : fornece
