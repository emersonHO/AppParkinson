from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS # <--- 1. IMPORTAR CORS
import os
from datetime import datetime
import pickle
import sys
import tempfile
import werkzeug
from werkzeug.utils import secure_filename

# ------------------- CONFIGURACIÓN -------------------
app = Flask(__name__)
CORS(app) # <--- 2. ACTIVAR CORS PARA TODA LA APP

basedir = os.path.abspath(os.path.dirname(__file__))
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'app.db')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL').replace("postgres://", "postgresql://", 1)
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

class VoiceTest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(100), nullable=False)
    date = db.Column(db.String(50), nullable=False)
    probability = db.Column(db.Float, nullable=False)
    level = db.Column(db.String(50), nullable=False)
    fo = db.Column(db.Float)
    fhi = db.Column(db.Float)
    flo = db.Column(db.Float)
    jitter_percent = db.Column(db.Float)
    jitter_abs = db.Column(db.Float)
    rap = db.Column(db.Float)
    ppq = db.Column(db.Float)
    ddp = db.Column(db.Float)
    shimmer = db.Column(db.Float)
    shimmer_db = db.Column(db.Float)
    apq3 = db.Column(db.Float)
    apq5 = db.Column(db.Float)
    apq = db.Column(db.Float)
    dda = db.Column(db.Float)
    nhr = db.Column(db.Float)
    hnr = db.Column(db.Float)
    rpde = db.Column(db.Float)
    dfa = db.Column(db.Float)
    spread1 = db.Column(db.Float)
    spread2 = db.Column(db.Float)
    d2 = db.Column(db.Float)
    ppe = db.Column(db.Float)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'date': self.date,
            'probability': self.probability,
            'level': self.level,
            'fo': self.fo,
            'fhi': self.fhi,
            'flo': self.flo,
            'jitter_percent': self.jitter_percent,
            'jitter_abs': self.jitter_abs,
            'rap': self.rap,
            'ppq': self.ppq,
            'ddp': self.ddp,
            'shimmer': self.shimmer,
            'shimmer_db': self.shimmer_db,
            'apq3': self.apq3,
            'apq5': self.apq5,
            'apq': self.apq,
            'dda': self.dda,
            'nhr': self.nhr,
            'hnr': self.hnr,
            'rpde': self.rpde,
            'dfa': self.dfa,
            'spread1': self.spread1,
            'spread2': self.spread2,
            'd2': self.d2,
            'ppe': self.ppe
        }

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

# ------------------- ENDPOINTS DE VOZ -------------------

def load_model():
    """Carga el modelo y el scaler entrenados"""
    model_path = os.path.join(basedir, 'model.pkl')
    scaler_path = os.path.join(basedir, 'scaler.pkl')
    
    if not os.path.exists(model_path) or not os.path.exists(scaler_path):
        return None, None
    
    try:
        with open(model_path, 'rb') as f:
            model = pickle.load(f)
        with open(scaler_path, 'rb') as f:
            scaler = pickle.load(f)
        return model, scaler
    except Exception as e:
        print(f"Error cargando modelo: {e}")
        return None, None

@app.route('/predict_voice', methods=['POST'])
def predict_voice():
    """Endpoint para predecir Parkinson desde un archivo de audio"""
    try:
        # Verificar que se envió un archivo
        if 'audio' not in request.files:
            return jsonify({'error': 'No se recibió archivo de audio'}), 400
        
        file = request.files['audio']
        if file.filename == '':
            return jsonify({'error': 'Archivo vacío'}), 400
        
        # Guardar temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as tmp_file:
            file.save(tmp_file.name)
            tmp_path = tmp_file.name
        
        try:
            # Importar extractor de features
            sys.path.insert(0, os.path.join(basedir, 'scripts'))
            from extract_features import extract_features
            
            # Extraer características
            features = extract_features(tmp_path)
            
            # Cargar modelo y scaler
            model, scaler = load_model()
            if model is None or scaler is None:
                return jsonify({'error': 'Modelo no disponible. Ejecute train_model.py primero'}), 500
            
            # Normalizar features
            features_array = scaler.transform([features])
            
            # Predecir
            prediction = model.predict(features_array)[0]
            probability = model.predict_proba(features_array)[0][1]  # Probabilidad de Parkinson
            
            # Determinar nivel
            if probability < 0.33:
                level = "Bajo"
            elif probability < 0.66:
                level = "Medio"
            else:
                level = "Alto"
            
            # Mapear características a nombres
            feature_names = [
                'fo', 'fhi', 'flo', 'jitter_percent', 'jitter_abs', 'rap', 'ppq', 'ddp',
                'shimmer', 'shimmer_db', 'apq3', 'apq5', 'apq', 'dda', 'nhr', 'hnr',
                'rpde', 'dfa', 'spread1', 'spread2', 'd2', 'ppe'
            ]
            
            parametros = {name: float(value) for name, value in zip(feature_names, features)}
            
            return jsonify({
                'probabilidad': float(probability),
                'nivel': level,
                'parametros': parametros
            }), 200
            
        finally:
            # Eliminar archivo temporal
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
                
    except Exception as e:
        return jsonify({'error': f'Error procesando audio: {str(e)}'}), 500

@app.route('/save_voice_result', methods=['POST'])
def save_voice_result():
    """Endpoint para guardar resultado de prueba de voz"""
    try:
        data = request.get_json()
        
        if not data or not data.get('user_id') or not data.get('probability') or not data.get('level'):
            return jsonify({'error': 'Faltan datos requeridos'}), 400
        
        nuevo_resultado = VoiceTest(
            user_id=data['user_id'],
            date=data.get('date', datetime.utcnow().isoformat()),
            probability=data['probability'],
            level=data['level'],
            fo=data.get('parametros', {}).get('fo'),
            fhi=data.get('parametros', {}).get('fhi'),
            flo=data.get('parametros', {}).get('flo'),
            jitter_percent=data.get('parametros', {}).get('jitter_percent'),
            jitter_abs=data.get('parametros', {}).get('jitter_abs'),
            rap=data.get('parametros', {}).get('rap'),
            ppq=data.get('parametros', {}).get('ppq'),
            ddp=data.get('parametros', {}).get('ddp'),
            shimmer=data.get('parametros', {}).get('shimmer'),
            shimmer_db=data.get('parametros', {}).get('shimmer_db'),
            apq3=data.get('parametros', {}).get('apq3'),
            apq5=data.get('parametros', {}).get('apq5'),
            apq=data.get('parametros', {}).get('apq'),
            dda=data.get('parametros', {}).get('dda'),
            nhr=data.get('parametros', {}).get('nhr'),
            hnr=data.get('parametros', {}).get('hnr'),
            rpde=data.get('parametros', {}).get('rpde'),
            dfa=data.get('parametros', {}).get('dfa'),
            spread1=data.get('parametros', {}).get('spread1'),
            spread2=data.get('parametros', {}).get('spread2'),
            d2=data.get('parametros', {}).get('d2'),
            ppe=data.get('parametros', {}).get('ppe')
        )
        
        db.session.add(nuevo_resultado)
        db.session.commit()
        
        return jsonify({'mensaje': 'Resultado guardado', 'resultado': nuevo_resultado.to_dict()}), 201
        
    except Exception as e:
        return jsonify({'error': f'Error guardando resultado: {str(e)}'}), 500

@app.route('/voice_results/<user_id>', methods=['GET'])
def get_voice_results(user_id):
    """Obtener resultados de voz de un usuario"""
    try:
        resultados = VoiceTest.query.filter_by(user_id=user_id).order_by(VoiceTest.date.desc()).all()
        return jsonify([r.to_dict() for r in resultados]), 200
    except Exception as e:
        return jsonify({'error': f'Error obteniendo resultados: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
