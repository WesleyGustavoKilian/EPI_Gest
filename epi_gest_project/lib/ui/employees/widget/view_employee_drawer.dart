import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ViewEmployeeDrawer extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onClose;

  const ViewEmployeeDrawer({
    super.key,
    required this.employee,
    required this.onClose,
  });

  @override
  State<ViewEmployeeDrawer> createState() => _ViewEmployeeDrawerState();
}

class _ViewEmployeeDrawerState extends State<ViewEmployeeDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeDrawer() async {
    await _animationController.reverse();
    widget.onClose();
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

                    // Conteúdo
                    Expanded(child: _buildContent(theme)),

                    // Rodapé
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

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.visibility,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visualizar Funcionário',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Informações do funcionário',
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
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dataEntrada = widget.employee['dataEntrada'] as DateTime?;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Seção: Informações Básicas
        _buildSectionTitle('Informações Básicas', Icons.info_outline),
        const SizedBox(height: 16),

        // Imagem, ID, Data de Entrada e Nome
        Row(
          children: [
            // Container da Imagem
            _buildImageDisplay(theme),

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
                        child: _buildDisabledTextField(
                          label: 'ID',
                          value: widget.employee['id'] ?? '',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildDisabledTextField(
                          label: 'Data de Entrada',
                          value: dataEntrada != null
                              ? dateFormat.format(dataEntrada)
                              : 'Não informada',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                  // Segunda linha: Nome do Funcionário
                  _buildDisabledTextField(
                    label: 'Nome do Funcionário',
                    value: widget.employee['nome'] ?? '',
                    icon: Icons.person_outline,
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

        _buildDisabledTextField(
          label: 'Setor',
          value: widget.employee['setor'] ?? '',
          icon: Icons.business_outlined,
        ),

        const SizedBox(height: 16),

        _buildDisabledTextField(
          label: 'Função na Empresa',
          value: widget.employee['funcao'] ?? '',
          icon: Icons.assignment_ind_outlined,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildImageDisplay(ThemeData theme) {
    final imagePath = widget.employee['imagem'] as String?;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sem foto',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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

  Widget _buildDisabledTextField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _closeDrawer,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}
