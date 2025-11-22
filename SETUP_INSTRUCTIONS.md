# 🚀 Instrucciones de Configuración - Prueba de Voz

## 📦 Pasos para Configurar el Proyecto Completo

### 1. Backend (Python/Flask)

#### a) Instalar dependencias:

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt
```

#### b) Subir el dataset:

Coloca tu archivo `parkinson_data.data` en:
```
backend/data/parkinson_data.data
```

**Importante**: El archivo debe tener las columnas en este orden exacto:
- name
- MDVP:Fo(Hz)
- MDVP:Fhi(Hz)
- MDVP:Flo(Hz)
- MDVP:Jitter(%)
- MDVP:Jitter(Abs)
- MDVP:RAP
- MDVP:PPQ
- Jitter:DDP
- MDVP:Shimmer
- MDVP:Shimmer(dB)
- Shimmer:APQ3
- Shimmer:APQ5
- MDVP:APQ
- Shimmer:DDA
- NHR
- HNR
- status
- RPDE
- DFA
- spread1
- spread2
- D2
- PPE

#### c) Entrenar el modelo:

```bash
python scripts/train_model.py
```

Esto generará:
- `backend/model.pkl` - Modelo Random Forest entrenado
- `backend/scaler.pkl` - Scaler para normalización

#### d) Crear migración de base de datos:

```bash
flask db migrate -m "Agregar tabla voice_test"
flask db upgrade
```

O ejecutar manualmente el SQL:
```bash
sqlite3 app.db < migrations/add_voice_test_table.sql
```

#### e) Ejecutar el servidor:

```bash
python app.py
```

El servidor estará en `http://127.0.0.1:5000`

### 2. Flutter

#### a) Instalar dependencias:

```bash
flutter pub get
```

#### b) Configurar permisos Android:

En `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### c) Configurar permisos iOS:

En `ios/Runner/Info.plist`, agregar antes de `</dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar tu voz y analizar patrones del habla</string>
```

#### d) Configurar URL del backend (si es necesario):

En `lib/services/api_service.dart`, línea 9, cambiar si usas dispositivo físico:

```dart
static const String baseUrl = 'http://TU_IP_LOCAL:5000'; // Ej: 'http://192.168.1.100:5000'
```

#### e) Ejecutar la app:

```bash
flutter run
```

## ✅ Verificación

### Backend:
1. Verificar que `model.pkl` y `scaler.pkl` existen
2. Verificar que el servidor responde en `/health`
3. Verificar que la tabla `voice_test` existe en la BD

### Flutter:
1. Verificar que las dependencias se instalaron correctamente
2. Verificar permisos de micrófono
3. Probar grabación de audio

## 🐛 Solución de Problemas Comunes

### Error: "Modelo no disponible"
**Solución**: Ejecutar `python scripts/train_model.py`

### Error: "No se encontró el archivo dataset"
**Solución**: Verificar que `backend/data/parkinson_data.data` existe

### Error: "Permisos de micrófono denegados"
**Solución**: 
- Android: Verificar AndroidManifest.xml
- iOS: Verificar Info.plist
- En el dispositivo: Ir a Configuración → Apps → Permisos

### Error: "Connection refused" en Flutter
**Solución**: 
- Verificar que el servidor Flask está corriendo
- Para dispositivos físicos, usar la IP de la máquina, no 127.0.0.1
- Verificar firewall/antivirus

### Error: "Table voice_test already exists"
**Solución**: La tabla ya existe, no es necesario crearla de nuevo

## 📝 Notas Adicionales

- El modelo se entrena una vez y se reutiliza para todas las predicciones
- Los resultados se guardan tanto localmente (SQLite) como en el backend
- La app funciona offline para ver historial, pero necesita conexión para procesar audio
- El formato de audio debe ser WAV, 44100 Hz, mono





