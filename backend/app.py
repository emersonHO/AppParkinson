from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
from datetime import datetime, timedelta
import random

app = Flask(__name__)
CORS(app)  # Permitir CORS para desarrollo

# Datos mockeados
USUARIOS = [
    {
        "id": 1,
        "nombre": "Juan Pérez",
        "correo": "juan.perez@email.com",
        "rol": "paciente",
        "contraseña": "123456"
    },
    {
        "id": 2,
        "nombre": "María González",
        "correo": "maria.gonzalez@email.com",
        "rol": "paciente",
        "contraseña": "123456"
    },
    {
        "id": 3,
        "nombre": "Dr. Carlos López",
        "correo": "carlos.lopez@email.com",
        "rol": "médico",
        "contraseña": "123456"
    },
    {
        "id": 4,
        "nombre": "Ana Investigadora",
        "correo": "ana.investigadora@email.com",
        "rol": "investigador",
        "contraseña": "123456"
    }
]

PACIENTES = [
    {
        "id": 1,
        "nombre": "Juan Pérez",
        "edad": 65,
        "genero": "M",
        "fecha_diagnostico": "2020-05-10",
        "contacto_emergencia": "999888777"
    },
    {
        "id": 2,
        "nombre": "María González",
        "edad": 59,
        "genero": "F",
        "fecha_diagnostico": None,
        "contacto_emergencia": "988777666"
    },
    {
        "id": 3,
        "nombre": "Roberto Silva",
        "edad": 72,
        "genero": "M",
        "fecha_diagnostico": "2019-03-15",
        "contacto_emergencia": "977666555"
    },
    {
        "id": 4,
        "nombre": "Carmen Ruiz",
        "edad": 68,
        "genero": "F",
        "fecha_diagnostico": "2021-08-22",
        "contacto_emergencia": "966555444"
    }
]

PRUEBAS = [
    {
        "id": 1,
        "tipo": "espiral",
        "fecha": "2024-01-15T10:30:00",
        "estado": "completada"
    },
    {
        "id": 2,
        "tipo": "tapping",
        "fecha": "2024-01-16T14:20:00",
        "estado": "completada"
    },
    {
        "id": 3,
        "tipo": "voz",
        "fecha": "2024-01-17T09:15:00",
        "estado": "completada"
    },
    {
        "id": 4,
        "tipo": "cuestionario",
        "fecha": "2024-01-18T16:45:00",
        "estado": "completada"
    },
    {
        "id": 5,
        "tipo": "espiral",
        "fecha": "2024-01-20T11:00:00",
        "estado": "pendiente"
    }
]

RESULTADOS = [
    {
        "id": 1,
        "prueba_id": 1,
        "nivel_riesgo": "bajo",
        "confianza": 87.5,
        "observaciones": "La espiral muestra patrones normales con buena fluidez y control. No se detectan irregularidades significativas."
    },
    {
        "id": 2,
        "prueba_id": 2,
        "nivel_riesgo": "moderado",
        "confianza": 72.3,
        "observaciones": "Se detectan variaciones menores en el ritmo de tapping. Se recomienda seguimiento adicional."
    },
    {
        "id": 3,
        "prueba_id": 3,
        "nivel_riesgo": "bajo",
        "confianza": 81.7,
        "observaciones": "Análisis de voz dentro de parámetros normales. Patrones de habla consistentes."
    },
    {
        "id": 4,
        "prueba_id": 4,
        "nivel_riesgo": "alto",
        "confianza": 68.2,
        "observaciones": "Respuestas del cuestionario sugieren necesidad de evaluación especializada inmediata."
    }
]

# ========== ENDPOINTS ==========

@app.route('/health', methods=['GET'])
def health_check():
    """Endpoint de salud para verificar que el servidor está funcionando"""
    return jsonify({
        "status": "ok",
        "message": "Servidor Flask funcionando correctamente",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/usuarios.json', methods=['GET'])
def get_usuarios():
    """Obtiene todos los usuarios"""
    return jsonify(USUARIOS)

@app.route('/usuarios/<int:usuario_id>', methods=['GET'])
def get_usuario(usuario_id):
    """Obtiene un usuario específico por ID"""
    usuario = next((u for u in USUARIOS if u['id'] == usuario_id), None)
    if usuario:
        return jsonify(usuario)
    return jsonify({"error": "Usuario no encontrado"}), 404

@app.route('/pacientes.json', methods=['GET'])
def get_pacientes():
    """Obtiene todos los pacientes"""
    return jsonify(PACIENTES)

@app.route('/pacientes/<int:paciente_id>', methods=['GET'])
def get_paciente(paciente_id):
    """Obtiene un paciente específico por ID"""
    paciente = next((p for p in PACIENTES if p['id'] == paciente_id), None)
    if paciente:
        return jsonify(paciente)
    return jsonify({"error": "Paciente no encontrado"}), 404

@app.route('/pruebas.json', methods=['GET'])
def get_pruebas():
    """Obtiene todas las pruebas"""
    return jsonify(PRUEBAS)

@app.route('/pruebas', methods=['POST'])
def crear_prueba():
    """Crea una nueva prueba"""
    data = request.get_json()
    
    nueva_prueba = {
        "id": len(PRUEBAS) + 1,
        "tipo": data.get('tipo', 'espiral'),
        "fecha": datetime.now().isoformat(),
        "estado": "pendiente"
    }
    
    PRUEBAS.append(nueva_prueba)
    return jsonify(nueva_prueba), 201

@app.route('/pruebas/<int:prueba_id>', methods=['GET'])
def get_prueba(prueba_id):
    """Obtiene una prueba específica por ID"""
    prueba = next((p for p in PRUEBAS if p['id'] == prueba_id), None)
    if prueba:
        return jsonify(prueba)
    return jsonify({"error": "Prueba no encontrada"}), 404

@app.route('/resultados.json', methods=['GET'])
def get_resultados():
    """Obtiene todos los resultados"""
    return jsonify(RESULTADOS)

@app.route('/resultados', methods=['POST'])
def crear_resultado():
    """Crea un nuevo resultado"""
    data = request.get_json()
    
    nuevo_resultado = {
        "id": len(RESULTADOS) + 1,
        "prueba_id": data.get('prueba_id'),
        "nivel_riesgo": data.get('nivel_riesgo', 'bajo'),
        "confianza": data.get('confianza', 75.0),
        "observaciones": data.get('observaciones', 'Resultado generado automáticamente')
    }
    
    RESULTADOS.append(nuevo_resultado)
    return jsonify(nuevo_resultado), 201

@app.route('/resultados/<int:resultado_id>', methods=['GET'])
def get_resultado(resultado_id):
    """Obtiene un resultado específico por ID"""
    resultado = next((r for r in RESULTADOS if r['id'] == resultado_id), None)
    if resultado:
        return jsonify(resultado)
    return jsonify({"error": "Resultado no encontrado"}), 404

# ========== ENDPOINTS ADICIONALES ==========

@app.route('/estadisticas', methods=['GET'])
def get_estadisticas():
    """Obtiene estadísticas generales del sistema"""
    stats = {
        "total_usuarios": len(USUARIOS),
        "total_pacientes": len(PACIENTES),
        "total_pruebas": len(PRUEBAS),
        "total_resultados": len(RESULTADOS),
        "pruebas_completadas": len([p for p in PRUEBAS if p['estado'] == 'completada']),
        "pruebas_pendientes": len([p for p in PRUEBAS if p['estado'] == 'pendiente']),
        "resultados_bajo_riesgo": len([r for r in RESULTADOS if r['nivel_riesgo'] == 'bajo']),
        "resultados_moderado_riesgo": len([r for r in RESULTADOS if r['nivel_riesgo'] == 'moderado']),
        "resultados_alto_riesgo": len([r for r in RESULTADOS if r['nivel_riesgo'] == 'alto']),
    }
    return jsonify(stats)

@app.route('/simular-prueba', methods=['POST'])
def simular_prueba():
    """Simula el procesamiento de una prueba y genera un resultado"""
    data = request.get_json()
    tipo_prueba = data.get('tipo', 'espiral')
    
    # Crear nueva prueba
    nueva_prueba = {
        "id": len(PRUEBAS) + 1,
        "tipo": tipo_prueba,
        "fecha": datetime.now().isoformat(),
        "estado": "completada"
    }
    PRUEBAS.append(nueva_prueba)
    
    # Generar resultado simulado
    nivel_riesgo = random.choice(['bajo', 'moderado', 'alto'])
    confianza = random.uniform(60.0, 95.0)
    
    observaciones_por_tipo = {
        'espiral': {
            'bajo': 'La espiral muestra patrones normales con buena fluidez y control.',
            'moderado': 'Se observan algunas irregularidades en la espiral que requieren seguimiento.',
            'alto': 'La espiral presenta patrones anómalos que sugieren evaluación médica.'
        },
        'tapping': {
            'bajo': 'Ritmo de tapping consistente y regular.',
            'moderado': 'Se detectan variaciones menores en el ritmo de tapping.',
            'alto': 'Patrones irregulares de tapping detectados.'
        },
        'voz': {
            'bajo': 'Análisis de voz dentro de parámetros normales.',
            'moderado': 'Se observan ligeras variaciones en el análisis de voz.',
            'alto': 'Análisis de voz muestra patrones anómalos.'
        },
        'cuestionario': {
            'bajo': 'Respuestas del cuestionario indican estado normal.',
            'moderado': 'Algunas respuestas requieren seguimiento médico.',
            'alto': 'Respuestas sugieren necesidad de evaluación especializada.'
        }
    }
    
    nuevo_resultado = {
        "id": len(RESULTADOS) + 1,
        "prueba_id": nueva_prueba['id'],
        "nivel_riesgo": nivel_riesgo,
        "confianza": round(confianza, 1),
        "observaciones": observaciones_por_tipo.get(tipo_prueba, {}).get(nivel_riesgo, 'Resultado generado automáticamente.')
    }
    RESULTADOS.append(nuevo_resultado)
    
    return jsonify({
        "prueba": nueva_prueba,
        "resultado": nuevo_resultado
    }), 201

# ========== CONFIGURACIÓN ==========

if __name__ == '__main__':
    print("🚀 Iniciando servidor Flask para Parkinson App")
    print("📊 Endpoints disponibles:")
    print("   - GET  /health - Verificar estado del servidor")
    print("   - GET  /usuarios.json - Obtener usuarios")
    print("   - GET  /pacientes.json - Obtener pacientes")
    print("   - GET  /pruebas.json - Obtener pruebas")
    print("   - POST /pruebas - Crear nueva prueba")
    print("   - GET  /resultados.json - Obtener resultados")
    print("   - POST /resultados - Crear nuevo resultado")
    print("   - GET  /estadisticas - Estadísticas del sistema")
    print("   - POST /simular-prueba - Simular prueba completa")
    print("\n🌐 Servidor ejecutándose en: http://localhost:5000")
    print("📱 Frontend configurado para: http://localhost:5000")
    
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True
    )
