# 📦 Dependências do Projeto

## Versão do SDK

```yaml
environment:
  sdk: ^3.8.0
```

---

## Dependências de Produção

### Framework Base

| Pacote | Versão | Descrição |
|---|---|---|
| `flutter` | SDK | Framework principal |
| `flutter_localizations` | SDK | Suporte a internacionalização |
| `cupertino_icons` | ^1.0.8 | Ícones no estilo iOS |

---

### Backend e Persistência

| Pacote | Versão | Descrição |
|---|---|---|
| `appwrite` | ^20.3.0 | SDK oficial do Appwrite — BaaS para banco de dados, storage e autenticação |
| `shared_preferences` | ^2.2.2 | Armazenamento local de chave-valor (usado para persistir preferências de tema) |

---

### Gerenciamento de Estado

| Pacote | Versão | Descrição |
|---|---|---|
| `provider` | ^6.1.1 | Gerenciamento de estado e injeção de dependências. Usado para expor repositórios e o `ThemeNotifier` via `MultiProvider` |

---

### Gráficos e Visualizações

| Pacote | Versão | Descrição |
|---|---|---|
| `syncfusion_flutter_charts` | ^31.1.19 | Gráficos avançados (pizza, barras, linha, área, série temporal) para o dashboard |
| `syncfusion_flutter_gauges` | ^31.2.5 | Gauges e medidores radiais para KPIs |
| `fl_chart` | ^0.68.0 | Biblioteca alternativa de gráficos (barras, linhas, pizza) |

> **Nota:** Os pacotes da Syncfusion requerem licença para uso em produção. Para uso community/pessoal, é necessário registrar-se gratuitamente no site da Syncfusion.

---

### Exportação e Geração de Documentos

| Pacote | Versão | Descrição |
|---|---|---|
| `pdf` | ^3.10.0 | Geração de arquivos PDF programaticamente |
| `printing` | ^5.11.0 | Impressão e preview de PDFs gerados |
| `excel` | ^4.0.0 | Criação e edição de planilhas Excel (.xlsx) |
| `csv` | ^6.0.0 | Encoding/decoding de arquivos CSV |

---

### Arquivos, Imagens e Compartilhamento

| Pacote | Versão | Descrição |
|---|---|---|
| `share_plus` | ^12.0.1 | Compartilhamento de conteúdo (arquivos, texto) via apps nativos |
| `path_provider` | ^2.1.5 | Obtenção de diretórios do sistema (documentos, cache, temp) |
| `open_file` | ^3.5.10 | Abertura de arquivos com o app padrão do SO |
| `image_picker` | ^1.2.0 | Seleção de imagens da galeria ou câmera (foto do funcionário) |
| `file_picker` | ^10.3.3 | Seleção de arquivos do sistema de arquivos |

---

### Localização e Internacionalização

| Pacote | Versão | Descrição |
|---|---|---|
| `intl` | ^0.20.2 | Formatação de datas, números e moedas para pt-BR |
| `flutter_localization` | ^0.3.3 | Suporte a múltiplos idiomas na aplicação |

---

### UI e Ícones

| Pacote | Versão | Descrição |
|---|---|---|
| `phosphor_flutter` | ^2.1.0 | Biblioteca de ícones Phosphor (alternativa aos Material Icons, com estilo mais moderno) |

---

## Dependências de Desenvolvimento

| Pacote | Versão | Descrição |
|---|---|---|
| `flutter_test` | SDK | Framework de testes do Flutter |
| `flutter_lints` | ^5.0.0 | Regras de linting recomendadas pelo time Flutter |

---

## Diagrama de Dependências por Responsabilidade

```
┌─────────────────────────────────────────────────────┐
│                   EPI Gest App                       │
├──────────────┬──────────────┬─────────────┬─────────┤
│   Backend    │   Estado     │  Gráficos   │  UI     │
│  appwrite    │  provider    │ syncfusion  │phosphor │
│  shared_prefs│              │ fl_chart    │         │
├──────────────┴──────────────┴─────────────┴─────────┤
│                   Exportação                         │
│    pdf  │  printing  │  excel  │  csv  │ share_plus │
├──────────────────────────────────────────────────────┤
│                Arquivos e Mídia                       │
│ image_picker │ file_picker │ path_provider │open_file│
├──────────────────────────────────────────────────────┤
│                  Localização                         │
│         intl  │  flutter_localization                 │
└──────────────────────────────────────────────────────┘
```

---

## Notas de Compatibilidade

- O app suporta **Flutter SDK ^3.8.0** (versão recente com suporte completo a Material 3)
- O SDK do Appwrite `^20.3.0` usa a API de **Tables** (nova API do Appwrite), diferente das versões anteriores que usavam `Databases`
- Os pacotes Syncfusion na versão `^31.x.x` são compatíveis entre si (mesma major version)

---

## Atualizando Dependências

Para verificar pacotes desatualizados:
```bash
flutter pub outdated
```

Para atualizar para a versão mais recente compatível:
```bash
flutter pub upgrade
```

Para atualizar para major versions (cuidado com breaking changes):
```bash
flutter pub upgrade --major-versions
```
