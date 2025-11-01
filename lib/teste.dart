import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class EPIDashboardApp extends StatelessWidget {
  const EPIDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard EPI 2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        brightness: Brightness.dark,
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isDarkMode = false;
  bool _isSidebarCollapsed = false;
  int _currentPageIndex = 0;
  
  // Dados de exemplo
  final List<EPIData> _epiData = [
    EPIData('Capacetes', 12500, Colors.pink),
    EPIData('Óculos', 8700, Colors.orange),
    EPIData('Luvas', 15600, Colors.cyan),
    EPIData('Protetor', 9800, Colors.blue),
    EPIData('Botinas', 13400, Colors.deepPurple),
    EPIData('Aventais', 7500, Colors.indigo),
    EPIData('Cintos', 6200, Colors.lightBlue),
  ];
  
  final List<EmployeeActivity> _recentActivities = [
    EmployeeActivity(
      'Carlos Silva', 
      'Soldador', 
      'https://randomuser.me/api/portraits/men/32.jpg',
      'Capacete de Segurança',
      'CA-12345',
      '15/08/2023',
      ActivityStatus.expired
    ),
    EmployeeActivity(
      'Ana Oliveira', 
      'Operadora', 
      'https://randomuser.me/api/portraits/women/44.jpg',
      'Protetor Auricular',
      'CA-98765',
      '20/08/2023',
      ActivityStatus.pending
    ),
    EmployeeActivity(
      'Roberto Santos', 
      'Eletricista', 
      'https://randomuser.me/api/portraits/men/75.jpg',
      'Luvas Dielétricas',
      'CA-86420',
      '22/08/2023',
      ActivityStatus.delivered
    ),
    EmployeeActivity(
      'Juliana Costa', 
      'Montadora', 
      'https://randomuser.me/api/portraits/women/68.jpg',
      'Botina de Segurança',
      'CA-13579',
      '23/08/2023',
      ActivityStatus.delivered
    ),
  ];
  
  final List<TopEmployee> _topEmployees = [
    TopEmployee('Carlos Silva', 'Soldador', 18, 2845.00, '15/08/2023', 25, true),
    TopEmployee('Ana Oliveira', 'Operadora', 12, 1920.00, '20/08/2023', 10, true),
    TopEmployee('Roberto Santos', 'Eletricista', 9, 1575.00, '22/08/2023', -5, false),
    TopEmployee('Juliana Costa', 'Montadora', 7, 1120.00, '23/08/2023', 0, false),
    TopEmployee('Marcos Souza', 'Pintor', 6, 980.00, '18/08/2023', 8, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4361ee),
                  Color(0xFF3a56d4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo e título
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logo.png', // Substitua pelo caminho correto da sua logo
                        width: 36,
                        height: 36,
                      ),
                      if (!_isSidebarCollapsed) ...[
                        SizedBox(width: 12),
                        Text(
                          'Controle de EPI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Menu
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 16),
                    children: [
                      _buildMenuItem(Icons.pie_chart, 'Dashboard', 0, isActive: true),
                      _buildMenuItem(Icons.people, 'Funcionários', 1),
                      _buildMenuItem(Icons.business, 'Estrutura Organizacional', 2),
                      _buildMenuItem(Icons.construction, 'Troca de EPIs', 3, badgeCount: 3),
                      _buildMenuItem(Icons.warehouse, 'Estoque', 4),
                      _buildMenuItem(Icons.settings, 'Auxiliares de Estoque', 5),
                      _buildMenuItem(Icons.analytics, 'Relatórios', 6),
                      _buildMenuItem(Icons.settings, 'Configurações', 7),
                      _buildMenuItem(Icons.school, 'Tutoriais', 8),
                    ],
                  ),
                ),
                
                // Suporte
                Container(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(_isSidebarCollapsed ? 8 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (!_isSidebarCollapsed) ...[
                          Text(
                            'Precisa de ajuda? Nossa equipe está disponível 24/7',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.headset, size: _isSidebarCollapsed ? 20 : 16),
                          label: _isSidebarCollapsed ? SizedBox() : Text('Suporte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF4361ee),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo principal
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Botão para recolher/expandir sidebar
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSidebarCollapsed = !_isSidebarCollapsed;
                            });
                          },
                          icon: Icon(Icons.menu),
                        ),
                        
                        Spacer(),
                        
                        // Campo de pesquisa
                        Container(
                          width: 250,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Pesquisar...',
                              prefixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Seletor de filial
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: 'matriz',
                            items: [
                              DropdownMenuItem(value: 'matriz', child: Text('Matriz')),
                              DropdownMenuItem(value: 'filial1', child: Text('Filial 01 - Campinas')),
                              DropdownMenuItem(value: 'filial2', child: Text('Filial 02 - Sorocaba')),
                            ],
                            onChanged: (value) {},
                            underline: SizedBox(),
                            icon: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Notificações
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Toggle modo escuro
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          },
                          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Perfil do usuário
                        GestureDetector(
                          onTap: () {
                            // Abrir menu do usuário
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/41.jpg'),
                              ),
                              SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wesley Kilian',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Administrador',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Conteúdo da página
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho da página
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard de EPIs',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Home',
                                        style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.chevron_right, size: 16, color: Theme.of(context).hintColor),
                                      SizedBox(width: 4),
                                      Text(
                                        'Dashboard',
                                        style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Filtros
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.filter_list),
                                        SizedBox(width: 8),
                                        Text(
                                          'Filtros',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: Icon(Icons.file_download),
                                      label: Text('Exportar'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text('Período:'),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButton<String>(
                                        value: 'semanal',
                                        items: [
                                          DropdownMenuItem(value: 'hoje', child: Text('Hoje')),
                                          DropdownMenuItem(value: 'semanal', child: Text('Esta Semana')),
                                          DropdownMenuItem(value: 'mensal', child: Text('Este Mês')),
                                          DropdownMenuItem(value: 'trimestral', child: Text('Este Trimestre')),
                                          DropdownMenuItem(value: 'anual', child: Text('Este Ano')),
                                          DropdownMenuItem(value: 'personalizado', child: Text('Personalizado')),
                                        ],
                                        onChanged: (value) {},
                                        underline: SizedBox(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Cards de métricas
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildMetricCard(
                                'Entregas Totais',
                                '1.248',
                                'EPIs',
                                'R\$ 89.745,00',
                                Colors.green,
                                Icons.check_circle,
                                'Em dia',
                                true,
                                12,
                              ),
                              _buildMetricCard(
                                'Pendentes',
                                '87',
                                'EPIs',
                                'R\$ 6.240,00',
                                Colors.orange,
                                Icons.schedule,
                                'Atenção',
                                true,
                                5,
                              ),
                              _buildMetricCard(
                                'CAs Vencidos',
                                '32',
                                'EPIs',
                                'R\$ 2.150,00',
                                Colors.red,
                                Icons.warning,
                                'Urgente',
                                false,
                                -8,
                              ),
                              _buildMetricCard(
                                'Tipos de EPI',
                                '14',
                                'Tipos',
                                'R\$ 98.135,00',
                                Colors.blue,
                                Icons.pie_chart,
                                'Diversos',
                                true,
                                3,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Gráficos
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Gastos por Tipo de EPI',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              _buildChartPeriodButton('Diário', false),
                                              _buildChartPeriodButton('Semanal', true),
                                              _buildChartPeriodButton('Mensal', false),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        height: 350,
                                        child: SfCartesianChart(
                                          primaryXAxis: CategoryAxis(),
                                          series: <ColumnSeries<EPIData, String>>[
                                            ColumnSeries<EPIData, String>(
                                              dataSource: _epiData,
                                              xValueMapper: (EPIData data, _) => data.name,
                                              yValueMapper: (EPIData data, _) => data.value,
                                              color: Color(0xFF4361ee),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Distribuição por Setor',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              _buildChartTypeButton('Quantidade', true),
                                              _buildChartTypeButton('Valor', false),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        height: 350,
                                        child: SfCircularChart(
                                          series: <PieSeries<EPIData, String>>[
                                            PieSeries<EPIData, String>(
                                              dataSource: _epiData,
                                              xValueMapper: (EPIData data, _) => data.name,
                                              yValueMapper: (EPIData data, _) => data.value,
                                              dataLabelMapper: (EPIData data, _) => '${data.name}\nR\$${data.value}',
                                              dataLabelSettings: DataLabelSettings(isVisible: true),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Tabela de atividades recentes
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Atividades Recentes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        children: [
                                          Text('Ver tudo'),
                                          SizedBox(width: 4),
                                          Icon(Icons.chevron_right, size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: [
                                      DataColumn(label: Text('Funcionário')),
                                      DataColumn(label: Text('EPI')),
                                      DataColumn(label: Text('CA')),
                                      DataColumn(label: Text('Data')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Ações')),
                                    ],
                                    rows: _recentActivities.map((activity) {
                                      return DataRow(cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(activity.avatarUrl),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    activity.name,
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  Text(
                                                    activity.position,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(activity.epi)),
                                        DataCell(Text(activity.ca)),
                                        DataCell(Text(activity.date)),
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(activity.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(activity.status),
                                                  size: 12,
                                                  color: _getStatusColor(activity.status),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _getStatusText(activity.status),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getStatusColor(activity.status),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.visibility, size: 18),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.print, size: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Tabela de top colaboradores
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Top Colaboradores em Trocas',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: Icon(Icons.file_download),
                                      label: Text('Exportar'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text('Exibir:'),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButton<String>(
                                        value: 'top10',
                                        items: [
                                          DropdownMenuItem(value: 'top5', child: Text('Top 5')),
                                          DropdownMenuItem(value: 'top10', child: Text('Top 10')),
                                          DropdownMenuItem(value: 'top15', child: Text('Top 15')),
                                          DropdownMenuItem(value: 'top20', child: Text('Top 20')),
                                          DropdownMenuItem(value: 'all', child: Text('Todos')),
                                        ],
                                        onChanged: (value) {},
                                        underline: SizedBox(),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButton<String>(
                                        value: 'mensal',
                                        items: [
                                          DropdownMenuItem(value: 'semanal', child: Text('Esta Semana')),
                                          DropdownMenuItem(value: 'mensal', child: Text('Este Mês')),
                                          DropdownMenuItem(value: 'trimestral', child: Text('Este Trimestre')),
                                          DropdownMenuItem(value: 'anual', child: Text('Este Ano')),
                                        ],
                                        onChanged: (value) {},
                                        underline: SizedBox(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: [
                                      DataColumn(label: Text('Posição')),
                                      DataColumn(label: Text('Colaborador')),
                                      DataColumn(label: Text('Qtd. Trocas')),
                                      DataColumn(label: Text('Valor Total')),
                                      DataColumn(label: Text('Última Troca')),
                                      DataColumn(label: Text('Tendência')),
                                    ],
                                    rows: _topEmployees.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      TopEmployee employee = entry.value;
                                      return DataRow(cells: [
                                        DataCell(Text('${index + 1}º')),
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/${32 + index}.jpg'),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    employee.name,
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  Text(
                                                    employee.position,
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(employee.exchanges.toString())),
                                        DataCell(Text('R\$${employee.totalValue.toStringAsFixed(2)}')),
                                        DataCell(Text(employee.lastExchange)),
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: employee.trend > 0 
                                                ? Colors.green.withOpacity(0.1)
                                                : employee.trend < 0
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  employee.trend > 0 
                                                    ? Icons.arrow_upward
                                                    : employee.trend < 0
                                                      ? Icons.arrow_downward
                                                      : Icons.remove,
                                                  size: 12,
                                                  color: employee.trend > 0 
                                                    ? Colors.green
                                                    : employee.trend < 0
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  employee.trend > 0 
                                                    ? '${employee.trend}%'
                                                    : employee.trend < 0
                                                      ? '${employee.trend.abs()}%'
                                                      : 'Estável',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: employee.trend > 0 
                                                      ? Colors.green
                                                      : employee.trend < 0
                                                        ? Colors.red
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem(IconData icon, String title, int index, {bool isActive = false, int badgeCount = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9)),
            if (badgeCount > 0) Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        title: _isSidebarCollapsed ? null : Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        tileColor: isActive ? Colors.white.withOpacity(0.15) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
  
  Widget _buildMetricCard(
    String title, 
    String value, 
    String unit, 
    String secondaryValue,
    Color color, 
    IconData icon,
    String badgeText,
    bool isPositive,
    int trend,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            secondaryValue,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: trend > 0 ? Colors.green : Colors.red,
              ),
              SizedBox(width: 4),
              Text(
                '${trend.abs()}% no mês',
                style: TextStyle(
                  fontSize: 14,
                  color: trend > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Atualizado agora',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartPeriodButton(String text, bool isActive) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Color(0xFF4361ee) : Theme.of(context).dividerColor,
          foregroundColor: isActive ? Colors.white : Theme.of(context).hintColor,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size(0, 0),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
  
  Widget _buildChartTypeButton(String text, bool isActive) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Color(0xFF4361ee) : Theme.of(context).dividerColor,
          foregroundColor: isActive ? Colors.white : Theme.of(context).hintColor,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size(0, 0),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
  
  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.delivered:
        return Colors.green;
      case ActivityStatus.pending:
        return Colors.orange;
      case ActivityStatus.expired:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.delivered:
        return Icons.check_circle;
      case ActivityStatus.pending:
        return Icons.schedule;
      case ActivityStatus.expired:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
  
  String _getStatusText(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.delivered:
        return 'Entregue';
      case ActivityStatus.pending:
        return 'Pendente';
      case ActivityStatus.expired:
        return 'Vencido';
      default:
        return 'Neutro';
    }
  }
}

// Modelos de dados
class EPIData {
  final String name;
  final int value;
  final Color color;
  
  EPIData(this.name, this.value, this.color);
}

enum ActivityStatus {
  delivered,
  pending,
  expired,
  neutral
}

class EmployeeActivity {
  final String name;
  final String position;
  final String avatarUrl;
  final String epi;
  final String ca;
  final String date;
  final ActivityStatus status;
  
  EmployeeActivity(
    this.name,
    this.position,
    this.avatarUrl,
    this.epi,
    this.ca,
    this.date,
    this.status
  );
}

class TopEmployee {
  final String name;
  final String position;
  final int exchanges;
  final double totalValue;
  final String lastExchange;
  final int trend;
  final bool isPositive;
  
  TopEmployee(
    this.name,
    this.position,
    this.exchanges,
    this.totalValue,
    this.lastExchange,
    this.trend,
    this.isPositive
  );
}