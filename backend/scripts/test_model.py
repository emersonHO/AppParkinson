"""
Script para probar el modelo reentrenado con datos del dataset.
Simula el proceso completo: extracción -> normalización -> predicción
"""

import pandas as pd
import numpy as np
import json
import os

DATASET_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'parkinson_data.data')
SCALER_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'scaler_params.json')
MODEL_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'assets', 'model', 'rf_model.json')

def load_model():
    with open(MODEL_JSON_PATH, 'r') as f:
        return json.load(f)

def load_scaler():
    with open(SCALER_JSON_PATH, 'r') as f:
        return json.load(f)

def normalize_features(features, scaler_params):
    """Normaliza características usando StandardScaler"""
    mean = np.array(scaler_params['mean'])
    scale = np.array(scaler_params['scale'])
    
    # Evitar división por cero
    scale = np.where(scale == 0, 1.0, scale)
    
    normalized = (features - mean) / scale
    return normalized

def predict_tree(tree_data, features):
    """Predice usando un solo árbol"""
    children_left = np.array(tree_data['children_left'])
    children_right = np.array(tree_data['children_right'])
    feature = np.array(tree_data['feature'])
    threshold = np.array(tree_data['threshold'])
    value = tree_data['value']
    
    node = 0
    while children_left[node] != -1 or children_right[node] != -1:
        feat_idx = feature[node]
        if feat_idx < 0 or feat_idx >= len(features):
            break
        
        if features[feat_idx] <= threshold[node]:
            node = children_left[node]
        else:
            node = children_right[node]
    
    # Obtener valor de la hoja
    leaf_value = value[node]
    if isinstance(leaf_value[0], list):
        class_values = leaf_value[0]
        if len(class_values) >= 2:
            total = float(class_values[0]) + float(class_values[1])
            if total > 0:
                return float(class_values[1]) / total
    
    return 0.0

def predict_rf(model_data, normalized_features):
    """Predice usando el Random Forest completo"""
    trees = model_data['trees']
    sum_probs = 0.0
    
    for tree_data in trees:
        sum_probs += predict_tree(tree_data, normalized_features)
    
    return sum_probs / len(trees) if trees else 0.0

def classify_level(probability):
    """Clasifica el nivel de riesgo"""
    if probability < 0.33:
        return 'Bajo'
    elif probability < 0.66:
        return 'Medio'
    else:
        return 'Alto'

def test_with_dataset():
    """Prueba el modelo con muestras del dataset"""
    print("=" * 70)
    print("PRUEBA DEL MODELO REENTRENADO")
    print("=" * 70)
    
    # Cargar dataset
    print("\n[1] Cargando dataset...")
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
    y = df['status']
    
    print(f"   Dataset cargado: {len(X_ordered)} muestras, {len(available_cols)} características")
    
    # Cargar modelo y scaler
    print("\n[2] Cargando modelo y scaler...")
    model_data = load_model()
    scaler_params = load_scaler()
    print(f"   Modelo cargado: {model_data['n_estimators']} árboles")
    print(f"   Scaler cargado: {len(scaler_params['mean'])} características")
    
    # Probar con 10 muestras aleatorias (5 con Parkinson, 5 sin)
    print("\n[3] Probando con 10 muestras del dataset...")
    print("-" * 70)
    
    # Muestras con Parkinson
    parkinson_samples = X_ordered[y == 1].sample(5, random_state=42)
    parkinson_labels = y[y == 1].sample(5, random_state=42)
    
    # Muestras sin Parkinson
    no_parkinson_samples = X_ordered[y == 0].sample(5, random_state=42)
    no_parkinson_labels = y[y == 0].sample(5, random_state=42)
    
    all_samples = pd.concat([parkinson_samples, no_parkinson_samples])
    all_labels = pd.concat([parkinson_labels, no_parkinson_labels])
    
    results = []
    
    for idx, (sample_idx, row) in enumerate(all_samples.iterrows()):
        # Extraer características (simulando lo que haría VoiceFeatureExtractor)
        features = row.values
        
        # Normalizar
        normalized_features = normalize_features(features, scaler_params)
        
        # Predecir
        probability = predict_rf(model_data, normalized_features)
        probability = np.clip(probability, 0.0, 1.0)
        level = classify_level(probability)
        
        actual_status = all_labels.loc[sample_idx]
        predicted_status = 1 if probability >= 0.5 else 0
        
        results.append({
            'sample': idx + 1,
            'actual': 'Parkinson' if actual_status == 1 else 'Sin Parkinson',
            'probability': probability,
            'level': level,
            'correct': actual_status == predicted_status
        })
        
        status_icon = "[OK]" if actual_status == predicted_status else "[ERROR]"
        print(f"{status_icon} Muestra {idx + 1:2d}: "
              f"Real={actual_status}, "
              f"Prob={probability:.4f} ({probability*100:.1f}%), "
              f"Nivel={level:5s}, "
              f"Prediccion={'Correcta' if actual_status == predicted_status else 'Incorrecta'}")
    
    # Estadísticas
    print("\n" + "=" * 70)
    print("ESTADISTICAS DE PREDICCIONES")
    print("=" * 70)
    
    probabilities = [r['probability'] for r in results]
    print(f"\nProbabilidades obtenidas:")
    print(f"  Minima:  {min(probabilities):.4f} ({min(probabilities)*100:.1f}%)")
    print(f"  Maxima:  {max(probabilities):.4f} ({max(probabilities)*100:.1f}%)")
    print(f"  Promedio: {np.mean(probabilities):.4f} ({np.mean(probabilities)*100:.1f}%)")
    print(f"  Desv. Est: {np.std(probabilities):.4f}")
    
    # Distribución por nivel
    bajo = sum(1 for r in results if r['level'] == 'Bajo')
    medio = sum(1 for r in results if r['level'] == 'Medio')
    alto = sum(1 for r in results if r['level'] == 'Alto')
    
    print(f"\nDistribucion por nivel:")
    print(f"  Bajo:  {bajo} muestras ({bajo/len(results)*100:.1f}%)")
    print(f"  Medio: {medio} muestras ({medio/len(results)*100:.1f}%)")
    print(f"  Alto:  {alto} muestras ({alto/len(results)*100:.1f}%)")
    
    # Precisión
    correct = sum(1 for r in results if r['correct'])
    accuracy = correct / len(results)
    print(f"\nPrecision en estas 10 muestras: {accuracy:.1%} ({correct}/{len(results)})")
    
    # Verificar que las probabilidades varían
    print("\n" + "=" * 70)
    if np.std(probabilities) > 0.1:
        print("[OK] Las probabilidades varian correctamente (no todas son ~85%)")
    else:
        print("[ADVERTENCIA] Las probabilidades son muy similares entre si")
    
    if max(probabilities) - min(probabilities) > 0.3:
        print("[OK] Hay una buena variacion entre probabilidades minimas y maximas")
    else:
        print("[ADVERTENCIA] La variacion entre probabilidades es muy pequena")
    
    print("=" * 70)

if __name__ == '__main__':
    try:
        test_with_dataset()
    except Exception as e:
        print(f"\n[ERROR] Error durante la prueba: {e}")
        import traceback
        traceback.print_exc()

