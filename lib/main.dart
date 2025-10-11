import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selector_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/register_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/prueba_selector_screen.dart';
import 'screens/prueba_ejecucion_screen.dart';
import 'screens/resultado_screen.dart';
import 'screens/historial_screen.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/paciente_viewmodel.dart';
import 'viewmodels/prueba_viewmodel.dart';
import 'viewmodels/resultado_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PacienteViewModel()),
        ChangeNotifierProvider(create: (_) => PruebaViewModel()),
        ChangeNotifierProvider(create: (_) => ResultadoViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Parkinson App - Sistema de Evaluación',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[700],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginSelectorScreen(),
          '/login_form': (context) => const LoginFormScreen(),
          '/register_form': (context) => const RegisterFormScreen(),
          '/home': (context) => const HomeScreen(),
          '/prueba_selector': (context) => const PruebaSelectorScreen(),
          '/prueba_ejecucion': (context) => const PruebaEjecucionScreen(),
          '/resultado': (context) => const ResultadoScreen(),
          '/historial': (context) => const HistorialScreen(),
        },
      ),
    );
  }
}
