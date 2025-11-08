import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';

const String DATABASE_ID = '690e798d002b058839e3';
const String TABLE_ID = 'funcionarios';

class EmployeeService {
  final Client _client;
  final TablesDB _funcionario;
  final Storage _storage;

  EmployeeService(this._client)
    : _funcionario = TablesDB(_client),
      _storage = Storage(_client);

  Future<void> createEmployee(Employee employee) async {
    try {
      await _funcionario.createRow(
        databaseId: DATABASE_ID,
        rowId: '',
        tableId: TABLE_ID,
        data: employee.toJson(),
      );
    } on AppwriteException {
      throw Exception('Falha ao adicionar funcionário.');
    }
  }

  Future<List<Employee>> getActiveEmployees() async {
    try {
      final response = await _funcionario.listRows(
        databaseId: DATABASE_ID,
        tableId: TABLE_ID,
        queries: [Query.equal('ativo', true)],
      );
      return response.rows.map((row) => Employee.fromAppwrite(row)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar funcionários.');
    }
  }

  // Atualizar um funcionário existente
  Future<void> updateEmployee(String rowId, Map<String, dynamic> data) async {
    try {
      await _funcionario.updateRow(
        databaseId: DATABASE_ID,
        tableId: TABLE_ID,
        rowId: rowId,
        data: data,
      );
    } catch (e) {
      throw Exception('Falha ao atualizar funcionário.');
    }
  }

  // Inativar um funcionário (Soft Delete)
  Future<void> inactivateEmployee(String rowId) async {
    try {
      await updateEmployee(rowId, {
        'isActive': false,
        'terminationDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Falha ao inativar funcionário.');
    }
  }

  // Reativar um funcionário
  Future<void> activateEmployee(String rowId) async {
    try {
      await updateEmployee(rowId, {
        'isActive': true,
        'terminationDate': null,
        'terminationReason': null,
      });
    } catch (e) {
      throw Exception('Falha ao reativar funcionário.');
    }
  }
}
