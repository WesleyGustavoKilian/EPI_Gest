import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CostPerEmployeeChart extends StatelessWidget {
  const CostPerEmployeeChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custo por Setor',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distribuição de custos mensais',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {
                    // Ações futuras
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Gráfico de Pizza
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  // Gráfico
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: _buildPieChartSections(colorScheme),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // Interação futura
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Legenda lateral
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPieLegendItem(
                          context,
                          'Produção',
                          'R\$ 12.450',
                          '35%',
                          const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 16),
                        _buildPieLegendItem(
                          context,
                          'Manutenção',
                          'R\$ 8.920',
                          '25%',
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 16),
                        _buildPieLegendItem(
                          context,
                          'Logística',
                          'R\$ 7.136',
                          '20%',
                          const Color(0xFFFFC107),
                        ),
                        const SizedBox(height: 16),
                        _buildPieLegendItem(
                          context,
                          'Qualidade',
                          'R\$ 5.352',
                          '15%',
                          const Color(0xFFFF5722),
                        ),
                        const SizedBox(height: 16),
                        _buildPieLegendItem(
                          context,
                          'Outros',
                          'R\$ 1.784',
                          '5%',
                          const Color(0xFF9E9E9E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custo Total Mensal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'R\$ 35.642,00',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(ColorScheme colorScheme) {
    return [
      PieChartSectionData(
        color: const Color(0xFF2196F3),
        value: 35,
        title: '35%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF4CAF50),
        value: 25,
        title: '25%',
        radius: 75,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFFFC107),
        value: 20,
        title: '20%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFFF5722),
        value: 15,
        title: '15%',
        radius: 65,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF9E9E9E),
        value: 5,
        title: '5%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildPieLegendItem(
    BuildContext context,
    String label,
    String value,
    String percentage,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
