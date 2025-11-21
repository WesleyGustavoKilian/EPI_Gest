import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class MapeamentoFuncionarioModel extends AppWriteModel {
  final String funcionarioId;
  final String mapeamentoId;
  final String unidadeId;

  MapeamentoFuncionarioModel({
    super.id,
    required this.funcionarioId,
    required this.mapeamentoId,
    required this.unidadeId,
  });

  factory MapeamentoFuncionarioModel.fromMap(Map<String, dynamic> map) {
    return MapeamentoFuncionarioModel(
      id: map['\$id'],
      funcionarioId: map['funcionario_id'],
      mapeamentoId: map['mapeamento_id'],
      unidadeId: map['unidade_id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'funcionario_id': funcionarioId,
      'mapeamento_id': mapeamentoId,
      'unidade_id': unidadeId
    };
  }
}
