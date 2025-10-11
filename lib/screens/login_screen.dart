import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> _mockLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('session_active', true);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text('Pantalla de login (placeholder). Implementa tu formulario aquí.'),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _mockLogin(context),
              child: Text('Simular inicio de sesión (establece sesión activa)'),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              child: Text('Continuar como invitado (sin permisos)'),
            )
          ],
        ),
      ),
    );
  }
}