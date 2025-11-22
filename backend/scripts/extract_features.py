"""
Script para extraer características acústicas de archivos de audio.
Las características extraídas deben coincidir exactamente con las del dataset.
"""

import librosa
import numpy as np
import warnings
warnings.filterwarnings('ignore')


def extract_features(audio_path):
    """
    Extrae las 22 características acústicas de un archivo de audio.
    
    Args:
        audio_path: Ruta al archivo de audio (.wav)
    
    Returns:
        Lista con 22 valores numéricos en el orden exacto del dataset:
        [MDVP:Fo(Hz), MDVP:Fhi(Hz), MDVP:Flo(Hz), MDVP:Jitter(%), 
         MDVP:Jitter(Abs), MDVP:RAP, MDVP:PPQ, Jitter:DDP,
         MDVP:Shimmer, MDVP:Shimmer(dB), Shimmer:APQ3, Shimmer:APQ5,
         MDVP:APQ, Shimmer:DDA, NHR, HNR, RPDE, DFA, spread1, spread2, D2, PPE]
    """
    try:
        # Cargar audio
        y, sr = librosa.load(audio_path, sr=None)
        
        # 1. MDVP:Fo(Hz) - Frecuencia fundamental (media)
        f0, voiced_flag, voiced_probs = librosa.pyin(
            y, fmin=librosa.note_to_hz('C2'), fmax=librosa.note_to_hz('C7')
        )
        f0_clean = f0[~np.isnan(f0)]
        mdvp_fo = np.mean(f0_clean) if len(f0_clean) > 0 else 0.0
        
        # 2. MDVP:Fhi(Hz) - Frecuencia máxima
        mdvp_fhi = np.max(f0_clean) if len(f0_clean) > 0 else 0.0
        
        # 3. MDVP:Flo(Hz) - Frecuencia mínima
        mdvp_flo = np.min(f0_clean) if len(f0_clean) > 0 else 0.0
        
        # 4-8. Jitter measures (variación de frecuencia)
        if len(f0_clean) > 1:
            periods = 1.0 / f0_clean
            period_diffs = np.diff(periods)
            
            # MDVP:Jitter(%) - Variación porcentual
            jitter_percent = np.mean(np.abs(period_diffs)) / np.mean(periods) * 100
            
            # MDVP:Jitter(Abs) - Jitter absoluto
            jitter_abs = np.mean(np.abs(period_diffs))
            
            # MDVP:RAP - Relative Average Perturbation
            rap = np.mean(np.abs(period_diffs)) / np.mean(periods)
            
            # MDVP:PPQ - Pitch Period Quotient (5-point)
            if len(periods) >= 5:
                ppq_values = []
                for i in range(2, len(periods) - 2):
                    local_mean = np.mean(periods[i-2:i+3])
                    ppq_values.append(np.abs(periods[i] - local_mean) / local_mean)
                ppq = np.mean(ppq_values) if ppq_values else 0.0
            else:
                ppq = 0.0
            
            # Jitter:DDP - Difference of Differences of Periods
            if len(period_diffs) > 1:
                ddp = np.mean(np.abs(np.diff(period_diffs)))
            else:
                ddp = 0.0
        else:
            jitter_percent = 0.0
            jitter_abs = 0.0
            rap = 0.0
            ppq = 0.0
            ddp = 0.0
        
        # 9-14. Shimmer measures (variación de amplitud)
        if len(f0_clean) > 1:
            # Obtener amplitudes en los puntos de F0
            frame_length = int(sr * 0.025)  # 25ms frames
            hop_length = int(sr * 0.010)    # 10ms hop
            amplitudes = np.abs(librosa.stft(y, n_fft=frame_length, hop_length=hop_length))
            rms = np.mean(amplitudes, axis=0)
            
            if len(rms) > 1:
                amp_diffs = np.diff(rms)
                
                # MDVP:Shimmer
                shimmer = np.mean(np.abs(amp_diffs)) / np.mean(rms)
                
                # MDVP:Shimmer(dB)
                shimmer_db = 20 * np.log10(np.mean(rms[1:]) / np.mean(rms[:-1])) if np.mean(rms[:-1]) > 0 else 0.0
                
                # Shimmer:APQ3 (3-point)
                if len(rms) >= 3:
                    apq3_values = []
                    for i in range(1, len(rms) - 1):
                        local_mean = np.mean(rms[i-1:i+2])
                        apq3_values.append(np.abs(rms[i] - local_mean) / local_mean if local_mean > 0 else 0.0)
                    apq3 = np.mean(apq3_values) if apq3_values else 0.0
                else:
                    apq3 = 0.0
                
                # Shimmer:APQ5 (5-point)
                if len(rms) >= 5:
                    apq5_values = []
                    for i in range(2, len(rms) - 2):
                        local_mean = np.mean(rms[i-2:i+3])
                        apq5_values.append(np.abs(rms[i] - local_mean) / local_mean if local_mean > 0 else 0.0)
                    apq5 = np.mean(apq5_values) if apq5_values else 0.0
                else:
                    apq5 = 0.0
                
                # MDVP:APQ (11-point)
                if len(rms) >= 11:
                    apq_values = []
                    for i in range(5, len(rms) - 5):
                        local_mean = np.mean(rms[i-5:i+6])
                        apq_values.append(np.abs(rms[i] - local_mean) / local_mean if local_mean > 0 else 0.0)
                    apq = np.mean(apq_values) if apq_values else 0.0
                else:
                    apq = 0.0
                
                # Shimmer:DDA
                if len(amp_diffs) > 1:
                    dda = np.mean(np.abs(np.diff(amp_diffs)))
                else:
                    dda = 0.0
            else:
                shimmer = 0.0
                shimmer_db = 0.0
                apq3 = 0.0
                apq5 = 0.0
                apq = 0.0
                dda = 0.0
        else:
            shimmer = 0.0
            shimmer_db = 0.0
            apq3 = 0.0
            apq5 = 0.0
            apq = 0.0
            dda = 0.0
        
        # 15. NHR - Noise-to-Harmonics Ratio
        # Usar análisis espectral
        stft = librosa.stft(y)
        magnitude = np.abs(stft)
        power = magnitude ** 2
        
        # Estimar armónicos y ruido
        harmonic, percussive = librosa.decompose.hpss(magnitude)
        harmonic_power = np.sum(harmonic ** 2)
        noise_power = np.sum(percussive ** 2)
        nhr = noise_power / harmonic_power if harmonic_power > 0 else 0.0
        
        # 16. HNR - Harmonics-to-Noise Ratio
        hnr = harmonic_power / noise_power if noise_power > 0 else 0.0
        
        # 17. RPDE - Recurrence Period Density Entropy
        # Simplificado: usar entropía de la señal
        if len(f0_clean) > 0:
            hist, _ = np.histogram(f0_clean, bins=50)
            hist = hist[hist > 0]
            prob = hist / np.sum(hist)
            rpde = -np.sum(prob * np.log2(prob + 1e-10))
        else:
            rpde = 0.0
        
        # 18. DFA - Detrended Fluctuation Analysis
        # Implementación simplificada
        if len(y) > 100:
            # Dividir en ventanas y calcular fluctuación
            window_size = min(100, len(y) // 10)
            fluctuations = []
            for i in range(0, len(y) - window_size, window_size):
                window = y[i:i+window_size]
                detrended = window - np.mean(window)
                fluctuations.append(np.std(detrended))
            dfa = np.mean(fluctuations) if fluctuations else 0.0
        else:
            dfa = 0.0
        
        # 19-20. spread1, spread2 - Parámetros del cepstrum
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
        if mfccs.shape[1] > 0:
            # spread1: varianza de los primeros coeficientes
            spread1 = np.var(mfccs[:5, :])
            # spread2: varianza de los últimos coeficientes
            spread2 = np.var(mfccs[5:, :])
        else:
            spread1 = 0.0
            spread2 = 0.0
        
        # 21. D2 - Dimensión correlativa (simplificada)
        # Usar correlación de la señal
        if len(y) > 100:
            autocorr = np.correlate(y[:1000], y[:1000], mode='full')
            autocorr = autocorr[len(autocorr)//2:]
            d2 = np.std(autocorr[:100]) if len(autocorr) >= 100 else 0.0
        else:
            d2 = 0.0
        
        # 22. PPE - Pitch Period Entropy
        if len(f0_clean) > 0:
            periods = 1.0 / f0_clean
            hist, _ = np.histogram(periods, bins=50)
            hist = hist[hist > 0]
            prob = hist / np.sum(hist)
            ppe = -np.sum(prob * np.log2(prob + 1e-10))
        else:
            ppe = 0.0
        
        # Retornar en el orden exacto del dataset
        features = [
            float(mdvp_fo),
            float(mdvp_fhi),
            float(mdvp_flo),
            float(jitter_percent),
            float(jitter_abs),
            float(rap),
            float(ppq),
            float(ddp),
            float(shimmer),
            float(shimmer_db),
            float(apq3),
            float(apq5),
            float(apq),
            float(dda),
            float(nhr),
            float(hnr),
            float(rpde),
            float(dfa),
            float(spread1),
            float(spread2),
            float(d2),
            float(ppe),
        ]
        
        return features
        
    except Exception as e:
        print(f"Error extrayendo características: {e}")
        # Retornar valores por defecto en caso de error
        return [0.0] * 22






