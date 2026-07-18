import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Inicializar Faker con localización de Brasil
fake = Faker('pt_BR')

def generate_synthetic_dataset(num_records=150):
    data = []
    program_name = "CAMPINHO DIGITAL" # Alineado con tu regla de negocio real
    acquisition_channels = ['Instagram', 'LinkedIn', 'Facebook', 'YouTube', 'Google Search', 'Indicación']
    genders = ['Homem Cis', 'Mulher Cis', 'Não Informado']
    
    for _ in range(num_records):
        # Generar nombres e identificadores realistas pero 100% falsos
        first_name = fake.first_name()
        last_name = fake.last_name()
        full_name = f"{first_name} {last_name}"
        email = f"{first_name.lower()}.{last_name.lower()}@{fake.free_email_domain()}"
        
        # 15% de probabilidad de que el canal de adquisición sea nulo (para probar el pipeline condicional)
        source = random.choice(acquisition_channels) if random.random() > 0.15 else None
        
        # Estructura idéntica a los inputs mapeados en tus consultas SQL
        record = {
            "join_email": email.strip().lower(),
            "email_principal": email,
            "nome_completo": full_name,
            "cpf": fake.cpf(),
            "telefone": f"+55{fake.msisdn()[:11]}",
            "programa": program_name,
            "estado_raw": fake.state_abbr(),
            "cidade_raw": fake.city(),
            "genero_raw": random.choice(genders),
            "data_nascimento": fake.date_of_birth(minimum_age=16, maximum_age=50).strftime('%Y-%m-%d'),
            "data_inscricao": (datetime.now() - timedelta(days=random.randint(1, 90))).strftime('%Y-%m-%d %H:%M:%S'),
            "fonte_candidato": source
        }
        data.append(record)
        
    df = pd.DataFrame(data)
    # Guardar como CSV de prueba para el repositorio
    df.to_csv("students_synthetic_input.csv", index=False, encoding="utf-8")
    print(f"🎉 Éxito: Se han generado {num_records} registros ficticios protegidos por LGPD.")

if __name__ == "__main__":
    generate_synthetic_dataset()
