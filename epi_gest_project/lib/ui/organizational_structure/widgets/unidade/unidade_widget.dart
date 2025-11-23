import 'package:epi_gest_project/data/services/unidade_repository.dart';
import 'package:epi_gest_project/domain/models/unidade_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/unidade/unidade_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnidadeWidget extends StatefulWidget {
  const UnidadeWidget({super.key});

  @override
  State<UnidadeWidget> createState() => UnidadeWidgetState();
}

class UnidadeWidgetState extends State<UnidadeWidget> {
  List<UnidadeModel> _unidades = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = Provider.of<UnidadeRepository>(context, listen: false);
      final result = await repository.getAllUnidades();
      
      if (mounted) {
        setState(() {
          _unidades = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar unidades: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({UnidadeModel? unidade, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Unidades',
      pageBuilder: (context, _, __) => UnidadeDrawer(
        unidadeToEdit: unidade,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedUnidade) async {
          _loadData(); 
        },
      ),
    );
  }

  Future<void> _deleteUnidade(UnidadeModel unidade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a unidade "${unidade.nomeUnidade}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = Provider.of<UnidadeRepository>(context, listen: false);
        await repository.delete(unidade.id!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidade excluída com sucesso!'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text("Tentar Novamente"))
          ],
        ),
      );
    }

    if (_unidades.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildUnidadeList()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhum cargo cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Nova Unidade" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnidadeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _unidades.length,
      itemBuilder: (context, index) {
        final unidade = _unidades[index];
        final isMatriz = unidade.tipoUnidade == Tipo.matriz;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              isMatriz ? Icons.business : Icons.business_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(unidade.nomeUnidade, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('CNPJ: ${unidade.cnpj} | ${unidade.endereco}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMatriz ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isMatriz ? 'Matriz' : 'Filial',
                    style: TextStyle(
                      fontSize: 12,
                      color: isMatriz ? Colors.blue.shade800 : Colors.orange.shade800,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(unidade: unidade, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(unidade: unidade),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteUnidade(unidade),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}