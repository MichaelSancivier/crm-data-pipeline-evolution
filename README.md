# 🚀 PLAN MAESTRO: ECOSISTEMA REVOPS & HUB AGÉNTICO IA (V9)
### Estrategia Enterprise: Inteligencia Predictiva (MLOps), Arquitectura Event-Driven y Consolidación de Estados (Firestore)

**PERFIL:** Michael Sancivier — Technical Product Owner & RevOps Process Specialist  
**CORE SKILLS:** Scrum | Six Sigma | FinOps Cloud Architecture | Data Pipeline Engineering | API Orchestration

---

## 📊 Resumen de Impacto de Datos (Métricas de Optimización Enterprise)

| Métrica Operativa | Volumen / Impacto Real |
| :--- | :--- |
| **Candidatos Brutos (Leads Ingestados)** | 132,248 registros |
| **Alumnos Brutos (Historial de Exámenes)** | 15,356 registros |
| **Volumen Bruto Total Procesado** | **147,604 registros** |
| **Entidades Únicas Consolidadas (Target: Brasil)** | **11,600 registros** |
| **Tasa de Reducción de Ruido (Filtro Geofencing & Deduplicación)** | **~92% de optimización** |
| **Costo Operativo Estructural (Orquestación en Make)** | **$0.00 USD** (1 sola operación por ciclo concluido) |

---

## 1. 🎯 Visión Estratégica: Del MVP al Ecosistema Enterprise Completo

Este repositorio detalla la evolución a la **Versión 9** de un proceso operativo manual hacia una arquitectura corporativa automatizada, dirigida por eventos (*Event-Driven*) y gobernada por Inteligencia Artificial Predictiva (*MLOps*).

Diseñado bajo principios de Mejora Continua (**Six Sigma**) y privacidad por diseño (**LGPD/GDPR**), este ecosistema unifica silos de datos y optimiza recursos financieros (**FinOps**). La principal evolución arquitectónica de esta versión radica en el establecimiento de **Google Cloud Platform (GCP)** como el centro neurálgico de ingesta, resolviendo la trazabilidad, aislando mercados regionales cruzados (separación geográfica/Geofencing de datos de Argentina y Brasil) y eliminando por completo los puntos ciegos operativos.

---

## 2. ⚡ Arquitectura FinOps: Máquina de Estados (GCP) y Conciliación de Ingesta Dual

Para garantizar la escalabilidad sin incurrir en costos de licencias ni saturar los webhooks transaccionales, la arquitectura integra **Google Cloud Pub/Sub** y **Cloud Firestore** como una máquina de estados elástica en la nube. 

El flujo elimina la dependencia de herramientas de terceros para la consolidación de estados tempranos, permitiendo la conciliación perfecta mediante el **correo electrónico del candidato** como llave primaria:

* 📩 **Evento de Ingesta (El origen del registro):** El ingreso de un nuevo lead impacta directamente en GCP, creando un documento inicial en **Firestore** (`estado: Pendiente de Evaluación`) de forma gratuita.
* 📝 **Evento de Evaluación (Cross-Check):** Cuando el candidato completa el examen en **Google Classroom**, Pub/Sub notifica a una Cloud Function, la cual realiza un cruce exacto en Firestore utilizando el **email** como llave primaria para unificar el expediente.
* 🚀 **Disparo Purificado (Webhook):** Una vez que la Máquina de Estados confirma que el perfil está completo y cualificado, emite **un único disparo HTTP purificado hacia Make**, orquestando el guardado final en **HubSpot CRM** y **BigQuery** sin incurrir en ejecuciones intermedias redundantes.

---

## 3. 🗺️ Plan de Ejecución por Hitos (Roadmap V9)

### 🔹 Hito 1: Data Engineering & Separación Geográfica de Mercados (Zoho Analytics ETL)
* **Situation:** El Data Warehouse (Zoho Analytics) presentaba una alta fragmentación operativa, acumulando 147,604 registros brutos mezclados entre bases de candidatos (132,248) y alumnos evaluados (15,356), con datos superpuestos de múltiples mercados latinoamericanos (incluyendo Brasil y Argentina).
* **Task:** Diseñar y ejecutar un pipeline ETL de grado Enterprise (*Staging, Transformation, Production*) para depurar la base de datos, aislar exclusivamente el mercado brasileño mediante lógica de **Geofencing** y consolidar entidades únicas de alta fidelidad para el entrenamiento del modelo de IA predictivo.
* **Action:** Refactorización avanzada de consultas SQL aplicando cruces relacionales estrictos y lógica condicional de negocio para deduplicar, unificar el historial de los candidatos y eliminar registros incompletos o fuera de la región objetivo.
* **Result:** Compresión del volumen analítico de **147,604 registros a 11,600 entidades únicas** y validadas, logrando una **reducción del 92% de ruido informático** y garantizando un dataset prístino y optimizado para Machine Learning.

### 🔹 Hito 2: Anonimización de Datos y Simulación de Ingesta Dual
Generación de 150 registros sintéticos en Python (`Faker pt_BR`) con inyección intencional de datos nulos para estresar el pipeline predictivo sin exponer PII (Información Personal Identificable), garantizando cumplimiento LGPD y GDPR. El script genera simulaciones del "Evento de Ingesta" (lead inicial) y, de manera separada, del "Evento de Evaluación" (datos de Classroom), garantizando que compartan el correo electrónico exacto para probar la llave primaria y la resiliencia de la Máquina de Estados ante perfiles incompletos.

### 🔹 Hito 3: Configuración de Entornos Enterprise Base
Despliegue del Sandbox en HubSpot con propiedades avanzadas mapeadas (*Acquisition Source, ML Confidence Score*). Inicialización del proyecto en Google Cloud Platform configurado estrictamente bajo la capa 100% gratuita, incluyendo el aprovisionamiento de Cloud Firestore y la activación de tópicos en Pub/Sub para capturar eventos asíncronos.

### 🔹 Hito 4: Migración del Data Warehouse a BigQuery
Sustitución de silos en hojas de cálculo por BigQuery como motor analítico columnar para almacenamiento histórico elástico, homologando cruces geográficos mediante consultas SQL serverless.

### 🔹 Hito 5: Ingesta Dual y Máquina de Estados Serverless (Core MLOps V9)
Empaquetado del modelo de Machine Learning (`model.pkl`) hacia una Google Cloud Function HTTP (Python 3.10). Configuración de rutas de ingesta inicial en Cloud Firestore para registrar nuevos leads. Activación de tópicos en Pub/Sub para capturar eventos de Classroom, convirtiendo a Firestore en una Máquina de Estados integral que consolida el perfil (Registro + Examen) a costo **$0.00 USD**.

### 🔹 Hito 6: Orquestación Inteligente Orientada a Eventos con Make
Implementación del escenario maestro en Make con enrutamiento inteligente (*Router*). El orquestador ya no asume la carga de procesar eventos sueltos; recibe un único disparo HTTP purificado desde la nube cuando el ciclo del candidato ha concluido con éxito, insertando los datos unificados en el CRM y reduciendo el consumo de operaciones estructurales.

### 🔹 Hito 7: Dashboards de Gobernanza y Negocio (Looker Studio)
Conexión nativa a BigQuery y HubSpot CRM para visualizar en tiempo real la salud de la infraestructura, atribución de canales de marketing y métricas de desempeño de los algoritmos de IA.

### 🔹 Hito 8: Documentación de Impacto y Storytelling (README)
Publicación del caso de estudio maestro aplicando la metodología STAR enfocado en ROI, estrategias FinOps y la superación definitiva de la deuda técnica en arquitecturas orientadas a eventos para el video final de presentación de GitHub.

---

## 📁 Estructura del Repositorio

```text
├── v1-mvp-staging/
│   ├── apps_script_code.js         # Script legacy de Google Apps Script (MVP)
│   ├── generate_fake_data.py       # Generador de datos sintéticos con Ingesta Dual (Faker)
│   ├── students_synthetic_input.csv# Dataset sintético anonimizado (LGPD)
│   └── zoho_analytics_dedup.sql    # Pipeline SQL de 3 capas con Geofencing (Brasil)
├── v2-enterprise-target/
│   ├── cloud-functions/
│   │   ├── main.py                 # Endpoint serverless para inferencia MLOps
│   │   ├── model.pkl               # Modelo ML entrenado (Scikit-Learn)
│   │   ├── model_columns.pkl       # Mapeo de variables
    │   └── requirements.txt        # Dependencias Python
├── .gitignore                      # Reglas de exclusión de seguridad
└── README.md                       # Documentación maestra del proyecto
