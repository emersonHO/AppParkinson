# Aplicación de Detección de Parkinson mediante Análisis de Voz

Aplicación Flutter para la detección temprana de síntomas de Parkinson mediante análisis de voz usando Machine Learning (Random Forest) con inferencia local.

## 📋 Tabla de Contenidos

1. [Arquitectura del Sistema](#arquitectura-del-sistema)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración del Entorno](#configuración-del-entorno)
4. [Preparación del Backend (Entrenamiento del Modelo)](#preparación-del-backend-entrenamiento-del-modelo)
5. [Configuración de la Aplicación Flutter](#configuración-de-la-aplicación-flutter)
6. [Despliegue de la Aplicación (APK)](#despliegue-de-la-aplicación-apk)
7. [Solución de Problemas](#solución-de-problemas)
8. [Estructura del Proyecto](#estructura-del-proyecto)

---

## 🏗️ Arquitectura del Sistema

### Flujo de Datos

```
Usuario graba voz (.wav)
    ↓
VoiceFeatureExtractor (Dart)
    ↓
Extracción de 22 características acústicas
    ↓
VoiceRFService (Dart)
    ↓
Normalización (StandardScaler) ← CRÍTICO
    ↓
Modelo Random Forest (JSON)
    ↓
Predicción de probabilidad (0.0 - 1.0)
    ↓
Clasificación de nivel (Bajo/Medio/Alto)
    ↓
Visualización en UI
    ↓
Almacenamiento en SQLite local
```

### Componentes Principales

1. **Extracción de Características** (`lib/services/voice_feature_extractor.dart`)
   - Implementa las 22 características acústicas en Dart
   - Replica la lógica de `backend/scripts/extract_features.py`

2. **Servicio de ML** (`lib/services/voice_rf_service.dart`)
   - Carga modelo Random Forest desde JSON
   - Aplica StandardScaler (normalización)
   - Ejecuta inferencia local

3. **Modelo Random Forest**
   - Entrenado con dataset real de Parkinson
   - Exportado a formato JSON para Dart
   - 100 árboles, profundidad máxima 10

4. **Base de Datos Local** (SQLite)
   - Almacena resultados de pruebas de voz
   - 22 parámetros acústicos + probabilidad + nivel

---

## 📦 Requisitos Previos

### Para Desarrollo Backend (Python)
- Python 3.8 o superior
- pip (gestor de paquetes de Python)

### Para Desarrollo Flutter
- Flutter SDK 3.9.2 o superior
- Dart SDK 3.9.2 o superior
- Android Studio / Xcode (para compilación)
- Android SDK (para Android)
- Xcode (para iOS, solo macOS)

### Para Despliegue
- Android: Android SDK con herramientas de compilación
- iOS: Xcode y certificados de desarrollador (solo macOS)

---

## ⚙️ Configuración del Entorno

### 1. Instalar Python

**Windows:**
```bash
# Descargar desde python.org
# O usar chocolatey:
choco install python
```

**macOS:**
```bash
brew install python3
```

**Linux:**
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip
```

### 2. Instalar Flutter

1. Descargar Flutter SDK desde [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extraer y agregar a PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
3. Verificar instalación:
   ```bash
   flutter doctor
   ```

### 3. Configurar Android Studio

1. Instalar Android Studio
2. Abrir Android Studio → Configure → SDK Manager
3. Instalar:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android SDK Platform (API 33 o superior)
4. Configurar variables de entorno:
   ```bash
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

---

## 🔧 Preparación del Backend (Entrenamiento del Modelo)

### Paso 1: Instalar Dependencias Python

```bash
cd backend
pip install -r requirements.txt
```

**Dependencias principales:**
- pandas
- numpy
- scikit-learn
- librosa (para extracción de características)

### Paso 2: Preparar el Dataset

1. Colocar el archivo `parkinson_data.data` en `backend/data/`
2. El dataset debe tener las siguientes columnas:
   - `name` (string)
   - `MDVP:Fo(Hz)` hasta `PPE` (22 características numéricas)
   - `status` (0 o 1, donde 1 = Parkinson)

### Paso 3: Entrenar el Modelo Random Forest

```bash
cd backend/scripts
python train_rf_model.py
```

**Salida esperada:**
- `assets/model/rf_model.json` - Modelo Random Forest en formato JSON
- `assets/model/scaler_params.json` - Parámetros del StandardScaler (mean y scale)

**⚠️ IMPORTANTE:** El archivo `scaler_params.json` es **CRÍTICO**. Sin él, las predicciones serán incorrectas (100% de detección).

### Paso 4: Verificar Archivos Generados

```bash
ls -lh assets/model/
# Debe mostrar:
# - rf_model.json (varios MB)
# - scaler_params.json (pequeño, ~1 KB)
```

---

## 📱 Configuración de la Aplicación Flutter

### Paso 1: Instalar Dependencias

```bash
cd mi_app  # Directorio raíz del proyecto Flutter
flutter pub get
```

### Paso 2: Copiar Archivos del Modelo

Asegúrate de que los archivos generados estén en:
```
assets/model/
  ├── rf_model.json
  └── scaler_params.json
```

### Paso 3: Verificar pubspec.yaml

El archivo `pubspec.yaml` debe incluir:

```yaml
assets:
  - assets/model/rf_model.json
  - assets/model/scaler_params.json
```

### Paso 4: Configurar Permisos

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar tu voz y analizarla.</string>
```

### Paso 5: Ejecutar la Aplicación

```bash
# Conecta un dispositivo o inicia un emulador
flutter devices

# Ejecutar en modo debug
flutter run

# O ejecutar en modo release (más rápido)
flutter run --release
```

---

## 📦 Despliegue de la Aplicación (APK)

### Paso 1: Preparar para Compilación

```bash
cd mi_app
flutter clean
flutter pub get
```

### Paso 2: Compilar APK de Release

```bash
flutter build apk --release
```

**Opciones adicionales:**
- `--split-per-abi`: Genera APKs separados por arquitectura (más pequeños)
- `--target-platform android-arm64`: Solo para dispositivos 64-bit

### Paso 3: Ubicación del APK

El APK se generará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Paso 4: Instalar en Dispositivo Android

**Opción A: USB (ADB)**
```bash
# Conectar dispositivo por USB
# Habilitar "Depuración USB" en opciones de desarrollador
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Opción B: Transferencia Manual**
1. Copiar `app-release.apk` al dispositivo
2. En el dispositivo: Configuración → Seguridad → Permitir fuentes desconocidas
3. Abrir el archivo APK e instalar

**Opción C: Google Play Store**
1. Crear cuenta de desarrollador
2. Subir APK a Google Play Console
3. Completar proceso de publicación

---

## 🔍 Solución de Problemas

### Problema: "100% de Detección" (Predicciones Incorrectas)

**Causa:** El escalado (StandardScaler) no se está aplicando correctamente.

**Solución:**
1. Verificar que `scaler_params.json` existe en `assets/model/`
2. Verificar que el archivo contiene `mean` y `scale` (arrays de 22 elementos)
3. Verificar que `VoiceRFService._normalizeFeatures()` se ejecuta antes de la predicción
4. Reentrenar el modelo si es necesario:
   ```bash
   cd backend/scripts
   python train_rf_model.py
   ```

### Problema: "Error cargando modelo RF"

**Causa:** El archivo `rf_model.json` no existe o está corrupto.

**Solución:**
1. Verificar que el archivo existe en `assets/model/rf_model.json`
2. Verificar que `pubspec.yaml` incluye el archivo en `assets`
3. Ejecutar `flutter clean && flutter pub get`
4. Reentrenar el modelo si es necesario

### Problema: "Permisos de micrófono denegados"

**Solución:**
1. Android: Verificar `AndroidManifest.xml` tiene permisos de audio
2. iOS: Verificar `Info.plist` tiene `NSMicrophoneUsageDescription`
3. En el dispositivo: Configuración → Aplicaciones → Permisos → Micrófono

### Problema: "Error al extraer características"

**Causa:** El archivo de audio está corrupto o en formato incorrecto.

**Solución:**
1. Verificar que el audio es formato WAV
2. Verificar que la frecuencia de muestreo es 44100 Hz
3. Verificar que el audio tiene al menos 3 segundos de duración

### Problema: "Modelo no inicializado"

**Solución:**
1. Verificar que `VoiceRFService.initialize()` se llama antes de `predict()`
2. Verificar que los archivos del modelo están en assets
3. Verificar logs para errores de carga

### Problema: APK muy grande

**Solución:**
```bash
# Compilar APK dividido por arquitectura
flutter build apk --split-per-abi --release

# Esto genera:
# app-armeabi-v7a-release.apk (~20 MB)
# app-arm64-v8a-release.apk (~20 MB)
# app-x86_64-release.apk (~20 MB)
```

---

## 📁 Estructura del Proyecto

```
mi_app/
├── android/                 # Configuración Android
├── ios/                     # Configuración iOS
├── lib/
│   ├── main.dart           # Punto de entrada
│   ├── models/             # Modelos de datos
│   │   ├── usuario.dart
│   │   ├── voice_test.dart
│   │   └── resultado_prueba.dart
│   ├── screens/            # Pantallas de la UI
│   │   ├── home_screen.dart
│   │   ├── voice_test_screen.dart
│   │   ├── voice_result_screen.dart
│   │   ├── historial_screen.dart
│   │   ├── perfil_screen.dart
│   │   └── recursos_screen.dart
│   ├── services/           # Servicios y lógica de negocio
│   │   ├── voice_rf_service.dart      # Servicio ML (Random Forest)
│   │   ├── voice_feature_extractor.dart # Extracción de características
│   │   ├── database_service.dart      # SQLite
│   │   └── api_service.dart           # Backend API
│   └── viewmodels/         # ViewModels (Provider)
├── assets/
│   ├── images/             # Imágenes
│   └── model/              # Modelos ML
│       ├── rf_model.json           # Modelo Random Forest
│       └── scaler_params.json      # Parámetros StandardScaler
├── backend/
│   ├── scripts/
│   │   ├── train_rf_model.py       # Entrenamiento RF
│   │   ├── extract_features.py    # Extracción (Python)
│   │   └── train_model.py          # Entrenamiento original
│   ├── data/
│   │   └── parkinson_data.data     # Dataset
│   └── requirements.txt
└── pubspec.yaml            # Dependencias Flutter
```

---

## 🎯 Características Principales

- ✅ **Inferencia Local**: Todo el procesamiento ML se realiza en el dispositivo
- ✅ **Sin Conexión a Internet**: Funciona completamente offline
- ✅ **Random Forest**: Modelo robusto y preciso
- ✅ **Escalado Correcto**: StandardScaler aplicado antes de predicción
- ✅ **Base de Datos Local**: SQLite para almacenamiento persistente
- ✅ **UI Intuitiva**: Diseñada para personas mayores
- ✅ **Historial Completo**: Visualización de todas las evaluaciones

---

## 📝 Notas Importantes

1. **El modelo requiere el archivo `scaler_params.json`** para funcionar correctamente. Sin él, las predicciones serán incorrectas.

2. **El dataset debe estar en el formato correcto** con las 22 características en el orden especificado.

3. **La aplicación funciona completamente offline** una vez que los archivos del modelo están incluidos en el APK.

4. **Esta aplicación es una herramienta de apoyo** y no reemplaza la consulta médica profesional.

---

## 📄 Licencia

Este proyecto es de uso educativo y de investigación.

---

## 👥 Contribuciones

Para contribuir al proyecto, por favor:
1. Fork el repositorio
2. Crea una rama para tu feature
3. Realiza tus cambios
4. Envía un Pull Request

---

## 📧 Contacto

Para preguntas o soporte, por favor abre un issue en el repositorio.

---

**Última actualización:** 2025
