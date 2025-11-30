import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/ficha_epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/cargo_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/mapeamento_funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/setor_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/turno_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/unidade_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/vinculo_model.dart';

class FichaEntregaModel extends AppWriteModel {
  final MapeamentoFuncionarioModel mapeamentoFuncionario;
  final List<FichaEpiModel> fichaEpi;
  final bool status;

  FichaEntregaModel({
    super.id,
    required this.mapeamentoFuncionario,
    required this.fichaEpi,
    this.status = true,
  });

  factory FichaEntregaModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final mapeamentoFunciData = getData(map['mapeamento_funcionario_id']);

    final mapeamentoFuncObj = mapeamentoFunciData != null
        ? MapeamentoFuncionarioModel.fromMap(mapeamentoFunciData)
        : MapeamentoFuncionarioModel(
            funcionario: FuncionarioModel(
              matricula: '',
              nomeFunc: '',
              dataEntrada: DateTime.now(),
              telefone: '',
              email: '',
              turno: TurnoModel(
                turno: '',
                horaEntrada: '',
                horaSaida: '',
                inicioAlmoco: '',
                fimAlomoco: '',
              ),
              vinculo: VinculoModel(nomeVinculo: ''),
              lider: '',
              gestor: '',
              statusAtivo: false,
              statusFerias: false,
            ),
            mapeamento: MapeamentoEpiModel(
              nomeMapeamento: '',
              codigoMapeamento: '',
              cargo: CargoModel(codigoCargo: '', nomeCargo: ''),
              setor: SetorModel(codigoSetor: '', nomeSetor: ''),
              riscos: List.empty(),
              epis: List.empty(),
            ),
            unidade: UnidadeModel(
              nomeUnidade: '',
              cnpj: '',
              endereco: '',
              tipoUnidade: '',
              status: false,
            ),
          );

    List<FichaEpiModel> parseFichaEpis(dynamic data) {
      if (data == null || data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => FichaEpiModel.fromMap(item))
          .toList();
    }

    return FichaEntregaModel(
      id: map['\$id'],
      mapeamentoFuncionario: mapeamentoFuncObj,
      fichaEpi: parseFichaEpis(map['ficha_epi_id']),
      status: map['status'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapeamento_funcionario_id': mapeamentoFuncionario.id,
      'ficha_epi_id': fichaEpi
          .map((epi) => epi.id)
          .where((id) => id != null && id.isNotEmpty)
          .toList(),
      'status': status,
    };
  }
}
