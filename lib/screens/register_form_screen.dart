import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contraseniaController = TextEditingController();
  String _rol = 'Paciente';
  bool _aceptaPoliticas = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contraseniaController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_aceptaPoliticas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos y acepta las políticas.')),
      );
      return;
    }

    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    final success = await loginViewModel.registrarUsuario(
      _nombreController.text,
      _correoController.text,
      _contraseniaController.text,
      _rol,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
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
                        const Text(
                          "Regístrate",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campo nombre
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(labelText: "Nombre Completo"),
                          validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        // Campo correo
                        TextFormField(
                          controller: _correoController,
                          decoration: const InputDecoration(labelText: "Correo electrónico"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'El correo es requerido';
                            if (!value.contains('@')) return 'Correo inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campo contraseña
                        TextFormField(
                          controller: _contraseniaController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Contraseña"),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'La contraseña es requerida';
                            if (value.length < 4) return 'La contraseña debe tener al menos 4 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Selector de Rol
                        DropdownButtonFormField<String>(
                          value: _rol,
                          decoration: const InputDecoration(labelText: 'Soy un...'),
                          items: ['Paciente', 'Médico'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _rol = val ?? "Paciente"),
                        ),
                        const SizedBox(height: 16),

                        // Checkbox de Políticas
                        FormField<bool>(
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  title: const Text(
                                    "Acepto las políticas de privacidad y los términos de uso.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: _aceptaPoliticas,
                                  onChanged: (val) => setState(() => _aceptaPoliticas = val ?? false),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (state.errorText != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                  ),
                              ],
                            );
                          },
                          validator: (value) {
                            if (!_aceptaPoliticas) {
                              return 'Debes aceptar las políticas para continuar.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Mensaje de error
                        if (loginViewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              loginViewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        // Botón registrarse
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginViewModel.isLoading ? null : _register,
                            child: loginViewModel.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Registrarse"),
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
