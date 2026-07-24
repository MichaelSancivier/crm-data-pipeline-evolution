-- ==============================================================================================
-- PLAN MAESTRO REVOPS V9: DATA ENGINEERING & GEOFENCING PIPELINE (ZOHO ANALYTICS)
-- ARCHITECT: Michael Sancivier (Technical Product Owner & RevOps Specialist)
-- OBJECTIVE: Multi-tier Enterprise ETL Pipeline to ingest, deduplicate, and geofence data.
-- IMPACT: Compressed 147,604 raw records (132,248 candidates + 15,356 students) down to 
--         11,600 unique high-fidelity entities (~92% noise reduction) for Brazil target.
-- ==============================================================================================

-- ==============================================================================================
-- TIER 1: STAGING LAYER (Multi-Source Ingestion & Key Normalization)
-- Description: Unifies raw candidate leads (132.2k) and student exam records (15.3k)
-- into a normalized staging view using UNION ALL and lowercased email keys.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_staging_all_sources AS
SELECT 
    LOWER(TRIM("E-mail")) AS join_email, 
    "E-mail" AS email_principal, 
    "Nome Completo" AS nome_completo, 
    "Estado" AS estado_raw, 
    "Genero" AS genero_raw, 
    "Fecha de nacimiento" AS data_nascimento, 
    "Fuente de Candidato" AS fuente_candidato,
    1 AS existe_em_candidatos, 
    0 AS existe_em_alumnos
FROM "Candidatos" 
WHERE "E-mail" IS NOT NULL 
  AND "E-mail" LIKE '%@%'
  AND UPPER(TRIM("Programa")) = 'CAMPINHO DIGITAL'

UNION ALL

SELECT 
    LOWER(TRIM("E-mail")) AS join_email, 
    "E-mail" AS email_principal, 
    "Nome Completo" AS nome_completo, 
    "Estado" AS estado_raw, 
    "Genero 2" AS genero_raw, 
    "Data de Nascimento" AS data_nascimento, 
    NULL AS fuente_candidato,
    0 AS existe_em_candidatos, 
    1 AS existe_em_alumnos
FROM "Alumnos" 
WHERE "E-mail" IS NOT NULL 
  AND "E-mail" LIKE '%@%'
  AND UPPER(TRIM("Programa")) = 'CAMPINHO DIGITAL';

-- ==============================================================================================
-- TIER 2: TRANSFORMATION & GEOFENCING LAYER (Golden Record & Market Isolation)
-- Description: Aggregates by primary key (join_email). Applies Geofencing logic to isolate
-- the Brazilian market (dropping out-of-scope regional records like Argentina/Uruguay),
-- unifies gender, and calculates demographic age ranges.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_transformed_golden_record AS
SELECT
    base.join_email,
    MAX(base.email_principal) AS email_principal,
    MAX(base.nome_completo) AS nome_completo,
    MAX(base.fuente_candidato) AS fuente_candidato,
    
    -- GEOFENCING & GEOGRAPHIC STANDARDIZATION (Target: Brazil IBGE Standards)
    -- Isolates Brazil and filters out noise/out-of-region entries
    CASE
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('SP', 'SÃO PAULO', 'SAO PAULO') THEN 'São Paulo (SP)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('RJ', 'RIO DE JANEIRO') THEN 'Rio de Janeiro (RJ)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('MG', 'MINAS GERAIS') THEN 'Minas Gerais (MG)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('BA', 'BAHIA') THEN 'Bahia (BA)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('PR', 'PARANÁ', 'PARANA') THEN 'Paraná (PR)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('RS', 'RIO GRANDE DO SUL') THEN 'Rio Grande do Sul (RS)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('PE', 'PERNAMBUCO') THEN 'Pernambuco (PE)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('CE', 'CEARÁ', 'CEARA') THEN 'Ceará (CE)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('PA', 'PARÁ', 'PARA') THEN 'Pará (PA)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('SC', 'SANTA CATARINA') THEN 'Santa Catarina (SC)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('MA', 'MARANHÃO', 'MARANHAO') THEN 'Maranhão (MA)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('GO', 'GOIÁS', 'GOIAS') THEN 'Goiás (GO)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('PB', 'PARAÍBA', 'PARAIBA') THEN 'Paraíba (PB)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('AM', 'AMAZONAS') THEN 'Amazonas (AM)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('ES', 'ESPÍRITO SANTO', 'ESPIRITO SANTO') THEN 'Espírito Santo (ES)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('RN', 'RIO GRANDE DO NORTE') THEN 'Rio Grande do Norte (RN)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('AL', 'ALAGOAS') THEN 'Alagoas (AL)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('MT', 'MATO GROSSO') THEN 'Mato Grosso (MT)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('PI', 'PIAUÍ', 'PIAUI') THEN 'Piauí (PI)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('DF', 'DISTRITO FEDERAL') THEN 'Distrito Federal (DF)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('MS', 'MATO GROSSO DO SUL') THEN 'Mato Grosso do Sul (MS)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('SE', 'SERGIPE') THEN 'Sergipe (SE)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('RO', 'RONDÔNIA', 'RONDONIA') THEN 'Rondônia (RO)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('TO', 'TOCANTINS') THEN 'Tocantins (TO)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('AC', 'ACRE') THEN 'Acre (AC)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('AP', 'AMAPÁ', 'AMAPA') THEN 'Amapá (AP)'
        WHEN UPPER(TRIM(MAX(base.estado_raw))) IN ('RR', 'RORAIMA') THEN 'Roraima (RR)'
        ELSE 'INVALID_OR_OUT_OF_BOUNDS'
    END AS estado_padronizado,

    -- GENDER UNIFICATION
    CASE
        WHEN UPPER(TRIM(MAX(base.genero_raw))) IN ('HOMBRE CIS', 'HOMEM CIS', 'MASCULINO', 'HOMEM') THEN 'Homem Cis'
        WHEN UPPER(TRIM(MAX(base.genero_raw))) IN ('MUJER CIS', 'MULHER CIS', 'FEMININO') THEN 'Mulher Cis'
        ELSE COALESCE(MAX(base.genero_raw), 'Não Informado')
    END AS genero_unificado,

    -- AGE CALCULATION & DEMOGRAPHIC SEGMENTATION
    CASE
        WHEN MAX(base.data_nascimento) IS NULL THEN 'Sem Data'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 18 THEN 'Menor de 18'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 25 THEN '18 a 24 anos'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 35 THEN '25 a 34 anos'
        ELSE '35 anos ou mais'
    END AS faixa_etaria,

    -- SOURCE ATTRIBUTION MATRIX
    MAX(base.existe_em_candidatos) AS flag_candidato,
    MAX(base.existe_em_alumnos) AS flag_alumno
FROM vw_staging_all_sources base
GROUP BY base.join_email
-- GEOFENCING FILTER (V9): Exclude out-of-scope markets (e.g. Argentina) & invalid locations
HAVING estado_padronizado != 'INVALID_OR_OUT_OF_BOUNDS';

-- ==============================================================================================
-- TIER 3: PRODUCTION EXPORT LAYER (Golden Record Target: ~11,600 Unique Entities)
-- Description: The final flat-table export. Generates the Golden Record dataset for BigQuery
-- and feeds feature engineering inputs to the MLOps predictive pipeline.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_final_production_export AS
SELECT
    -- PII Splitting for downstream CRM & Firestore operations
    CASE WHEN p.nome_completo IS NOT NULL THEN SUBSTRING_INDEX(TRIM(p.nome_completo), ' ', 1) ELSE '' END AS first_name,
    p.email_principal AS email,
    p.estado_padronizado AS location_state,
    p.genero_unificado AS demographic_gender,
    p.faixa_etaria AS demographic_age_range,
    p.fuente_candidato AS acquisition_channel,
    
    -- Academic & Service State enrichment
    COALESCE(m.cursada, 'Sem Cursada') AS current_academic_cohort,
    CASE
        WHEN COALESCE(m.tem_cursada_atual, 0) = 1 THEN 'Active Student'
        WHEN COALESCE(m.tem_matricula, 0) = 1 THEN 'Inactive Student'
        ELSE 'Lead/Candidate'
    END AS operational_profile_status,
    
    -- Feature engineering placeholders for MLOps Pipeline (Fallback API)
    '' AS ml_predicted_acquisition_channel,
    '' AS ml_confidence_score
FROM vw_transformed_golden_record p

-- Academic History Subquery
LEFT JOIN (
    SELECT join_email, 
           MAX(CASE WHEN eh_cursada_atual = 1 THEN 1 ELSE 0 END) AS tem_cursada_atual,
           MAX(CASE WHEN matricula IS NOT NULL THEN 1 ELSE 0 END) AS tem_matricula,
           MAX(nome_cursada) AS cursada
    FROM "vw_matriculas_campinho"
    GROUP BY join_email
) m ON p.join_email = m.join_email;
