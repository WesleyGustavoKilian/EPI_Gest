import 'package:flutter/material.dart';

class MeasurementUnitsWidget extends StatefulWidget {
  const MeasurementUnitsWidget({super.key});

  @override
  State<MeasurementUnitsWidget> createState() => MeasurementUnitsWidgetState();
}

class MeasurementUnitsWidgetState extends State<MeasurementUnitsWidget> {
  final List<Map<String, String>> _units = [];
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
  // SAVE UNIT
  // ------------------------------
  void _saveUnit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _units.add({
          'name': _nameController.text,
          'code': _codeController.text.toUpperCase(),
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unidade ${_nameController.text} cadastrada!')),
      );
    }
  }

  void _deleteUnit(int index) {
    setState(() {
      _units.removeAt(index);
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
              'Nova Unidade de Medida',
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
                  // Código/ID (AGORA EM CIMA)
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código/ID',
                      hintText: 'Ex: UN, CX, PAR',
                      border: OutlineInputBorder(),
                      helperText: 'Código único para identificação',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código';
                      }
                      if (_units.any(
                          (unit) => unit['code'] == value.toUpperCase())) {
                        return 'Código já existe';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Nome da Unidade
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Unidade',
                      hintText: 'Ex: Unidade, Caixa, Par',
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
                onPressed: _saveUnit,
                child: const Text('Salvar Unidade'),
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
      child: _units.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.straighten_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma unidade cadastrada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em "Nova Unidade" para começar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _units.length,
              itemBuilder: (context, index) {
                final unit = _units[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        unit['code']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(unit['name']!),
                    subtitle: Text('Código: ${unit['code']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteUnit(index),
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
