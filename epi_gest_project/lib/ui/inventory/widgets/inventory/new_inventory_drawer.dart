import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory/product_search_dialog.dart';

class NewInventoryDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const NewInventoryDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<NewInventoryDrawer> createState() => _NewInventoryDrawerState();
}

class _NewInventoryDrawerState extends State<NewInventoryDrawer> {
  final _formKey = GlobalKey<FormState>();
  
  // Dados do inventário
  final TextEditingController _dataInventarioController = TextEditingController();
  final TextEditingController _produtoCodigoController = TextEditingController();
  final TextEditingController _produtoDescricaoController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _quantidadeSistemaController = TextEditingController();
  final TextEditingController _novaQuantidadeController = TextEditingController();

  // Lista de produtos do inventário (pode adicionar múltiplos)
  final List<Map<String, dynamic>> _produtos = [];

  @override
  void initState() {
    super.initState();
    // Define a data atual como padrão
    _dataInventarioController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataInventarioController.dispose();
    _produtoCodigoController.dispose();
    _produtoDescricaoController.dispose();
    _caController.dispose();
    _quantidadeSistemaController.dispose();
    _novaQuantidadeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataInventarioController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _searchProduct() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ProductSearchDialog(
        onSelect: (product) {
          setState(() {
            _produtoCodigoController.text = product['codigo'] ?? '';
            _produtoDescricaoController.text = product['descricao'] ?? '';
            _caController.text = product['ca'] ?? '';
            _quantidadeSistemaController.text = '${product['quantidadeSistema'] ?? 0}';
            _novaQuantidadeController.text = '${product['quantidadeSistema'] ?? 0}';
          });
        },
      ),
    );
  }

  void _addProduct() {
    if (_produtoCodigoController.text.isEmpty || 
        _novaQuantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o código do produto e a nova quantidade'),
        ),
      );
      return;
    }

    final quantidadeSistema = int.tryParse(_quantidadeSistemaController.text) ?? 0;
    final novaQuantidade = int.tryParse(_novaQuantidadeController.text) ?? 0;
    final diferenca = novaQuantidade - quantidadeSistema;

    setState(() {
      _produtos.add({
        'codigo': _produtoCodigoController.text,
        'descricao': _produtoDescricaoController.text,
        'ca': _caController.text,
        'quantidadeSistema': quantidadeSistema,
        'novaQuantidade': novaQuantidade,
        'diferenca': diferenca,
      });

      // Limpa campos do produto
      _produtoCodigoController.clear();
      _produtoDescricaoController.clear();
      _caController.clear();
      _quantidadeSistemaController.clear();
      _novaQuantidadeController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _produtos.removeAt(index);
    });
  }

  void _saveInventory() {
    if (_formKey.currentState!.validate() && _produtos.isNotEmpty) {
      final inventoryData = {
        'dataInventario': _dataInventarioController.text,
        'produtos': List.from(_produtos),
      };

      widget.onSave(inventoryData);
    } else if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      contentPadding: EdgeInsets.zero,
      scrollable: true,
      title: Row(
        children: [
          Icon(
            Icons.inventory_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Novo Inventário'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dados do Inventário
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados do Inventário',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Data do Inventário
                          Expanded(
                            child: TextFormField(
                              controller: _dataInventarioController,
                              decoration: InputDecoration(
                                labelText: 'Data do Inventário',
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a data do inventário';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Produtos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Produtos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Produto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Formulário para adicionar produto
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _produtoCodigoController,
                                    decoration: InputDecoration(
                                      labelText: 'Código do Produto',
                                      prefixIcon: const Icon(Icons.code),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _searchProduct,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _produtoDescricaoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Descrição do Produto',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _caController,
                                    decoration: const InputDecoration(
                                      labelText: 'C.A do Produto',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _quantidadeSistemaController,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantidade no Sistema',
                                      prefixIcon: Icon(Icons.inventory_2),
                                    ),
                                    readOnly: true,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _novaQuantidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Nova Quantidade',
                                prefixIcon: Icon(Icons.refresh),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a nova quantidade';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de produtos adicionados
                      if (_produtos.isNotEmpty) ...[
                        Text(
                          'Produtos do Inventário (${_produtos.length})',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ..._produtos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final produto = entry.value;
                          final diferenca = produto['diferenca'];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: diferenca == 0 
                                    ? theme.colorScheme.outline
                                    : diferenca > 0
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${produto['codigo']} - ${produto['descricao']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('CA: ${produto['ca']}'),
                                      Row(
                                        children: [
                                          Text('Sistema: ${produto['quantidadeSistema']}'),
                                          const SizedBox(width: 16),
                                          Text('Inventário: ${produto['novaQuantidade']}'),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Dif: ${diferenca >= 0 ? '+' : ''}$diferenca',
                                            style: TextStyle(
                                              color: diferenca == 0
                                                  ? theme.colorScheme.onSurfaceVariant
                                                  : diferenca > 0
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => _removeProduct(index),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: widget.onClose,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saveInventory,
          child: const Text('Salvar Inventário'),
        ),
      ],
    );
  }
}