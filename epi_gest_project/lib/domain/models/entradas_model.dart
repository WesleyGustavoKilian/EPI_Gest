import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class EntradasModel extends AppWriteModel {
  final String nfReferente;
  final String fornecedorId;
  final String epiId;
  final int quantidade;
  final double valor;

  EntradasModel({
    super.id,
    super.createdAt,
    required this.nfReferente,
    required this.fornecedorId,
    required this.epiId,
    required this.quantidade,
    required this.valor,
  });

  factory EntradasModel.fromMap(Map<String, dynamic> map) {
    return EntradasModel(
      id: map['\$id'],
      nfReferente: map['nf_ref'],
      fornecedorId: map['fornecedor_id'],
      epiId: map['epi_id'],
      quantidade: map['quantidade'],
      valor: map['valor'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nf_ref': nfReferente,
      'fornecedor_id': fornecedorId,
      'epi_id': epiId,
      'quantidade': quantidade,
      'valor': valor,
    };
  }
}
