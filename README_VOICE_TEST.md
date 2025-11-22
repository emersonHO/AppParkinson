# 🎤 Guía de Implementación - Prueba de Voz para Detección de Parkinson

## 📋 Resumen

Este documento describe la implementación completa de la funcionalidad de prueba de voz para detección de Parkinson, incluyendo el entrenamiento del modelo, el backend y la aplicación Flutter.

## 🗂️ Estructura de Archivos

### Backend (Python/Flask)

```
backend/
├── app.py                          # API Flask con endpoints de voz
├── model.pkl                       # Modelo entrenado (generado)
├── scaler.pkl                      # Scaler para normalización (generado)
├── requirements.txt                # Dependencias actualizadas
├── data/
│   └── parkinson_data.data         # Dataset (debe subirse aquí)
└── scripts/
    ├── train_model.py              # Script de entrenamiento
    └── extract_features.py         # Extractor de características
```

### Flutter

```
lib/
├── models/
│   └── voice_test.dart             # Modelo de datos
├── services/
│   ├── api_service.dart            # Servicio API (actualizado)
│   └── database_service.dart       # Servicio de BD local
└── screens/
    ├── voice_test_screen.dart      # Pantalla de grabación
    └── voice_result_screen.dart    # Pantalla de resultados
```

## 🚀 Instrucciones de Instalación

### 1. Backend

#### Instalar dependencias:

```bash
cd backend
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### Subir el dataset:

Coloca tu archivo `parkinson_data.data` en:
```
backend/data/parkinson_data.data
```

#### Entrenar el modelo:

```bash
python scripts/train_model.py
```

Esto generará:
- `backend/model.pkl` - Modelo entrenado
- `backend/scaler.pkl` - Scaler para normalización

#### Ejecutar el servidor:

```bash
python app.py
```

El servidor estará disponible en `http://127.0.0.1:5000`

### 2. Flutter

#### Instalar dependencias:

```bash
flutter pub get
```

#### Configurar permisos (Android):

En `android/app/src/main/AndroidManifest.xml`, asegúrate de tener:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### Configurar permisos (iOS):

En `ios/Runner/Info.plist`, agregar:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar tu voz</string>
```

## 📱 Uso de la Aplicación

### Flujo de Prueba de Voz:

1. **Seleccionar Prueba**: Desde el home, ir a "Iniciar Nueva Evaluación" → Seleccionar "Voz"

2. **Grabar Audio**:
   - Presionar el botón de grabar (micrófono)
   - Hablar claramente durante al menos 3 segundos
   - Soltar el botón para detener

3. **Procesar**: Presionar "Procesar Audio" para enviar al backend

4. **Ver Resultados**: Se muestra:
   - Nivel de riesgo (Bajo/Medio/Alto)
   - Probabilidad porcentual
   - Gráfico circular
   - Parámetros acústicos extraídos

5. **Guardar**: Presionar "Guardar Resultado" para almacenar localmente y en el backend

### Historial:

Los resultados de voz aparecen en el historial junto con las otras pruebas, identificados con el ícono de micrófono.

## 🔧 Endpoints del Backend

### POST `/predict_voice`

Recibe un archivo de audio `.wav` y retorna la predicción.

**Request:**
- Form-data con campo `audio` (archivo .wav)

**Response:**
```json
{
  "probabilidad": 0.75,
  "nivel": "Alto",
  "parametros": {
    "fo": 120.5,
    "fhi": 150.2
  }
}
```

### POST `/save_voice_result`

Guarda un resultado de prueba de voz en la base de datos.

**Request:**
```json
{
  "user_id": "123",
  "date": "2024-01-15T10:30:00",
  "probability": 0.75,
  "level": "Alto",
  "parametros": { }
}
```

### GET `/voice_results/<user_id>`

Obtiene todos los resultados de voz de un usuario.

## 🗄️ Base de Datos Local (SQLite)

La aplicación Flutter guarda los resultados localmente en SQLite usando `sqflite`.

**Tabla `voice_tests`:**
- Almacena todos los resultados de pruebas de voz
- Sincroniza con el backend cuando es posible
- Permite acceso offline al historial

## 📊 Características Extraídas

El modelo utiliza 22 características acústicas:

1. MDVP:Fo(Hz) - Frecuencia fundamental
2. MDVP:Fhi(Hz) - Frecuencia máxima
3. MDVP:Flo(Hz) - Frecuencia mínima
4. MDVP:Jitter(%) - Variación porcentual de frecuencia
5. MDVP:Jitter(Abs) - Jitter absoluto
6. MDVP:RAP - Relative Average Perturbation
7. MDVP:PPQ - Pitch Period Quotient
8. Jitter:DDP - Difference of Differences of Periods
9. MDVP:Shimmer - Variación de amplitud
10. MDVP:Shimmer(dB) - Shimmer en decibelios
11. Shimmer:APQ3 - Amplitude Perturbation Quotient (3-point)
12. Shimmer:APQ5 - Amplitude Perturbation Quotient (5-point)
13. MDVP:APQ - Amplitude Perturbation Quotient (11-point)
14. Shimmer:DDA - Difference of Differences of Amplitude
15. NHR - Noise-to-Harmonics Ratio
16. HNR - Harmonics-to-Noise Ratio
17. RPDE - Recurrence Period Density Entropy
18. DFA - Detrended Fluctuation Analysis
19. spread1 - Parámetro del cepstrum
20. spread2 - Parámetro del cepstrum
21. D2 - Dimensión correlativa
22. PPE - Pitch Period Entropy

## ⚠️ Notas Importantes

1. **Dataset**: El archivo `parkinson_data.data` debe tener exactamente las columnas especificadas en el orden correcto.

2. **Modelo**: El modelo debe entrenarse antes de usar los endpoints de predicción.

3. **Formato de Audio**: El backend espera archivos `.wav` con:
   - Sample rate: 44100 Hz
   - Canales: Mono (1)
   - Formato: WAV

4. **Permisos**: La aplicación requiere permisos de micrófono en Android e iOS.

5. **Conexión**: La aplicación funciona offline guardando localmente, pero necesita conexión para procesar el audio.

## 🐛 Solución de Problemas

### Error: "Modelo no disponible"
- Ejecutar `python scripts/train_model.py` para entrenar el modelo

### Error: "No se encontró el archivo dataset"
- Verificar que `backend/data/parkinson_data.data` existe

### Error de permisos de micrófono
- Verificar configuración en AndroidManifest.xml (Android) o Info.plist (iOS)

### Error de conexión al backend
- Verificar que el servidor Flask está corriendo en `http://127.0.0.1:5000`
- Para dispositivos físicos, usar la IP de la máquina en lugar de 127.0.0.1

## 📝 Próximos Pasos

- [ ] Agregar visualización de tendencias en el historial
- [ ] Implementar exportación de resultados
- [ ] Agregar filtros por fecha en el historial
- [ ] Mejorar la UI de la pantalla de resultados
- [ ] Agregar validación de calidad del audio antes de procesar





