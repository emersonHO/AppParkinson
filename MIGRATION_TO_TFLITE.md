# 🚀 Migración a Inferencia Local con TensorFlow Lite

## 📋 Resumen

Este documento describe la migración del sistema de detección de Parkinson desde un backend Flask/Python a inferencia local usando TensorFlow Lite en Flutter. Esto permite que la aplicación funcione completamente offline sin necesidad de servidor.

## ✅ Cambios Implementados

### 1. Backend - Script de Entrenamiento TFLite

**Archivo**: `backend/scripts/train_tflite_model.py`

- Entrena un modelo TensorFlow/Keras (red neuronal) en lugar de Random Forest
- Exporta el modelo a formato TensorFlow Lite (.tflite)
- Guarda los parámetros del scaler en JSON para normalización en Dart
- Genera archivos en `assets/model/`:
  - `parkinson_voice_model.tflite` - Modelo entrenado
  - `scaler_params.json` - Parámetros de normalización

### 2. Flutter - Extracción de Características

**Archivo**: `lib/services/voice_feature_extractor.dart`

- Implementa la extracción de las 22 características acústicas directamente en Dart
- No requiere librerías externas de Python
- Usa análisis de audio básico (autocorrelación, FFT, etc.)
- Compatible con archivos WAV

### 3. Flutter - Servicio de ML Local

**Archivo**: `lib/services/voice_ml_service.dart`

- Carga el modelo TFLite desde assets
- Normaliza características usando parámetros del scaler
- Ejecuta inferencia local sin conexión a internet
- Retorna probabilidad y nivel de riesgo

### 4. Flutter - Actualización de Pantallas

**Archivo**: `lib/screens/voice_test_screen.dart`

- Eliminada dependencia de `ApiService.predictVoice()`
- Usa `VoiceMLService` para procesamiento local
- Funciona completamente offline

### 5. Dependencias Actualizadas

**Archivo**: `pubspec.yaml`

- Agregado `tflite_flutter: ^0.10.4` para inferencia TFLite
- Agregado `wav: ^1.0.0` para lectura de archivos WAV
- Agregados assets del modelo en `assets/model/`

## 📦 Instrucciones de Configuración

### Paso 1: Entrenar el Modelo TFLite

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python scripts/train_tflite_model.py
```

Esto generará:
- `assets/model/parkinson_voice_model.tflite`
- `assets/model/scaler_params.json`

### Paso 2: Copiar Archivos a Flutter

Los archivos generados deben estar en:
```
mi_app/
└── assets/
    └── model/
        ├── parkinson_voice_model.tflite
        └── scaler_params.json
```

### Paso 3: Instalar Dependencias Flutter

```bash
flutter pub get
```

### Paso 4: Verificar Assets

Asegúrate de que `pubspec.yaml` incluye:
```yaml
assets:
  - assets/model/parkinson_voice_model.tflite
  - assets/model/scaler_params.json
```

## 🔄 Diferencias con la Versión Anterior

### Antes (Backend Flask):
- ❌ Requiere servidor Flask corriendo
- ❌ Requiere conexión a internet
- ❌ Dependiente de IP del servidor
- ❌ Latencia de red
- ❌ Posibles errores de conexión

### Ahora (TFLite Local):
- ✅ Funciona completamente offline
- ✅ Sin necesidad de servidor
- ✅ Sin latencia de red
- ✅ Más rápido (procesamiento local)
- ✅ Más privado (datos no salen del dispositivo)

## 🧪 Pruebas

1. **Grabar Audio**: La grabación funciona igual que antes
2. **Procesar**: Ahora se procesa localmente sin conexión
3. **Resultados**: Se muestran igual, pero generados localmente
4. **Guardar**: Los resultados se guardan localmente (y opcionalmente en backend si está disponible)

## ⚠️ Notas Importantes

1. **Modelo TFLite**: El modelo debe entrenarse antes de usar la app
2. **Tamaño del Modelo**: El archivo .tflite puede ser de varios MB
3. **Precisión**: El modelo TensorFlow puede tener una precisión ligeramente diferente al Random Forest original
4. **Extracción de Características**: La implementación en Dart es una aproximación de la versión Python. Para máxima precisión, considera usar un plugin nativo.

## 🐛 Solución de Problemas

### Error: "Modelo no encontrado"
- Verificar que `parkinson_voice_model.tflite` existe en `assets/model/`
- Ejecutar `flutter clean` y `flutter pub get`
- Verificar que los assets están declarados en `pubspec.yaml`

### Error: "Scaler no inicializado"
- Verificar que `scaler_params.json` existe en `assets/model/`
- Verificar formato JSON del archivo

### Error: "TFLite no compatible"
- Verificar versión de `tflite_flutter`
- Verificar que el modelo fue exportado correctamente desde TensorFlow

### Rendimiento lento
- El modelo se carga la primera vez que se usa
- Considera precargar el modelo al iniciar la app

## 📝 Próximos Pasos Opcionales

- [ ] Precargar modelo al iniciar la app
- [ ] Agregar caché de resultados
- [ ] Optimizar extracción de características
- [ ] Agregar validación de calidad de audio
- [ ] Implementar actualización de modelo OTA

