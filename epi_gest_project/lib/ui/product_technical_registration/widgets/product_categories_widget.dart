import 'package:flutter/material.dart';

class ProductCategoriesWidget extends StatefulWidget {
  const ProductCategoriesWidget({super.key});

  @override
  State<ProductCategoriesWidget> createState() => ProductCategoriesWidgetState();
}

class ProductCategoriesWidgetState extends State<ProductCategoriesWidget> {
  final List<Map<String, String>> _categories = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  // ------------------------------
  //  OPEN RIGHT SIDE DRAWER
  // ------------------------------
  void showAddDrawer() {
    _nameController.clear();
    _codeController.clear();

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
              width: 420,
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
  // SAVE CATEGORY
  // ------------------------------
  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _categories.add({
          'name': _nameController.text,
          'code': _codeController.text.toUpperCase(),
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoria ${_nameController.text} cadastrada!')),
      );
    }
  }

  void _deleteCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
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
            Text(
              'Nova Categoria de Produto',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
                  // Código/ID
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código/ID',
                      hintText: 'Ex: LUV, CAP, BOT',
                      border: OutlineInputBorder(),
                      helperText: 'Código único para identificação',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código';
                      }
                      if (_categories.any(
                          (cat) => cat['code'] == value.toUpperCase())) {
                        return 'Código já existe';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Nome da Categoria
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      hintText: 'Ex: Luvas, Capacetes, Botinas',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
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
                onPressed: _saveCategory,
                child: const Text('Salvar Categoria'),
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
      child: _categories.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma categoria cadastrada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em "Nova Categoria" para começar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
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
                        Icons.category,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(category['name']!),
                    subtitle: Text('Código: ${category['code']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteCategory(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}