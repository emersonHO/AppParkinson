import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_active');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo en forma de casa
            const Icon(
              Icons.home,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 40),

            // Menú de botones
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/evaluar');
              },
              icon: const Icon(Icons.assignment),
              label: const Text("Evaluar"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/historial');
              },
              icon: const Icon(Icons.history),
              label: const Text("Historial"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/recursos_info');
              },
              icon: const Icon(Icons.menu_book),
              label: const Text("Recursos e Información"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ajustes');
              },
              icon: const Icon(Icons.settings),
              label: const Text("Ajustes"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
