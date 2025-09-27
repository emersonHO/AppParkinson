import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'search_view.dart';

class LoginView extends StatelessWidget{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) => Scaffold(
          backgroundColor: Colors.indigo.shade50,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Iniciar Sesión', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty) return 'Ingrese su correo';
                              return null;
                            },
                            onChanged: (val) => viewModel.email = val,
                          ),

                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty) return 'Ingrese su contraseña';
                              return null;
                            },
                            onChanged: (val) => viewModel.password = val,
                          ),
                          const SizedBox(height: 30),
                          viewModel.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                onPressed: () async{
                                  if (_formKey.currentState!.validate()) {
                                    final success = await viewModel.validateLogin();
                                    if (success){
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const SearchView()),
                                      );
                                    } else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Credenciales inválidas')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
                          )
                        ],
                      ),
                    ),
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}