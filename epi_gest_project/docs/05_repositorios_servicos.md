# 🔧 Repositórios e Serviços

## BaseRepository — Repositório Genérico

Localizado em `lib/data/services/base_repository.dart`, é a classe abstrata que centraliza todas as operações CRUD do Appwrite.

```dart
abstract class BaseRepository<T extends AppWriteModel> {
  final TablesDB databases;
  final String tableId;

  T fromMap(Map<String, dynamic> map); // Implementado por cada subclasse

  Future<List<T>> getAll(List<String> queries)
  Future<T> get(String id, List<String> queries)
  Future<T> create(T item)
  Future<T> update(String id, Map<String, dynamic> item)
  Future<void> delete(String id)
}
```

Todos os repositórios estendem `BaseRepository<T>`, onde `T` é o modelo da entidade correspondente. Isso elimina repetição de código e padroniza o tratamento de erros (todos os erros Appwrite são capturados e relançados como `Exception` com mensagem descritiva).

---

## Repositórios Simples (CRUD Básico)

Esses repositórios apenas estendem `BaseRepository` e implementam o `fromMap()`, sem lógica adicional:

| Repositório | Modelo | Collection ID |
|---|---|---|
| `CargoRepository` | `CargoModel` | `cargo` |
| `SetorRepository` | `SetorModel` | `setor` |
| `TurnoRepository` | `TurnoModel` | `turno` |
| `VinculoRepository` | `VinculoModel` | `vinculo` |
| `RiscosRepository` | `RiscosModel` | `riscos` |
| `UnidadeRepository` | `UnidadeModel` | `localtrabalho` |
| `CategoriaRepository` | `CategoriaModel` | `categoria` |
| `MarcasRepository` | `MarcasModel` | `marcas` |
| `MedidaRepository` | `MedidaModel` | `medida` |
| `FornecedorRepository` | `FornecedorModel` | `fornecedor` |
| `ArmazemRepository` | `ArmazemModel` | `local_armazem` |
| `FichaEpiRepository` | `FichaEpiModel` | `ficha_epi` |
| `EntradasEpiRepository` | `EntradasEpiModel` | `entradas_epi` |

---

## Repositórios com Lógica de Negócio

### `EpiRepository`
Gerencia o cadastro de EPIs, incluindo atualização de estoque e valor.

**Métodos especializados:**
```dart
// Busca todos os EPIs com seus relacionamentos expandidos
Future<List<EpiModel>> getAllEpis()

// Busca EPIs com filtro de status e joins
Future<List<EpiModel>> getEpisByStatus(bool status)

// Atualiza estoque e valor médio ponderado após entrada/saída
Future<void> updateEstoqueEValor(String id, double novoEstoque, double novoValor)
```

**Queries usadas:**
```dart
Query.select(['*', 'marca_id.*', 'categoria_id.*', 'medida_id.*'])
```

---

### `EntradasRepository`
O repositório mais complexo do sistema — gerencia notas de entrada com **atualização automática de estoque** e **cálculo de Preço Médio Ponderado (PMP)**.

**Dependências:** `EpiRepository`, `EntradasEpiRepository`

**Método `registrarEntradaCompleta()`**

Fluxo ao registrar uma entrada:
1. Para cada item da entrada:
   - Busca o EPI atual (estoque + valor)
   - Calcula o novo PMP: `(estoqueAtual × valorAtual + qtdEntrada × valorCompra) / (estoqueAtual + qtdEntrada)`
   - Salva o item de entrada (`EntradasEpiModel`)
   - Atualiza estoque + valor do EPI
2. Salva o cabeçalho da nota de entrada (`EntradasModel`) com os IDs dos itens

**Método `excluirEntrada()`**

Fluxo ao excluir uma entrada (reversão do PMP):
1. Busca a entrada completa com todos os itens
2. Para cada item:
   - Calcula o PMP reverso:
     ```
     novoValorTotal = valorTotalAtual - (qtdEntrada × valorCompraÉpoca)
     novoEstoque = estoqueAtual - qtdEntrada
     novoValorUnitario = novoValorTotal / novoEstoque
     ```
   - Atualiza estoque + valor do EPI
   - Deleta o item de entrada
3. Deleta o cabeçalho da entrada

> ⚠️ **Observação:** Se o novo estoque for negativo, é zerado para 0 (proteção contra inconsistências). Se o valor total revertido for negativo, também é zerado.

---

### `FuncionarioRepository`
Gerencia o cadastro de funcionários com queries para status ativo/férias/desligado.

**Queries usadas:**
```dart
Query.select(['*', 'turno_id.*', 'vinculo_id.*'])
Query.equal('status_ativo', true)
```

---

### `MapeamentoFuncionarioRepository`
Associa funcionários ao seu cargo/setor (mapeamento de EPIs).

**Queries usadas:**
```dart
Query.select([
  '*',
  'funcionario_id.*',
  'funcionario_id.turno_id.*',
  'funcionario_id.vinculo_id.*',
  'mapeamento_epi_id.*',
  'mapeamento_epi_id.cargo_id.*',
  'mapeamento_epi_id.setor_id.*',
  'mapeamento_epi_id.riscos_id.*',
  'mapeamento_epi_id.epi_id.*',
  'unidade_id.*',
])
```

---

### `MapeamentoEpiRepository`
Gerencia o mapeamento de EPIs obrigatórios por cargo + setor.

**Queries usadas:**
```dart
Query.select([
  '*',
  'cargo_id.*',
  'setor_id.*',
  'riscos_id.*',
  'epi_id.*',
  'epi_id.marca_id.*',
  'epi_id.categoria_id.*',
  'epi_id.medida_id.*',
])
```

---

### `FichaEntregaRepository`
Gerencia as fichas de entrega individuais dos funcionários.

**Dependências:** `FichaEpiRepository`, `EpiRepository`

**Responsabilidades:**
- Criar uma ficha de entrega associando os EPIs ao funcionário
- Atualizar o estoque de EPIs ao registrar uma entrega (debitar do estoque)
- Registrar data e status de cada entrega

---

## Como os Repositórios São Injetados

Toda a injeção de dependência ocorre em `main.dart` via `MultiProvider`:

```dart
MultiProvider(
  providers: [
    // Simples
    Provider<EpiRepository>(create: (_) => EpiRepository(databases)),

    // Com dependência (ProxyProvider)
    Provider<EntradasEpiRepository>(create: (_) => EntradasEpiRepository(databases)),
    ProxyProvider2<EpiRepository, EntradasEpiRepository, EntradasRepository>(
      update: (_, epiRepo, entradasEpiRepo, __) =>
          EntradasRepository(databases, epiRepo, entradasEpiRepo),
    ),
  ],
  child: MyApp(),
)
```

Na UI, os repositórios são acessados assim:
```dart
// Leitura sem rebuild
final epiRepo = context.read<EpiRepository>();

// Com rebuild automático (mais raro, pois repositórios são stateless)
final epiRepo = context.watch<EpiRepository>();
```

---

## Tratamento de Erros

Todos os métodos do `BaseRepository` e repositórios especializados envolvem chamadas ao Appwrite em blocos `try/catch`:

```dart
try {
  // operação Appwrite
} on AppwriteException catch (e) {
  throw Exception('Mensagem descritiva: $e');
}
```

Os erros são propagados para a camada de UI, que pode exibir `SnackBars` ou diálogos de erro ao usuário.
