import 'package:flutter/material.dart';
import 'widgets/organizational_type_card.dart';
import 'widgets/units_widget.dart';
import 'widgets/epi_maping_widget.dart';
import 'widgets/departments_widget.dart';
import 'widgets/roles_widget.dart';
import 'widgets/employment_types_widget.dart';
import 'widgets/shifts_widget.dart';
import 'widgets/risks_widget.dart';

class OrganizationalStructurePage extends StatefulWidget {
  const OrganizationalStructurePage({super.key});

  @override
  State<OrganizationalStructurePage> createState() =>
      _OrganizationalStructurePageState();
}

class _OrganizationalStructurePageState
    extends State<OrganizationalStructurePage> {
  int? _selectedSection;
  bool _showDrawer = false;

  // Keys para controlar cada widget
  final GlobalKey<UnitsWidgetState> _unitsKey = GlobalKey();
  final GlobalKey<DepartmentsWidgetState> _departmentsKey = GlobalKey();
  final GlobalKey<RolesWidgetState> _rolesKey = GlobalKey();
  final GlobalKey<EmploymentTypesWidgetState> _employmentTypesKey = GlobalKey();
  final GlobalKey<ShiftsWidgetState> _shiftsKey = GlobalKey();
  final GlobalKey<RisksWidgetState> _risksKey = GlobalKey();
  final GlobalKey<EpiMapingWidgetState> _epiMapingKey = GlobalKey();

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Unidades (Matriz / Filial)',
      'icon': Icons.business_outlined,
      'description': 'Gerencie matriz e filiais da empresa',
      'index': 0,
    },
    {
      'title': 'Setores / Departamentos',
      'icon': Icons.work_outline,
      'description': 'Configure departamentos e áreas',
      'index': 1,
    },
    {
      'title': 'Cargos / Funções',
      'icon': Icons.badge_outlined,
      'description': 'Defina cargos e responsabilidades',
      'index': 2,
    },
    {
      'title': 'Riscos Ocupacionais',
      'icon': Icons.warning_amber_outlined,
      'description': 'Classifique riscos por atividade',
      'index': 3,
    },
    {
      'title': 'Mapeamento de EPIs',
      'icon': Icons.assignment_turned_in_outlined,
      'description': 'Vincule EPIs a cargos, setores e riscos',
      'index': 4,
    },
    {
      'title': 'Tipos de Vínculo',
      'icon': Icons.assignment_ind_outlined,
      'description': 'Tipos de contratação e vínculos',
      'index': 5,
    },
    {
      'title': 'Turnos de Trabalho',
      'icon': Icons.access_time_outlined,
      'description': 'Configure jornadas e horários',
      'index': 6,
    },
  ];

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSection = index;
      // Fecha drawer no mobile após seleção
      if (MediaQuery.of(context).size.width < 768) {
        _showDrawer = false;
      }
    });
  }

  Widget _getSectionWidget(int index) {
    switch (index) {
      case 0:
        return UnitsWidget(key: _unitsKey);
      case 1:
        return DepartmentsWidget(key: _departmentsKey);
      case 2:
        return RolesWidget(key: _rolesKey);
      case 3:
        return RisksWidget(key: _risksKey);
      case 4:
        return EpiMapingWidget(key: _epiMapingKey);
      case 5:
        return EmploymentTypesWidget(key: _employmentTypesKey);
      case 6:
        return ShiftsWidget(key: _shiftsKey);
      default:
        return const Center(child: Text('Seção não encontrada'));
    }
  }

  String _getAddButtonText(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        return 'Nova Unidade';
      case 1:
        return 'Novo Departamento';
      case 2:
        return 'Novo Cargo';
      case 3:
        return 'Novo Risco';
      case 4:
        return 'Novo Mapeamento';
      case 5:
        return 'Novo Vínculo';
      case 6:
        return 'Novo Turno';
      default:
        return 'Adicionar';
    }
  }

  void _triggerAddAction(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        _unitsKey.currentState?.showAddDrawer();
        break;
      case 1:
        _departmentsKey.currentState?.showAddDrawer();
        break;
      case 2:
        _rolesKey.currentState?.showAddDrawer();
        break;
      case 3:
        _risksKey.currentState?.showAddDrawer();
        break;
      case 4:
        _epiMapingKey.currentState?.showAddDrawer();
        break;
      case 5:
        _employmentTypesKey.currentState?.showAddDrawer();
        break;
      case 6:
        _shiftsKey.currentState?.showAddDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSelectionPanel(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _buildConfigurationPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Conteúdo principal
        _buildConfigurationPanel(),

        // Drawer lateral
        if (_showDrawer) ...[
          GestureDetector(
            onTap: () => setState(() => _showDrawer = false),
            child: Container(
              color: Colors.black54,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              child: Container(
                width: 320,
                child: _buildSelectionPanel(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionPanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_tree,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estrutura Organizacional',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_sections.length} seções de gestão',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile) ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showDrawer = false),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isSelected = _selectedSection == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrganizationalTypeCard(
                  icon: section['icon'],
                  title: section['title'],
                  description: section['description'],
                  isSelected: isSelected,
                  onTap: () => _onSectionSelected(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationPanel() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_selectedSection == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'Selecione um tipo de Seção',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isMobile 
                    ? 'Toque no menu para ver as seções'
                    : 'Escolha uma seção no painel lateral para começar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              if (isMobile) ...[
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => setState(() => _showDrawer = true),
                  icon: const Icon(Icons.menu),
                  label: const Text('Abrir Menu'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.08),
                Theme.of(context).colorScheme.surface.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
            ),
          ),
          child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _getSectionWidget(_selectedSection!),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _sections[_selectedSection!]['icon'],
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sections[_selectedSection!]['title'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _sections[_selectedSection!]['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => _triggerAddAction(_selectedSection!),
          icon: const Icon(Icons.add),
          label: Text(_getAddButtonText(_selectedSection!)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => setState(() => _showDrawer = true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sections[_selectedSection!]['title'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _triggerAddAction(_selectedSection!),
              icon: const Icon(Icons.add),
              label: Text(_getAddButtonText(_selectedSection!)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Text(
            _sections[_selectedSection!]['description'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}