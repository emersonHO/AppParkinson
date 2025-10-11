# Backend Flask - Parkinson App

Este es el backend Flask que proporciona endpoints JSON mockeados para la aplicación móvil de evaluación de Parkinson.

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Python 3.8 o superior
- pip (gestor de paquetes de Python)

### Instalación

1. **Navegar al directorio del backend:**
   ```bash
   cd backend
   ```

2. **Crear un entorno virtual (recomendado):**
   ```bash
   python -m venv venv
   
   # En Windows:
   venv\Scripts\activate
   
   # En macOS/Linux:
   source venv/bin/activate
   ```

3. **Instalar dependencias:**
   ```bash
   pip install -r requirements.txt
   ```

### Ejecución

```bash
python app.py
```

El servidor se ejecutará en `http://localhost:5000`

## 📊 Endpoints Disponibles

### Endpoints Principales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/health` | Verificar estado del servidor |
| GET | `/usuarios.json` | Obtener todos los usuarios |
| GET | `/pacientes.json` | Obtener todos los pacientes |
| GET | `/pruebas.json` | Obtener todas las pruebas |
| POST | `/pruebas` | Crear nueva prueba |
| GET | `/resultados.json` | Obtener todos los resultados |
| POST | `/resultados` | Crear nuevo resultado |

### Endpoints Adicionales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/estadisticas` | Estadísticas generales del sistema |
| POST | `/simular-prueba` | Simular procesamiento completo de prueba |

## 🔧 Configuración

### Datos Mockeados

El servidor incluye datos de prueba predefinidos:

- **Usuarios:** 4 usuarios (pacientes, médico, investigador)
- **Pacientes:** 4 pacientes con información clínica
- **Pruebas:** 5 pruebas de diferentes tipos
- **Resultados:** 4 resultados con diferentes niveles de riesgo

### Credenciales de Prueba

Para testing, puedes usar estas credenciales:

| Rol | Correo | Contraseña |
|-----|--------|------------|
| Paciente | juan.perez@email.com | 123456 |
| Paciente | maria.gonzalez@email.com | 123456 |
| Médico | carlos.lopez@email.com | 123456 |
| Investigador | ana.investigadora@email.com | 123456 |

## 🌐 CORS

El servidor está configurado con CORS habilitado para permitir conexiones desde el frontend Flutter durante el desarrollo.

## 📱 Integración con Flutter

El frontend Flutter está configurado para conectarse a este backend en `http://localhost:5000`. Asegúrate de que:

1. El servidor Flask esté ejecutándose
2. El frontend Flutter tenga la URL correcta en `ApiService`
3. Ambos estén en la misma red o configurados para desarrollo local

## 🔄 Flujo de Datos

1. **Autenticación:** Usuario se autentica con `/usuarios.json`
2. **Carga de Datos:** Se obtienen pacientes, pruebas y resultados
3. **Ejecución de Prueba:** Se crea nueva prueba con `/pruebas`
4. **Procesamiento:** Se simula análisis y se crea resultado con `/resultados`
5. **Visualización:** Se muestran resultados en el frontend

## 🛠️ Desarrollo

### Agregar Nuevos Endpoints

Para agregar nuevos endpoints, edita `app.py` y sigue el patrón existente:

```python
@app.route('/nuevo-endpoint', methods=['GET'])
def nuevo_endpoint():
    return jsonify({"mensaje": "Nuevo endpoint funcionando"})
```

### Modificar Datos Mockeados

Los datos están definidos como listas Python al inicio de `app.py`. Puedes modificarlos directamente o implementar persistencia con base de datos.

## 🚨 Notas Importantes

- Este es un servidor de desarrollo con datos mockeados
- No incluye autenticación real ni persistencia de datos
- Los datos se reinician cada vez que se reinicia el servidor
- Para producción, implementar base de datos real y autenticación segura

## 📞 Soporte

Para problemas o preguntas sobre el backend, revisa los logs del servidor o contacta al equipo de desarrollo.
