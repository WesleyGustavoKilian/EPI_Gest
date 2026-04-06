# 🏗️ Arquitetura do Projeto

## Visão Geral

O EPI Gest adota uma arquitetura baseada em **camadas** (Layered Architecture), inspirada nos princípios da **Clean Architecture**, adaptada ao contexto de um aplicativo Flutter de médio porte. A separação de responsabilidades garante manutenibilidade, testabilidade e escalabilidade.

---

## Estrutura de Diretórios

```
lib/
├── main.dart                    # Ponto de entrada — inicialização e injeção de dependências
│
├── config/                      # Configurações globais da aplicação
│   └── theme_notifier.dart      # Gerenciamento de tema (claro/escuro/sistema)
│
├── core/                        # Recursos centrais e compartilhados
│   └── constants/
│       └── appwrite_constants.dart  # IDs de coleções do Appwrite
│
├── domain/                      # Camada de Domínio (entidades e modelos)
│   └── models/
│       ├── appwrite_model.dart           # Classe base para todos os modelos
│       ├── epi_model.dart                # Entidade EPI
│       ├── ficha_entrega_model.dart      # Ficha de entrega de EPI
│       ├── ficha_epi_model.dart          # Item da ficha de EPI
│       ├── entradas_model.dart           # Nota de entrada de EPIs
│       ├── entradas_epi_model.dart       # Item de entrada de EPI
│       ├── inventario_model.dart         # Inventário
│       ├── funcionarios/                 # Modelos de funcionários
│       │   ├── funcionario_model.dart
│       │   └── mapeamento_funcionario_model.dart
│       ├── organizational_structure/     # Modelos da estrutura organizacional
│       │   ├── cargo_model.dart
│       │   ├── setor_model.dart
│       │   ├── unidade_model.dart
│       │   ├── turno_model.dart
│       │   ├── vinculo_model.dart
│       │   ├── riscos_model.dart
│       │   └── mapeamento_epi_model.dart
│       ├── product_technical_registration/  # Modelos de cadastros técnicos
│       │   ├── categoria_model.dart
│       │   ├── marcas_model.dart
│       │   ├── medida_model.dart
│       │   ├── fornecedor_model.dart
│       │   └── armazem_model.dart
│       ├── filters/                      # Modelos de filtro/busca
│       └── report/                       # Modelos de relatórios
│
├── data/                        # Camada de Dados (repositórios/serviços)
│   └── services/
│       ├── base_repository.dart              # Repositório genérico base (CRUD)
│       ├── epi_repository.dart               # Repositório de EPIs
│       ├── entradas_repository.dart          # Repositório de entradas (com lógica de preço médio)
│       ├── entradas_epi_repository.dart      # Repositório de itens de entrada
│       ├── ficha_entrega_repository.dart     # Repositório de fichas de entrega
│       ├── funcionarios/
│       │   ├── funcionario_repository.dart
│       │   ├── ficha_epi_repository.dart
│       │   └── mapeamento_funcionario_repository.dart
│       ├── organizational_structure/
│       │   ├── cargo_repository.dart
│       │   ├── setor_repository.dart
│       │   ├── unidade_repository.dart
│       │   ├── turno_repository.dart
│       │   ├── vinculo_repository.dart
│       │   ├── riscos_repository.dart
│       │   └── mapeamento_epi_repository.dart
│       └── product_technical_registration/
│           ├── categoria_repository.dart
│           ├── marcas_repository.dart
│           ├── medida_repository.dart
│           ├── fornecedor_repository.dart
│           └── armazem_repository.dart
│
├── ui/                          # Camada de Apresentação (telas e widgets)
│   ├── home/                    # Shell principal (NavigationRail + AppBar)
│   ├── dashboard/               # Tela de dashboard com gráficos
│   ├── employees/               # Gestão de funcionários
│   ├── epis/                    # Gestão de estoque de EPIs
│   ├── entrega_epi/             # Entrega de EPIs
│   ├── organizational_structure/ # Estrutura organizacional
│   ├── product_technical_registration/ # Cadastros técnicos
│   ├── reports/                 # Relatórios
│   ├── settings/                # Configurações
│   └── widgets/                 # Widgets reutilizáveis globais
│
└── settings/                    # Módulo de configurações adicionais
```

---

## Camadas da Arquitetura

### 1. Domain Layer (`lib/domain/`)
A camada mais interna e pura. Contém apenas as **entidades de negócio** (modelos Dart) sem qualquer dependência de framework externo.

- Todos os modelos herdam de `AppWriteModel` (classe base com `id`, `createdAt`, `updatedAt`)
- Cada modelo implementa `fromMap()` (desserialização) e `toMap()` (serialização)
- Não possui lógica de negócio complexa — apenas estrutura de dados

### 2. Data Layer (`lib/data/`)
Responsável pela **comunicação com o backend** (Appwrite). Implementa o padrão **Repository**.

- `BaseRepository<T>` é uma classe genérica abstrata que fornece CRUD completo para qualquer entidade
- Repositórios especializados estendem `BaseRepository` e adicionam queries e lógicas específicas
- Usa `TablesDB` do pacote `appwrite` para comunicação com o banco

### 3. Config Layer (`lib/config/`)
Configurações e notificadores globais. Atualmente contém:

- `ThemeNotifier`: `ChangeNotifier` que persiste e gerencia o tema (claro/escuro/sistema) via `SharedPreferences`

### 4. Core Layer (`lib/core/`)
Constantes e recursos compartilhados:

- `AppwriteConstants`: centraliza os IDs de coleções do Appwrite para evitar strings hard-coded espalhadas pelo código

### 5. UI Layer (`lib/ui/`)
Camada de apresentação. Cada módulo tem sua pasta com:

- Página principal (ex: `epi_page.dart`)
- Subpasta `widgets/` com componentes específicos do módulo

---

## Padrões e Decisões Técnicas

### Gerenciamento de Estado: Provider
O projeto usa o pacote **Provider** para injeção de dependências e gerenciamento de estado.

Todos os repositórios são registrados no `main.dart` via `MultiProvider`:
- Repositórios simples → `Provider<T>(create: ...)`
- Repositórios com dependências → `ProxyProvider2<A, B, C>(update: ...)`

Exemplo de dependência em cadeia:
```dart
// EntradasRepository depende de EpiRepository e EntradasEpiRepository
ProxyProvider2<EpiRepository, EntradasEpiRepository, EntradasRepository>(
  update: (context, epiRepo, entradasEpiRepo, previous) =>
      EntradasRepository(databases, epiRepo, entradasEpiRepo),
)
```

### Repository Pattern
Toda comunicação com o Appwrite é centralizada nos repositórios. A UI jamais acessa o SDK do Appwrite diretamente.

```
UI → Provider → Repository → Appwrite SDK → Appwrite Cloud
```

### Preço Médio Ponderado
A entrada de EPIs em estoque utiliza cálculo de **Preço Médio Ponderado (PMP)**:

```
NovoPMP = (EstoqueAtual × ValorAtual + QtdEntrada × ValorEntrada) / (EstoqueAtual + QtdEntrada)
```

A exclusão de entradas reverte o PMP matematicamente.

### Tema Dinâmico
O `ThemeNotifier` é um `ChangeNotifier` que:
1. Carrega a preferência salva no `SharedPreferences` ao inicializar
2. Expõe `themeMode` para o `MaterialApp`
3. Persiste mudanças automaticamente

### Localização
O app é configurado para `pt-BR` tanto no SDK do Appwrite (`setLocale('pt_BR')`) quanto nas delegates do Flutter (`GlobalMaterialLocalizations`, `GlobalCupertinoLocalizations`).

---

## Fluxo de Dados Simplificado

```
┌─────────────────────────────────────────────────────────┐
│                       UI (Widget)                        │
│          context.read<Repository>().method()             │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                   Repository Layer                        │
│    Estende BaseRepository<T> → CRUD genérico             │
│    Lógica de negócio específica (ex: PMP, queries)       │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                  Appwrite SDK (TablesDB)                  │
│    listRows / getRow / createRow / updateRow / deleteRow │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│               Appwrite Cloud (nyc.cloud.appwrite.io)     │
│                   Database ID: 691cc116001e1ed74089      │
└─────────────────────────────────────────────────────────┘
```
