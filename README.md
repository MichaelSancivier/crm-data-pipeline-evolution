# 🚀 MASTER PLAN: REVOPS ECOSYSTEM & DUAL AI ARCHITECTURE (V9)
**Enterprise Strategy: Legacy Migration, MLOps, Generative AI, and Privacy by Design**

![Google Cloud Platform](https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Python 3.10](https://img.shields.io/badge/Python_3.10-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Make](https://img.shields.io/badge/Make-6D00CC?style=for-the-badge&logo=make&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=googlebard&logoColor=white)
![HubSpot CRM](https://img.shields.io/badge/HubSpot_CRM-FF7A59?style=for-the-badge&logo=hubspot&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-669DF6?style=for-the-badge&logo=googlecloud&logoColor=white)

**PROFILE:** Michael Sancivier — Technical Product Owner & RevOps Process Specialist  
**CORE SKILLS:** Scrum | Six Sigma | FinOps Cloud Architecture | Data Pipeline Engineering | AI Orchestration

---

## 📊 1. Data Impact & Enterprise Metrics

| Strategic Dimension | Real Volume / Impact |
| :--- | :--- |
| **Legacy Migration Volume** | 147,604 raw records cleaned from the manual system. |
| **ETL Efficiency & Minimization** | 11,600 historical entities rescued (~92% noise reduction). |
| **Dual AI Architecture** | **Predictive (Scikit-Learn):** Social Media origin attribution. <br> **Generative (Gemini):** Real-time exam evaluation. |
| **Governance & Privacy** | Total anonymization (Faker), strict GDPR / LGPD compliance. |
| **FinOps & Orchestration** | Smart routing via Make & GCP at **$0.00 USD operating cost**. |

---

## 🎯 2. The Business Challenge: The Past and The Future
This repository documents the architectural evolution of a RevOps ecosystem that collapsed under the weight of **147,604 raw records**. 

As a Technical Product Owner, I designed an event-driven **Dual AI Architecture** to solve two critical business fronts while eliminating technical debt:

1. **The Past (Legacy Migration):** Migrate 11,600 historical records to a new CRM (HubSpot). These records suffered from severe data gaps, specifically missing **Social Media Origin (RRSS)**, which destroyed marketing attribution.
2. **The Future (New Leads):** Automate the qualitative evaluation of new candidates taking admission exams in Google Classroom, replacing a slow, manual process disconnected from the CRM.

---

## 🛠️ 3. Data Engineering & Privacy by Design (GDPR/LGPD)
* **SQL Funnel Pipeline:** Designed a 3-tier ETL engine (Staging ➔ Transformation ➔ Target) to clean and prepare the massive migration.
* **Geofencing & Data Minimization:** Applied strict GDPR/LGPD data minimization principles using regional logic to isolate the target market (Brazil) and discard out-of-scope data.
* **The Result:** Compressed 147,604 rows into **11,600 unique, validated historical entities**. This ~92% noise reduction drastically lowered the legal risk surface.

---

## 🧠 4. Dual AI Architecture

### 🔹 4.1 Predictive AI (Rescuing the Past)
To recover the missing marketing attribution of legacy records:
* **MLOps Training:** Trained a classification model (`Scikit-Learn`) in **Google Colab** capable of predicting the missing Social Media channel. Exported the artifacts (`model.pkl`) into a **Google Cloud Function** (Python 3.10) running at $0.00 USD cost.
* **Scenario 1 - Make (MLOps Router):** Orchestrated the migration using smart routing.
  * **"Happy Path":** If the legacy record was complete, it routed directly to HubSpot and BigQuery.
  * **"AI Path":** If the Social Media origin was missing, Make executed an HTTP request to the Cloud Function, predicting the data in milliseconds before injecting the enriched profile into the CRM.

### 🤖 4.2 Generative AI (Automating the Future)
For new candidate evaluations, I designed a real-time agentic ecosystem:
* **Scenario 2 - Make (Agentic Master Hub):** 
  1. Captures the exam event via a purified webhook.
  2. Dynamically extracts the master evaluation prompt from **Google Docs**, intelligently decoupling business logic from the integration flow.
  3. Sends the prompt and answers to **Gemini 2.5 Flash / Vertex AI**.
  4. The AI outputs a structured qualitative evaluation (JSON Parser), updating the existing contact record in **HubSpot CRM** and streaming logs to **BigQuery**.

---

## ⚡ 5. FinOps, Governance & Privacy
* **FinOps Mastery:** By using GCP for the heavy lifting and Make exclusively to react to webhooks and route data, the entire infrastructure (MLOps and GenAI) operates at a **$0.00 USD structural cost**.
* **Responsible AI & Traceability:** Every model prediction and Gemini evaluation logs its respective `Confidence Score` directly into **Google BigQuery** and HubSpot, enabling real-time auditing.
* **PII Isolation:** The entire pipeline was initially stress-tested using synthetic data generated in Python (`Faker pt_BR`) to guarantee zero exposure of Personally Identifiable Information during development.

---

## 📁 6. Repository Structure

```text
crm-data-pipeline-evolution/
├── v1-mvp-staging/                 # Phase 1: Data Engineering & Training
│   ├── apps_script_code.js         # Legacy Google Apps Script
│   ├── generate_fake_data.py       # PII-Free Synthetic Data Generator
│   ├── students_synthetic_input.csv# Anonymized dataset sample
│   └── multi_tier_sql_dedup.sql    # 3-Layer SQL Pipeline (147k -> 11.6k records)
├── v2-enterprise-target/           # Phase 2: Dual AI Architecture
│   └── cloud-functions/            
│       ├── main.py                 # Serverless MLOps endpoint for legacy prediction
│       ├── model.pkl               # Trained Scikit-Learn Model
│       ├── model_columns.pkl       # Column mapping metadata
│       └── requirements.txt        # Python dependencies
├── .gitignore                      # Security exclusion rules
└── README.md                       # Master Documentation
