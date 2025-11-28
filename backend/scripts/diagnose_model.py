"""
Script de diagnóstico para verificar el modelo y las características.
"""

import pandas as pd
import numpy as np
import json
import os

# Rutas
DATASET_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'parkinson_data.data')
SCALER_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'scaler_params.json')
MODEL_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'rf_model.json')

def analyze_dataset():
    """Analiza el dataset para ver distribución de clases"""
    print("=" * 60)
    print("ANÁLISIS DEL DATASET")
    print("=" * 60)
    
    df = pd.read_csv(DATASET_PATH, sep=',')
    
    if 'name' in df.columns:
        df = df.drop(columns=['name'])
    
    if 'status' not in df.columns:
        print("ERROR: No se encuentra la columna 'status'")
        return
    
    y = df['status']
    print(f"\nTotal de muestras: {len(y)}")
    print(f"Distribución de clases:")
    print(f"  - Sin Parkinson (0): {(y == 0).sum()} ({(y == 0).sum() / len(y) * 100:.1f}%)")
    print(f"  - Con Parkinson (1): {(y == 1).sum()} ({(y == 1).sum() / len(y) * 100:.1f}%)")
    
    # Verificar orden de columnas
    expected_columns = [
        'MDVP:Fo(Hz)', 'MDVP:Fhi(Hz)', 'MDVP:Flo(Hz)', 'MDVP:Jitter(%)',
        'MDVP:Jitter(Abs)', 'MDVP:RAP', 'MDVP:PPQ', 'Jitter:DDP',
        'MDVP:Shimmer', 'MDVP:Shimmer(dB)', 'Shimmer:APQ3', 'Shimmer:APQ5',
        'MDVP:APQ', 'Shimmer:DDA', 'NHR', 'HNR', 'RPDE', 'DFA',
        'spread1', 'spread2', 'D2', 'PPE'
    ]
    
    X = df.drop(columns=['status'])
    available_cols = [col for col in expected_columns if col in X.columns]
    
    print(f"\nOrden de columnas en el dataset:")
    for i, col in enumerate(available_cols, 1):
        print(f"  {i:2d}. {col}")
    
    # Estadísticas básicas
    X_ordered = X[available_cols]
    print(f"\nEstadísticas básicas (primeras 5 características):")
    print(X_ordered.iloc[:, :5].describe())
    
    return X_ordered, y

def analyze_scaler():
    """Analiza los parámetros del scaler"""
    print("\n" + "=" * 60)
    print("ANÁLISIS DEL SCALER")
    print("=" * 60)
    
    if not os.path.exists(SCALER_JSON_PATH):
        print(f"ERROR: No se encuentra el archivo: {SCALER_JSON_PATH}")
        return None
    
    with open(SCALER_JSON_PATH, 'r') as f:
        scaler_params = json.load(f)
    
    mean = scaler_params['mean']
    scale = scaler_params['scale']
    feature_names = scaler_params.get('feature_names', [])
    
    print(f"\nNúmero de características: {len(mean)}")
    print(f"\nOrden de características en scaler_params.json:")
    for i, name in enumerate(feature_names, 1):
        print(f"  {i:2d}. {name} (mean={mean[i-1]:.6f}, scale={scale[i-1]:.6f})")
    
    # Verificar si hay valores de scale cercanos a cero
    zero_scales = [i for i, s in enumerate(scale) if abs(s) < 1e-10]
    if zero_scales:
        print(f"\n⚠️ ADVERTENCIA: Hay {len(zero_scales)} características con scale ≈ 0:")
        for idx in zero_scales:
            print(f"  - Índice {idx}: {feature_names[idx] if idx < len(feature_names) else 'N/A'}")
    
    return scaler_params

def test_normalization():
    """Prueba la normalización con valores de ejemplo"""
    print("\n" + "=" * 60)
    print("PRUEBA DE NORMALIZACIÓN")
    print("=" * 60)
    
    # Cargar dataset
    df = pd.read_csv(DATASET_PATH, sep=',')
    if 'name' in df.columns:
        df = df.drop(columns=['name'])
    
    expected_columns = [
        'MDVP:Fo(Hz)', 'MDVP:Fhi(Hz)', 'MDVP:Flo(Hz)', 'MDVP:Jitter(%)',
        'MDVP:Jitter(Abs)', 'MDVP:RAP', 'MDVP:PPQ', 'Jitter:DDP',
        'MDVP:Shimmer', 'MDVP:Shimmer(dB)', 'Shimmer:APQ3', 'Shimmer:APQ5',
        'MDVP:APQ', 'Shimmer:DDA', 'NHR', 'HNR', 'RPDE', 'DFA',
        'spread1', 'spread2', 'D2', 'PPE'
    ]
    
    X = df.drop(columns=['status'])
    available_cols = [col for col in expected_columns if col in X.columns]
    X_ordered = X[available_cols]
    
    # Cargar scaler
    with open(SCALER_JSON_PATH, 'r') as f:
        scaler_params = json.load(f)
    
    mean = np.array(scaler_params['mean'])
    scale = np.array(scaler_params['scale'])
    
    # Tomar una muestra del dataset
    sample = X_ordered.iloc[0].values
    
    print(f"\nValores originales (primera muestra del dataset):")
    for i, (val, name) in enumerate(zip(sample[:5], available_cols[:5])):
        print(f"  {name}: {val:.6f}")
    
    # Normalizar
    normalized = (sample - mean) / scale
    
    print(f"\nValores normalizados:")
    for i, (val, name) in enumerate(zip(normalized[:5], available_cols[:5])):
        print(f"  {name}: {val:.6f}")
    
    # Verificar si hay valores extremos
    extreme_values = np.abs(normalized) > 5
    if extreme_values.any():
        print(f"\n⚠️ ADVERTENCIA: Hay {extreme_values.sum()} valores normalizados con |valor| > 5:")
        for idx in np.where(extreme_values)[0]:
            print(f"  - Índice {idx} ({available_cols[idx]}): {normalized[idx]:.6f}")

def main():
    """Función principal"""
    try:
        # Analizar dataset
        X, y = analyze_dataset()
        
        # Analizar scaler
        scaler_params = analyze_scaler()
        
        # Probar normalización
        test_normalization()
        
        print("\n" + "=" * 60)
        print("DIAGNÓSTICO COMPLETADO")
        print("=" * 60)
        print("\nPosibles problemas si todas las predicciones dan ~85%:")
        print("1. El modelo está sesgado hacia la clase positiva (más casos de Parkinson en el dataset)")
        print("2. Las características extraídas en Dart no coinciden con las del entrenamiento")
        print("3. El orden de las características está incorrecto")
        print("4. Los valores extraídos están fuera del rango esperado")
        print("\nRecomendación: Reentrenar el modelo y verificar que las características")
        print("extraídas en Dart coincidan exactamente con las del entrenamiento.")
        
    except Exception as e:
        print(f"\n✗ Error durante el diagnóstico: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()

