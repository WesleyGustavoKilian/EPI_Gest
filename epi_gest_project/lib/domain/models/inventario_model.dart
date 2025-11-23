import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';

class InventarioModel extends AppWriteModel {
  final List<EpiModel> epi;
  final int quantidade;

  InventarioModel({
    super.id,
    super.createdAt,
    required this.epi,
    required this.quantidade,
  });

  factory InventarioModel.fromMap(Map<String, dynamic> map) {
    List<EpiModel> parseEpis(dynamic data) {
      if (data == null || data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => EpiModel.fromMap(item))
          .toList();
    }

    return InventarioModel(
      id: map['\$id'],
      createdAt: map['\$createdAt'],
      epi: parseEpis(map['epi_id']),
      quantidade: map['quantidade'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'epi_id': epi
          .map((epi) => epi.id)
          .where((id) => id != null && id.isNotEmpty)
          .toList(),
      'quantidade': quantidade,
    };
  }
}
