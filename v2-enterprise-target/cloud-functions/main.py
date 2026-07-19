import os
import functions_framework
import joblib
import pandas as pd
import numpy as np

# Forzar la ruta absoluta del directorio donde reside main.py
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'model.pkl')
COLUMNS_PATH = os.path.join(BASE_DIR, 'model_columns.pkl')

# Capturamos el error de inicialización en una variable para auditoría
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
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    headers = {'Access-Control-Allow-Origin': '*'}

    # Si el modelo falló al cargar, exponemos el detalle técnico del error
    if model is None or model_columns is None:
        return ({"error": f"El modelo de IA no se inicializó correctamente en el servidor. Detalle: {init_error}"}, 500, headers)

    request_json = request.get_json(silent=True)
    if not request_json:
        return ({"error": "Cuerpo de petición inválido o JSON vacío."}, 400, headers)

    input_data = [
        str(request_json.get('estado', '')),
        str(request_json.get('cidade', '')),
        str(request_json.get('genero', '')),
        str(request_json.get('faixa_etaria', ''))
    ]

    df_input = pd.DataFrame(0, index=[0], columns=model_columns)

    for valor in input_data:
        if valor:
            for col in model_columns:
                if f"_{valor}".lower() in col.lower() or col.lower().endswith(f"_{valor}".lower()):
                    df_input.at[0, col] = 1

    try:
        prediccion = model.predict(df_input)[0]
        probabilidades = model.predict_proba(df_input)[0]
        clases = model.classes_
        indice_clase = np.where(clases == prediccion)[0][0]
        confidence_score = float(probabilidades[indice_clase])

        response = {
            "predicted_channel": str(prediccion),
            "confidence_score": round(confidence_score, 2),
            "status": "success"
        }
        return (response, 200, headers)

    except Exception as e:
        return ({"error": f"Error interno durante la predicción: {str(e)}"}, 500, headers)
