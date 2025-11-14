import 'package:flutter/material.dart';

class StorageLocationsWidget extends StatefulWidget {
  const StorageLocationsWidget({super.key});

  @override
  State<StorageLocationsWidget> createState() => StorageLocationsWidgetState();
}

class StorageLocationsWidgetState extends State<StorageLocationsWidget> {
  final List<Map<String, dynamic>> _locations = [];
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  // Lista mock de unidades (matriz/filial)
  final List<String> _units = ['Matriz', 'Filial SP', 'Filial RJ', 'Filial MG'];
  String? _selectedUnit;

  // Lista mock de produtos
  final Map<String, String> _products = {
    'EPI001': 'Luva de Proteção Nitrílica',
    'EPI002': 'Capacete de Segurança',
    'EPI003': 'Óculos de Proteção',
    'EPI004': 'Botina de Segurança',
    'EPI005': 'Protetor Auricular',
  };

  // ------------------------------
  //  OPEN RIGHT SIDE DRAWER
  // ------------------------------
  void showAddDrawer() {
    _codeController.clear();
    _addressController.clear();
    _productCodeController.clear();
    _productDescriptionController.clear();
    _selectedUnit = null;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fechar",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500, // AUMENTADO PARA 500px
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(-3, 0),
                  )
                ],
              ),
              child: _buildAddDrawer(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: slide, child: child);
      },
    );
  }

  // ------------------------------
  // SAVE LOCATION
  // ------------------------------
  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _locations.add({
          'code': _codeController.text.toUpperCase(),
          'unit': _selectedUnit,
          'address': _addressController.text,
          'productCode': _productCodeController.text,
          'productDescription': _productDescriptionController.text,
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Local ${_codeController.text} cadastrado!')),
      );
    }
  }

  void _deleteLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  void _updateProductDescription(String code) {
    if (_products.containsKey(code)) {
      setState(() {
        _productDescriptionController.text = _products[code]!;
      });
    } else {
      setState(() {
        _productDescriptionController.clear();
      });
    }
  }

  // ------------------------------
  // RIGHT DRAWER CONTENT
  // ------------------------------
  Widget _buildAddDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Novo Local de Armazenamento',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // FORM
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Código/ID do Local
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código/ID do Local',
                      hintText: 'Ex: ALM001, EST002',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código';
                      }
                      if (_locations.any(
                          (loc) => loc['code'] == value.toUpperCase())) {
                        return 'Código já existe';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Unidade Vinculada
                  DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidade Vinculada',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((String unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma unidade';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Endereço
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      hintText: 'Ex: Rua A, 123 - Setor B',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o endereço';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Código do Produto
                  TextFormField(
                    controller: _productCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código do Produto',
                      hintText: 'Ex: EPI001, EPI002',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: _updateProductDescription,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código do produto';
                      }
                      if (!_products.containsKey(value)) {
                        return 'Código de produto não encontrado';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Descrição do Produto
                  TextFormField(
                    controller: _productDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição do Produto',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // BOTÃO SALVAR
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _saveLocation,
                child: const Text('Salvar Local'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------
  // MAIN LIST SCREEN
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: _locations.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum local cadastrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em "Novo Local" para começar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.place,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text('Local: ${location['code']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unidade: ${location['unit']}'),
                        Text('Endereço: ${location['address']}'),
                        Text('Produto: ${location['productDescription']}'),
                        Text('Código: ${location['productCode']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteLocation(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _addressController.dispose();
    _productCodeController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }
}