# 🔴 Normalización Crítica del Modelo - Documentación Técnica

## Problema Resuelto

**Inconsistencia entre preprocesamiento en Python y extracción en Dart** que causaba resultados poco fiables.

## Solución Implementada

### Flujo de Procesamiento Correcto

```
┌─────────────────────────────────────────────────────────────┐
│ 1. EXTRACCIÓN DE CARACTERÍSTICAS                            │
│    VoiceFeatureExtractor.extractFeatures(audioPath)          │
│    → Genera 22 valores numéricos (sin normalizar)           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. NORMALIZACIÓN (CRÍTICO) ⚠️                               │
│    VoiceRFService.normalizeFeatures(features)               │
│    → Aplica StandardScaler: (valor - mean) / scale          │
│    → Usa parámetros de assets/model/scaler_params.json      │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. PREDICCIÓN                                               │
│    VoiceRFService._predictRF(normalizedFeatures)             │
│    → Modelo Random Forest recibe datos normalizados         │
└─────────────────────────────────────────────────────────────┘
```

## Archivos Clave

### 1. `lib/services/voice_rf_service.dart`

**Método Principal: `normalizeFeatures()`**

```dart
List<double> normalizeFeatures(List<double> features) {
  // Carga parámetros del StandardScaler
  final mean = List<double>.from(_scalerParams!['mean'] as List);
  final scale = List<double>.from(_scalerParams!['scale'] as List);
  
  // Aplica fórmula: (x - mean) / scale
  return List.generate(features.length, (i) {
    if (scale[i] == 0.0) return 0.0;
    return (features[i] - mean[i]) / scale[i];
  });
}
```

**Flujo en `predict()`:**

```dart
// 1. Extraer características
final features = await VoiceFeatureExtractor.extractFeatures(audioPath);

// 2. NORMALIZAR (CRÍTICO)
final normalizedFeatures = normalizeFeatures(features);

// 3. Predecir con características normalizadas
double probability = _predictRF(normalizedFeatures);
```

### 2. `assets/model/scaler_params.json`

Estructura requerida:

```json
{
  "mean": [valor1, valor2, ..., valor22],
  "scale": [valor1, valor2, ..., valor22],
  "feature_names": ["fo", "fhi", ...]
}
```

## ¿Por Qué es Crítico?

### 1. **Coherencia con el Entrenamiento**

El modelo Random Forest fue entrenado en Python con datos normalizados:

```python
# En Python (train_rf_model.py)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
rf_model.fit(X_train_scaled, y_train)
```

Por lo tanto, **las características en Dart deben estar normalizadas** antes de la predicción.

### 2. **Diferentes Escalas de Características**

Las 22 características tienen diferentes unidades y rangos:
- `fo` (Hz): ~100-300
- `jitter_percent` (%): ~0.001-0.1
- `hnr` (dB): ~10-30

Sin normalización, características con valores grandes dominarían el modelo.

### 3. **Resultados Incorrectos sin Normalización**

Si no se normaliza:
- ❌ Predicciones inconsistentes
- ❌ Probabilidades incorrectas (a menudo 100% o 0%)
- ❌ Modelo no funciona como fue entrenado

Con normalización:
- ✅ Predicciones coherentes
- ✅ Probabilidades en rango [0, 1]
- ✅ Modelo funciona correctamente

## Validaciones Implementadas

### 1. Validación de Parámetros del Scaler

```dart
if (!_scalerParams!.containsKey('mean') || !_scalerParams!.containsKey('scale')) {
  throw Exception('scaler_params.json debe contener "mean" y "scale"');
}

if (mean.length != 22 || scale.length != 22) {
  throw Exception('scaler_params.json debe tener exactamente 22 valores');
}
```

### 2. Validación de Número de Características

```dart
if (features.length != 22) {
  throw Exception('Se esperaban 22 características, se obtuvieron ${features.length}');
}
```

### 3. Validación de Valores Finitos

```dart
if (!normalizedValue.isFinite) {
  print('⚠️ Advertencia: valor normalizado no finito');
  return 0.0;
}
```

## Logging para Debugging

El código incluye logging detallado:

```
📊 Iniciando predicción para: /path/to/audio.wav
  → Extrayendo características acústicas...
  ✓ 22 características extraídas
  → Normalizando características con StandardScaler...
  ✓ Características normalizadas (mean y scale aplicados)
  → Ejecutando inferencia con Random Forest...
  ✓ Probabilidad obtenida: 0.65
  ✓ Nivel de riesgo: Medio
✓ Predicción completada exitosamente
```

## Verificación

Para verificar que la normalización funciona correctamente:

1. **Verificar que scaler_params.json existe:**
   ```bash
   ls -lh assets/model/scaler_params.json
   ```

2. **Verificar estructura del archivo:**
   ```bash
   cat assets/model/scaler_params.json | jq '.mean | length'  # Debe ser 22
   cat assets/model/scaler_params.json | jq '.scale | length'  # Debe ser 22
   ```

3. **Ejecutar la app y revisar logs:**
   - Buscar mensajes "✓ Características normalizadas"
   - Verificar que no hay errores de normalización

## Troubleshooting

### Error: "StandardScaler no inicializado"

**Causa:** `initialize()` no fue llamado antes de `predict()`

**Solución:** El método `predict()` llama automáticamente a `initialize()` si es necesario.

### Error: "Número incorrecto de características"

**Causa:** `VoiceFeatureExtractor` no está generando 22 características

**Solución:** Verificar que `extract_features.py` y `voice_feature_extractor.dart` están sincronizados.

### Error: "scaler_params.json debe tener exactamente 22 valores"

**Causa:** El archivo JSON no tiene la estructura correcta

**Solución:** Reentrenar el modelo:
```bash
cd backend/scripts
python train_rf_model.py
```

---

**Última actualización:** 2025



