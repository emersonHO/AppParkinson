# Mantener clases de TensorFlow Lite que son llamadas de forma nativa
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }

# Mantener clases relacionadas con los delegados (GPU, NNAPI), que es la causa de tu error específico
-keep class org.tensorflow.lite.gpu.** { *; }
-keep interface org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep interface org.tensorflow.lite.nnapi.** { *; }

# Regla genérica para no ofuscar librerías nativas, lo cual puede romper la comunicación
-dontwarn org.tensorflow.lite.**