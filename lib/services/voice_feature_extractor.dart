import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:collection';
import 'package:wav/wav.dart';

/// Servicio para extraer características acústicas de archivos de audio.
/// Implementa la misma lógica que extract_features.py en Python.
class VoiceFeatureExtractor {

  static Future<List<double>> extractFeatures(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception("El archivo de audio no existe en la ruta: $audioPath");
      }
      final bytes = await file.readAsBytes();
      final wav = Wav.read(bytes);

      if (wav.channels.isEmpty || wav.channels[0].isEmpty) {
        throw Exception("El archivo WAV está vacío o no tiene canales de audio.");
      }

      final List<double> audioData = wav.channels[0];

      // CORRECCIÓN FINAL: La frecuencia de muestreo es una propiedad directa del objeto Wav.
      final sampleRate = wav.samplesPerSecond.toDouble();

      return _extractAllFeatures(audioData, sampleRate);
    } catch (e) {
      print('Error extrayendo características: $e');
      return List.filled(22, 0.0);
    }
  }

  static List<double> _extractAllFeatures(List<double> audioData, double sampleRate) {
    final f0Values = _extractF0(audioData, sampleRate);
    final mdvpFo = f0Values.isNotEmpty ? f0Values.reduce((a, b) => a + b) / f0Values.length : 0.0;
    final mdvpFhi = f0Values.isNotEmpty ? f0Values.reduce(math.max) : 0.0;
    final mdvpFlo = f0Values.isNotEmpty ? f0Values.reduce(math.min) : 0.0;

    final jitterMeasures = _calculateJitter(f0Values, sampleRate);
    final shimmerMeasures = _calculateShimmer(audioData, sampleRate);
    final nhrHnr = _calculateNHRHNR(audioData, sampleRate);
    final rpde = _calculateRPDE(f0Values);
    final dfa = _calculateDFA(audioData);
    final spreads = _calculateSpreads(audioData, sampleRate);
    final d2 = _calculateD2(audioData);
    final ppe = _calculatePPE(f0Values);

    return [
      mdvpFo,
      mdvpFhi,
      mdvpFlo,
      jitterMeasures['jitter_percent'] ?? 0.0,
      jitterMeasures['jitter_abs'] ?? 0.0,
      jitterMeasures['rap'] ?? 0.0,
      jitterMeasures['ppq'] ?? 0.0,
      jitterMeasures['ddp'] ?? 0.0,
      shimmerMeasures['shimmer'] ?? 0.0,
      shimmerMeasures['shimmer_db'] ?? 0.0,
      shimmerMeasures['apq3'] ?? 0.0,
      shimmerMeasures['apq5'] ?? 0.0,
      shimmerMeasures['apq'] ?? 0.0,
      shimmerMeasures['dda'] ?? 0.0,
      nhrHnr['nhr'] ?? 0.0,
      nhrHnr['hnr'] ?? 0.0,
      rpde,
      dfa,
      spreads['spread1'] ?? 0.0,
      spreads['spread2'] ?? 0.0,
      d2,
      ppe,
    ];
  }

  static List<double> _extractF0(List<double> audioData, double sampleRate) {
    if (audioData.length < 1024) return [];

    final f0Values = <double>[];
    final frameSize = (sampleRate * 0.025).round();
    final hopSize = (sampleRate * 0.010).round();

    for (int i = 0; i <= audioData.length - frameSize; i += hopSize) {
      final frame = audioData.sublist(i, i + frameSize);
      final f0 = _pitchFromAutocorrelation(frame, sampleRate);
      if (f0 > 50 && f0 < 500) {
        f0Values.add(f0);
      }
    }
    return f0Values;
  }

  static double _pitchFromAutocorrelation(List<double> frame, double sampleRate) {
    final autocorr = _autocorrelation(frame);
    if (autocorr.length < 2) return 0.0;

    final minPeriod = (sampleRate / 500).round();
    final maxPeriod = (sampleRate / 50).round();

    double maxVal = -1.0;
    int maxIndex = 0;

    for (int i = minPeriod; i < math.min(maxPeriod, autocorr.length); i++) {
      if (autocorr[i] > maxVal) {
        maxVal = autocorr[i];
        maxIndex = i;
      }
    }

    return maxIndex > 0 ? sampleRate / maxIndex : 0.0;
  }

  static List<double> _autocorrelation(List<double> data) {
    final n = data.length;
    final result = List<double>.filled(n, 0.0);

    for (int lag = 0; lag < n; lag++) {
      double sum = 0.0;
      for (int i = 0; i < n - lag; i++) {
        sum += data[i] * data[i + lag];
      }
      result[lag] = sum / (n - lag);
    }
    return result;
  }

  static Map<String, double> _calculateJitter(List<double> f0Values, double sampleRate) {
    if (f0Values.length < 2) {
      return {'jitter_percent': 0.0, 'jitter_abs': 0.0, 'rap': 0.0, 'ppq': 0.0, 'ddp': 0.0};
    }

    final periods = f0Values.map((f) => 1.0 / f).toList();
    final periodDiffs = <double>[];
    for (int i = 0; i < periods.length - 1; i++) {
      periodDiffs.add((periods[i + 1] - periods[i]).abs());
    }

    final meanPeriod = periods.reduce((a, b) => a + b) / periods.length;
    final meanDiff = periodDiffs.reduce((a, b) => a + b) / periodDiffs.length;

    final jitterPercent = (meanDiff / meanPeriod) * 100;
    final jitterAbs = meanDiff * sampleRate;
    final rap = meanDiff / meanPeriod;

    double ppq = 0.0;
    if (periods.length >= 5) {
      final ppqValues = <double>[];
      for (int i = 2; i < periods.length - 2; i++) {
        final localMean = (periods[i - 2] + periods[i - 1] + periods[i] + periods[i + 1] + periods[i + 2]) / 5;
        if (localMean > 0) {
          ppqValues.add((periods[i] - localMean).abs() / localMean);
        }
      }
      ppq = ppqValues.isNotEmpty ? ppqValues.reduce((a, b) => a + b) / ppqValues.length : 0.0;
    }

    double ddp = 0.0;
    if (periodDiffs.length > 1) {
      final diffDiffs = <double>[];
      for (int i = 0; i < periodDiffs.length - 1; i++) {
        diffDiffs.add((periodDiffs[i + 1] - periodDiffs[i]).abs());
      }
      ddp = diffDiffs.reduce((a, b) => a + b) / diffDiffs.length;
    }

    return {
      'jitter_percent': jitterPercent,
      'jitter_abs': jitterAbs,
      'rap': rap,
      'ppq': ppq,
      'ddp': ddp,
    };
  }

  static Map<String, double> _calculateShimmer(List<double> audioData, double sampleRate) {
    final frameSize = (sampleRate * 0.025).round();
    final hopSize = (sampleRate * 0.010).round();
    final rmsValues = <double>[];

    for (int i = 0; i <= audioData.length - frameSize; i += hopSize) {
      final frame = audioData.sublist(i, i + frameSize);
      if (frame.isEmpty) continue;
      final rms = math.sqrt(frame.map((x) => x * x).reduce((a, b) => a + b) / frame.length);
      rmsValues.add(rms);
    }

    if (rmsValues.length < 2) {
      return {'shimmer': 0.0, 'shimmer_db': 0.0, 'apq3': 0.0, 'apq5': 0.0, 'apq': 0.0, 'dda': 0.0};
    }

    final ampDiffs = <double>[];
    for (int i = 0; i < rmsValues.length - 1; i++) {
      ampDiffs.add((rmsValues[i + 1] - rmsValues[i]).abs());
    }

    final meanRms = rmsValues.reduce((a, b) => a + b) / rmsValues.length;
    final shimmer = meanRms > 0 ? (ampDiffs.reduce((a, b) => a + b) / ampDiffs.length) / meanRms : 0.0;
    
    // MDVP:Shimmer(dB) - Calculado como en Python: 20 * log10(mean(rms[1:]) / mean(rms[:-1]))
    double shimmerDb = 0.0;
    if (rmsValues.length >= 2) {
      final meanRms1 = rmsValues.sublist(1).reduce((a, b) => a + b) / (rmsValues.length - 1);
      final meanRms0 = rmsValues.sublist(0, rmsValues.length - 1).reduce((a, b) => a + b) / (rmsValues.length - 1);
      if (meanRms0 > 0) {
        final ratio = meanRms1 / meanRms0;
        shimmerDb = 20 * (math.log(ratio) / math.ln10);
        if (!shimmerDb.isFinite) shimmerDb = 0.0;
      }
    }

    double apq3 = 0.0;
    if (rmsValues.length >= 3) {
      final apq3Values = <double>[];
      for (int i = 1; i < rmsValues.length - 1; i++) {
        final localMean = (rmsValues[i-1] + rmsValues[i] + rmsValues[i+1]) / 3;
        if (localMean > 0) {
          apq3Values.add((rmsValues[i] - localMean).abs() / localMean);
        }
      }
      apq3 = apq3Values.isNotEmpty ? apq3Values.reduce((a, b) => a + b) / apq3Values.length : 0.0;
    }

    double apq5 = 0.0;
    if (rmsValues.length >= 5) {
      final apq5Values = <double>[];
      for (int i = 2; i < rmsValues.length - 2; i++) {
        final localMean = (rmsValues[i-2] + rmsValues[i-1] + rmsValues[i] + rmsValues[i+1] + rmsValues[i+2]) / 5;
        if (localMean > 0) {
          apq5Values.add((rmsValues[i] - localMean).abs() / localMean);
        }
      }
      apq5 = apq5Values.isNotEmpty ? apq5Values.reduce((a, b) => a + b) / apq5Values.length : 0.0;
    }

    double apq = 0.0;
    if (rmsValues.length >= 11) {
      final apqValues = <double>[];
      for (int i = 5; i < rmsValues.length - 5; i++) {
        final localMean = rmsValues.sublist(i-5, i+6).reduce((a,b) => a+b) / 11;
        if (localMean > 0) {
          apqValues.add((rmsValues[i] - localMean).abs() / localMean);
        }
      }
      apq = apqValues.isNotEmpty ? apqValues.reduce((a, b) => a + b) / apqValues.length : 0.0;
    }

    double dda = 0.0;
    if (ampDiffs.length > 1) {
      final diffDiffs = <double>[];
      for (int i = 0; i < ampDiffs.length - 1; i++) {
        diffDiffs.add((ampDiffs[i + 1] - ampDiffs[i]).abs());
      }
      dda = diffDiffs.reduce((a, b) => a + b) / diffDiffs.length;
    }

    return {
      'shimmer': shimmer,
      'shimmer_db': shimmerDb.isFinite ? shimmerDb : 0.0,
      'apq3': apq3,
      'apq5': apq5,
      'apq': apq,
      'dda': dda,
    };
  }
  
  static Map<String, double> _calculateNHRHNR(List<double> audioData, double sampleRate) {
    final fftSize = 2048;
    if (audioData.length < fftSize) return {'nhr': 0.0, 'hnr': 0.0};
    final fft = _fft(audioData.take(fftSize).toList());
    final magnitude = fft.map((c) => c.real * c.real + c.imaginary * c.imaginary).toList();

    final totalPower = magnitude.reduce((a, b) => a + b);
    if (totalPower == 0) return {'nhr': 0.0, 'hnr': 0.0};

    final noisePower = totalPower * 0.05;
    final harmonicPower = totalPower * 0.95;

    final hnr = harmonicPower > 0 ? 10 * (math.log(harmonicPower / noisePower) / math.ln10) : 0.0;
    final nhr = harmonicPower > 0 ? noisePower / harmonicPower : 0.0;

    return {'nhr': nhr, 'hnr': hnr.isFinite ? hnr : 0.0};
  }

  static double _calculateRPDE(List<double> f0Values) {
    if (f0Values.length < 2) return 0.0;

    final hist = List.filled(50, 0);
    final minF0 = f0Values.reduce(math.min);
    final maxF0 = f0Values.reduce(math.max);
    final range = maxF0 - minF0;

    if (range == 0) return 0.0;

    for (final f0 in f0Values) {
      final bin = ((f0 - minF0) / range * 49).round().clamp(0, 49);
      hist[bin]++;
    }

    final total = f0Values.length;
    double entropy = 0.0;
    for (final count in hist) {
      if (count > 0) {
        final prob = count / total;
        entropy -= prob * (math.log(prob) / math.ln2);
      }
    }
    return entropy;
  }

  static double _calculateDFA(List<double> audioData) {
     if (audioData.length < 100) return 0.0;

    final y = List<double>.filled(audioData.length, 0.0);
    final mean = audioData.reduce((a,b)=>a+b) / audioData.length;
    double sum = 0.0;
    for(int i=0; i<audioData.length; i++){
      sum += (audioData[i] - mean);
      y[i] = sum;
    }

    final n = audioData.length;
    final boxSizes = [16, 32, 64, 128];
    final f_n = <double>[];

    for (final boxSize in boxSizes) {
      if (n < boxSize) continue;
      double sumSquaredError = 0;
      for (int i = 0; i < n; i += boxSize) {
        final end = math.min(i + boxSize, n);
        if (end - i < 2) continue;
        final window = y.sublist(i, end);
        final x = List<double>.generate(window.length, (j) => (i+j).toDouble());
        final line = _linearFit(x, window);
        for (int j = 0; j < window.length; j++) {
          sumSquaredError += math.pow(window[j] - (line[0] * x[j] + line[1]), 2);
        }
      }
      f_n.add(math.sqrt(sumSquaredError / n));
    }

    if (f_n.length < 2) return 0.0;
    final logBoxSizes = boxSizes.take(f_n.length).map((s) => math.log(s.toDouble())).toList();
    final log_f_n = f_n.map((f) => math.log(f)).toList();
    
    final dfaLine = _linearFit(logBoxSizes, log_f_n);
    return dfaLine[0];
  }

  static List<double> _linearFit(List<double> x, List<double> y) {
    final n = x.length;
    final sumX = x.reduce((a,b)=>a+b);
    final sumY = y.reduce((a,b)=>a+b);
    final sumXY = List.generate(n, (i) => x[i]*y[i]).reduce((a,b)=>a+b);
    final sumX2 = List.generate(n, (i) => x[i]*x[i]).reduce((a,b)=>a+b);
    
    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - m * sumX) / n;
    return [m,b];
  }

  static Map<String, double> _calculateSpreads(List<double> audioData, double sampleRate) {
    final frameSize = 2048;
    if (audioData.length < frameSize) return {'spread1': 0.0, 'spread2': 0.0};

    final frame = audioData.take(frameSize).toList();
    final fft = _fft(frame);
    final magnitude = fft.map((c) => math.sqrt(c.real * c.real + c.imaginary * c.imaginary)).toList();

    final midPoint = magnitude.length ~/ 2;
    final firstHalf = magnitude.sublist(1, midPoint);
    final secondHalf = magnitude.sublist(midPoint);
    if(firstHalf.isEmpty || secondHalf.isEmpty) return {'spread1': 0.0, 'spread2': 0.0};

    final mean1 = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final mean2 = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final variance1 = firstHalf.map((x) => (x - mean1) * (x - mean1)).reduce((a, b) => a + b) / firstHalf.length;
    final variance2 = secondHalf.map((x) => (x - mean2) * (x - mean2)).reduce((a, b) => a + b) / secondHalf.length;

    return {'spread1': math.sqrt(variance1), 'spread2': math.sqrt(variance2)};
  }

  static double _calculateD2(List<double> audioData) {
    if (audioData.length < 2) return 0.0;
    final points = List.generate(math.min(1000, audioData.length - 1), (i) => [audioData[i], audioData[i+1]]);
    
    int count = 0;
    final r = 0.2 * _stdDev(audioData);
    if (r == 0) return 0.0;

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final dist = math.sqrt(math.pow(points[i][0] - points[j][0], 2) + math.pow(points[i][1] - points[j][1], 2));
        if (dist < r) {
          count++;
        }
      }
    }

    final correlationSum = count > 0 ? math.log(count / (points.length * (points.length - 1) / 2)) : 0.0;
    return correlationSum;
  }

  static double _stdDev(List<double> list) {
      if (list.length < 2) return 0.0;
      final mean = list.reduce((a, b) => a + b) / list.length;
      final variance = list.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / (list.length - 1);
      return math.sqrt(variance);
  }

  static double _calculatePPE(List<double> f0Values) {
     if (f0Values.isEmpty) return 0.0;

    final periods = f0Values.map((f) => 1.0 / f).where((p) => p.isFinite).toList();
    if (periods.length < 2) return 0.0;

    final hist = List.filled(50, 0);
    final minPeriod = periods.reduce(math.min);
    final maxPeriod = periods.reduce(math.max);
    final range = maxPeriod - minPeriod;

    if (range == 0) return 0.0;

    for (final period in periods) {
      final bin = ((period - minPeriod) / range * 49).round().clamp(0, 49);
      hist[bin]++;
    }

    final total = periods.length;
    double entropy = 0.0;
    for (final count in hist) {
      if (count > 0) {
        final prob = count / total;
        entropy -= prob * (math.log(prob) / math.ln2);
      }
    }
    return entropy;
  }

  static List<Complex> _fft(List<double> data) {
    final n = data.length;
    if (n == 0) return [];
    var pow2 = math.log(n) / math.ln2;
    if (pow2 != pow2.floor()) {
      final newN = math.pow(2, pow2.ceil()).toInt();
      final paddedData = List<double>.from(data)..addAll(List<double>.filled(newN - n, 0.0));
      return _fft(paddedData);
    }

    final result = List<Complex>.generate(n, (i) => Complex(data[i], 0.0));
    _fftRecursive(result);
    return result;
  }

  static void _fftRecursive(List<Complex> data) {
    final n = data.length;
    if (n <= 1) return;

    final even = <Complex>[];
    final odd = <Complex>[];
    for (int i = 0; i < n; i++) {
      if (i % 2 == 0) {
        even.add(data[i]);
      } else {
        odd.add(data[i]);
      }
    }

    _fftRecursive(even);
    _fftRecursive(odd);

    for (int k = 0; k < n ~/ 2; k++) {
      final t = Complex.polar(1.0, -2 * math.pi * k / n) * odd[k];
      data[k] = even[k] + t;
      data[k + n ~/ 2] = even[k] - t;
    }
  }
}

class Complex {
  final double real;
  final double imaginary;

  Complex(this.real, this.imaginary);

  factory Complex.polar(double r, double theta) {
    return Complex(r * math.cos(theta), r * math.sin(theta));
  }

  Complex operator +(Complex other) => Complex(real + other.real, imaginary + other.imaginary);
  Complex operator -(Complex other) => Complex(real - other.real, imaginary - other.imaginary);
  Complex operator *(Complex other) => Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real
  );
}
