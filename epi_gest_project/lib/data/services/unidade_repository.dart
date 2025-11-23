import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/unidade_model.dart';

class UnidadeRepository extends BaseRepository<UnidadeModel> {
  UnidadeRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseId); 
      
  @override
  String get tableId => 'unidade'; 

  @override
  UnidadeModel fromMap(Map<String, dynamic> map) {
    return UnidadeModel.fromMap(map);
  }

  Future<List<UnidadeModel>> getAllUnidades() async {
    return await getAll([]);
  }
}