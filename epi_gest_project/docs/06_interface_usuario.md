# 🖥️ Interface do Usuário

## Layout Principal

O EPI Gest utiliza um layout de **shell** fixo com:
- **AppBar** no topo (barra de título + seletor de empresa + perfil)
- **NavigationRail** lateral esquerdo (menu de navegação recolhível)
- **Área de conteúdo** à direita (a página ativa)

```
┌───────────────────────────────────────────────────────────┐
│  AppBar: [☰] EPI Gest         [Empresa ▼] [Perfil]       │
├──────────────┬────────────────────────────────────────────┤
│              │                                            │
│  Navigation  │                                            │
│  Rail        │          Página Ativa                      │
│  (recolhível)│          (Card.outlined)                   │
│              │                                            │
│  [Suporte]   │                                            │
└──────────────┴────────────────────────────────────────────┘
```

---

## Componente: `HomePage`

**Arquivo:** `lib/ui/home/home_page.dart`

É um `StatefulWidget` que gerencia:
- `_selectedIndex`: controla qual página está ativa
- `_isRailExtended`: controla se o rail está expandido (`256px`) ou recolhido (`72px`)

```dart
final List<Widget> _pages = [
  DashboardPage(),
  EmployeesPage(),
  EpiPage(),
  ExchangePage(),           // Entrega de EPIs
  OrganizationalStructurePage(),
  ProductTechnicalRegistrationPage(),
  ReportsPage(),
  SettingsPage(),
];
```

A troca de páginas é via `_pages[_selectedIndex]` — sem navegação de rotas, usando **IndexedStack** implícito.

### Widgets do Home
- **`CompanySelectorWidget`**: Dropdown no AppBar para selecionar empresa/unidade ativa
- **`PerfilWidget`**: Menu de perfil do usuário no AppBar

---

## Módulos de Telas

### 📊 Dashboard (`ui/dashboard/`)
Visão executiva com:
- Cards de indicadores (estoque total, entregas pendentes, EPIs vencendo)
- Gráficos de distribuição de EPIs por categoria (Syncfusion Charts / FL Chart)
- Status geral do inventário

### 👥 Funcionários (`ui/employees/`)
Gestão completa do quadro de pessoal:
- Listagem com filtros por status (ativo, férias, desligado)
- Formulário de cadastro/edição
- Visualização da ficha individual do funcionário

### 🦺 Estoque de EPIs (`ui/epis/`)
Controle do inventário de EPIs:
- Lista de EPIs com estoque, valor e validade do CA
- Cadastro e edição de EPIs
- Registro de entradas (notas de compra)
- Alertas de EPIs com CA próximo do vencimento

### 🔄 Entrega de EPIs (`ui/entrega_epi/`)
Módulo de entrega com badge de pendências no menu:
- Ficha de entrega por funcionário
- Registro de entrega com baixa automática de estoque
- Visualização de histórico de entregas

### 🏢 Estrutura Organizacional (`ui/organizational_structure/`)
Cadastros hierárquicos da empresa:
- Unidades (matriz/filiais com CNPJ)
- Setores, Cargos
- Turnos de trabalho
- Tipos de vínculo empregatício
- Riscos ocupacionais
- Mapeamento de EPIs por cargo/setor

### 📋 Cadastros Técnicos (`ui/product_technical_registration/`)
Tabelas de apoio para o cadastro de EPIs:
- Categorias de EPI
- Marcas/fabricantes
- Unidades de medida
- Fornecedores
- Locais de armazenamento

### 📈 Relatórios (`ui/reports/`)
Geração e exportação de relatórios:
- Relatório de fichas de entrega
- Relatório de inventário
- Exportação em PDF, Excel e CSV
- Compartilhamento via `share_plus`

### ⚙️ Configurações (`ui/settings/`)
Preferências do usuário:
- Alternância de tema (claro / escuro / sistema)
- Preferências da conta

---

## NavigationRail

O `NavigationRail` tem 8 destinos, com suporte a:
- **Badge** no item "Entrega de EPIs" indicando entregas pendentes
- **Labels em múltiplas linhas** para itens com nome mais longo ("Estrutura Organizacional", "Cadastros Técnicos")
- **Modo estendido** (com texto) e **modo recolhido** (apenas ícones)

```dart
NavigationRailDestination(
  icon: Icon(Icons.swap_horiz_outlined),
  selectedIcon: Icon(Icons.swap_horiz),
  label: Text('Entrega de EPIs'),
  // + Badge com contador de pendências
)
```

---

## Material Design 3

O projeto usa `useMaterial3: true` com tema baseado em `ColorScheme.fromSeed`:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light, // ou Brightness.dark
  ),
  useMaterial3: true,
)
```

Isso gera automaticamente uma paleta de cores harmônica baseada no roxo-profundo, aplicada em toda a UI.

### Suporte a Tema Claro/Escuro
O `ThemeNotifier` (ChangeNotifier) persiste a preferência de tema no `SharedPreferences`. O `MaterialApp` consome o `themeMode` via `Consumer<ThemeNotifier>`.

Opções disponíveis:
- **Claro** → `ThemeMode.light`
- **Escuro** → `ThemeMode.dark`
- **Sistema** → `ThemeMode.system` (padrão)

---

## Widgets Globais (`ui/widgets/`)

Pasta para widgets reutilizáveis compartilhados entre múltiplos módulos (ex: loading indicators, empty states, dialogs de confirmação, cards padronizados).

---

## Gráficos e Visualizações

O sistema utiliza dois pacotes de gráficos:

| Pacote | Uso |
|---|---|
| `syncfusion_flutter_charts` | Gráficos avançados de série temporal, pizza e barras |
| `syncfusion_flutter_gauges` | Gauges/medidores para indicadores de KPI no dashboard |
| `fl_chart` | Gráficos alternativos (barras, linhas) |

---

## Exportação e Compartilhamento

| Funcionalidade | Pacote |
|---|---|
| Geração de PDF | `pdf` + `printing` |
| Exportação Excel | `excel` |
| Exportação CSV | `csv` |
| Compartilhamento | `share_plus` |
| Salvar arquivos | `path_provider` |
| Abrir arquivos | `open_file` |
| Selecionar imagens | `image_picker` |
| Selecionar arquivos | `file_picker` |

---

## Localização

O app é configurado para **português do Brasil** via:

```dart
localizationsDelegates: [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

Isso garante que componentes Material nativos (como `DatePicker`, `TimePicker`) exibam textos em pt-BR automaticamente.
