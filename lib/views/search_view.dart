import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';

class SearchView extends StatelessWidget{
  const SearchView({super.key});

  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
        create: (_) => SearchViewModel()..loadPersonas(),
        child: Consumer<SearchViewModel>(
          builder: (context, viewModel, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Buscar Personas'),
              backgroundColor: Colors.deepOrange,
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Buscar por nombre',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: viewModel.filter,
                        ),
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.filtered.length,
                          itemBuilder: (context, index){
                            final persona = viewModel.filtered[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepOrange,
                                  child: Text(persona.nombre[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text('${persona.nombre} ${persona.apellido}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(persona.correo),
                                    Text(persona.telefono),
                                  ],
                                ),
                              ),
                            );
                          },
                        ))
                  ],
            ),
          ),
        ),
    );
  }
}

