import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/ficha_epi_model.dart';

class FichaEpiRepository extends BaseRepository<FichaEpiModel> {
  FichaEpiRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseFichaEpi);

  @override
  FichaEpiModel fromMap(Map<String, dynamic> map) {
    return FichaEpiModel.fromMap(map);
  }

  Future<List<FichaEpiModel>> getItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    try {
      return await getAll([
        Query.equal('\$id', ids),
        Query.select(['*', 'epi_id.*']),
      ]);
    } catch (e) {
      throw Exception('Erro ao buscar itens da ficha: $e');
    }
  }
}