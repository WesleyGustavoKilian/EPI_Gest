import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/categoria_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/marcas_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/medida_model.dart';

class FichaEpiModel extends AppWriteModel {
  final EpiModel epi;
  final DateTime validadeEpi;
  final double valor;
  final int quantidade;
  final String motivo;

  FichaEpiModel({
    super.id,
    required this.epi,
    required this.validadeEpi,
    required this.valor,
    required this.quantidade,
    required this.motivo
  });

  factory FichaEpiModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final epiData = getData(map['epi_id']);

    final epiObj = epiData != null
        ? EpiModel.fromMap(epiData)
        : EpiModel(
            ca: '',
            nomeProduto: '',
            validadeCa: DateTime.now(),
            periodicidade: 0,
            estoque: 0,
            valor: 0,
            marca: MarcasModel(nomeMarca: ''),
            categoria: CategoriaModel(codigoCategoria: '', nomeCategoria: ''),
            medida: MedidaModel(nomeMedida: ''),
          );

    return FichaEpiModel(
      id: map['\$id'],
      epi: epiObj,
      validadeEpi: DateTime.parse(map['data_validade']),
      valor: map['valor'],
      quantidade: map['quantidade'],
      motivo: map['motivo']
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'epi_id': epi.id,
      'data_validade': validadeEpi.toIso8601String(),
      'valor': valor,
      'quantidade': quantidade,
      'motivo': motivo,
    };
  }
}
