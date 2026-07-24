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
| **Raw Legacy Volume Processed** | 147,604 records cleaned from the legacy system[cite: 1]. |
| **Data Minimization (GDPR/LGPD)** | 11,600 unique entities recovered (~92% noise reduction)[cite: 1]. |
| **Dual AI Architecture** | **MLOps:** Social Media origin prediction. **GenAI:** Exam evaluation. |
| **Structural Operating Cost** | **$0.00 USD** (GCP Serverless + Make Smart Routing)[cite: 1]. |

---

## 🎯 2. The Business Challenge: Migration & Automation
This repository documents the architectural evolution of a RevOps ecosystem that previously collapsed under the weight of **147,604 raw records**. 

The business required a two-front solution:
1. **The Past (Legacy Migration):** Migrate 11,600 historical records to a new CRM (HubSpot)[cite: 1]. However, these records lacked critical marketing attribution data (Social Media Origin).
2. **The Future (New Leads):** Automate the qualitative evaluation of new candidates taking admission exams in Google Classroom.

Under **Six Sigma** and **Privacy by Design** principles, I architected a **Dual AI Event-Driven System** to solve both challenges at $0.00 infrastructure cost[cite: 1].

---

## 🧠 3. Dual AI Architecture: MLOps & Generative AI

### 🔹 3.1 Resolving the Past: MLOps Router & Legacy Migration
To rescue the historical data attribution, I engineered a Predictive AI workflow:
* **MLOps Training:** Trained a classification model (`Scikit-Learn`) in **Google Colab** using the clean dataset to predict missing Social Media channels.
* **Serverless GCP:** Packaged the `.pkl` artifacts into a **Google Cloud Function** (Python 3.10)[cite: 1].
* **Make Smart Router:** Configured a webhook router. If a legacy record is complete, it takes the **"Happy Path"** to the CRM. If the Social Media origin is missing, it takes the **"AI Path"**, triggering the GCP microservice to predict the channel in <2s before injecting the enriched profile into HubSpot.

### 🔹 3.2 Automating the Future: Agentic AI & Real-Time Evaluation
For new candidate evaluations, I designed a Generative AI hub:
* **Decoupled Business Logic:** When a candidate submits an exam, Make retrieves the evaluation master prompt dynamically from **Google Docs** (ensuring security and decoupled governance).
* **Gemini Enterprise Agent:** The payload is sent to **Gemini 2.5 Flash**, which conducts a qualitative evaluation of the answers.
* **JSON Structuring:** The AI outputs a structured JSON response, seamlessly updating the existing contact record in **HubSpot CRM** and logging the event in **Google BigQuery**[cite: 1].

---

## 🛡️ 4. Governance, Data Privacy (GDPR/LGPD) & FinOps

* **Privacy by Design:** Engineered a 3-Layer SQL Pipeline (Staging ➔ Transformation ➔ Target) that applied Geofencing to isolate the target market. This minimized data exposure by **92%**[cite: 1].
* **Synthetic Stress Testing:** To avoid exposing Personally Identifiable Information (PII) during staging, the pipeline was stress-tested using 150 synthetic records generated in Python (`Faker pt_BR`)[cite: 1].
* **Responsible AI:** Every AI decision logs its `ML Confidence Score` into BigQuery to guarantee full auditability[cite: 1].
* **FinOps Mastery:** By leveraging GCP's free tier for heavy lifting and restricting Make to purified event routing, the entire dual ecosystem operates at **$0.00 USD**[cite: 1].

---

## 📁 5. Repository Structure
```text
crm-data-pipeline-evolution/
├── v1-data-engineering/
│   ├── generate_fake_data.py       # PII-Free Synthetic Data Generator (Faker pt_BR)
│   ├── multi_tier_sql_dedup.sql    # 3-Layer SQL Pipeline (147k -> 11.6k records)
│   └── ml_model_training.ipynb     # Colab Notebook (Model training for Social Media Origin)
├── v2-dual-ai-architecture/
│   ├── cloud-functions/
│   │   ├── main.py                 # Serverless MLOps endpoint for legacy prediction
│   │   ├── model.pkl               # Trained Scikit-Learn Model
│   │   └── requirements.txt        # Python dependencies
│   ├── make-scenarios/
│   │   ├── integration_webhooks.json # Scenario 1: MLOps Router (Happy Path vs AI Path)
│   │   └── hub_maestro_agentic.json  # Scenario 2: Gemini Exam Evaluator
│   └── bigquery-sql/
│       └── audit_logging.sql       # AI Confidence Score tracking
└── README.md                       # Master Documentation
