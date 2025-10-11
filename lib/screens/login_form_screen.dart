import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contraseniaController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _contraseniaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

      final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
      loginViewModel.updateCorreo(_correoController.text);
      loginViewModel.updateContrasenia(_contraseniaController.text);

      final success = await loginViewModel.validateLogin();

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con degradado suave
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<LoginViewModel>(
          builder: (context, loginViewModel, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          '../../assets/images/app_logo.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Bienvenido de nuevo",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Inicia sesión para continuar explorando nuestra aplicación.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),

                        // Campo correo
                        TextFormField(
                          controller: _correoController,
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor ingresa tu correo.";
                            }
                            if (!value.contains('@')) {
                              return "Correo inválido.";
                            }
                            return null;
                          },
                          onChanged: loginViewModel.updateCorreo,
                        ),
                        const SizedBox(height: 16),

                        // Campo contraseña
                        TextFormField(
                          controller: _contraseniaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor ingresa tu contraseña.";
                            }
                            if (value.length < 4) {
                              return "La contraseña debe tener al menos 4 caracteres.";
                            }
                            return null;
                          },
                          onChanged: loginViewModel.updateContrasenia,
                        ),
                        const SizedBox(height: 16),

                        // Mensaje de error
                        if (loginViewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              loginViewModel.errorMessage!,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),

                        // Botón iniciar sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginViewModel.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: loginViewModel.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "Iniciar sesión",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón crear cuenta
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register_form');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.green),
                              ),
                            ),
                            child: const Text(
                              "Crear una nueva cuenta",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Línea divisora
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("o"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botón Google
                        GestureDetector(
                          onTap: () {
                            // Lógica futura para login con Google
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  '../../assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Continuar con Google",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
