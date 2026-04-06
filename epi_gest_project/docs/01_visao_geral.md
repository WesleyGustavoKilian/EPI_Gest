# 🛡️ Visão Geral do Projeto — EPI Gest

## O que é o EPI Gest?

O **EPI Gest** é um sistema desktop/web de gestão de Equipamentos de Proteção Individual (EPIs) voltado para empresas que precisam controlar o ciclo de vida dos EPIs dos seus funcionários — desde a entrada em estoque até a entrega e renovação periódica.

O sistema é construído em **Flutter**, com suporte multiplataforma (Windows, Web, Linux, macOS), e utiliza o **Appwrite** como BaaS (Backend as a Service) para persistência de dados na nuvem.

---

## Contexto e Problema

O controle de EPIs é uma obrigação legal no Brasil (regulamentado pela NR-6), exigindo que as empresas:

- Registrem quais EPIs são obrigatórios para cada função/setor
- Controlem a entrega de EPIs a cada funcionário
- Garantam a validade do Certificado de Aprovação (CA)
- Definam periodicidade de troca e renovação
- Gerem fichas de entrega e relatórios para auditorias

O **EPI Gest** automatiza e centraliza todo esse processo.

---

## Funcionalidades Principais

| Módulo | Descrição |
|---|---|
| **Dashboard** | Visão geral com gráficos de estoque, entregas e vencimentos |
| **Funcionários** | Cadastro e gestão de funcionários, status (ativo, férias, desligado) |
| **Estoque de EPIs** | Cadastro de EPIs com CA, validade, estoque, valor médio e periodicidade |
| **Entrega de EPIs** | Registro de entregas, ficha de entrega individual por funcionário |
| **Estrutura Organizacional** | Unidades, setores, cargos, turnos, vínculos e riscos ocupacionais |
| **Cadastros Técnicos** | Categorias, marcas, medidas, fornecedores e locais de armazenamento |
| **Relatórios** | Geração de relatórios, exportação CSV, Excel e PDF |
| **Configurações** | Tema (claro/escuro/sistema), preferências do usuário |

---

## Plataformas Suportadas

- ✅ **Windows** (aplicação desktop)
- ✅ **Web** (via Flutter Web)
- ✅ **Linux**
- ✅ **macOS**
- ✅ **Android** (build disponível)
- ✅ **iOS** (build disponível)

---

## Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Framework | Flutter (Dart) |
| Backend / Banco de Dados | Appwrite Cloud |
| Gerenciamento de Estado | Provider |
| Gráficos | Syncfusion Flutter Charts, FL Chart |
| Exportação | PDF, Excel, CSV |
| Localização | Flutter Localizations (pt-BR) |
| Persistência Local | Shared Preferences |
| Ícones | Phosphor Flutter |

---

## Requisitos Legais Atendidos

- Registro de CA (Certificado de Aprovação) por EPI
- Controle de validade do CA
- Periodicidade de troca definida por produto
- Ficha de entrega por funcionário (rastreabilidade)
- Mapeamento de EPIs obrigatórios por cargo/setor (NR-6)
