import functions_framework
import joblib
import pandas as pd
import numpy as np

# Carga global del modelo y sus columnas para optimizar rendimiento (Warm Start FinOps)
try:
    model = joblib.load('model.pkl')
    model_columns = joblib.load('model_columns.pkl')
except Exception as e:
    model = None
    model_columns = None

@functions_framework.http
def predict_channel(request):
    # Manejo de CORS para permitir conexiones externas seguras desde Make/Zapier
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    headers = {'Access-Control-Allow-Origin': '*'}

    if model is None or model_columns is None:
        return ({"error": "El modelo de IA no se inicializó correctamente en el servidor."}, 500, headers)

    # Procesar el JSON entrante enviado por el orquestador
    request_json = request.get_json(silent=True)
    if not request_json:
        return ({"error": "Cuerpo de petición inválido o JSON vacío."}, 400, headers)

    # Extraer variables demográficas estandarizadas
    input_data = [
        str(request_json.get('estado', '')),
        str(request_json.get('cidade', '')),
        str(request_json.get('genero', '')),
        str(request_json.get('faixa_etaria', ''))
    ]

    # Reconstruir la matriz de One-Hot Encoding con ceros absolutos
    df_input = pd.DataFrame(0, index=[0], columns=model_columns)

    # Activar con un "1" las columnas dummy correspondientes al lead recibido
    for valor in input_data:
        if valor:
            for col in model_columns:
                if f"_{valor}".lower() in col.lower() or col.lower().endswith(f"_{valor}".lower()):
                    df_input.at[0, col] = 1

    try:
        # Ejecutar la inferencia en tiempo real
        prediccion = model.predict(df_input)[0]
        
        # Calcular el puntaje de confianza (Confidence Score) de la predicción
        probabilidades = model.predict_proba(df_input)[0]
        clases = model.classes_
        indice_clase = np.where(clases == prediccion)[0][0]
        confidence_score = float(probabilidades[indice_clase])

        # Formatear la respuesta de salida para el CRM
        response = {
            "predicted_channel": str(prediccion),
            "confidence_score": round(confidence_score, 2),
            "status": "success"
        }
        return (response, 200, headers)

    except Exception as e:
        return ({"error": f"Error interno durante la predicción: {str(e)}"}, 500, headers)
