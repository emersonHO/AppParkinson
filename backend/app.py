from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS # <--- 1. IMPORTAR CORS
import os
from datetime import datetime

# ------------------- CONFIGURACIÓN -------------------
app = Flask(__name__)
CORS(app) # <--- 2. ACTIVAR CORS PARA TODA LA APP

basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# ... (el resto del archivo no necesita cambios) ...

# ------------------- MODELOS DE LA BASE DE DATOS -------------------

class Usuario(db.Model):
    usuario_id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    correo = db.Column(db.String(100), unique=True, nullable=False)
    contrasena = db.Column(db.String(100), nullable=False)
    rol = db.Column(db.String(50), nullable=False)
    fecha_creacion = db.Column(db.DateTime, default=datetime.utcnow)
    activo = db.Column(db.Boolean, default=True)

    paciente = db.relationship('Paciente', backref='usuario', uselist=False, cascade="all, delete-orphan")
    medico = db.relationship('Medico', backref='usuario', uselist=False, cascade="all, delete-orphan")
    consentimiento = db.relationship('Consentimiento', backref='usuario', uselist=False, cascade="all, delete-orphan")

    def to_dict(self, include_profile=False):
        data = {
            'usuario_id': self.usuario_id,
            'nombre': self.nombre,
            'correo': self.correo,
            'rol': self.rol,
            'fecha_creacion': self.fecha_creacion.isoformat(),
            'activo': self.activo
        }
        if include_profile:
            if self.rol == 'Paciente' and self.paciente:
                data['paciente'] = self.paciente.to_dict()
            elif self.rol == 'Médico' and self.medico:
                data['medico'] = self.medico.to_dict()
        return data

class Paciente(db.Model):
    paciente_id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.usuario_id'), nullable=False, unique=True)
    edad = db.Column(db.Integer)
    genero = db.Column(db.String(50))
    fecha_diagnostico = db.Column(db.String(50))
    contacto_emergencia = db.Column(db.String(100))
    notas_medicas = db.Column(db.Text)
    resultados = db.relationship('ResultadoPrueba', backref='paciente', lazy=True, cascade="all, delete-orphan")

    def to_dict(self):
        return {
            'paciente_id': self.paciente_id,
            'usuario_id': self.usuario_id,
            'edad': self.edad,
            'genero': self.genero,
            'fecha_diagnostico': self.fecha_diagnostico,
            'contacto_emergencia': self.contacto_emergencia,
            'notas_medicas': self.notas_medicas
        }

class Medico(db.Model):
    medico_id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.usuario_id'), nullable=False, unique=True)
    especialidad = db.Column(db.String(100))
    centro_medico = db.Column(db.String(100))
    nro_colegiatura = db.Column(db.String(50))

    def to_dict(self):
        return {
            'medico_id': self.medico_id,
            'usuario_id': self.usuario_id,
            'especialidad': self.especialidad,
            'centro_medico': self.centro_medico,
            'nro_colegiatura': self.nro_colegiatura
        }

class RelacionMedicoPaciente(db.Model):
    relacion_id = db.Column(db.Integer, primary_key=True)
    medico_id = db.Column(db.Integer, db.ForeignKey('medico.medico_id'), nullable=False)
    paciente_id = db.Column(db.Integer, db.ForeignKey('paciente.paciente_id'), nullable=False)
    fecha_asignacion = db.Column(db.DateTime, default=datetime.utcnow)

class ResultadoPrueba(db.Model):
    resultado_id = db.Column(db.Integer, primary_key=True)
    paciente_id = db.Column(db.Integer, db.ForeignKey('paciente.paciente_id'), nullable=False)
    tipo_prueba = db.Column(db.String(50), nullable=False)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)
    nivel_riesgo = db.Column(db.String(50))
    confianza = db.Column(db.Integer)
    observaciones = db.Column(db.Text)
    archivo_referencia = db.Column(db.String(200))

    def to_dict(self):
        return {
            'resultado_id': self.resultado_id,
            'paciente_id': self.paciente_id,
            'tipo_prueba': self.tipo_prueba,
            'fecha': self.fecha.isoformat(),
            'nivel_riesgo': self.nivel_riesgo,
            'confianza': self.confianza,
            'observaciones': self.observaciones,
            'archivo_referencia': self.archivo_referencia
        }

class PruebaConfiguracion(db.Model):
    config_id = db.Column(db.Integer, primary_key=True)
    tipo_prueba = db.Column(db.String(100), unique=True, nullable=False)
    parametros_json = db.Column(db.Text)
    ultima_actualizacion = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Consentimiento(db.Model):
    consentimiento_id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.usuario_id'), nullable=False, unique=True)
    fecha_aceptacion = db.Column(db.DateTime, default=datetime.utcnow)
    politica_version = db.Column(db.String(50))
    permisos_otorgados = db.Column(db.Boolean, default=False)

# ------------------- RUTAS DE LA API -------------------

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok'}), 200

@app.route('/registro.json', methods=['POST'])
def registro():
    data = request.get_json()
    if not data or not data.get('correo') or not data.get('contrasena'):
        return jsonify({'error': 'Faltan datos requeridos'}), 400
    if Usuario.query.filter_by(correo=data['correo']).first():
        return jsonify({'error': 'El correo ya está registrado'}), 409
    nuevo_usuario = Usuario(nombre=data['nombre'], correo=data['correo'], contrasena=data['contrasena'], rol=data['rol'])
    db.session.add(nuevo_usuario)
    db.session.flush()
    if data['rol'] == 'Paciente':
        db.session.add(Paciente(usuario_id=nuevo_usuario.usuario_id))
    elif data['rol'] == 'Médico':
        db.session.add(Medico(usuario_id=nuevo_usuario.usuario_id))
    if data.get('acepta_politicas', False):
        db.session.add(Consentimiento(usuario_id=nuevo_usuario.usuario_id, politica_version="1.0", permisos_otorgados=True))
    db.session.commit()
    return jsonify({'mensaje': 'Usuario creado', 'usuario': nuevo_usuario.to_dict(include_profile=True)}), 201

@app.route('/login.json', methods=['POST'])
def login():
    data = request.get_json()
    usuario = Usuario.query.filter_by(correo=data.get('correo')).first()
    if not usuario or usuario.contrasena != data.get('contrasena'):
        return jsonify({'error': 'Credenciales inválidas'}), 401
    return jsonify({'mensaje': 'Login exitoso', 'usuario': usuario.to_dict(include_profile=True)})

@app.route('/pacientes.json', methods=['GET'])
def get_pacientes():
    pacientes = Paciente.query.all()
    return jsonify([p.to_dict() for p in pacientes])

@app.route('/pacientes/<int:paciente_id>.json', methods=['GET'])
def get_paciente(paciente_id):
    paciente = Paciente.query.get_or_404(paciente_id)
    return jsonify(paciente.to_dict())

@app.route('/resultados.json', methods=['GET', 'POST'])
def handle_resultados():
    if request.method == 'POST':
        data = request.get_json()
        nuevo_resultado = ResultadoPrueba(
            paciente_id=data['paciente_id'],
            tipo_prueba=data['tipo_prueba'],
            nivel_riesgo=data.get('nivel_riesgo'),
            confianza=data.get('confianza'),
            observaciones=data.get('observaciones')
        )
        db.session.add(nuevo_resultado)
        db.session.commit()
        return jsonify(nuevo_resultado.to_dict()), 201
    else:
        resultados = ResultadoPrueba.query.all()
        return jsonify([r.to_dict() for r in resultados])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
