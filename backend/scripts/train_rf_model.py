"""
Script para entrenar un modelo Random Forest y exportarlo a formato JSON
compatible con Flutter/Dart para inferencia local.
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import json
import os
import warnings
warnings.filterwarnings('ignore')

# Rutas
DATASET_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'parkinson_data.data')
MODEL_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'rf_model.json')
SCALER_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'scaler_params.json')

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

def train_rf_model(X, y):
    """Entrena el modelo Random Forest"""
    print("\n=== Entrenando modelo Random Forest ===")
    
    # Dividir en train y test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Train: {X_train.shape[0]} muestras")
    print(f"Test: {X_test.shape[0]} muestras")
    
    # Normalización CRÍTICA: StandardScaler
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Guardar parámetros del scaler para usar en Dart
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist(),
        'feature_names': list(X.columns)
    }
    
    os.makedirs(os.path.dirname(SCALER_JSON_PATH), exist_ok=True)
    with open(SCALER_JSON_PATH, 'w') as f:
        json.dump(scaler_params, f, indent=2)
    print(f"✓ Parámetros del scaler guardados en: {SCALER_JSON_PATH}")
    
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
    y_pred_proba = rf_model.predict_proba(X_test_scaled)[:, 1]  # Probabilidad de clase positiva
    
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n=== Resultados ===")
    print(f"Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Exportar modelo a JSON
    export_rf_to_json(rf_model, MODEL_JSON_PATH)
    
    return rf_model, scaler

def export_rf_to_json(model, output_path):
    """Exporta el modelo Random Forest a formato JSON para Dart"""
    print(f"\n=== Exportando modelo Random Forest a JSON ===")
    
    # Extraer información de cada árbol
    trees_data = []
    for i, tree in enumerate(model.estimators_):
        tree_data = {
            'tree_index': i,
            'max_depth': tree.tree_.max_depth,
            'node_count': tree.tree_.node_count,
            'children_left': tree.tree_.children_left.tolist(),
            'children_right': tree.tree_.children_right.tolist(),
            'feature': tree.tree_.feature.tolist(),
            'threshold': tree.tree_.threshold.tolist(),
            'value': tree.tree_.value.tolist(),
        }
        trees_data.append(tree_data)
    
    model_data = {
        'n_estimators': model.n_estimators,
        'max_depth': model.max_depth,
        'n_features': model.n_features_in_,
        'trees': trees_data,
    }
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w') as f:
        json.dump(model_data, f, indent=2)
    
    print(f"✓ Modelo RF exportado a: {output_path}")
    print(f"  - Número de árboles: {model.n_estimators}")
    print(f"  - Número de características: {model.n_features_in_}")

def main():
    """Función principal"""
    try:
        # Crear directorios necesarios
        data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data')
        os.makedirs(data_dir, exist_ok=True)
        os.makedirs(os.path.dirname(MODEL_JSON_PATH), exist_ok=True)
        
        # Cargar dataset
        df = load_dataset()
        
        # Preparar datos
        X, y = prepare_data(df)
        
        # Entrenar modelo Random Forest
        model, scaler = train_rf_model(X, y)
        
        print("\n✓ Entrenamiento completado exitosamente")
        print(f"\nArchivos generados:")
        print(f"  - Modelo RF (JSON): {MODEL_JSON_PATH}")
        print(f"  - Parámetros Scaler: {SCALER_JSON_PATH}")
        print(f"\n¡Copia estos archivos a la carpeta assets/model/ en tu proyecto Flutter!")
        
    except Exception as e:
        print(f"\n✗ Error durante el entrenamiento: {e}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == '__main__':
    main()




