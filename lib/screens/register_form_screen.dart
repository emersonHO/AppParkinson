import 'package:flutter/material.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = "Paciente";
  bool _acceptPolicies = false;

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptPolicies) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar las políticas de privacidad")),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Crear Cuenta"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 64, color: Colors.green),
              const SizedBox(height: 16),

              const Text(
                "Regístrate para comenzar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Completa los datos para crear tu cuenta y disfruta de todos los beneficios.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo requerido";
                  if (!value.contains('@')) return "Correo inválido";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo requerido";
                  if (value.length < 4) return "Mínimo 4 caracteres";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirmar Contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo requerido";
                  if (value != _passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Dropdown Rol
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: "Selecciona tu rol",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                items: ["Paciente", "Médico", "Investigador"]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _role = val ?? "Paciente";
                  });
                },
              ),
              const SizedBox(height: 24),

              // Checkbox de Políticas
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Acepto las políticas de privacidad y términos de uso",
                  style: TextStyle(fontSize: 14),
                ),
                value: _acceptPolicies,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _acceptPolicies = val ?? false;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Botón Crear Cuenta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Crear Cuenta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
