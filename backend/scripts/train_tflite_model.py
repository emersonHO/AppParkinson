"""
Script para entrenar un modelo TensorFlow/Keras y exportarlo a TensorFlow Lite.
Este modelo reemplazará al Random Forest para permitir inferencia local en Flutter.
"""

import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import os
import warnings
warnings.filterwarnings('ignore')

# Ruta del dataset
DATASET_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'parkinson_data.data')
TFLITE_MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'parkinson_voice_model.tflite')
SCALER_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'scaler_params.json')
os.makedirs(os.path.dirname(TFLITE_MODEL_PATH), exist_ok=True)

def load_dataset():
    """Carga el dataset desde el archivo .data"""
    print(f"Cargando dataset desde: {DATASET_PATH}")
    
    if not os.path.exists(DATASET_PATH):
        raise FileNotFoundError(f"No se encontró el archivo: {DATASET_PATH}")
    
    try:
        df = pd.read_csv(DATASET_PATH, sep=',')
    except:
        try:
            df = pd.read_csv(DATASET_PATH, sep=r'\s+')
        except:
            df = pd.read_csv(DATASET_PATH, sep='\t')
    
    print(f"Dataset cargado: {df.shape[0]} filas, {df.shape[1]} columnas")
    return df

def prepare_data(df):
    """Prepara los datos para el entrenamiento"""
    if 'name' in df.columns:
        df = df.drop(columns=['name'])
    
    if 'status' not in df.columns:
        raise ValueError("La columna 'status' no existe en el dataset")
    
    X = df.drop(columns=['status'])
    y = df['status']
    
    for col in X.columns:
        X[col] = pd.to_numeric(X[col], errors='coerce')
    
    mask = ~(X.isna().any(axis=1) | y.isna())
    X = X[mask]
    y = y[mask]
    
    print(f"Datos preparados: {X.shape[0]} muestras, {X.shape[1]} features")
    print(f"Distribución de clases: {y.value_counts().to_dict()}")
    
    # Reordenar columnas al orden esperado
    expected_columns = [
        'MDVP:Fo(Hz)', 'MDVP:Fhi(Hz)', 'MDVP:Flo(Hz)', 'MDVP:Jitter(%)',
        'MDVP:Jitter(Abs)', 'MDVP:RAP', 'MDVP:PPQ', 'Jitter:DDP',
        'MDVP:Shimmer', 'MDVP:Shimmer(dB)', 'Shimmer:APQ3', 'Shimmer:APQ5',
        'MDVP:APQ', 'Shimmer:DDA', 'NHR', 'HNR', 'RPDE', 'DFA',
        'spread1', 'spread2', 'D2', 'PPE'
    ]
    
    available_cols = [col for col in expected_columns if col in X.columns]
    X = X[available_cols]
    
    return X, y

def train_tensorflow_model(X, y):
    """Entrena un modelo TensorFlow/Keras"""
    print("\n=== Entrenando modelo TensorFlow/Keras ===")
    
    # Dividir en train y test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Train: {X_train.shape[0]} muestras")
    print(f"Test: {X_test.shape[0]} muestras")
    
    # Normalización
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Guardar parámetros del scaler para usar en Dart
    import json
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist(),
        'feature_names': list(X.columns)
    }
    with open(SCALER_JSON_PATH, 'w') as f:
        json.dump(scaler_params, f, indent=2)
    print(f"Parámetros del scaler guardados en: {SCALER_JSON_PATH}")
    
    # Crear modelo de red neuronal
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(64, activation='relu', input_shape=(X_train_scaled.shape[1],)),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')  # Probabilidad de Parkinson
    ])
    
    model.compile(
        optimizer='adam',
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    
    # Entrenar
    print("\nEntrenando modelo...")
    history = model.fit(
        X_train_scaled, y_train,
        epochs=100,
        batch_size=32,
        validation_split=0.2,
        verbose=1,
        callbacks=[
            tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)
        ]
    )
    
    # Evaluar
    y_pred_proba = model.predict(X_test_scaled)
    y_pred = (y_pred_proba > 0.5).astype(int).flatten()
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n=== Resultados ===")
    print(f"Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    return model, scaler

def convert_to_tflite(model, output_path):
    """Convierte el modelo Keras a TensorFlow Lite"""
    print(f"\n=== Convirtiendo a TensorFlow Lite ===")
    
    # Convertir a TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    # Guardar
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"✓ Modelo TFLite guardado en: {output_path}")
    print(f"Tamaño del modelo: {len(tflite_model) / 1024:.2f} KB")

def main():
    """Función principal"""
    try:
        # Crear directorios necesarios
        data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data')
        os.makedirs(data_dir, exist_ok=True)
        os.makedirs(os.path.dirname(TFLITE_MODEL_PATH), exist_ok=True)
        
        # Cargar dataset
        df = load_dataset()
        
        # Preparar datos
        X, y = prepare_data(df)
        
        # Entrenar modelo TensorFlow
        model, scaler = train_tensorflow_model(X, y)
        
        # Convertir a TFLite
        convert_to_tflite(model, TFLITE_MODEL_PATH)
        
        print("\n✓ Entrenamiento y conversión completados exitosamente")
        print(f"\nArchivos generados:")
        print(f"  - Modelo TFLite: {TFLITE_MODEL_PATH}")
        print(f"  - Parámetros Scaler: {SCALER_JSON_PATH}")
        print(f"\n¡Copia estos archivos a la carpeta assets/model/ en tu proyecto Flutter!")
        
    except Exception as e:
        print(f"\n✗ Error durante el entrenamiento: {e}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == '__main__':
    main()

