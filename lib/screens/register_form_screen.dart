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
        const SnackBar(content: Text("Debes aceptar las políticas")),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo"),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: "Confirmar Contraseña"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo requerido";
                  }
                  if (value != _passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: "Rol"),
                items: ["Paciente", "Médico", "Investigador"]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _role = val ?? "Paciente";
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Acepto las políticas de privacidad"),
                value: _acceptPolicies,
                onChanged: (val) {
                  setState(() {
                    _acceptPolicies = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Crear Cuenta"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
