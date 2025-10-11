import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resultado_viewmodel.dart';
import '../viewmodels/prueba_viewmodel.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _filtroTipo = '';
  String _filtroRiesgo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultadoViewModel>(context, listen: false).loadResultados();
      Provider.of<PruebaViewModel>(context, listen: false).loadPruebas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Evaluaciones"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: "Filtrar resultados",
          ),
        ],
      ),
      body: Consumer2<ResultadoViewModel, PruebaViewModel>(
        builder: (context, resultadoViewModel, pruebaViewModel, child) {
          if (resultadoViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final resultados = _filtrarResultados(resultadoViewModel.resultados);

          return Column(
            children: [
              // Estadísticas rápidas
              _buildEstadisticasCard(resultadoViewModel.getEstadisticas()),
              
              // Lista de resultados
              Expanded(
                child: resultados.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: resultados.length,
                        itemBuilder: (context, index) {
                          final resultado = resultados[index];
                          return _buildResultadoItem(resultado, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEstadisticasCard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem("Total", "${stats['total']}", Colors.blue),
          ),
          Expanded(
            child: _buildStatItem("Bajo", "${stats['bajo']}", Colors.green),
          ),
          Expanded(
            child: _buildStatItem("Moderado", "${stats['moderado']}", Colors.orange),
          ),
          Expanded(
            child: _buildStatItem("Alto", "${stats['alto']}", Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResultadoItem(resultado, int index) {
    Color colorRiesgo;
    IconData iconRiesgo;
    
    switch (resultado.nivelRiesgo.toLowerCase()) {
      case 'bajo':
        colorRiesgo = Colors.green;
        iconRiesgo = Icons.check_circle;
        break;
      case 'moderado':
        colorRiesgo = Colors.orange;
        iconRiesgo = Icons.warning;
        break;
      case 'alto':
        colorRiesgo = Colors.red;
        iconRiesgo = Icons.error;
        break;
      default:
        colorRiesgo = Colors.grey;
        iconRiesgo = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _verDetalleResultado(resultado),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorRiesgo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconRiesgo, color: colorRiesgo, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Evaluación #${index + 1}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Riesgo: ${resultado.nivelRiesgo.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorRiesgo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Confianza: ${resultado.confianza.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No hay evaluaciones registradas",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Complete su primera evaluación para ver el historial",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/prueba_selector'),
            icon: const Icon(Icons.play_arrow),
            label: const Text("Iniciar Evaluación"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List _filtrarResultados(List resultados) {
    return resultados.where((resultado) {
      bool cumpleTipo = _filtroTipo.isEmpty || resultado.tipo == _filtroTipo;
      bool cumpleRiesgo = _filtroRiesgo.isEmpty || resultado.nivelRiesgo == _filtroRiesgo;
      return cumpleTipo && cumpleRiesgo;
    }).toList();
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filtrar Resultados",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Filtro por tipo
            Text(
              "Tipo de Prueba",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip("Todos", _filtroTipo == '', (value) {
                  setState(() => _filtroTipo = value ? '' : _filtroTipo);
                }),
                _buildFilterChip("Espiral", _filtroTipo == 'espiral', (value) {
                  setState(() => _filtroTipo = value ? 'espiral' : '');
                }),
                _buildFilterChip("Tapping", _filtroTipo == 'tapping', (value) {
                  setState(() => _filtroTipo = value ? 'tapping' : '');
                }),
                _buildFilterChip("Voz", _filtroTipo == 'voz', (value) {
                  setState(() => _filtroTipo = value ? 'voz' : '');
                }),
                _buildFilterChip("Cuestionario", _filtroTipo == 'cuestionario', (value) {
                  setState(() => _filtroTipo = value ? 'cuestionario' : '');
                }),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Filtro por nivel de riesgo
            Text(
              "Nivel de Riesgo",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip("Todos", _filtroRiesgo == '', (value) {
                  setState(() => _filtroRiesgo = value ? '' : _filtroRiesgo);
                }),
                _buildFilterChip("Bajo", _filtroRiesgo == 'bajo', (value) {
                  setState(() => _filtroRiesgo = value ? 'bajo' : '');
                }),
                _buildFilterChip("Moderado", _filtroRiesgo == 'moderado', (value) {
                  setState(() => _filtroRiesgo = value ? 'moderado' : '');
                }),
                _buildFilterChip("Alto", _filtroRiesgo == 'alto', (value) {
                  setState(() => _filtroRiesgo = value ? 'alto' : '');
                }),
              ],
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aplicar Filtros"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }

  void _verDetalleResultado(resultado) {
    Navigator.pushNamed(
      context,
      '/resultado',
      arguments: {'resultado': resultado},
    );
  }
}
