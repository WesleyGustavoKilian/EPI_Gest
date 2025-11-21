import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class FichaEpiModel extends AppWriteModel {
  final String mapeamentoFuncionarioId;
  final String epiId;
  final DateTime validadeEpi;
  final bool status;

  FichaEpiModel({
    super.id,
    required this.mapeamentoFuncionarioId,
    required this.epiId,
    required this.validadeEpi,
    required this.status,
  });

  factory FichaEpiModel.fromMap(Map<String, dynamic> map) {
    return FichaEpiModel(
      id: map['\$id'],
      mapeamentoFuncionarioId: map['mapeamentoFuncionario_id'],
      epiId: map['epi_id'],
      validadeEpi: map['validade_epi'],
      status: map['status'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapeamentoFuncionario_id': mapeamentoFuncionarioId,
      'epi_id': epiId,
      'validade_epi': validadeEpi,
      'status': status,
    };
  }
}
