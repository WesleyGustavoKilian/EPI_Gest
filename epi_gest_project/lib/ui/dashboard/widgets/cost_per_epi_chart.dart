import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'dart:convert';

class CostPerEpiChart extends StatefulWidget {
  const CostPerEpiChart({super.key});

  @override
  State<CostPerEpiChart> createState() => _CostPerEpiChartState();
}

class _CostPerEpiChartState extends State<CostPerEpiChart> {
  bool _showValues = true;
  bool _sortedByValue = true;
  List<Map<String, dynamic>> _epiData = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _epiData = [
      {
        'epi': 'Capacete',
        'custo': 18300,
        'cor': Colors.blue.shade700,
        'quantidade': 150,
        'custoUnitario': 122.00,
      },
      {
        'epi': 'Botas',
        'custo': 12500,
        'cor': Colors.green.shade700,
        'quantidade': 200,
        'custoUnitario': 62.50,
      },
      {
        'epi': 'Luvas',
        'custo': 8500,
        'cor': Colors.orange.shade700,
        'quantidade': 500,
        'custoUnitario': 17.00,
      },
      {
        'epi': 'Óculos',
        'custo': 6200,
        'cor': Colors.purple.shade700,
        'quantidade': 310,
        'custoUnitario': 20.00,
      },
      {
        'epi': 'Prot. Auditivo',
        'custo': 4500,
        'cor': Colors.red.shade700,
        'quantidade': 180,
        'custoUnitario': 25.00,
      },
    ];
    _sortDataByValue();
  }

  void _sortDataByValue() {
    setState(() {
      _epiData.sort((a, b) => b['custo'].compareTo(a['custo']));
      _sortedByValue = true;
    });
  }

  void _sortDataByName() {
    setState(() {
      _epiData.sort((a, b) => a['epi'].compareTo(b['epi']));
      _sortedByValue = false;
    });
  }

  void _toggleValues() {
    setState(() {
      _showValues = !_showValues;
    });
  }

  // ========== ANÁLISE DETALHADA COMPLETA ==========
  void _showDetailedAnalysis() {
    final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalysisSheet(totalGeral),
    );
  }

  Widget _buildAnalysisSheet(int totalGeral) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header melhorado
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análise Detalhada - Custos de EPI',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visão completa dos investimentos em equipamentos de proteção',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo Geral Melhorado
                  _buildEnhancedSummaryCard(theme, colorScheme, totalGeral),
                  
                  const SizedBox(height: 24),
                  
                  // Tabela Detalhada
                  _buildDetailedTable(theme, colorScheme, totalGeral),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    final maiorCusto = _epiData.first;
    final menorCusto = _epiData.last;
    final mediaCusto = _epiData.fold(0.0, (sum, epi) => sum + (epi['custo'] as int)) / _epiData.length;
    final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do card
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumo Executivo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Métricas principais
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Total Investido',
                    _formatarReal(totalGeral),
                    Icons.attach_money,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Itens Analisados',
                    '${_epiData.length}',
                    Icons.inventory_2,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Destaques
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destaques',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightItem(
                    '🎯 Maior Investimento',
                    '${maiorCusto['epi']} - ${_formatarReal(maiorCusto['custo'])} (${percentualMaiorCusto.toStringAsFixed(1)}% do total)',
                    colorScheme.primary,
                  ),
                  _buildHighlightItem(
                    '📊 Média por Item',
                    _formatarReal(mediaCusto.toInt()),
                    Colors.blue,
                  ),
                  _buildHighlightItem(
                    '💰 Custo Unitário Mais Alto',
                    'Capacete - R\$${maiorCusto['custoUnitario']}',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String title, String value, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTable(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalhamento por Item',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 60,
                headingRowColor: MaterialStateProperty.all(
                  colorScheme.primaryContainer.withOpacity(0.1),
                ),
                columns: [
                  DataColumn(
                    label: Text('EPI', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Custo Total', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Quantidade', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Custo Unit.', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('% do Total', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ],
                rows: _epiData.map((epi) {
                  final percentage = (epi['custo'] / totalGeral * 100);
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: epi['cor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(epi['epi']),
                          ],
                        ),
                      ),
                      DataCell(Text(_formatarReal(epi['custo']))),
                      DataCell(Text(epi['quantidade'].toString())),
                      DataCell(Text('R\$${epi['custoUnitario'].toStringAsFixed(2)}')),
                      DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== EXPORT PDF - MELHORADO ==========
  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final totalGeral = _epiData.fold(
        0,
        (sum, epi) => sum + (epi['custo'] as int),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: await _getPdfFont()),
          build: (pw.Context context) {
            return [
              // Cabeçalho moderno
              _buildPdfHeader(totalGeral),
              pw.SizedBox(height: 20),

              // Cards de resumo
              _buildPdfSummaryCards(totalGeral),
              pw.SizedBox(height: 25),

              // Tabela melhorada
              _buildPdfTable(totalGeral),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_epi_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

      _showSnackBar('PDF exportado com sucesso!', Colors.green);
    } catch (e) {
      _showSnackBar('Erro ao exportar PDF: $e', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  pw.Widget _buildPdfHeader(int totalGeral) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: pw.EdgeInsets.all(25),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório de Custos de EPI',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Análise detalhada dos investimentos em equipamentos de proteção individual',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Gerado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} às ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              _formatarReal(totalGeral),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryCards(int totalGeral) {
    final maiorCusto = _epiData.first;
    final menorCusto = _epiData.last;

    return pw.Row(
      children: [
        _buildPdfSummaryCard(
          'Total Investido',
          _formatarReal(totalGeral),
          PdfColors.blue700,
          Icons.attach_money,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Itens Analisados',
          '${_epiData.length} tipos',
          PdfColors.green700,
          Icons.inventory_2,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Maior Custo',
          '${maiorCusto['epi']}',
          PdfColors.orange700,
          Icons.trending_up,
        ),
      ],
    );
  }

  pw.Widget _buildPdfSummaryCard(
    String title,
    String value,
    PdfColor color,
    IconData icon,
  ) {
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        padding: pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTable(int totalGeral) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalhamento por Item',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: [
            'EPI',
            'Custo Total',
            'Quantidade',
            'Custo Unitário',
            '% do Total',
          ],
          data: _epiData.map((epi) {
            final percentage = (epi['custo'] / totalGeral * 100);
            return [
              epi['epi'],
              _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
              epi['quantidade'].toString(),
              'R\$${(epi['custoUnitario'] as double).toStringAsFixed(2)}',
              '${percentage.toStringAsFixed(1)}%',
            ];
          }).toList(),
          border: pw.TableBorder(
            left: pw.BorderSide(color: PdfColors.grey300),
            top: pw.BorderSide(color: PdfColors.grey300),
            right: pw.BorderSide(color: PdfColors.grey300),
            bottom: pw.BorderSide(color: PdfColors.grey300),
            horizontalInside: pw.BorderSide(color: PdfColors.grey300),
            verticalInside: pw.BorderSide(color: PdfColors.grey300),
          ),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellStyle: pw.TextStyle(fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.center,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.center,
          },
          rowDecoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100)),
          ),
        ),
      ],
    );
  }

  Future<pw.Font> _getPdfFont() async {
    return pw.Font.courier();
  }

  // ========== EXPORT EXCEL SEM ACENTOS ==========
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));

      List<List<dynamic>> csvData = [];

      // Cabeçalho SEM ACENTOS
      csvData.add(['RELATORIO DE CUSTOS DE EPI']);
      csvData.add(['Gerado em:', '${DateTime.now().toString().split(' ')[0]}']);
      csvData.add([]);
      csvData.add(['RESUMO GERAL']);
      csvData.add(['Total Investido:', '${_formatarReal(totalGeral)}']);
      csvData.add(['Quantidade de Itens:', '${_epiData.length} tipos']);
      csvData.add([]);

      // Tabela detalhada SEM ACENTOS
      csvData.add(['DETALHAMENTO POR ITEM']);
      csvData.add(['EPI', 'Custo Total (R\$)', 'Quantidade', 'Custo Unitario (R\$)', '% do Total']);

      for (var epi in _epiData) {
        final percentage = (epi['custo'] / totalGeral * 100);
        csvData.add([
          epi['epi'],
          _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
          epi['quantidade'].toString(),
          (epi['custoUnitario'] as double).toStringAsFixed(2),
          '${percentage.toStringAsFixed(1)}%',
        ]);
      }

      csvData.add([]);
      csvData.add(['ANALISE E INSIGHTS']);

      final maiorCusto = _epiData.first;
      final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);

      csvData.add(['Maior Investimento:', '${maiorCusto['epi']} (${percentualMaiorCusto.toStringAsFixed(1)}%)']);
      csvData.add(['Custo Unitario Mais Alto:', 'Capacete - R\$${maiorCusto['custoUnitario']}']);
      csvData.add(['Recomendacao:', 'Avaliar compra em maior quantidade para reducao de custos']);

      String csv = const ListToCsvConverter().convert(csvData);

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/relatorio_epi_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await OpenFile.open(file.path);

      _showSnackBar('Excel/CSV exportado com sucesso!', Colors.green);
    } catch (e) {
      _showSnackBar('Erro ao exportar Excel: $e', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // ========== MENU TRADICIONAL ==========
  void _showMenuActions() {
    if (_isExporting) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'export_pdf',
          child: Row(
            children: [
              _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 20),
              const SizedBox(width: 8),
              const Text('Exportar para PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'export_excel',
          child: Row(
            children: [
              _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart, size: 20),
              const SizedBox(width: 8),
              const Text('Exportar para Excel'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Divider(height: 1),
        ),
        PopupMenuItem(
          value: 'toggle_values',
          child: Row(
            children: [
              Icon(_showValues ? Icons.visibility_off : Icons.visibility, size: 20),
              const SizedBox(width: 8),
              Text(_showValues ? 'Ocultar Valores' : 'Mostrar Valores'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort',
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 8),
              Text(_sortedByValue ? 'Ordenar por Nome' : 'Ordenar por Valor'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Divider(height: 1),
        ),
        PopupMenuItem(
          value: 'analysis',
          child: Row(
            children: [
              const Icon(Icons.analytics, size: 20),
              const SizedBox(width: 8),
              const Text('Análise Detalhada'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_pdf':
        _exportToPdf();
        break;
      case 'export_excel':
        _exportToExcel();
        break;
      case 'toggle_values':
        _toggleValues();
        break;
      case 'sort':
        if (_sortedByValue) {
          _sortDataByName();
        } else {
          _sortDataByValue();
        }
        break;
      case 'analysis':
        _showDetailedAnalysis();
        break;
    }
  }

  // ========== INTERFACE PRINCIPAL ==========
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildMainContent(theme, colorScheme);
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));
    final double maxCost = 20000;

    return Stack(
      children: [
        Card(
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
                          'Custos por Tipo de EPI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distribuição de custos por item',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: _isExporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.more_vert_rounded),
                      onPressed: _isExporting ? null : _showMenuActions,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Gráfico de Barras SEM tooltips e SEM ícones
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      // Gráfico principal
                      BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxCost * 1.15,
                          // TOOLTIPS DESATIVADOS
                          barTouchData: BarTouchData(
                            enabled: false,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 0 && value < _epiData.length) {
                                    final epi = _epiData[value.toInt()];
                                    // SEM ÍCONES - SÓ TEXTO
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 4,
                                      child: Text(
                                        epi['epi'],
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 5000,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5000 == 0) {
                                    // VALORES EM REAIS COMPLETOS (SEM K)
                                    return Text(
                                      _formatarReal(value.toInt()),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 5000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorScheme.outlineVariant.withAlpha(50),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: colorScheme.outlineVariant.withAlpha(80),
                              width: 1,
                            ),
                          ),
                          barGroups: _epiData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: data['custo'].toDouble(),
                                  color: data['cor'],
                                  width: 32,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      // Valores em cima das colunas
                      if (_showValues)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double chartWidth = constraints.maxWidth;
                              final double chartHeight = constraints.maxHeight;
                              final double barWidth = 32.0;
                              final double spaceBetweenBars = (chartWidth - (_epiData.length * barWidth)) / (_epiData.length + 1);

                              return Stack(
                                children: _epiData.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;
                                  
                                  final double xPosition = spaceBetweenBars + (index * (barWidth + spaceBetweenBars)) + (barWidth / 2);
                                  final double yPosition = chartHeight - ((data['custo'] / maxCost) * chartHeight * 0.85) - 25;

                                  return Positioned(
                                    left: xPosition - 30,
                                    top: yPosition,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: colorScheme.outlineVariant.withAlpha(80),
                                        ),
                                      ),
                                      child: Text(
                                        _formatarReal(data['custo']),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Total geral
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Investido:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatarReal(totalGeral),
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
        ),

        // Overlay de carregamento
        if (_isExporting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Exportando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Função para formatar em Real brasileiro COMPLETO (sem K)
  String _formatarReal(int valor) {
    return 'R\$${valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )},00';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}