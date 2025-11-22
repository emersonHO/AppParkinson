"""
Script para entrenar un modelo Random Forest con el dataset de Parkinson.
Lee el archivo .data y entrena el modelo guardándolo como model.pkl
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import pickle
import os
import warnings
warnings.filterwarnings('ignore')

# Ruta del dataset
DATASET_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'parkinson_data.data')
MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'model.pkl')
SCALER_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'scaler.pkl')

def load_dataset():
    """
    Carga el dataset desde el archivo .data
    """
    print(f"Cargando dataset desde: {DATASET_PATH}")
    
    if not os.path.exists(DATASET_PATH):
        raise FileNotFoundError(f"No se encontró el archivo: {DATASET_PATH}")
    
    # Leer el archivo .data
    # Asumiendo que está separado por comas o espacios
    try:
        df = pd.read_csv(DATASET_PATH, sep=',')
    except:
        try:
            df = pd.read_csv(DATASET_PATH, sep=r'\s+')
        except:
            df = pd.read_csv(DATASET_PATH, sep='\t')
    
    print(f"Dataset cargado: {df.shape[0]} filas, {df.shape[1]} columnas")
    print(f"Columnas: {list(df.columns)}")
    
    return df

def prepare_data(df):
    """
    Prepara los datos para el entrenamiento:
    - Elimina la columna 'name'
    - Separa features y target (status)
    - Convierte a float
    """
    # Verificar que existe la columna 'name'
    if 'name' in df.columns:
        df = df.drop(columns=['name'])
    
    # Verificar que existe la columna 'status'
    if 'status' not in df.columns:
        raise ValueError("La columna 'status' no existe en el dataset")
    
    # Separar features y target
    X = df.drop(columns=['status'])
    y = df['status']
    
    # Convertir todas las columnas a float (excepto status que ya es int)
    for col in X.columns:
        X[col] = pd.to_numeric(X[col], errors='coerce')
    
    # Eliminar filas con valores NaN
    mask = ~(X.isna().any(axis=1) | y.isna())
    X = X[mask]
    y = y[mask]
    
    print(f"Datos preparados: {X.shape[0]} muestras, {X.shape[1]} features")
    print(f"Distribución de clases: {y.value_counts().to_dict()}")
    
    # Verificar el orden de las columnas
    expected_columns = [
        'MDVP:Fo(Hz)', 'MDVP:Fhi(Hz)', 'MDVP:Flo(Hz)', 'MDVP:Jitter(%)',
        'MDVP:Jitter(Abs)', 'MDVP:RAP', 'MDVP:PPQ', 'Jitter:DDP',
        'MDVP:Shimmer', 'MDVP:Shimmer(dB)', 'Shimmer:APQ3', 'Shimmer:APQ5',
        'MDVP:APQ', 'Shimmer:DDA', 'NHR', 'HNR', 'RPDE', 'DFA',
        'spread1', 'spread2', 'D2', 'PPE'
    ]
    
    # Reordenar columnas si es necesario
    missing_cols = [col for col in expected_columns if col not in X.columns]
    if missing_cols:
        print(f"Advertencia: Faltan columnas: {missing_cols}")
        print(f"Columnas disponibles: {list(X.columns)}")
    
    # Reordenar a la secuencia esperada
    available_cols = [col for col in expected_columns if col in X.columns]
    X = X[available_cols]
    
    return X, y

def train_model(X, y):
    """
    Entrena el modelo Random Forest
    """
    print("\n=== Entrenando modelo Random Forest ===")
    
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
    
    # Entrenar Random Forest
    print("\nEntrenando Random Forest...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    rf_model.fit(X_train_scaled, y_train)
    
    # Evaluar
    y_pred = rf_model.predict(X_test_scaled)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n=== Resultados ===")
    print(f"Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    return rf_model, scaler

def save_model(model, scaler):
    """
    Guarda el modelo y el scaler
    """
    print(f"\nGuardando modelo en: {MODEL_PATH}")
    with open(MODEL_PATH, 'wb') as f:
        pickle.dump(model, f)
    
    print(f"Guardando scaler en: {SCALER_PATH}")
    with open(SCALER_PATH, 'wb') as f:
        pickle.dump(scaler, f)
    
    print("✓ Modelo y scaler guardados exitosamente")

def main():
    """
    Función principal
    """
    try:
        # Crear directorio data si no existe
        data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data')
        os.makedirs(data_dir, exist_ok=True)
        
        # Cargar dataset
        df = load_dataset()
        
        # Preparar datos
        X, y = prepare_data(df)
        
        # Entrenar modelo
        model, scaler = train_model(X, y)
        
        # Guardar modelo
        save_model(model, scaler)
        
        print("\n✓ Entrenamiento completado exitosamente")
        
    except Exception as e:
        print(f"\n✗ Error durante el entrenamiento: {e}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == '__main__':
    main()





