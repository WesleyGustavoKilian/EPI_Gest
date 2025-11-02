import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AddEmployeeDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>)? onSave;

  const AddEmployeeDrawer({
    super.key,
    required this.onClose,
    this.onSave,
  });

  @override
  State<AddEmployeeDrawer> createState() => _AddEmployeeDrawerState();
}

class _AddEmployeeDrawerState extends State<AddEmployeeDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _setorController = TextEditingController();
  final TextEditingController _funcaoController = TextEditingController();
  final TextEditingController _dataEntradaController = TextEditingController();

  // Controllers para adicionar novo setor/função
  final TextEditingController _novoSetorController = TextEditingController();
  final TextEditingController _novaFuncaoController = TextEditingController();

  // GlobalKeys para posicionar os overlays
  final GlobalKey _setorButtonKey = GlobalKey();
  final GlobalKey _funcaoButtonKey = GlobalKey();

  DateTime? _selectedDate;
  bool _isSaving = false;

  // Overlays
  OverlayEntry? _setorOverlay;
  OverlayEntry? _funcaoOverlay;

  // Imagem do funcionário
  File? _imageFile;

  // Listas (podem vir do controller futuramente)
  final List<String> _setoresSugeridos = [
    'Produção',
    'Qualidade',
    'Manutenção',
    'Logística',
    'Administrativo',
    'Recursos Humanos',
    'Financeiro',
    'Comercial',
  ];

  final List<String> _funcoesSugeridas = [
    'Operador de Máquinas',
    'Inspetor de Qualidade',
    'Técnico de Manutenção',
    'Auxiliar de Produção',
    'Supervisor',
    'Gerente',
    'Analista',
    'Assistente',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _removeOverlays();
    _animationController.dispose();
    _idController.dispose();
    _nomeController.dispose();
    _setorController.dispose();
    _funcaoController.dispose();
    _dataEntradaController.dispose();
    _novoSetorController.dispose();
    _novaFuncaoController.dispose();
    super.dispose();
  }

  void _removeOverlays() {
    _setorOverlay?.remove();
    _setorOverlay = null;
    _funcaoOverlay?.remove();
    _funcaoOverlay = null;
  }

  Future<void> _closeDrawer() async {
    _removeOverlays();
    await _animationController.reverse();
    widget.onClose();
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _imageFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Erro ao selecionar imagem: $e'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Imagem removida'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddSetorOverlay() {
    if (_setorOverlay != null) {
      _setorOverlay!.remove();
      _setorOverlay = null;
      return;
    }

    final RenderBox renderBox =
        _setorButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _setorOverlay = OverlayEntry(
      builder: (context) => _buildAddOverlayDropdown(
        theme: Theme.of(context),
        title: 'Adicionar Novo Setor',
        controller: _novoSetorController,
        position: position,
        buttonSize: size,
        onAdd: _addNovoSetor,
        onCancel: () {
          _setorOverlay?.remove();
          _setorOverlay = null;
          _novoSetorController.clear();
        },
      ),
    );

    Overlay.of(context).insert(_setorOverlay!);
  }

  void _showAddFuncaoOverlay() {
    if (_funcaoOverlay != null) {
      _funcaoOverlay!.remove();
      _funcaoOverlay = null;
      return;
    }

    final RenderBox renderBox =
        _funcaoButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _funcaoOverlay = OverlayEntry(
      builder: (context) => _buildAddOverlayDropdown(
        theme: Theme.of(context),
        title: 'Adicionar Nova Função',
        controller: _novaFuncaoController,
        position: position,
        buttonSize: size,
        onAdd: _addNovaFuncao,
        onCancel: () {
          _funcaoOverlay?.remove();
          _funcaoOverlay = null;
          _novaFuncaoController.clear();
        },
      ),
    );

    Overlay.of(context).insert(_funcaoOverlay!);
  }

  void _addNovoSetor() {
    if (_novoSetorController.text.trim().isNotEmpty) {
      setState(() {
        final novoSetor = _novoSetorController.text.trim();
        if (!_setoresSugeridos.contains(novoSetor)) {
          _setoresSugeridos.add(novoSetor);
          _setorController.text = novoSetor;
        }
        _novoSetorController.clear();
      });

      _setorOverlay?.remove();
      _setorOverlay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Setor adicionado com sucesso!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addNovaFuncao() {
    if (_novaFuncaoController.text.trim().isNotEmpty) {
      setState(() {
        final novaFuncao = _novaFuncaoController.text.trim();
        if (!_funcoesSugeridas.contains(novaFuncao)) {
          _funcoesSugeridas.add(novaFuncao);
          _funcaoController.text = novaFuncao;
        }
        _novaFuncaoController.clear();
      });

      _funcaoOverlay?.remove();
      _funcaoOverlay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Função adicionada com sucesso!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Selecione a data de entrada'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      // Dados do formulário
      final data = {
        'id': _idController.text,
        'nome': _nomeController.text,
        'setor': _setorController.text,
        'funcao': _funcaoController.text,
        'dataEntrada': _selectedDate,
        'imagem': _imageFile?.path,
      };

      // Simula salvamento
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          widget.onSave?.call(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Funcionário adicionado com sucesso!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _closeDrawer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Overlay escuro
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        // Painel lateral
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: Container(
                width: size.width > 600 ? size.width * 0.45 : size.width * 0.85,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Cabeçalho
                    _buildHeader(theme),

                    // Formulário
                    Expanded(child: _buildForm(theme)),

                    // Rodapé com botões
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOverlayDropdown({
    required ThemeData theme,
    required String title,
    required TextEditingController controller,
    required Offset position,
    required Size buttonSize,
    required VoidCallback onAdd,
    required VoidCallback onCancel,
  }) {
    final screenSize = MediaQuery.of(context).size;
    const dropdownWidth = 450.0;
    const dropdownMaxHeight = 200.0;

    double left = position.dx;
    double? right;

    if (left + dropdownWidth > screenSize.width) {
      right = screenSize.width - (position.dx + buttonSize.width);
      left = screenSize.width - right - dropdownWidth;
    }

    double top = position.dy + buttonSize.height + 16;
    double? bottom;

    if (top + dropdownMaxHeight > screenSize.height) {
      bottom = screenSize.height - position.dy + 16;
      top = position.dy - dropdownMaxHeight - 16;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          right: right,
          top: bottom == null ? top : null,
          bottom: bottom,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(maxHeight: dropdownMaxHeight),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onCancel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Digite o nome',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) {
                            if (controller.text.trim().isNotEmpty) {
                              onAdd();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onAdd();
                          }
                        },
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar Funcionário',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados do novo funcionário',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeDrawer,
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Seção: Informações Básicas
          _buildSectionTitle('Informações Básicas', Icons.info_outline),
          const SizedBox(height: 16),

          // Imagem, ID, Data de Entrada e Nome
          Row(
            children: [
              // Container da Imagem
              _buildImagePicker(theme),

              const SizedBox(width: 16),

              // ID, Data de Entrada e Nome
              Expanded(
                child: Column(
                  spacing: 16,
                  children: [
                    // Primeira linha: ID e Data de Entrada
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _idController,
                            label: 'ID',
                            hint: 'Ex: 001',
                            icon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildDateField(
                            controller: _dataEntradaController,
                            label: 'Data de Entrada',
                            hint: 'dd/mm/aaaa',
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectDate,
                          ),
                        ),
                      ],
                    ),
                    // Segunda linha: Nome do Funcionário
                    _buildTextField(
                      controller: _nomeController,
                      label: 'Nome do Funcionário',
                      hint: 'Ex: João Silva',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção: Cargo e Setor
          _buildSectionTitle('Cargo e Setor', Icons.work_outline),
          const SizedBox(height: 16),

          // Setor com botão de adicionar
          _buildAutocompleteFieldWithAdd(
            controller: _setorController,
            label: 'Setor',
            hint: 'Selecione ou digite um setor',
            icon: Icons.business_outlined,
            suggestions: _setoresSugeridos,
            buttonKey: _setorButtonKey,
            onToggleAdd: _showAddSetorOverlay,
          ),

          const SizedBox(height: 16),

          // Função com botão de adicionar
          _buildAutocompleteFieldWithAdd(
            controller: _funcaoController,
            label: 'Função na Empresa',
            hint: 'Selecione ou digite uma função',
            icon: Icons.assignment_ind_outlined,
            suggestions: _funcoesSugeridas,
            buttonKey: _funcaoButtonKey,
            onToggleAdd: _showAddFuncaoOverlay,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicionar\nFoto',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_imageFile != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _pickImage,
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Alterar foto',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete, size: 18),
                tooltip: 'Remover foto',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(icon: const Icon(Icons.event), onPressed: onTap),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildAutocompleteFieldWithAdd({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> suggestions,
    required GlobalKey buttonKey,
    required VoidCallback onToggleAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return suggestions;
              }
              return suggestions.where((String option) {
                return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              fieldController.text = controller.text;
              fieldController.addListener(() {
                controller.text = fieldController.text;
              });

              return TextFormField(
                controller: fieldController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          key: buttonKey,
          onPressed: onToggleAdd,
          icon: const Icon(Icons.add),
          tooltip: 'Adicionar novo',
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _closeDrawer,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Salvando...' : 'Adicionar Funcionário'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
