# 🧩 Modelos de Domínio

Todos os modelos herdam de `AppWriteModel`, que fornece campos base gerados pelo Appwrite.

## Classe Base: `AppWriteModel`

```dart
class AppWriteModel {
  final String? id;        // $id do documento Appwrite
  final String? createdAt; // $createdAt
  final String? updatedAt; // $updatedAt

  Map<String, dynamic> toMap(); // Sobrescrito em cada subclasse
}
```

---

## Módulo: EPIs e Estoque

### `EpiModel`
Representa um EPI cadastrado no sistema.

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String?` | ID único (Appwrite) |
| `ca` | `String` | Número do Certificado de Aprovação |
| `nomeProduto` | `String` | Nome do EPI |
| `validadeCa` | `DateTime` | Data de vencimento do CA |
| `periodicidade` | `int` | Dias entre trocas obrigatórias |
| `estoque` | `double` | Quantidade em estoque |
| `valor` | `double` | Preço médio ponderado unitário |
| `marca` | `MarcasModel` | Marca do EPI (relação) |
| `categoria` | `CategoriaModel` | Categoria do EPI (relação) |
| `medida` | `MedidaModel` | Unidade de medida (relação) |
| `status` | `bool` | Ativo = `true` |

### `EntradasModel`
Cabeçalho de uma nota de entrada de EPIs em estoque.

| Campo | Tipo | Descrição |
|---|---|---|
| `nfReferente` | `String` | Número da Nota Fiscal |
| `fornecedorId` | `FornecedorModel` | Fornecedor (relação) |
| `entradasId` | `List<EntradasEpiModel>` | Itens da entrada |
| `dataEntrada` | `DateTime` | Data da entrada |

### `EntradasEpiModel`
Item individual de uma entrada, representando um EPI específico comprado.

| Campo | Tipo | Descrição |
|---|---|---|
| `epi` | `EpiModel` | EPI relacionado |
| `quantidade` | `double` | Quantidade adquirida |
| `valor` | `double` | Valor unitário de compra |

### `InventarioModel`
Snapshot de inventário para controle histórico.

---

## Módulo: Funcionários

### `FuncionarioModel`
Cadastro completo de um funcionário.

| Campo | Tipo | Descrição |
|---|---|---|
| `matricula` | `String` | Matrícula do funcionário |
| `nomeFunc` | `String` | Nome completo |
| `dataEntrada` | `DateTime` | Data de admissão |
| `email` | `String` | E-mail |
| `telefone` | `String` | Telefone |
| `turno` | `TurnoModel` | Turno de trabalho (relação) |
| `vinculo` | `VinculoModel` | Tipo de vínculo empregatício (relação) |
| `lider` | `String` | Nome do líder direto |
| `gestor` | `String` | Nome do gestor |
| `statusAtivo` | `bool` | Se o funcionário está ativo |
| `statusFerias` | `bool` | Se está em férias |
| `dataRetornoFerias` | `DateTime?` | Data prevista de retorno das férias |
| `dataDesligamento` | `DateTime?` | Data de desligamento |
| `motivoDesligamento` | `String?` | Motivo do desligamento |
| `imagemPath` | `String?` | URL da foto do funcionário |

### `MapeamentoFuncionarioModel`
Associa um funcionário a uma posição na estrutura organizacional (unidade + mapeamento de EPI).

| Campo | Tipo | Descrição |
|---|---|---|
| `funcionario` | `FuncionarioModel` | O funcionário |
| `mapeamento` | `MapeamentoEpiModel` | O mapeamento de EPIs do cargo/setor |
| `unidade` | `UnidadeModel` | A unidade onde trabalha |

---

## Módulo: Ficha de Entrega

### `FichaEntregaModel`
Ficha de entrega de EPIs para um funcionário.

| Campo | Tipo | Descrição |
|---|---|---|
| `mapeamentoFuncionario` | `MapeamentoFuncionarioModel` | Funcionário + posição |
| `fichaEpi` | `List<FichaEpiModel>` | Lista de EPIs entregues |
| `status` | `bool` | Ficha ativa = `true` |

### `FichaEpiModel`
Registro individual de entrega de um EPI específico.

---

## Módulo: Estrutura Organizacional

### `UnidadeModel`
Unidade de negócio (empresa, filial, matriz).

| Campo | Tipo | Descrição |
|---|---|---|
| `nomeUnidade` | `String` | Nome da unidade |
| `cnpj` | `String` | CNPJ |
| `endereco` | `String` | Endereço |
| `tipoUnidade` | `String` | Ex: Matriz, Filial |
| `status` | `bool` | Ativo = `true` |

### `SetorModel`
Setor dentro da empresa (ex: Produção, TI, Logística).

| Campo | Tipo | Descrição |
|---|---|---|
| `codigoSetor` | `String` | Código identificador |
| `nomeSetor` | `String` | Nome do setor |

### `CargoModel`
Cargo/função do funcionário.

| Campo | Tipo | Descrição |
|---|---|---|
| `codigoCargo` | `String` | Código do cargo |
| `nomeCargo` | `String` | Nome do cargo |

### `TurnoModel`
Turno de trabalho com horários.

| Campo | Tipo | Descrição |
|---|---|---|
| `turno` | `String` | Nome do turno (ex: Manhã) |
| `horaEntrada` | `String` | Hora de entrada |
| `horaSaida` | `String` | Hora de saída |
| `inicioAlmoco` | `String` | Início do intervalo |
| `fimAlomoco` | `String` | Fim do intervalo |

### `VinculoModel`
Tipo de vínculo empregatício (CLT, PJ, Estagiário, etc.).

| Campo | Tipo | Descrição |
|---|---|---|
| `nomeVinculo` | `String` | Nome do vínculo |

### `RiscosModel`
Risco ocupacional identificado para o mapeamento.

### `MapeamentoEpiModel`
Mapeamento que define quais EPIs são obrigatórios para um determinado cargo + setor.

| Campo | Tipo | Descrição |
|---|---|---|
| `nomeMapeamento` | `String` | Nome descritivo do mapeamento |
| `codigoMapeamento` | `String` | Código identificador |
| `cargo` | `CargoModel` | Cargo ao qual se aplica |
| `setor` | `SetorModel` | Setor ao qual se aplica |
| `riscos` | `List<RiscosModel>` | Riscos ocupacionais associados |
| `epis` | `List<EpiModel>` | EPIs obrigatórios para este mapeamento |

---

## Módulo: Cadastros Técnicos

### `CategoriaModel`
Categoria de EPI (ex: Proteção Auditiva, Proteção dos Olhos).

| Campo | Tipo | Descrição |
|---|---|---|
| `codigoCategoria` | `String` | Código da categoria |
| `nomeCategoria` | `String` | Nome da categoria |

### `MarcasModel`
Marca/fabricante do EPI.

| Campo | Tipo | Descrição |
|---|---|---|
| `nomeMarca` | `String` | Nome da marca |

### `MedidaModel`
Unidade de medida (par, unidade, kit, etc.).

| Campo | Tipo | Descrição |
|---|---|---|
| `nomeMedida` | `String` | Nome da medida |

### `FornecedorModel`
Fornecedor de EPIs.

| Campo | Tipo | Descrição |
|---|---|---|
| `cnpj` | `String` | CNPJ do fornecedor |
| `nomeFornecedor` | `String` | Razão social |
| `endereco` | `String` | Endereço |

### `ArmazemModel`
Local de armazenamento físico dos EPIs.

---

## Diagrama de Relacionamentos

```
UnidadeModel
    │
    └─── MapeamentoFuncionarioModel ──── FuncionarioModel
              │                               │
              │                          TurnoModel
              │                          VinculoModel
              │
         MapeamentoEpiModel
              │
         ┌───┴────────┐
      CargoModel   SetorModel
              │
    ┌─────────┴────────┐
 RiscosModel       EpiModel ─── MarcasModel
                       │    ─── CategoriaModel
                       │    ─── MedidaModel
                       │
               EntradasEpiModel ─── EntradasModel ─── FornecedorModel
                       │
               FichaEpiModel ──── FichaEntregaModel
```
