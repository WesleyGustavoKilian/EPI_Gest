import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class InventarioModel extends AppWriteModel {
  final String epiId;
  final int quantidade;

  InventarioModel({
    super.id,
    super.createdAt,
    required this.epiId,
    required this.quantidade,
  });

  factory InventarioModel.fromMap(Map<String, dynamic> map) {
    return InventarioModel(
      id: map['\$id'],
      createdAt: map['\$createdAt'],
      epiId: map['epi_id'],
      quantidade: map['quantidade'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'epi_id': epiId,
      'quantidade': quantidade
    };
  }
}
