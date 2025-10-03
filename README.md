# Parkinson App - Sistema de Evaluación y Seguimiento

Una aplicación móvil Flutter con backend Flask para la evaluación y clasificación del Parkinson, desarrollada bajo el patrón MVVM.

## Arquitectura del Sistema

### Frontend (Flutter + MVVM)

- **Patrón:** MVVM (Model-View-ViewModel)
- **Gestión de Estado:** Provider
- **Comunicación:** HTTP REST API
- **Plataformas:** Android (iOS en desarrollo)

### Backend (Flutter)

- **Framework:** Flask (Python)
- **Datos:** JSON mockeados en memoria
- **CORS:** Habilitado para desarrollo
- **Endpoints:** REST API JSON

## Funcionalidades Principales

### Entidades del Sistema

- **Usuario:** Cuenta de acceso (paciente, médico, investigador)
- **Paciente:** Información clínica y personal
- **Prueba:** Evaluaciones (espiral, tapping, voz, cuestionario)
- **Resultado:** Análisis y clasificación de riesgo

### Pantallas Implementadas

1. **Splash Screen** - Pantalla de bienvenida
2. **Login** - Autenticación de usuarios
3. **Home Dashboard** - Panel principal con estadísticas
4. **Selector de Prueba** - Elección del tipo de evaluación
5. **Ejecución de Prueba** - Realización de la evaluación
6. **Resultado** - Visualización de resultados y recomendaciones
7. **Historial** - Lista de evaluaciones anteriores

## Instalación y Configuración

### Prerrequisitos

- Flutter SDK 3.9.2+
- Dart SDK
- Python 3.8+
- Android Studio / VS Code

### Frontend (Flutter)

1. **Clonar el repositorio:**

   ```bash
   git clone <repository-url>
   cd mi_app
   ```

2. **Instalar dependencias:**

   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

### Backend (Flutter)

1. **Navegar al directorio del backend:**

   ```bash
   cd backend
   ```

2. **Crear entorno virtual:**

   ```bash
   python -m venv venv

   # Windows:
   venv\bin\Activate.ps1
   ```

3. **Instalar dependencias:**

   ```bash
   pip install -r requirements.txt
   ```

4. **Ejecutar el servidor:**
   ```bash
   python app.py
   ```

El servidor se ejecutará en `http://localhost:5000`

## Configuración de Conexión

### Frontend → Backend

El frontend está configurado para conectarse al backend en `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:5000';
```

### Credenciales de Prueba

| Rol          | Correo                      | Contraseña |
| ------------ | --------------------------- | ---------- |
| Paciente     | juan.perez@email.com        | 123456     |
| Paciente     | maria.gonzalez@email.com    | 123456     |
| Médico       | carlos.lopez@email.com      | 123456     |
| Investigador | ana.investigadora@email.com | 123456     |

## Endpoints del Backend

### Principales

- `GET /health` - Estado del servidor
- `GET /usuarios.json` - Lista de usuarios
- `GET /pacientes.json` - Lista de pacientes
- `GET /pruebas.json` - Lista de pruebas
- `POST /pruebas` - Crear nueva prueba
- `GET /resultados.json` - Lista de resultados
- `POST /resultados` - Crear nuevo resultado

### Adicionales

- `GET /estadisticas` - Estadísticas del sistema
- `POST /simular-prueba` - Simular procesamiento de prueba

## Estructura del Proyecto

```
mi_app/
├── lib/
│   ├── models/           # Modelos de datos
│   │   ├── usuario.dart
│   │   ├── paciente.dart
│   │   ├── prueba.dart
│   │   └── resultado.dart
│   ├── viewmodels/       # Lógica de negocio
│   │   ├── login_viewmodel.dart
│   │   ├── paciente_viewmodel.dart
│   │   ├── prueba_viewmodel.dart
│   │   └── resultado_viewmodel.dart
│   ├── screens/          # Pantallas de la aplicación
│   │   ├── splash_screen.dart
│   │   ├── login_form_screen.dart
│   │   ├── home_screen.dart
│   │   ├── prueba_selector_screen.dart
│   │   ├── prueba_ejecucion_screen.dart
│   │   ├── resultado_screen.dart
│   │   └── historial_screen.dart
│   ├── services/         # Servicios externos
│   │   └── api_service.dart
│   └── main.dart         # Punto de entrada
├── backend/
│   ├── app.py           # Servidor Flask
│   ├── requirements.txt # Dependencias Python
│   └── README.md        # Documentación del backend
└── README.md            # Este archivo
```

## Flujo de la Aplicación

1. **Inicio:** Usuario abre la app → Splash Screen
2. **Autenticación:** Login con credenciales → Validación en backend
3. **Dashboard:** Carga de datos del usuario → Estadísticas y accesos rápidos
4. **Evaluación:** Selección de prueba → Ejecución → Procesamiento
5. **Resultado:** Análisis simulado → Visualización de resultados
6. **Historial:** Consulta de evaluaciones anteriores

## Tipos de Pruebas

### 1. Espiral

- **Descripción:** Dibujo de espiral para evaluar control motor fino
- **Métricas:** Fluidez, control, irregularidades

### 2. Tapping

- **Descripción:** Toque rítmico para evaluar coordinación
- **Métricas:** Ritmo, consistencia, variaciones

### 3. Voz

- **Descripción:** Grabación de voz para análisis del habla
- **Métricas:** Patrones de voz, claridad, ritmo

### 4. Cuestionario

- **Descripción:** Preguntas sobre síntomas y estado general
- **Métricas:** Respuestas, patrones, síntomas reportados

## Niveles de Riesgo

- **Bajo:** Patrones normales, seguimiento regular
- **Moderado:** Irregularidades menores, seguimiento médico
- **Alto:** Patrones anómalos, evaluación especializada

## Desarrollo

### Agregar Nueva Pantalla

1. Crear archivo en `lib/screens/`
2. Agregar ruta en `lib/main.dart`
3. Implementar navegación desde pantallas existentes

### Agregar Nuevo Endpoint

1. Modificar `backend/app.py`
2. Actualizar `lib/services/api_service.dart`
3. Probar conexión frontend-backend

### Modificar Modelos

1. Actualizar archivos en `lib/models/`
2. Regenerar serialización si es necesario
3. Actualizar ViewModels correspondientes

## Consideraciones Importantes

### Desarrollo

- Backend con datos mockeados (no persistencia real)
- CORS habilitado para desarrollo local
- Autenticación simulada (no segura para producción)

### Producción

- Implementar base de datos real
- Autenticación segura (JWT, OAuth)
- Validación y sanitización de datos
- Logs y monitoreo
- HTTPS y certificados SSL

## Licencia

Este proyecto es un prototipo para investigación y desarrollo. Ver archivo de licencia para más detalles.
