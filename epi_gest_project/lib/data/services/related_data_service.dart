// lib/data/services/related_data_service.dart

import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/domain/models/related_data_model.dart';

const String DATABASE_ID = '690e798d002b058839e3';
const String TABLE_ID = 'funcionarios';

class RelatedDataService {
  final TablesDB _relatedData;

  RelatedDataService(Client client) : _relatedData = TablesDB(client);

  // Método genérico para buscar todos os itens de uma coleção
  Future<List<RelatedData>> getAll(String collectionId) async {
    try {
      final response = await _relatedData.listRows(
        databaseId: DATABASE_ID,
        tableId: TABLE_ID,
        queries: [Query.limit(100)], // Aumente o limite se necessário
      );
      return response.rows.map((doc) => RelatedData.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar dados da coleção $collectionId: $e');
    }
  }
}
