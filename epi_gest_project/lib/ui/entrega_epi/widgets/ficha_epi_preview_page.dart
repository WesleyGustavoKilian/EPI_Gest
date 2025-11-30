import 'dart:typed_data';

import 'package:epi_gest_project/domain/models/ficha_entrega_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/mapeamento_funcionario_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FichaEpiPreviewPage extends StatelessWidget {
  final MapeamentoFuncionarioModel mapFunc;
  final List<FichaEntregaModel> historico;

  const FichaEpiPreviewPage({
    super.key,
    required this.mapFunc,
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    // O nome do arquivo será usado ao salvar/compartilhar
    final fileName = 'Ficha_${mapFunc.funcionario.matricula}_${DateFormat('ddMMyyyy').format(DateTime.now())}.pdf';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Ficha de Entrega'),
      ),
      // PdfPreview é o widget mais estável para Windows/Web/Mobile
      body: PdfPreview(
        // Constrói o PDF sob demanda (resolve problemas de memória)
        build: (format) => _generatePdfContent(format),
        
        // Configurações de Funcionalidade
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false, // Bloqueia para manter layout A4
        canDebug: false, // Remove opções de debug
        
        // Configurações de Layout da Tela de Preview
        pdfFileName: fileName,
        maxPageWidth: 700, // Limita largura no Desktop para melhor leitura
        
        // Personalização da Interface de Carregamento
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando documento...'),
            ],
          ),
        ),
        
        // Tratamento de Erros de Renderização
        onError: (context, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Erro ao gerar PDF: $error'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GERAÇÃO DO CONTEÚDO (Mantida a lógica de negócio)
  // ==========================================
  Future<Uint8List> _generatePdfContent(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    // Preparação dos dados
    final List<Map<String, dynamic>> itemsTable = [];
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var entrega in historico) {
      if (!entrega.status) continue;

      for (var item in entrega.fichaEpi) {
        itemsTable.add({
          'data': dateFormat.format(entrega.createdAt != null
              ? DateTime.parse(entrega.createdAt!)
              : DateTime.now()),
          'ca': item.epi.ca,
          'descricao': item.epi.nomeProduto,
          'qtd': item.quantidade.toString(),
          'motivo': item.motivo, 
          'fabricante': item.epi.marca.nomeMarca,
        });
      }
    }

    // Carregamento de fontes seguras para evitar erros de renderização de texto
    final fontBase = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(2.0 * 72.0 / 25.4), // 2cm
        theme: pw.ThemeData.withFont(
          base: fontBase,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            _buildPdfCompanyHeader(),
            pw.SizedBox(height: 20),
            _buildPdfDocumentTitle(),
            pw.SizedBox(height: 20),
            _buildPdfEmployeeInfo(dateFormat),
            pw.SizedBox(height: 20),
            _buildPdfEPIList(itemsTable),
            pw.SizedBox(height: 20),
            _buildPdfTermoResponsabilidade(),
            pw.SizedBox(height: 40),
            _buildPdfSignatures(),
            pw.SizedBox(height: 20),
            _buildPdfFooter(itemsTable.length),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // --- Widgets PDF (Layout) ---

  pw.Widget _buildPdfCompanyHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text('EPI GEST - GESTÃO INTELIGENTE',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.SizedBox(height: 8),
          pw.Text('Departamento de Segurança do Trabalho',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDocumentTitle() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text('FICHA DE ENTREGA DE EPI',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
              textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 4),
          pw.Text('NR-6 - Equipamento de Proteção Individual',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfEmployeeInfo(DateFormat dateFormat) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('DADOS DO COLABORADOR',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(3)},
            children: [
              _buildPdfTableRow('Nome:', mapFunc.funcionario.nomeFunc),
              _buildPdfTableRow('Matrícula:', mapFunc.funcionario.matricula),
              _buildPdfTableRow('Cargo:', mapFunc.mapeamento.cargo.nomeCargo),
              _buildPdfTableRow('Setor:', mapFunc.mapeamento.setor.nomeSetor),
              _buildPdfTableRow('Admissão:', dateFormat.format(mapFunc.funcionario.dataEntrada)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfEPIList(List<Map<String, dynamic>> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(0.7),
        2: const pw.FlexColumnWidth(1.0),
        3: const pw.FlexColumnWidth(2.5),
        4: const pw.FlexColumnWidth(1.8),
        5: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
          children: [
            _buildPdfTableHeaderCell('Data'),
            _buildPdfTableHeaderCell('Qtd'),
            _buildPdfTableHeaderCell('CA'),
            _buildPdfTableHeaderCell('EPI'),
            _buildPdfTableHeaderCell('Motivo'),
            _buildPdfTableHeaderCell('Visto'),
          ],
        ),
        if (items.isEmpty)
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text("Nenhum registro encontrado.", style: const pw.TextStyle(fontSize: 9)),
            )
          ]),
        ...items.map((item) {
          return pw.TableRow(
            children: [
              _buildPdfTableCell(item['data']),
              _buildPdfTableCell(item['qtd']),
              _buildPdfTableCell(item['ca']),
              _buildPdfTableCell(item['descricao'], alignLeft: true),
              _buildPdfTableCell(item['motivo'] ?? '-', alignLeft: true),
              pw.Container(height: 20),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPdfTermoResponsabilidade() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Text(
        'Declaro ter recebido os EPIs descritos, em perfeitas condições de uso. Comprometo-me a utilizá-los apenas para as finalidades a que se destinam.',
        style: const pw.TextStyle(fontSize: 8),
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  pw.Widget _buildPdfSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: _buildPdfSignatureField('Assinatura do Colaborador')),
        pw.SizedBox(width: 40),
        pw.Expanded(child: _buildPdfSignatureField('Responsável pela Entrega')),
      ],
    );
  }

  pw.Widget _buildPdfFooter(int totalItems) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total de itens listados: $totalItems', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.Text('EPI Gest', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ],
        )
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 2), child: pw.Text(value, style: const pw.TextStyle(fontSize: 9))),
      ],
    );
  }

  pw.Widget _buildPdfTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool alignLeft = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8), textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center),
    );
  }

  pw.Widget _buildPdfSignatureField(String label) {
    return pw.Column(
      children: [
        pw.Container(height: 0.5, color: PdfColors.black, width: double.infinity),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
      ],
    );
  }
}