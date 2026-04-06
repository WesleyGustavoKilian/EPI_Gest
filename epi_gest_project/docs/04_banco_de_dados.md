# 🗄️ Banco de Dados — Appwrite

## Configuração do Projeto

| Propriedade | Valor |
|---|---|
| **Endpoint** | `https://nyc.cloud.appwrite.io/v1` |
| **Project ID** | `68ac56f3001bcef1296e` |
| **Database ID** | `691cc116001e1ed74089` |
| **Locale** | `pt_BR` |

O Appwrite é utilizado como **Backend as a Service (BaaS)**, fornecendo banco de dados, autenticação e storage na nuvem, sem necessidade de servidor próprio.

---

## Coleções (Tabelas)

Cada constante abaixo representa o ID de uma coleção no Appwrite. Todos estão centralizados em `AppwriteConstants`.

| Constante | Collection ID | Descrição |
|---|---|---|
| `databaseId` | `691cc116001e1ed74089` | ID do banco de dados principal |
| `databaseLocalTrabalho` | `localtrabalho` | Locais de trabalho (unidades) |
| `databaseSetor` | `setor` | Setores da empresa |
| `databaseCargo` | `cargo` | Cargos/funções |
| `databaseRiscos` | `riscos` | Riscos ocupacionais |
| `databaseCategoria` | `categoria` | Categorias de EPI |
| `databaseLocalArmazem` | `local_armazem` | Locais de armazenamento |
| `databaseFornecedor` | `fornecedor` | Fornecedores |
| `databaseMarcas` | `marcas` | Marcas/fabricantes |
| `databaseMedida` | `medida` | Unidades de medida |
| `databaseVinculo` | `vinculo` | Vínculos empregatícios |
| `databaseTurno` | `turno` | Turnos de trabalho |
| `databaseFuncionarios` | `funcionarios` | Cadastro de funcionários |
| `databaseEpi` | `epi` | Cadastro de EPIs |
| `databaseMapeamentoEpi` | `mapeamento_epi` | Mapeamento EPI × Cargo × Setor |
| `databaseFuncionarioEpi` | `funcionario_epi` | Associação Funcionário × Mapeamento |
| `databaseFichaEpi` | `ficha_epi` | Itens da ficha de entrega |
| `databaseFichaEntrega` | `ficha_entrega` | Cabeçalho da ficha de entrega |
| `databaseEntradas` | `entradas` | Cabeçalho de nota de entrada |
| `databaseEntradasEpi` | `entradas_epi` | Itens de entrada por EPI |

---

## Esquema das Coleções Principais

### `epi`
| Campo | Tipo | Descrição |
|---|---|---|
| `ca` | String | Certificado de Aprovação |
| `nome_produto` | String | Nome do EPI |
| `validade_ca` | DateTime (ISO 8601) | Validade do CA |
| `periodicidade` | Integer | Dias entre trocas |
| `estoque` | Double | Quantidade atual em estoque |
| `valor` | Double | Preço médio ponderado unitário |
| `marca_id` | Relationship | → `marcas` |
| `categoria_id` | Relationship | → `categoria` |
| `medida_id` | Relationship | → `medida` |
| `status` | Boolean | Ativo = `true` |

### `funcionarios`
| Campo | Tipo | Descrição |
|---|---|---|
| `matricula` | String | Matrícula |
| `nome_func` | String | Nome |
| `data_entrada` | DateTime | Data de admissão |
| `email` | String | E-mail |
| `telefone` | String | Telefone |
| `turno_id` | Relationship | → `turno` |
| `vinculo_id` | Relationship | → `vinculo` |
| `lider` | String | Nome do líder |
| `gestor` | String | Nome do gestor |
| `status_ativo` | Boolean | Funcionário ativo |
| `status_ferias` | Boolean | Em férias |
| `data_retorno_ferias` | DateTime? | Retorno das férias |
| `data_desligamento` | DateTime? | Data de desligamento |
| `motivo_desligamento` | String? | Motivo do desligamento |
| `urlImagem` | String? | URL da foto |

### `entradas`
| Campo | Tipo | Descrição |
|---|---|---|
| `nf_ref` | String | Número da Nota Fiscal |
| `fornecedor_id` | Relationship | → `fornecedor` |
| `entradas_epi_id` | Relationship (array) | → `entradas_epi` |
| `data_entrada` | DateTime | Data da nota |

### `entradas_epi`
| Campo | Tipo | Descrição |
|---|---|---|
| `epi_id` | Relationship | → `epi` |
| `quantidade` | Double | Quantidade comprada |
| `valor` | Double | Valor unitário de compra |

### `ficha_entrega`
| Campo | Tipo | Descrição |
|---|---|---|
| `mapeamento_funcionario_id` | Relationship | → `funcionario_epi` |
| `ficha_epi_id` | Relationship (array) | → `ficha_epi` |
| `status` | Boolean | Ficha ativa |

### `mapeamento_epi`
| Campo | Tipo | Descrição |
|---|---|---|
| `nome_mapeamento` | String | Nome do mapeamento |
| `codigo_mapeamento` | String | Código único |
| `cargo_id` | Relationship | → `cargo` |
| `setor_id` | Relationship | → `setor` |
| `riscos_id` | Relationship (array) | → `riscos` |
| `epi_id` | Relationship (array) | → `epi` |

---

## Padrão de Queries

O Appwrite SDK usado é `TablesDB` (versão das tabelas do Appwrite). As operações seguem o padrão:

```dart
// Listar com filtros e joins
await databases.listRows(
  databaseId: AppwriteConstants.databaseId,
  tableId: 'epi',
  queries: [
    Query.orderDesc('data_entrada'),
    Query.select(['*', 'marca_id.*', 'categoria_id.*', 'medida_id.*']),
  ],
);

// Criar registro
await databases.createRow(
  databaseId: AppwriteConstants.databaseId,
  tableId: 'epi',
  rowId: ID.unique(),
  data: epiModel.toMap(),
);

// Atualizar registro
await databases.updateRow(
  databaseId: AppwriteConstants.databaseId,
  tableId: 'epi',
  rowId: id,
  data: {'estoque': novoEstoque, 'valor': novoValor},
);

// Deletar registro
await databases.deleteRow(
  databaseId: AppwriteConstants.databaseId,
  tableId: 'epi',
  rowId: id,
);
```

### Joins (Relações)
O Appwrite permite buscar relações usando `Query.select()` com notação de ponto:

```dart
Query.select([
  '*',                      // Todos os campos do documento raiz
  'fornecedor_id.*',        // Todos os campos do fornecedor relacionado
  'entradas_epi_id.*',      // Todos os campos dos itens de entrada
  'entradas_epi_id.epi_id.*', // Campos do EPI de cada item
])
```

---

## Observações Importantes

> **Preço Médio Ponderado (PMP):** A lógica de atualização do estoque e valor unitário é gerenciada no `EntradasRepository`, que calcula o PMP a cada entrada e reverte matematicamente ao excluir uma entrada. Isso evita inconsistências de dados diretamente no banco.

> **IDs únicos:** Ao criar um documento, usa-se `ID.unique()` do SDK Appwrite para gerar um identificador UUID único automaticamente.

> **Relacionamentos com arrays:** Coleções como `ficha_epi_id` e `entradas_epi_id` armazenam arrays de IDs, que são salvos explicitamente como listas de strings antes de enviar ao banco.
