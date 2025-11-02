import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_employee_drawer.dart';
import 'view_employee_drawer.dart';

class EmployeesDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> employees;

  const EmployeesDataTable({super.key, required this.employees});

  @override
  State<EmployeesDataTable> createState() => _EmployeesDataTableState();
}

class _EmployeesDataTableState extends State<EmployeesDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _sortedEmployees = [];

  // Scroll controllers sincronizados
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();

  bool _isSyncingScroll = false;

  // Larguras das colunas
  static const double idWidth = 110.0;
  static const double nomeWidth = 280.0;
  static const double setorWidth = 200.0;
  static const double funcaoWidth = 220.0;
  static const double dataEntradaWidth = 160.0;
  static const double acoesWidth = 160.0;

  static const double totalTableWidth =
      idWidth + nomeWidth + setorWidth + funcaoWidth + dataEntradaWidth + acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedEmployees = List.from(widget.employees);
    _headerScrollController.addListener(_syncFromHeader);
    _bodyScrollController.addListener(_syncFromBody);
  }

  void _syncFromHeader() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _bodyScrollController.jumpTo(_headerScrollController.offset);
    _isSyncingScroll = false;
  }

  void _syncFromBody() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _headerScrollController.jumpTo(_bodyScrollController.offset);
    _isSyncingScroll = false;
  }

  @override
  void dispose() {
    _headerScrollController.removeListener(_syncFromHeader);
    _bodyScrollController.removeListener(_syncFromBody);
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEmployees.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 0:
            compare = a['id'].compareTo(b['id']);
            break;
          case 1:
            compare = a['nome'].compareTo(b['nome']);
            break;
          case 2:
            compare = a['setor'].compareTo(b['setor']);
            break;
          case 3:
            compare = a['funcao'].compareTo(b['funcao']);
            break;
          case 4:
            final dateA = a['dataEntrada'] as DateTime?;
            final dateB = b['dataEntrada'] as DateTime?;
            if (dateA == null && dateB == null) {
              compare = 0;
            } else if (dateA == null) {
              compare = 1;
            } else if (dateB == null) {
              compare = -1;
            } else {
              compare = dateA.compareTo(dateB);
            }
            break;
          default:
            compare = 0;
        }
        return ascending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // ====== CABEÇALHO FIXO ======
            SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: totalTableWidth,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildHeaderCell('ID', idWidth, 0),
                    _buildHeaderCell('Nome do Funcionário', nomeWidth, 1),
                    _buildHeaderCell('Setor', setorWidth, 2),
                    _buildHeaderCell('Função na Empresa', funcaoWidth, 3),
                    _buildHeaderCell('Data de Entrada', dataEntradaWidth, 4),
                    _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                  ],
                ),
              ),
            ),

            // ====== CORPO DA TABELA ======
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _bodyScrollController,
                child: SingleChildScrollView(
                  controller: _bodyScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalTableWidth,
                    child: ListView.builder(
                      itemCount: _sortedEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _sortedEmployees[index];
                        final isLast = index == _sortedEmployees.length - 1;
                        final dataEntrada = employee['dataEntrada'] as DateTime?;

                        return Container(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? theme.colorScheme.surface
                                : theme.colorScheme.surfaceContainerLowest,
                            border: Border(
                              bottom: isLast
                                  ? BorderSide.none
                                  : BorderSide(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                    ),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ID
                                _buildDataCell(
                                  width: idWidth,
                                  context: context,
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        employee['id'],
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Nome
                                _buildDataCell(
                                  width: nomeWidth,
                                  context: context,
                                  child: Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        child: Text(
                                          employee['nome'][0].toUpperCase(),
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          employee['nome'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Setor
                                _buildDataCell(
                                  width: setorWidth,
                                  context: context,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business_outlined,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          employee['setor'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Função
                                _buildDataCell(
                                  width: funcaoWidth,
                                  context: context,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          employee['funcao'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Data de Entrada
                                _buildDataCell(
                                  width: dataEntradaWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dataEntrada != null
                                            ? dateFormat.format(dataEntrada)
                                            : 'Não informada',
                                      ),
                                      if (dataEntrada != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _getTempoServico(dataEntrada),
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Ações
                                _buildDataCell(
                                  width: acoesWidth,
                                  isLast: true,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined),
                                        tooltip: 'Visualizar',
                                        onPressed: () {
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            barrierLabel: 'View Employee',
                                            transitionDuration:
                                                const Duration(milliseconds: 300),
                                            pageBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) {
                                              return ViewEmployeeDrawer(
                                                employee: employee,
                                                onClose: () =>
                                                    Navigator.of(context).pop(),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                        onPressed: () {
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            barrierLabel: 'Edit Employee',
                                            transitionDuration:
                                                const Duration(milliseconds: 300),
                                            pageBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) {
                                              return EditEmployeeDrawer(
                                                employee: employee,
                                                onClose: () =>
                                                    Navigator.of(context).pop(),
                                                onSave: (data) {
                                                  // TODO: Implementar salvamento
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        tooltip: 'Excluir',
                                        onPressed: () {
                                          _showDeleteDialog(context, employee);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String label,
    double width,
    int columnIndex, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final isActive = columnIndex == _sortColumnIndex;

    return Container(
      width: width,
      height: 56,
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
      ),
      child: InkWell(
        onTap: columnIndex >= 0 ? () => _sortData(columnIndex, !_sortAscending) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (columnIndex >= 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    isActive
                        ? (_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.unfold_more,
                    size: 16,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell({
    required BuildContext context,
    required double width,
    required Widget child,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
        ),
      ),
      child: child,
    );
  }

  String _getTempoServico(DateTime dataEntrada) {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataEntrada);

    final anos = diferenca.inDays ~/ 365;
    final meses = (diferenca.inDays % 365) ~/ 30;

    if (anos > 0) {
      return '$anos ${anos == 1 ? 'ano' : 'anos'}${meses > 0 ? ' e $meses ${meses == 1 ? 'mês' : 'meses'}' : ''}';
    } else if (meses > 0) {
      return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    } else {
      final dias = diferenca.inDays;
      return '$dias ${dias == 1 ? 'dia' : 'dias'}';
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Funcionário'),
        content: Text(
          'Deseja realmente excluir o funcionário ${employee['nome']}?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implementar exclusão
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text('Funcionário ${employee['nome']} excluído'),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
