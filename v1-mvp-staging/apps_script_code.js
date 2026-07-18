/**
 * REVOPS & DATA QUALITY MVP PIPELINE
 * Arquitectura de Enriquecimiento Condicional de Datos Históricos
 */

// Configuración de variables de entorno anonimizadas (Data Governance)
const CONFIG = {
  SPREADSHEET_ID: "YOUR_ANONYMIZED_SPREADSHEET_ID",
  INPUT_SHEET_NAME: "Nuevos Alumnos",
  HISTORIC_SHEET_NAME: "Base Histórica",
  ML_ENDPOINT_URL: "https://YOUR_ANONYMIZED_COLAB_OR_FUNCTION_URL/predict"
};

/**
 * Crea el menú personalizado al abrir la hoja de cálculo
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('🚀 RevOps Engine')
    .addItem('🔍 Validar y Enriquecer Datos (ML)', 'processConditionalEnrichment')
    .addToUi();
}

/**
 * Escanea de forma inteligente los registros y procesa únicamente los datos faltantes
 */
function processConditionalEnrichment() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const inputSheet = ss.getSheetByName(CONFIG.INPUT_SHEET_NAME);
  
  const dataRange = inputSheet.getDataRange();
  const values = dataRange.getValues();
  const headers = values[0];
  
  // Localizar índices de columnas clave de acuerdo a tu arquitectura de datos
  const emailIdx = headers.indexOf("E-mail");
  const sourceIdx = headers.indexOf("Canal de Origem (C1)");
  const genderIdx = headers.indexOf("Gênero");
  const ageIdx = headers.indexOf("Faixa Etária");
  const cityIdx = headers.indexOf("Cidade");
  const stateIdx = headers.indexOf("Estado");
  
  let rowsToEnrich = [];
  
  // Paso 1: Filtro Condicional (Ignorar completos, aislar registros huérfanos)
  for (let i = 1; i < values.length; i++) {
    const currentSource = values[i][sourceIdx];
    
    if (!currentSource || currentSource.toString().trim() === "") {
      // Registrar el número de fila y el payload demográfico mínimo requerido por el modelo de ML
      rowsToEnrich.push({
        rowNumber: i + 1,
        payload: {
          email: values[i][emailIdx],
          gender: values[i][genderIdx],
          age_range: values[i][ageIdx],
          city: values[i][cityIdx],
          state: values[i][stateIdx]
        }
      });
    }
  }
  
  if (rowsToEnrich.length === 0) {
    SpreadsheetApp.getUi().alert('✅ Calidad de Datos Completa: No se encontraron registros con canales vacíos.');
    return;
  }
  
  // Paso 2: Conexión asíncrona controlada con el entorno de Machine Learning
  try {
    const options = {
      method: 'post',
      contentType: 'application/json',
      payload: JSON.stringify({ records: rowsToEnrich.map(r => r.payload) }),
      muteHttpExceptions: true
    };
    
    Logger.log(`Enviando ${rowsToEnrich.length} registros huérfanos al microservicio de Machine Learning...`);
    const response = UrlFetchApp.fetch(CONFIG.ML_ENDPOINT_URL, options);
    
    if (response.getResponseCode() === 200) {
      const predictions = JSON.parse(response.getContentText()).predictions;
      
      // Paso 3: Imputación precisa en las celdas correspondientes sin alterar el resto de la base
      rowsToEnrich.forEach((row, index) => {
        const predictedSource = predictions[index].source;
        // Asignar el output devuelto por Colab directamente a la columna de origen
        inputSheet.getRange(row.rowNumber, sourceIdx + 1).setValue(predictedSource);
      });
      
      SpreadsheetApp.getUi().alert(`🎉 Éxito: Se optimizaron y completaron ${rowsToEnrich.length} registros en segundos.`);
    } else {
      throw new Error(`Error en el servidor de IA. Código de Estado: ${response.getResponseCode()}`);
    }
    
  } catch (error) {
    SpreadsheetApp.getUi().alert(`⚠️ Falla en la automatización: ${error.message}`);
    Logger.log(`Error de ejecución: ${error.toString()}`);
  }
}
