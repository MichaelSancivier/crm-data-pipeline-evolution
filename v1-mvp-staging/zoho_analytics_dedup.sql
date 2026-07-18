-- ==============================================================================================
-- CASE STUDY: CRM DATA ARCHITECTURE EVOLUTION (V1 MVP)
-- ARCHITECT: Michael Sancivier (Senior CRM & Data Architect)
-- OBJECTIVE: Multi-tier ETL Pipeline in Zoho Analytics to consolidate, deduplicate, and enrich
-- IMPACT: Consolidated 5 fragmented sources, standardized Brazilian census data, and output 11.6k unique rows.
-- ==============================================================================================

-- ==============================================================================================
-- TIER 1: STAGING LAYER (Data Ingestion & Consolidation)
-- Description: Unifies fragmented tables (Candidates, Students, Vouchers, Employability, Surveys) 
-- into a single raw staging view using UNION ALL.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_staging_all_sources AS
SELECT LOWER(TRIM("E-mail")) AS join_email, "E-mail" AS email_principal, "Nome Completo" AS nome_completo, "Estado" AS estado_raw, "Genero" AS genero_raw, "Fecha de nacimiento" AS data_nascimento, 1 AS existe_em_candidatos, 0 AS existe_em_alumnos, 0 AS existe_em_vouchers
FROM "Candidatos" WHERE "E-mail" IS NOT NULL AND UPPER(TRIM("Programa")) = 'CAMPINHO DIGITAL'
UNION ALL
SELECT LOWER(TRIM("E-mail")) AS join_email, "E-mail" AS email_principal, "Nome Completo" AS nome_completo, "Estado" AS estado_raw, "Genero 2" AS genero_raw, "Data de Nascimento" AS data_nascimento, 0 AS existe_em_candidatos, 1 AS existe_em_alumnos, 0 AS existe_em_vouchers
FROM "Alumnos" WHERE "E-mail" IS NOT NULL AND UPPER(TRIM("Programa")) = 'CAMPINHO DIGITAL'
-- Note: Additional UNION ALL blocks for Vouchers, Employability, and Surveys have been 
-- consolidated in the live environment to map source origin flags (existe_em_*).
;

-- ==============================================================================================
-- TIER 2: TRANSFORMATION & GOLDEN RECORD LAYER
-- Description: Deduplicates records by email. Standardizes geographic locations (IBGE mapping), 
-- unifies gender categories, and calculates analytical age fields.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_transformed_golden_record AS
SELECT
    base.join_email,
    MAX(base.email_principal) AS email_principal,
    MAX(base.nome_completo) AS nome_completo,
    
    -- Geographic Standardization (Mapping to IBGE Standards)
    CASE
        WHEN MAX(base.estado_raw) IS NULL OR TRIM(MAX(base.estado_raw)) = '' THEN 'Não Informado'
        WHEN TRIM(MAX(base.estado_raw)) IN ('SP', 'São Paulo', 'Sao Paulo', 'SÃO PAULO') THEN 'São Paulo (SP)'
        WHEN TRIM(MAX(base.estado_raw)) IN ('RJ', 'Rio de Janeiro', 'RIO DE JANEIRO') THEN 'Rio de Janeiro (RJ)'
        WHEN TRIM(MAX(base.estado_raw)) IN ('MG', 'Minas Gerais', 'MINAS GERAIS') THEN 'Minas Gerais (MG)'
        -- Note: Full Brazilian state mapping applied in production.
        ELSE 'Não Informado'
    END AS estado_padronizado,

    -- Gender Unification
    CASE
        WHEN MAX(base.genero_raw) IN ('Hombre Cis', 'Homem Cis', 'Masculino', 'Homem') THEN 'Homem Cis'
        WHEN MAX(base.genero_raw) IN ('Mujer Cis', 'Mulher Cis', 'Feminino') THEN 'Mulher Cis'
        ELSE COALESCE(MAX(base.genero_raw), 'Não Informado')
    END AS genero_unificado,

    -- Age Calculation & Demographic Segmentation
    CASE
        WHEN MAX(base.data_nascimento) IS NULL THEN 'Sem Data'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 18 THEN 'Menor de 18'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 25 THEN '18 a 24 anos'
        WHEN DATEDIFF(CURRENT_DATE(), MAX(base.data_nascimento)) / 365.25 < 35 THEN '25 a 34 anos'
        ELSE '35 anos ou mais'
    END AS faixa_etaria,

    -- Source Attribution Matrix
    MAX(base.existe_em_candidatos) AS flag_candidato,
    MAX(base.existe_em_alumnos) AS flag_alumno
FROM vw_staging_all_sources base
GROUP BY base.join_email;

-- ==============================================================================================
-- TIER 3: PRODUCTION EXPORT LAYER
-- Description: The final flat-table export. Joins the Golden Record with subqueries calculating 
-- active academic status and certification statuses to feed the Machine Learning pipeline.
-- ==============================================================================================
CREATE OR REPLACE VIEW vw_final_production_export AS
SELECT
    -- PII Splitting for downstream operations
    CASE WHEN p.nome_completo IS NOT NULL THEN SUBSTRING_INDEX(TRIM(p.nome_completo), ' ', 1) ELSE '' END AS first_name,
    p.email_principal AS email,
    p.estado_padronizado AS location_state,
    p.genero_unificado AS demographic_gender,
    p.faixa_etaria AS demographic_age_range,
    
    -- Academic & Service State enrichment
    COALESCE(m.cursada, 'Sem Cursada') AS current_academic_cohort,
    CASE
        WHEN COALESCE(m.tem_cursada_atual, 0) = 1 THEN 'Active Student'
        WHEN COALESCE(m.tem_matricula, 0) = 1 THEN 'Inactive Student'
        ELSE 'Lead/Candidate'
    END AS operational_profile_status,
    
    -- Feature engineering placeholders for ML Pipeline (Acquisition Source)
    '' AS ml_predicted_acquisition_channel,
    '' AS ml_confidence_score
FROM vw_transformed_golden_record p

-- Academic History Subquery
LEFT JOIN (
    SELECT join_email, 
           MAX(CASE WHEN eh_cursada_atual = 1 THEN 1 ELSE 0 END) AS tem_cursada_atual,
           MAX(nome_cursada) AS cursada
    FROM "vw_matriculas_campinho"
    GROUP BY join_email
) m ON p.join_email = m.join_email;
