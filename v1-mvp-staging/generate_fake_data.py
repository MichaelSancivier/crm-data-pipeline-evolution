import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Inicializar Faker con localización de Brasil (Cumplimiento LGPD)
fake = Faker('pt_BR')

def generate_v9_dual_ingestion_dataset(num_records=150):
    leads_data = []
    classroom_data = []
    
    program_name = "CAMPINHO DIGITAL"
    acquisition_channels = ['Instagram', 'LinkedIn', 'Facebook', 'YouTube', 'Google Search', 'Indicación']
    genders = ['Homem Cis', 'Mulher Cis', 'Não Informado']
    
    for _ in range(num_records):
        # 1. Generar identidad única y clave primaria de cruce (Email purificado)
        first_name = fake.first_name()
        last_name = fake.last_name()
        full_name = f"{first_name} {last_name}"
        email = f"{first_name.lower()}.{last_name.lower()}@{fake.free_email_domain()}"
        join_email = email.strip().lower()
        
        # Fecha base de registro (Evento 1)
        inscription_date = datetime.now() - timedelta(days=random.randint(10, 90))
        
        # 15% de probabilidad de canal nulo para estresar el microservicio MLOps (Predictor de canales)
        source = random.choice(acquisition_channels) if random.random() > 0.15 else None
        
        # --- PAYLOAD 1: EVENTO DE INGESTA (REGISTRO INICIAL - FIRESTORE) ---
        lead_record = {
            "join_email": join_email,
            "email_principal": email,
            "nome_completo": full_name,
            "cpf": fake.cpf(),
            "telefone": f"+55{fake.msisdn()[:11]}",
            "programa": program_name,
            "estado_raw": fake.state_abbr(),
            "cidade_raw": fake.city(),
            "genero_raw": random.choice(genders),
            "data_nascimento": fake.date_of_birth(minimum_age=16, maximum_age=50).strftime('%Y-%m-%d'),
            "data_inscricao": inscription_date.strftime('%Y-%m-%d %H:%M:%S'),
            "fonte_candidato": source,
            "estado_maquina": "Pendiente_Evaluacion"
        }
        leads_data.append(lead_record)
        
        # --- PAYLOAD 2: EVENTO DE EVALUACIÓN (GOOGLE CLASSROOM - PUB/SUB) ---
        # 85% de los candidatos completan el examen (simula tasa real de conversión)
        if random.random() < 0.85:
            submission_date = inscription_date + timedelta(days=random.randint(1, 7))
            classroom_record = {
                "join_email": join_email,
                "nota_examen": round(random.uniform(60.0, 100.0), 2),
                "data_entrega": submission_date.strftime('%Y-%m-%d %H:%M:%S'),
                "status_submissao": "SUBMITTED",
                "modulo_evaluado": "Examen Tecnico RevOps V9"
            }
            classroom_data.append(classroom_record)
            
    # Crear DataFrames
    df_leads = pd.DataFrame(leads_data)
    df_classroom = pd.DataFrame(classroom_data)
    
    # Guardar ambos Payloads para simulación de la Máquina de Estados
    df_leads.to_csv("leads_synthetic_input.csv", index=False, encoding="utf-8")
    df_classroom.to_csv("classroom_synthetic_input.csv", index=False, encoding="utf-8")
    
    print(f"🚀 ¡Éxito V9! Datasets para Ingesta Dual generados correctamente:")
    print(f" ├─ 📩 Evento 1 (Leads Ingestados): {len(df_leads)} filas en 'leads_synthetic_input.csv'")
    print(f" ├─ 📝 Evento 2 (Entregas Classroom): {len(df_classroom)} filas en 'classroom_synthetic_input.csv'")
    print(f" └─ 🗝️ Llave Primaria de Conciliación: 'join_email' (Firestore State Machine)")

if __name__ == "__main__":
    generate_v9_dual_ingestion_dataset()
