import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selector_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/register_form_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkinson App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginSelectorScreen(),
        '/login_form': (context) => const LoginFormScreen(),
        '/register_form': (context) => const RegisterFormScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
