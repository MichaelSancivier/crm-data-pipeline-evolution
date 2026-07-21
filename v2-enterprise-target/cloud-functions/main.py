import os
import functions_framework
import joblib
import pandas as pd
import numpy as np

# Ruta absoluta para asegurar la lectura de artefactos (.pkl)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'model.pkl')
COLUMNS_PATH = os.path.join(BASE_DIR, 'model_columns.pkl')

# Captura de auditoría de inicialización (Cold Start Optimization)
init_error = None
try:
    model = joblib.load(MODEL_PATH)
    model_columns = joblib.load(COLUMNS_PATH)
except Exception as e:
    model = None
    model_columns = None
    init_error = str(e)

@functions_framework.http
def predict_channel(request):
    """
    Endpoint Serverless MLOps (V9)
    Inferencia de Canal de Adquisición con Modelo Scikit-Learn
    """
    headers = {'Access-Control-Allow-Origin': '*'}

    # 1. Manejo de Preflight CORS
    if request.method == 'OPTIONS':
        options_headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, options_headers)

    # 2. Validación de Inicialización del Modelo
    if model is None or model_columns is None:
        return ({
            "status": "error",
            "error": f"El modelo de IA no se inicializó correctamente. Detalle: {init_error}"
        }, 500, headers)

    # 3. Lectura y Validación del Payload JSON
    request_json = request.get_json(silent=True)
    if not request_json:
        return ({
            "status": "error",
            "error": "Cuerpo de petición inválido o JSON vacío."
        }, 400, headers)

    # 4. Extracción de variables con compatibilidad Dual (PT / EN / ES)
    estado = str(request_json.get('estado') or request_json.get('state') or '')
    cidade = str(request_json.get('cidade') or request_json.get('city') or '')
    genero = str(request_json.get('genero') or request_json.get('gender') or '')
    faixa_etaria = str(request_json.get('faixa_etaria') or request_json.get('age_range') or '')

    input_data = [estado, cidade, genero, faixa_etaria]

    # 5. Reconstrucción del Vector One-Hot Encoded según el pipeline de Colab
    df_input = pd.DataFrame(0, index=[0], columns=model_columns)

    for valor in input_data:
        if valor:
            for col in model_columns:
                if f"_{valor}".lower() in col.lower() or col.lower().endswith(f"_{valor}".lower()):
                    df_input.at[0, col] = 1

    # 6. Inferencia y Cálculo de Confidence Score
    try:
        prediccion = model.predict(df_input)[0]
        probabilidades = model.predict_proba(df_input)[0]
        clases = model.classes_
        indice_clase = np.where(clases == prediccion)[0][0]
        confidence_score = float(probabilidades[indice_clase])

        response = {
            "status": "success",
            "predicted_channel": str(prediccion),
            "predicted_acquisition_channel": str(prediccion),  # Alias para compatibilidad con HubSpot/Make
            "confidence_score": round(confidence_score, 4),
            "architecture_version": "RevOps_MLOps_V9",
            "execution_cost_usd": 0.00
        }
        return (response, 200, headers)

    except Exception as e:
        return ({
            "status": "error",
            "error": f"Error interno durante la inferencia ML: {str(e)}"
        }, 500, headers)
