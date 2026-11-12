# SGP-DISPO
## SISTEMA INTEGRADO DE GESTÃƒO DO PATRIMÃ“NIO DA DIRECÃ‡ÃƒO DE SEGURANÃ‡A PÃšBLICA E OPERAÃ‡Ã•ES â€” POLÃCIA NACIONAL DE ANGOLA

### MASTER PROMPT CANÃ“NICO DE ENGENHARIA, ARQUITECTURA, SEGURANÃ‡A, GOVERNANÃ‡A E ENTREGA

**Identificador:** `SGP-DISPO-MASTER-v1.1`
**Estado:** `FROZEN â€” FINAL CONSOLIDADO`
**VersÃ£o anterior preservada:** `SGP-DISPO-MASTER-v1.0-FROZEN`
**SHA-256 da versÃ£o anterior:** `7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667`
**Change Request de consolidaÃ§Ã£o:** `CR-SGP-001 â€” EXPANSÃƒO CONTROLADA M2â€“M9`
**Autoridade:** CANÃ“NICA
**Natureza:** Enterprise / Sistema Institucional CrÃ­tico
**Destino:** Infraestrutura interna da PolÃ­cia Nacional de Angola
**Modo de implantaÃ§Ã£o:** On-Premises / Rede privada institucional
**Agente principal de engenharia:** Codex
**Base de dados oficial:** PostgreSQL
**Estado final exigido:** `PRODUCTION_READY`
**ProtÃ³tipo / Demo / PoC:** PROIBIDO como resultado final
**Dados operacionais mock/fake/demo:** PROIBIDOS
**Frontend desacoplado de dados reais:** PROIBIDO
**Funcionalidades decorativas:** PROIBIDAS

---

# CR-SGP-001 â€” EXPANSÃƒO CONTROLADA DOS MILESTONES M2â€“M9

## Estado da decisÃ£o

```text
APPROVED
INCORPORATED INTO SGP-DISPO-MASTER-v1.1-FROZEN
```

## RazÃ£o

Consolidar no Master canÃ³nico os domÃ­nios funcionais e transversais necessÃ¡rios para que o SGP-DISPO cubra integralmente o ciclo patrimonial institucional, sem fragmentar o roadmap, sem criar milestones posteriores a M10 e sem destruir garantias jÃ¡ implementadas.

## Requisitos afectados

```text
SecÃ§Ã£o 9 â€” DomÃ­nios Funcionais ObrigatÃ³rios
M2 â€” OrganizaÃ§Ã£o e LocalizaÃ§Ãµes
M3 â€” Cadastro / PatrimÃ³nio E2E
M4 â€” AfectaÃ§Ã£o, MovimentaÃ§Ã£o e CustÃ³dia
M5 â€” InventÃ¡rio FÃ­sico e ReconciliaÃ§Ã£o
M6 â€” ManutenÃ§Ã£o e Ciclo de Vida
M7 â€” Auditoria, RelatÃ³rios, Analytics e GovernanÃ§a
M8 â€” IntegraÃ§Ã£o, Hardening e Operabilidade
M9 â€” System Acceptance & Production Readiness
```

## Arquitectura afectada

A arquitectura fundamental nÃ£o Ã© substituÃ­da. MantÃªm-se:

```text
React + TypeScript + Vite
Node.js + TypeScript + Fastify
PostgreSQL como source of truth
RBAC + ABAC + RLS + Need-to-Know + Least Privilege
Migrations versionadas
OpenAPI /api/v1
On-Premises / Rede privada PNA
Frontend â†’ API â†’ Services â†’ Rules â†’ Authorization â†’ Repository â†’ PostgreSQL
```

## Impacto de seguranÃ§a

```text
NO SECURITY REDUCTION
NO RLS REDUCTION
NO AUTHORIZATION BYPASS
NO AUDIT REDUCTION
NO MOCK RELAXATION
```

Os novos domÃ­nios herdam integralmente os controlos de M0/M1.

## Impacto de base de dados

Novas entidades, relaÃ§Ãµes, constraints e migrations poderÃ£o ser introduzidas a partir de M2 conforme DoR/ADR. Ã‰ proibido reescrever migrations jÃ¡ publicadas para acomodar esta expansÃ£o.

## Impacto de compatibilidade

```text
BACKWARD COMPATIBLE BY DESIGN
```

Tudo o que foi implementado e aprovado em M0 e M1 permanece vÃ¡lido. Esta consolidaÃ§Ã£o nÃ£o exige reconstruir autenticaÃ§Ã£o, autorizaÃ§Ã£o, RLS, security context, auditoria, CI, sessÃµes, maker-checker ou demais controlos jÃ¡ aprovados.

## Impacto de migrations

```text
FORWARD-ONLY
```

Migrations jÃ¡ publicadas permanecem imutÃ¡veis. ExpansÃµes futuras utilizam novas migrations numeradas sequencialmente.

## Impacto de testes

A suite existente permanece obrigatÃ³ria e verde. Cada milestone acrescentarÃ¡ os testes especÃ­ficos dos novos domÃ­nios sem remover regressÃµes anteriores.

## Rollback Plan

NÃ£o existe rollback destrutivo de cÃ³digo jÃ¡ aprovado. Se um requisito novo nÃ£o puder ser implementado com seguranÃ§a, o milestone correspondente permanece `BLOCKED` ou `GATE_FAILED`; os milestones anteriores nÃ£o sÃ£o desfeitos.

## DecisÃ£o

```text
INCORPORATE NEW DOMAINS INSIDE M2â€“M9
DO NOT CREATE M11/M12/M13
PRESERVE M0â€“M1 IMPLEMENTATION
PRESERVE M0â†’M10 ORDER
PRESERVE ALL EXISTING GATES
```

## AprovaÃ§Ã£o

AprovaÃ§Ã£o humana expressa para consolidaÃ§Ã£o do Master e congelamento final em 12 de Novembro de 2026.

---

# REGRA DE CONTINUIDADE E NÃƒO REGRESSÃƒO DA CONSOLIDAÃ‡ÃƒO

1. O conteÃºdo de `SGP-DISPO-MASTER-v1.0-FROZEN` continua vÃ¡lido excepto onde esta versÃ£o **adiciona** requisitos futuros de M2â€“M9.
2. Nenhum requisito novo desta consolidaÃ§Ã£o retroage para invalidar M0/M1 que jÃ¡ tenha sido implementado, testado e aprovado.
3. M0 e M1 nÃ£o deverÃ£o ser reescritos para satisfazer domÃ­nios de M2â€“M9.
4. Contratos FROZEN, hashes, evidÃªncias, migrations e gates jÃ¡ aprovados devem ser preservados.
5. Qualquer implementaÃ§Ã£o futura deverÃ¡ estender padrÃµes existentes; nÃ£o criar caminhos paralelos de autenticaÃ§Ã£o, autorizaÃ§Ã£o, RLS, auditoria ou persistÃªncia.
6. Toda alteraÃ§Ã£o de schema serÃ¡ forward-only.
7. Todos os novos domÃ­nios deverÃ£o respeitar os controlos de seguranÃ§a, auditoria, traceabilidade, DoR, DoD e zero-mock jÃ¡ existentes.
8. O M1 Final Gate nÃ£o recebe escopo funcional patrimonial adicional por causa deste CR.
9. O M2 somente poderÃ¡ iniciar apÃ³s o gate formal que jÃ¡ o autoriza.
10. M10 continua sendo o Ãºltimo milestone; nÃ£o existe extensÃ£o automÃ¡tica para M11+.

---

# 0. AUTORIDADE CANÃ“NICA

Este documento constitui a autoridade mÃ¡xima de governaÃ§Ã£o tÃ©cnica do projecto SGP-DISPO.

Quando existir conflito entre:

- implementaÃ§Ã£o;
- documentaÃ§Ã£o;
- decisÃµes anteriores;
- prompts auxiliares;
- sugestÃµes do agente;
- conveniÃªncia de desenvolvimento;
- atalhos tÃ©cnicos;

prevalece este documento.

Nenhuma decisÃ£o do agente poderÃ¡ reduzir os requisitos definidos neste Master Prompt.

O agente pode propor melhorias.

O agente nÃ£o pode unilateralmente:

- remover controlos;
- substituir requisitos crÃ­ticos;
- reduzir seguranÃ§a;
- desactivar auditoria;
- enfraquecer RLS;
- introduzir mocks;
- alterar arquitectura fundamental;
- eliminar testes;
- contornar gates;
- declarar produÃ§Ã£o sem evidÃªncias.

---

# 1. OBJECTIVO FINAL

Construir um sistema real, completo, auditÃ¡vel, seguro e operacional para gestÃ£o do patrimÃ³nio da DISPO/PNA.

O sistema deverÃ¡ poder ser instalado numa infraestrutura real da PolÃ­cia Nacional e operar com dados institucionais verdadeiros sem necessidade posterior de:

- substituir mocks;
- reconstruir backend;
- refazer banco de dados;
- reconstruir autenticaÃ§Ã£o;
- reconstruir autorizaÃ§Ã£o;
- adicionar auditoria retroactivamente;
- refazer arquitectura;
- substituir dashboards fictÃ­cios;
- reimplementar workflows;
- reescrever pÃ¡ginas para integraÃ§Ã£o real.

O produto deverÃ¡ nascer como sistema de produÃ§Ã£o.

---

# 2. PRINCÃPIO FUNDAMENTAL

O SGP-DISPO:

**Ã‰:**

- aplicaÃ§Ã£o enterprise;
- sistema transaccional;
- sistema institucional;
- sistema auditÃ¡vel;
- sistema multi-unidade;
- sistema seguro;
- sistema on-premises;
- sistema operacional;
- sistema com base de dados persistente;
- sistema pronto para ambientes DEV, TEST, STAGING e PRODUCTION.

**NÃƒO Ã‰:**

- protÃ³tipo;
- demonstraÃ§Ã£o;
- mockup;
- PoC;
- aplicaÃ§Ã£o acadÃ©mica;
- template;
- sistema visual;
- projecto frontend;
- conjunto de pÃ¡ginas;
- dashboard estÃ¡tico;
- simulaÃ§Ã£o.

---

# 3. REGRA ABSOLUTA â€” ZERO MOCK OPERACIONAL

Ã‰ proibida a utilizaÃ§Ã£o de:

```text
mockData
fakeData
dummyData
sampleData
demoData
fakeDashboard
hardcodedUsers
hardcodedAssets
hardcodedDepartments
JSON utilizado como banco
arrays locais representando entidades persistentes
Math.random() para dados de negÃ³cio
IDs inventados apresentados como informaÃ§Ã£o institucional
```

Nenhuma tela deverÃ¡ aparentar possuir dados que nÃ£o existam efectivamente no PostgreSQL.

Quando nÃ£o existirem dados:

```text
Total de activos: 0
```

Ã© correcto.

Inventar:

```text
Total de activos: 3.842
```

Ã© incorrecto.

---

# 4. EXCEPÃ‡ÃƒO CONTROLADA PARA TESTES

Dados efÃ©meros poderÃ£o ser criados exclusivamente em:

```text
TEST
CI
E2E
INTEGRATION TEST ENVIRONMENT
```

para execuÃ§Ã£o automatizada de testes.

Esses dados:

- nÃ£o poderÃ£o chegar a produÃ§Ã£o;
- deverÃ£o possuir lifecycle controlado;
- deverÃ£o poder ser apagados/recriados;
- deverÃ£o ser claramente identificÃ¡veis como dados de teste.

Test doubles poderÃ£o existir em testes unitÃ¡rios quando tecnicamente apropriados.

Mocks nunca deverÃ£o ser usados para mascarar uma integraÃ§Ã£o ausente no produto.

---

# 5. PRINCÃPIO DATA-DRIVEN

Fluxo obrigatÃ³rio:

```text
Frontend
   â†“
API
   â†“
Application Services
   â†“
Domain / Business Rules
   â†“
Authorization
   â†“
Repository / Data Access
   â†“
PostgreSQL
```

Cada elemento visual que apresente informaÃ§Ã£o operacional deverÃ¡ possuir origem rastreÃ¡vel atÃ© uma fonte real.

---

# 6. STACK DE REFERÃŠNCIA

## Frontend

```text
React
TypeScript
Vite
```

## Backend

```text
Node.js
TypeScript
Fastify
```

## Banco

```text
PostgreSQL
```

## Infraestrutura

```text
Linux
Nginx ou reverse proxy equivalente
Docker
Docker Compose quando adequado
Kubernetes quando justificado
Redis quando tecnicamente necessÃ¡rio
Object Storage interno
Monitoring interno
Backup interno
SIEM interno quando disponÃ­vel
```

A stack poderÃ¡ ser refinada atravÃ©s de ADR.

NÃ£o deverÃ¡ ser alterada por simples preferÃªncia do agente.

---

# 7. REPOSITÃ“RIO

Adoptar preferencialmente monorepo:

```text
/apps
    /web
    /api

/packages
    /contracts
    /config
    /database
    /auth
    /ui
    /logging
    /security

/infrastructure
    /docker
    /nginx
    /kubernetes
    /monitoring

/docs
    /architecture
    /adr
    /security
    /operations
    /requirements
    /evidence

/migrations
/tests
/scripts
```

---

# 8. ESTRUTURA ORGANIZACIONAL

O sistema deverÃ¡ modelar dinamicamente:

```text
PNA
â””â”€â”€ Comando-Geral
    â””â”€â”€ DISPO
        â”œâ”€â”€ DirecÃ§Ã£o
        â”œâ”€â”€ DirecÃ§Ã£o Adjunta
        â”œâ”€â”€ Secretariado
        â””â”€â”€ Departamentos
            â””â”€â”€ SecÃ§Ãµes
                â””â”€â”€ Unidades
                    â””â”€â”€ LocalizaÃ§Ãµes
```

A hierarquia nunca deverÃ¡ ser rigidamente codificada na interface.

Utilizar relaÃ§Ã£o hierÃ¡rquica configurÃ¡vel.

Exemplo:

```text
organizational_units

id
parent_id
code
name
type
status
manager_id
valid_from
valid_to
```

---

# 9. DOMÃNIOS FUNCIONAIS OBRIGATÃ“RIOS

A plataforma deverÃ¡ contemplar, no mÃ­nimo:

```text
OrganizaÃ§Ã£o Institucional
IAM
Utilizadores
Perfis
PermissÃµes
ClassificaÃ§Ã£o da InformaÃ§Ã£o
Departamentos
SecÃ§Ãµes
LocalizaÃ§Ãµes
EdifÃ­cios
Pisos
Salas
ArmazÃ©ns

PatrimÃ³nio
Activos
Categorias
Subcategorias
Marcas
Modelos
NÃºmeros de sÃ©rie
QR Code
Barcode

AquisiÃ§Ãµes
RecepÃ§Ã£o
Entrada
Armazenamento
AfectaÃ§Ã£o
CustÃ³dia
TransferÃªncia
DevoluÃ§Ã£o
InventÃ¡rio fÃ­sico
ReconciliaÃ§Ã£o

ManutenÃ§Ã£o
Avaria
ReparaÃ§Ã£o
Garantias
Prestadores

Abate
AlienaÃ§Ã£o
ReclassificaÃ§Ã£o

Viaturas
Equipamento TIC
Equipamento operacional
MobiliÃ¡rio
ConsumÃ­veis
InstalaÃ§Ãµes

Fornecedores
Contratos
Documentos

Workflow
AprovaÃ§Ãµes
NotificaÃ§Ãµes

Auditoria
Eventos de seguranÃ§a
RelatÃ³rios
Dashboard
ExportaÃ§Ãµes autorizadas
AdministraÃ§Ã£o
ConfiguraÃ§Ã£o
Observabilidade
```

## 9.1 DomÃ­nios transversais consolidados obrigatÃ³rios

AlÃ©m dos domÃ­nios acima, a execuÃ§Ã£o integral M2â€“M9 deverÃ¡ incorporar, conforme o milestone responsÃ¡vel:

```text
Centros de custo e referenciais financeiros
ValorizaÃ§Ã£o patrimonial bÃ¡sica
DepreciaÃ§Ã£o / amortizaÃ§Ã£o quando institucionalmente aplicÃ¡vel
ReavaliaÃ§Ã£o / imparidade quando institucionalmente aplicÃ¡vel
Criticidade e risco do activo
Activos intangÃ­veis
LicenÃ§as e subscriÃ§Ãµes institucionais
Stock patrimonial, peÃ§as e sobressalentes
Contratos de manutenÃ§Ã£o e SLA
Garantias e vigÃªncias
EmprÃ©stimos e cessÃµes temporÃ¡rias
Reservas e devoluÃ§Ãµes
Qualidade de dados e master data governance
DetecÃ§Ã£o de duplicados
ReconciliaÃ§Ã£o de dados legados
Mobile para operaÃ§Ãµes de inventÃ¡rio e custÃ³dia
QR / Barcode operacional
Modo offline controlado e sincronizaÃ§Ã£o segura quando tecnicamente necessÃ¡rio
Integration Layer / APIs institucionais
IntegraÃ§Ã£o com RH / ERP / FinanÃ§as / SIEM / directÃ³rios quando autorizada
Alertas e notificaÃ§Ãµes operacionais
Workflows parametrizÃ¡veis
```

## 9.2 ClassificaÃ§Ã£o dos domÃ­nios

### Core obrigatÃ³rio para completude funcional

```text
OrganizaÃ§Ã£o e localizaÃ§Ãµes
AquisiÃ§Ã£o / entrada patrimonial
Cadastro patrimonial
AfectaÃ§Ã£o e custÃ³dia
MovimentaÃ§Ã£o
InventÃ¡rio e reconciliaÃ§Ã£o
ManutenÃ§Ã£o e ciclo de vida
Contratos e garantias
Workflow e notificaÃ§Ãµes
Documentos
RelatÃ³rios e auditoria
Mobile / QR / Barcode para operaÃ§Ãµes de campo
Qualidade e reconciliaÃ§Ã£o de dados
IntegraÃ§Ãµes institucionais necessÃ¡rias ao processo homologado
```

### Maturidade institucional obrigatÃ³ria quando aplicÃ¡vel

```text
Criticidade e risco
Activos intangÃ­veis
ValorizaÃ§Ã£o / depreciaÃ§Ã£o / reavaliaÃ§Ã£o
SLA de fornecedores
BI patrimonial avanÃ§ado
```

### DomÃ­nios especializados

```text
Frota
GestÃ£o tÃ©cnica aprofundada de viaturas
Outros subdomÃ­nios patrimoniais especializados
```

DomÃ­nios especializados somente entram no escopo funcional quando aprovados por DoR/CR ou quando indispensÃ¡veis ao processo patrimonial homologado da DISPO.

---

# 10. MODELO DO ACTIVO

Cada activo deverÃ¡ separar obrigatoriamente:

```text
PROPRIEDADE
AFECTAÃ‡ÃƒO ORGANIZACIONAL
LOCALIZAÃ‡ÃƒO FÃSICA
CUSTÃ“DIA
RESPONSABILIDADE
CLASSIFICAÃ‡ÃƒO
ESTADO OPERACIONAL
ESTADO PATRIMONIAL
```

Nunca tratar estes elementos como se fossem o mesmo conceito.

---

# 11. IDENTIFICAÃ‡ÃƒO PATRIMONIAL

Cada activo terÃ¡:

```text
internal_id = UUID/UUIDv7
asset_number = cÃ³digo patrimonial humano
```

Exemplo:

```text
PNA-DISPO-DOP-TIC-000001
```

O cÃ³digo humano nÃ£o substitui o identificador interno.

---

# 12. POSTGRESQL COMO SOURCE OF TRUTH

PostgreSQL serÃ¡ a fonte autoritativa do sistema.

Utilizar:

```text
PRIMARY KEY
FOREIGN KEY
UNIQUE
NOT NULL
CHECK
INDEX
TRANSACTION
CONSTRAINT
VERSIONING
```

A integridade nunca poderÃ¡ depender exclusivamente do frontend.

---

# 13. MIGRATIONS

Toda alteraÃ§Ã£o estrutural serÃ¡ executada mediante migration versionada.

Proibido:

```text
alterar schema manualmente em produÃ§Ã£o
```

sem migration formal.

---

# 14. SEEDS

Seed permitido para:

```text
roles
permissions
system configuration
classification levels
status
reference tables
workflow definitions
system enums
```

Seed proibido para fabricar inventÃ¡rio institucional fictÃ­cio.

---

# 15. AUTENTICAÃ‡ÃƒO

O sistema deverÃ¡ suportar inicialmente autenticaÃ§Ã£o interna robusta e arquitectura pronta para integraÃ§Ã£o futura com:

```text
Active Directory
LDAP
OIDC
SSO
MFA
```

A integraÃ§Ã£o futura nÃ£o deverÃ¡ exigir reconstruÃ§Ã£o do IAM.

---

# 16. AUTORIZAÃ‡ÃƒO

Combinar:

```text
RBAC
+
ABAC
+
RLS
+
Need-to-Know
+
Least Privilege
```

A autorizaÃ§Ã£o deverÃ¡ ser aplicada no servidor.

Esconder um botÃ£o no frontend nÃ£o constitui autorizaÃ§Ã£o.

---

# 17. ROW LEVEL SECURITY

Tabelas sensÃ­veis deverÃ£o utilizar PostgreSQL RLS.

Quando aplicÃ¡vel:

```sql
ENABLE ROW LEVEL SECURITY;
FORCE ROW LEVEL SECURITY;
```

Testes deverÃ£o provar:

```text
permitido â†’ retorna dados
nÃ£o autorizado â†’ nÃ£o retorna dados
tentativa de bypass â†’ bloqueada
```

---

# 18. CLASSIFICAÃ‡ÃƒO

Implementar estrutura parametrizÃ¡vel.

Exemplo:

```text
Uso Geral
Uso Interno
Reservado
Confidencial
Secreto
```

A nomenclatura definitiva serÃ¡ validada pela PNA.

Activos e documentos poderÃ£o possuir classificaÃ§Ã£o.

---

# 19. COMPARTIMENTAÃ‡ÃƒO

A polÃ­tica poderÃ¡ considerar:

```text
organizaÃ§Ã£o
departamento
secÃ§Ã£o
unidade
localizaÃ§Ã£o
funÃ§Ã£o
role
classification
clearance
categoria
missÃ£o
tipo de activo
operaÃ§Ã£o
```

---

# 20. SEGREGAÃ‡ÃƒO DE FUNÃ‡Ã•ES â€” SoD

OperaÃ§Ãµes crÃ­ticas deverÃ£o utilizar maker-checker ou workflows equivalentes.

Exemplo:

```text
SOLICITANTE
     â†“
APROVADOR
     â†“
ENTREGADOR
     â†“
RECEPTOR
```

Quando aplicÃ¡vel, o mesmo utilizador nÃ£o poderÃ¡ acumular etapas incompatÃ­veis.

---

# 21. MOVIMENTAÃ‡ÃƒO E CADEIA DE CUSTÃ“DIA

Uma transferÃªncia deverÃ¡ produzir registo permanente.

Nunca sobrescrever silenciosamente a localizaÃ§Ã£o.

Registrar:

```text
asset_id
from_unit
to_unit
from_location
to_location
previous_custodian
new_custodian
requested_by
approved_by
delivered_by
received_by
reason
timestamp
document
request_id
correlation_id
```

---

# 22. AUDITORIA

Eventos crÃ­ticos deverÃ£o possuir:

```text
WHO
WHAT
WHEN
WHERE
WHY
BEFORE
AFTER
RESULT
IP
DEVICE
SESSION
REQUEST_ID
CORRELATION_ID
```

A auditoria deverÃ¡ ser separada de logs tÃ©cnicos comuns.

---

# 23. HISTÃ“RICO IMUTÃVEL

Um activo deverÃ¡ permitir reconstruÃ§Ã£o de:

```text
AquisiÃ§Ã£o
â†’ RecepÃ§Ã£o
â†’ Registo
â†’ Etiquetagem
â†’ Armazenamento
â†’ AfectaÃ§Ã£o
â†’ CustÃ³dia
â†’ TransferÃªncia
â†’ ManutenÃ§Ã£o
â†’ DevoluÃ§Ã£o
â†’ InventÃ¡rio
â†’ ReclassificaÃ§Ã£o
â†’ Abate
```

Nunca apagar a cadeia histÃ³rica por mera alteraÃ§Ã£o do registo corrente.

---

# 24. APIs

Adoptar:

```text
/api/v1
```

Todas as funÃ§Ãµes deverÃ£o ter contrato real.

OpenAPI serÃ¡ obrigatÃ³rio.

Exemplo:

```text
GET    /api/v1/assets
POST   /api/v1/assets
GET    /api/v1/assets/{id}
PATCH  /api/v1/assets/{id}

POST   /api/v1/assets/{id}/assign
POST   /api/v1/assets/{id}/transfer
POST   /api/v1/assets/{id}/maintenance
POST   /api/v1/assets/{id}/retire
```

---

# 25. TRANSAÃ‡Ã•ES

OperaÃ§Ãµes compostas deverÃ£o utilizar transacÃ§Ãµes.

Exemplo:

```text
BEGIN

create movement
update custody
update location
update assignment
create audit event

COMMIT
```

Em caso de erro:

```text
ROLLBACK
```

---

# 26. CONCORRÃŠNCIA

Implementar, quando necessÃ¡rio:

```text
optimistic locking
version columns
transactions
appropriate isolation
idempotency
```

Dois utilizadores nÃ£o poderÃ£o produzir estados contraditÃ³rios para o mesmo activo sem detecÃ§Ã£o.

---

# 27. DOCUMENTOS

Facturas, contratos, termos, fotografias e documentos nÃ£o deverÃ£o ser expostos directamente em pasta pÃºblica.

Implementar:

```text
controlled object storage
authorization
metadata
hash
classification
audit
versioning quando aplicÃ¡vel
```

---

# 28. QR CODE

QR Code deverÃ¡ representar referÃªncia segura.

Nunca deverÃ¡ transportar dados sensÃ­veis directamente.

Fluxo:

```text
Scan
 â†“
Authentication
 â†“
Authorization
 â†“
RLS/ABAC
 â†“
Asset view
```

---

# 29. FRONTEND ENTERPRISE

O frontend deverÃ¡ ser completamente implementado pelo agente Codex.

NÃ£o existe separaÃ§Ã£o entre â€œfrontend visualâ€ e â€œengenharia realâ€.

Cada pÃ¡gina deverÃ¡ possuir:

```text
API real
loading state
empty state
error state
authorization
validation
responsive behavior
accessibility adequada
persistÃªncia
telemetria necessÃ¡ria
```

---

# 30. ZERO BOTÃ•ES FALSOS

Proibido:

```text
alert("Em breve")
console.log("TODO")
TODO buttons
disabled fake functionality
placeholder submit
```

Uma acÃ§Ã£o visÃ­vel deverÃ¡:

```text
FUNCIONAR
```

ou nÃ£o deverÃ¡ ser publicada como disponÃ­vel.

---

# 31. ZERO ROTAS DECORATIVAS

Toda rota deve executar o seu propÃ³sito real.

Uma rota visual sem backend/persistÃªncia nÃ£o estÃ¡ concluÃ­da.

---

# 32. DASHBOARD

Todos os KPIs deverÃ£o ser produzidos a partir de consultas reais.

Nenhum nÃºmero hardcoded.

Exemplos:

```text
Total de activos
Valor patrimonial
DistribuiÃ§Ã£o por departamento
DistribuiÃ§Ã£o por categoria
Activos em manutenÃ§Ã£o
Activos avariados
Activos sem custÃ³dia vÃ¡lida
InventÃ¡rios em atraso
TransferÃªncias pendentes
```

---

# 33. SEGURANÃ‡A DE APLICAÃ‡ÃƒO

Implementar quando aplicÃ¡vel:

```text
Secure Headers
TLS
CORS Policy
CSRF Protection
Input Validation
Output Encoding
Rate Limiting
Account Lockout
Password Policy
Session Revocation
MFA readiness
Secrets Management
Secure Cookies
Request Size Limits
Upload Validation
Dependency Control
SQL Injection Protection
XSS Protection
SSRF Protection
```

---

# 34. SECRETS

Ã‰ proibido colocar no repositÃ³rio:

```text
password
API key
database credential
JWT secret
private key
production token
```

ProduÃ§Ã£o deverÃ¡ utilizar mecanismo seguro de secrets.

---

# 35. CONTAINERS

Containers de produÃ§Ã£o:

```text
non-root
minimal image
healthcheck
read-only filesystem quando possÃ­vel
version pinning
resource limits quando aplicÃ¡vel
```

---

# 36. AMBIENTES

Manter separaÃ§Ã£o:

```text
DEV
TEST
STAGING
PRODUCTION
```

PRODUCTION nunca deverÃ¡ ser ambiente de experimentaÃ§Ã£o.

---

# 37. CI/CD

Pipeline deverÃ¡ executar gates como:

```text
Lint
Type Check
Unit Tests
Integration Tests
Database Tests
API Tests
Authorization Tests
RLS Tests
E2E Tests
SAST
SCA
Secret Scan
Dependency Audit
Container Scan
SBOM
Build
Migration Validation
```

Falha de gate crÃ­tico bloqueia promoÃ§Ã£o.

---

# 38. ARTEFACTOS OBRIGATÃ“RIOS

Manter no repositÃ³rio:

```text
README.md
ARCHITECTURE.md
SECURITY.md
DATABASE.md
DEPLOYMENT.md
BACKUP-RESTORE.md
RUNBOOK.md
CONTRIBUTING.md
CHANGELOG.md
OpenAPI
ADR/
docs/
migrations/
tests/
```

---

# 39. TRACEABILIDADE

Cada requisito terÃ¡ identificador.

Exemplo:

```text
SGP-IAM-001
SGP-AST-017
SGP-RLS-004
```

Fluxo:

```text
REQUIREMENT
   â†“
DESIGN
   â†“
ADR
   â†“
CODE
   â†“
MIGRATION
   â†“
API
   â†“
TEST
   â†“
EVIDENCE
```

Nenhum requisito crÃ­tico poderÃ¡ permanecer sem teste ou evidÃªncia.

---

# 40. DEFINITION OF READY â€” DoR

Uma tarefa sÃ³ entra em implementaÃ§Ã£o quando possuir:

```text
objectivo
requisito
actor
preconditions
business rules
security rules
data requirements
API impact
database impact
audit requirement
acceptance criteria
test expectations
```

---

# 41. DEFINITION OF DONE â€” DoD

Uma funcionalidade somente estÃ¡ DONE quando, conforme aplicÃ¡vel, possuir:

```text
Frontend real
Backend real
PersistÃªncia real
Migration
Constraints
API
OpenAPI
Business Rules
Authorization
RLS
Audit
Validation
Error Handling
Logging
Tests
Security Tests
Documentation
Acceptance Evidence
No Mock
No Fake Button
No TODO crÃ­tico
```

Se faltar requisito obrigatÃ³rio:

```text
NOT DONE
```

---

# 42. ESTADOS PERMITIDOS

O agente utilizarÃ¡:

```text
PLANNED
IN_PROGRESS
BLOCKED
READY_FOR_GATE
GATE_FAILED
GATE_PASSED
DONE
```

`PRODUCTION_READY` sÃ³ existe no fim do projecto.

---

# 43. PROIBIÃ‡ÃƒO DE CLAIM SEM EVIDÃŠNCIA

O agente nÃ£o poderÃ¡ dizer:

```text
DONE
COMPLETE
SECURE
PRODUCTION READY
TESTED
IMPLEMENTED
```

sem apresentar evidÃªncia verificÃ¡vel.

---

# 44. MILESTONE M0 â€” FOUNDATION & GOVERNANCE

## Objectivo

Criar a fundaÃ§Ã£o empresarial do SGP-DISPO.

## EntregÃ¡veis

```text
Repository
Monorepo
Workspace
TypeScript strict
Frontend baseline
Backend baseline
PostgreSQL
Migrations
Docker
Environment management
Logging
Error model
Health endpoints
CI baseline
Architecture documentation
Security baseline
OpenAPI baseline
ADR structure
Test harness
```

## M0-GATE

ObrigatÃ³rio:

```text
Build PASS
Lint PASS
Typecheck PASS
API starts
Web starts
PostgreSQL real starts
Migration PASS
Health live PASS
Health ready PASS
No mock operational data
No committed secret
Container security baseline PASS
```

Se qualquer requisito crÃ­tico falhar:

```text
M0 = FAILED
```

M1 nÃ£o pode iniciar.

---

# 45. MILESTONE M1 â€” IAM, AUTHORIZATION & SECURITY CONTEXT

Implementar:

```text
users
roles
permissions
sessions
authentication
authorization
RBAC
ABAC foundations
classification
clearance
compartments
security context
account lifecycle
lockout
session revocation
password policies
audit authentication events
RLS foundation
```

## M1-GATE

Testar:

```text
login
invalid login
lockout
logout
session revocation
permission deny
permission allow
cross-department deny
classification deny
RLS deny
RLS allow
privilege escalation attempt
```

Todos os cenÃ¡rios crÃ­ticos deverÃ£o passar.

---

# 46. MILESTONE M2 â€” ORGANIZAÃ‡ÃƒO, LOCALIZAÃ‡Ã•ES E REFERENCIAIS

## Objectivo

Construir a estrutura institucional e os referenciais que servirÃ£o de base segura a todos os domÃ­nios patrimoniais posteriores.

## Implementar

```text
organizational_units
hierarchy
departments
sections
units
locations
buildings
floors
rooms
warehouses
responsible officers
validity periods
cost centers
reference catalogs
asset types
category reference foundations
supplier reference foundations
location types
warehouse types
master data governance foundations
data quality rules
reference lifecycle
```

CRUD real + autorizaÃ§Ã£o + RLS + audit.

## Regras adicionais

- hierarquia data-driven, nunca hardcoded;
- impedir ciclos e movimentos hierÃ¡rquicos invÃ¡lidos;
- separar unidade organizacional de localizaÃ§Ã£o fÃ­sica;
- suportar validade temporal;
- centros de custo nÃ£o concedem autorizaÃ§Ã£o por si sÃ³;
- catÃ¡logos mestres deverÃ£o possuir cÃ³digo, estado, validade e auditoria quando aplicÃ¡vel;
- preparar referenciais para M3 sem criar activos fictÃ­cios;
- qualidade de dados deverÃ¡ detectar cÃ³digos duplicados, referÃªncias invÃ¡lidas e entidades Ã³rfÃ£s.

## M2-GATE

Demonstrar:

```text
criar unidade
editar
mover na hierarquia de forma controlada
desactivar
consultar
filtrar
impedir ciclo hierÃ¡rquico
proteger cross-scope access
auditar alteraÃ§Ãµes
criar e utilizar localizaÃ§Ã£o real
criar armazÃ©m real
validar centro de custo
validar integridade de referenciais
rejeitar duplicados proibidos
validar perÃ­odos temporais
provar paginaÃ§Ã£o server-side
provar RLS/API consistency
```

Nenhuma entidade de M2 poderÃ¡ exigir reescrita de M1.

---

# 47. MILESTONE M3 â€” PATRIMÃ“NIO E2E: AQUISIÃ‡ÃƒO, RECEPÃ‡ÃƒO, INCORPORAÃ‡ÃƒO E CADASTRO

## Objectivo

Implementar o nascimento institucional do activo, desde a origem documental da aquisiÃ§Ã£o/entrada atÃ© ao cadastro patrimonial utilizÃ¡vel.

## Implementar

```text
asset categories
subcategories
brands
models
assets
serial numbers
asset numbers
status
classification
acquisition
acquisition metadata
receipt
entry
incorporation
initial storage
initial assignment
supplier linkage
warranty
attachments
QR/barcode
asset criticality
asset risk classification
asset valuation baseline
acquisition value
book-value fields when applicable
intangible asset type
license/subscription metadata when applicable
```

## Regras adicionais

- separar aquisiÃ§Ã£o, recepÃ§Ã£o, incorporaÃ§Ã£o e cadastro;
- suportar entradas que nÃ£o sejam compra, quando juridicamente vÃ¡lidas e parametrizadas;
- impedir duplicaÃ§Ã£o indevida de serial/asset number;
- valor financeiro nunca substitui identidade patrimonial;
- depreciaÃ§Ã£o/amortizaÃ§Ã£o sÃ³ serÃ¡ activada segundo polÃ­tica institucional validada;
- activos intangÃ­veis deverÃ£o respeitar lifecycle prÃ³prio sem quebrar o modelo comum de activo;
- criticidade e risco sÃ£o atributos distintos de classificaÃ§Ã£o de informaÃ§Ã£o;
- QR/barcode nÃ£o transporta dados sensÃ­veis;
- anexos em storage controlado;
- fornecedores e garantias vinculados por referÃªncia real.

## M3-GATE

Fluxo E2E obrigatÃ³rio:

```text
Login
â†’ Register acquisition/entry source
â†’ Receive item
â†’ Validate receipt
â†’ Incorporate asset
â†’ Persist PostgreSQL
â†’ Generate internal UUID
â†’ Generate human asset number
â†’ Associate category/model/supplier/warranty
â†’ Generate QR/barcode reference
â†’ Retrieve through API
â†’ Display frontend
â†’ Audit events
â†’ Authorization validation
```

Provar adicionalmente:

```text
duplicate serial/asset number denied
classified asset hidden from unauthorized user
criticality persisted
financial baseline persisted when applicable
document access controlled
intangible asset scenario when enabled
zero mock operational data
```

Todos os passos devem ser reais.

---

# 48. MILESTONE M4 â€” MOVIMENTAÃ‡ÃƒO, CUSTÃ“DIA, WORKFLOW E RESPONSABILIDADE

## Objectivo

Controlar toda circulaÃ§Ã£o patrimonial e mudanÃ§a de responsabilidade com cadeia de custÃ³dia reconstruÃ­vel.

## Implementar

```text
assignment
custody
transfer
delivery
receipt
return
loan
temporary assignment
mission allocation
reservation
release
chain of custody
approval
maker-checker
workflow
workflow state
notification
escalation when applicable
responsibility terms
documents
transactional integrity
```

## Regras adicionais

- nenhuma transferÃªncia sobrescreve silenciosamente o estado anterior;
- emprÃ©stimos/cessÃµes possuem prazo, origem, destino, responsÃ¡vel e devoluÃ§Ã£o;
- reservas nÃ£o equivalem a afectaÃ§Ã£o concluÃ­da;
- workflows deverÃ£o ser parametrizÃ¡veis dentro de contratos controlados;
- notificaÃ§Ãµes nÃ£o substituem autorizaÃ§Ã£o;
- operaÃ§Ãµes crÃ­ticas deverÃ£o ser idempotentes quando expostas a repetiÃ§Ã£o;
- mudanÃ§a de custÃ³dia/localizaÃ§Ã£o/afectaÃ§Ã£o deve ser transaccional;
- termos de responsabilidade deverÃ£o ser versionados e auditÃ¡veis quando aplicÃ¡vel.

## M4-GATE

Teste E2E obrigatÃ³rio:

```text
Solicitar transferÃªncia
â†’ Aprovar
â†’ Confirmar entrega
â†’ Confirmar recepÃ§Ã£o
â†’ Actualizar localizaÃ§Ã£o
â†’ Actualizar custÃ³dia
â†’ Preservar histÃ³rico
â†’ Gerar auditoria
```

Adicionar cenÃ¡rios:

```text
maker = checker â†’ DENY quando incompatÃ­vel
self-approval â†’ DENY
loan â†’ return PASS
temporary assignment expiry handled
reservation conflict detected
duplicate request idempotent
notification generated from real event
partial failure â†’ rollback
cross-scope transfer unauthorized â†’ DENY
```

---

# 49. MILESTONE M5 â€” INVENTÃRIO FÃSICO, MOBILE E RECONCILIAÃ‡ÃƒO

## Objectivo

Provar a existÃªncia fÃ­sica, localizaÃ§Ã£o, custÃ³dia e condiÃ§Ã£o dos activos atravÃ©s de campanhas auditÃ¡veis, incluindo operaÃ§Ãµes de campo.

## Implementar

```text
inventory campaigns
scope
counting
QR scan
barcode scan
manual verification
mobile inventory workflow
offline controlled capture when required
secure synchronization
reconciliation
missing asset
unexpected asset
location discrepancy
custody discrepancy
condition discrepancy
photo evidence when authorized
risk/criticality-based inventory frequency
approval
closure
reports
```

## Regras adicionais

- mobile Ã© cliente do mesmo backend/autorizaÃ§Ã£o, nÃ£o sistema paralelo;
- offline, se necessÃ¡rio, deverÃ¡ usar dados mÃ­nimos, cifrados quando aplicÃ¡vel, validade curta e sincronizaÃ§Ã£o autenticada;
- conflito offline nÃ£o poderÃ¡ sobrescrever estado mais recente silenciosamente;
- imagem/evidÃªncia deve respeitar classificaÃ§Ã£o e storage controlado;
- inventÃ¡rios poderÃ£o ser priorizados por criticidade/risco;
- reconciliaÃ§Ã£o exige decisÃ£o e evidÃªncia, nÃ£o simples ediÃ§Ã£o do activo.

## M5-GATE

Executar inventÃ¡rio completo em TEST com dados efÃ©meros reais em PostgreSQL.

Validar:

```text
QR/barcode scan
manual count
missing asset
unexpected asset
location discrepancy
custody discrepancy
reconciliation approval
closure
mobile authorized user
mobile unauthorized user denied
offline capture + secure sync when feature enabled
sync conflict detected
audit reconstruction
real reports
```

---

# 50. MILESTONE M6 â€” MANUTENÃ‡ÃƒO, CONTRATOS, VALORIZAÃ‡ÃƒO E CICLO DE VIDA

## Objectivo

Gerir disponibilidade, manutenÃ§Ã£o, garantias, contratos, custos e encerramento do ciclo patrimonial.

## Implementar

```text
incident
breakdown
maintenance request
work order
provider
maintenance contract
SLA
warranty
spare parts
stock of parts/consumables related to maintenance
repair
cost
downtime
status
return to service
valuation adjustments when applicable
depreciation/amortization when applicable
revaluation when applicable
impairment when applicable
reclassification
retirement proposal
retirement approval
asset retirement
alienation
```

## Regras adicionais

- consumÃ­veis e sobressalentes nÃ£o devem ser confundidos com activos capitalizÃ¡veis;
- uso de stock deve produzir movimento e custo quando aplicÃ¡vel;
- garantia e contrato deverÃ£o influenciar elegibilidade/custo da intervenÃ§Ã£o;
- SLA deverÃ¡ medir tempos a partir de eventos reais;
- regras financeiras serÃ£o parametrizadas e homologadas; nÃ£o inventar polÃ­tica contabilÃ­stica;
- abate/alienaÃ§Ã£o exige workflow, evidÃªncia e preservaÃ§Ã£o do histÃ³rico;
- activo abatido nÃ£o Ã© apagado.

## M6-GATE

Validar ciclo integral:

```text
Operational
â†’ Fault
â†’ Maintenance Request
â†’ Work Order
â†’ Provider/Contract/Warranty evaluation
â†’ Repair
â†’ Cost/Downtime recorded
â†’ Repaired
â†’ Operational
```

E:

```text
Operational
â†’ Retirement Request
â†’ Approval
â†’ Retired / Alienated
```

Adicionar:

```text
warranty coverage decision
SLA measurement
part consumption
cost aggregation
financial adjustment when enabled
retired asset immutable history
failed maintenance workflow rollback
```

---

# 51. MILESTONE M7 â€” RELATÃ“RIOS, ANALYTICS, AUDITORIA E GOVERNANÃ‡A

## Objectivo

Transformar dados operacionais reais em controlo, decisÃ£o executiva e evidÃªncia de governanÃ§a.

## Implementar

```text
executive dashboard
operational dashboard
audit search
asset reports
movement reports
inventory reports
maintenance reports
department reports
financial/valuation reports when enabled
criticality/risk reports
contract/warranty/SLA reports
data quality reports
reconciliation reports
alerts
notifications
controlled exports
filters
pagination
aggregation
historical trends
```

## Indicadores mÃ­nimos quando aplicÃ¡veis

```text
total assets
asset value
assets by organization/location/category
assets without valid custody
assets in maintenance
downtime
warranty expirations
contracts/SLA status
inventory discrepancies
overdue inventories
pending transfers
missing assets
data quality exceptions
critical assets by condition
retired/alienated assets
```

## M7-GATE

Provar que:

```text
todos os indicadores provÃªm do PostgreSQL
nenhum KPI Ã© hardcoded
filtros respeitam autorizaÃ§Ã£o
exports respeitam RLS/ABAC
audit trail estÃ¡ Ã­ntegro
financial totals reconcile when enabled
alerts originate from real conditions
notifications correspond to real events
pagination is server-side
large exports are bounded and audited
historical trend is reproducible
```

---

# 52. MILESTONE M8 â€” INTEGRAÃ‡ÃƒO, HARDENING E OPERABILIDADE

## Objectivo

Preparar a plataforma para integraÃ§Ã£o institucional e operaÃ§Ã£o robusta em ambiente privado PNA sem degradar seguranÃ§a ou independÃªncia operacional.

## Executar

```text
security review
threat modelling
authorization matrix validation
RLS review
dependency review
secret scan
SAST
SCA
container scan
configuration hardening
rate limit validation
upload security
session review
logging review
error disclosure review
integration layer review
API interoperability
AD/LDAP/OIDC/SSO readiness or approved integration
HR integration when approved
ERP/finance integration when approved
SIEM integration when available
observability
structured logs
metrics
performance tuning
jobs/schedulers review
queue introduction only if justified
backup validation
restore test
network segmentation validation
TLS validation
secrets management validation
```

## Regras de integraÃ§Ã£o

- integraÃ§Ã£o nÃ£o pode criar segunda fonte autoritativa sem ADR;
- contratos de integraÃ§Ã£o deverÃ£o ser versionados;
- falha de sistema externo deve falhar de modo controlado;
- nÃ£o permitir acesso directo de integraÃ§Ãµes Ã s tabelas de negÃ³cio sem boundary autorizado;
- jobs e filas sÃ³ serÃ£o introduzidos quando necessidade comprovada justificar;
- sincronizaÃ§Ãµes devem possuir idempotÃªncia, retry bounded, dead-letter/error handling quando aplicÃ¡vel e auditabilidade.

## M8-GATE

Vulnerabilidades crÃ­ticas abertas:

```text
0
```

Vulnerabilidades altas sem decisÃ£o formal:

```text
0
```

Provar adicionalmente:

```text
integration contracts tested
external dependency failure handled
no authorization bypass through integration
SIEM/security events verified when integrated
metrics and alerts active
performance targets measured
secrets externalized
TLS validated
backup/restore PASS
network segmentation assumptions documented
```

---

# 53. MILESTONE M9 â€” SYSTEM ACCEPTANCE & PRODUCTION READINESS

## Objectivo

Executar aceitaÃ§Ã£o institucional integral e provar que o sistema completo pode operar em produÃ§Ã£o com dados reais, processos homologados e recuperaÃ§Ã£o comprovada.

## UAT / SAT

Cobrir:

```text
Authentication
Authorization
Administration
Organization
Locations
Reference Data
Acquisition / Entry
Receipt / Incorporation
Assets
Intangible Assets when enabled
Custody
Transfers
Loans / Temporary Assignments
Inventory
Mobile / QR / Barcode
Offline synchronization when enabled
Reconciliation
Maintenance
Contracts / Warranty / SLA
Stock / Spare Parts when enabled
Valuation / Depreciation when enabled
Retirement / Alienation
Documents
Workflow
Notifications
Dashboard
Reports
Audit
Integrations
Data Quality
Migration
Backup
Restore
PITR when applicable
Security
Performance
Failure Recovery
Observability
Operational Runbooks
Training
```

## MigraÃ§Ã£o e qualidade de dados

Antes de produÃ§Ã£o executar:

```text
Validate
Normalize
Stage
Detect duplicates
Resolve mapping
Review
Import transactionally
Reconcile
Approve
Produce migration evidence
```

## E2E institucional consolidado

Executar cenÃ¡rio integral:

```text
Administrador cria estrutura e referenciais
â†“
Gestor regista origem de aquisiÃ§Ã£o/entrada
â†“
Activo Ã© recebido e incorporado
â†“
Ã‰ cadastrado e etiquetado
â†“
Ã‰ armazenado / afectado
â†“
Custodiante recebe
â†“
Activo Ã© transferido ou temporariamente cedido
â†“
Outro custodiante recebe
â†“
InventÃ¡rio mobile/QR confirma existÃªncia e localizaÃ§Ã£o
â†“
DivergÃªncia Ã© reconciliada quando existente
â†“
Activo entra em manutenÃ§Ã£o
â†“
Contrato/garantia/SLA sÃ£o avaliados
â†“
Regressa ao serviÃ§o
â†“
RelatÃ³rios mostram operaÃ§Ã£o, custos e histÃ³rico
â†“
Auditor reconstrÃ³i toda a cadeia
â†“
Backup Ã© produzido
â†“
Ambiente descartÃ¡vel Ã© restaurado
â†“
AplicaÃ§Ã£o e dados restaurados sÃ£o validados
```

Tudo atravÃ©s de interfaces, APIs, PostgreSQL e storage reais.

## Acceptance de produÃ§Ã£o

Definir e validar:

```text
RPO
RTO
Retention
Backup policy
PITR strategy when applicable
DR procedure
Rollback plan
Monitoring
Alerting
Capacity baseline
Concurrent users target
API latency targets
Report performance targets
Security sign-off
Business sign-off
Technical sign-off
Training completion
Operational ownership
```

---

# 54. M9-GATE â€” PRODUCTION READINESS REVIEW

Somente aprovar quando:

```text
Functional tests PASS
Integration PASS
API PASS
Database PASS
RLS PASS
Authorization PASS
Security PASS
E2E PASS
UAT PASS
SAT PASS
Migration rehearsal PASS
Data reconciliation PASS
Mobile/QR PASS when in scope
Offline sync PASS when in scope
Institutional integrations PASS when in scope
Performance PASS
Capacity PASS
Backup PASS
Restore PASS
PITR PASS when applicable
DR procedure validated
Deployment PASS
Rollback PASS
Monitoring PASS
Alerting PASS
Documentation PASS
Runbooks PASS
Training PASS
No operational mocks
No fake buttons
No critical TODO
No critical vulnerability
No unresolved HIGH without formal decision
```

Resultado permitido:

```text
PRODUCTION_READY
```

ou:

```text
NOT_PRODUCTION_READY
```

NÃ£o existe aprovaÃ§Ã£o parcial fictÃ­cia.

---

# 55. MILESTONE M10 â€” PRODUCTION DEPLOYMENT

M10 somente poderÃ¡ iniciar apÃ³s M9 PASS.

Executar:

```text
production configuration
production secrets
TLS
database provisioning
migrations
application deployment
monitoring
logging
backup
restore validation
health validation
smoke test
access validation
UAT confirmation
runbook handover
```

---

# 56. GO-LIVE GATE

Antes do GO-LIVE:

```text
Change approval
Deployment plan
Rollback plan
Backup completed
Restore procedure verified
Monitoring active
Logging active
Security controls active
Users provisioned
Access reviewed
Data import validated
Smoke tests PASS
Business sign-off
Technical sign-off
Security sign-off
```

Resultado:

```text
GO-LIVE APPROVED
```

---

# 57. MODELO DE EXECUÃ‡ÃƒO DO AGENTE CODEX

Codex Ã© o responsÃ¡vel por:

```text
Architecture
Frontend
UX implementation
Backend
Database
Migrations
Security
RLS
Tests
Infrastructure
CI/CD
Documentation
Evidence
Deployment artefacts
```

NÃ£o deverÃ¡ delegar a integridade arquitectural a geradores exclusivamente visuais.

---

# 58. POLÃTICA DE UTILIZAÃ‡ÃƒO DE MODELOS IA

A escolha do modelo Ã© uma decisÃ£o de engenharia e gestÃ£o de custo.

PrincÃ­pio:

> Utilizar o modelo menos dispendioso capaz de executar a tarefa com qualidade e seguranÃ§a adequadas, elevando capacidade quando complexidade, risco ou impacto justificarem.

Os nomes SOL, ASTRA e TERRA deverÃ£o ser utilizados apenas quando estiverem efectivamente disponÃ­veis no ambiente do agente.

---

# 59. CLASSE TERRA â€” EXECUÃ‡ÃƒO DE VOLUME

Quando disponÃ­vel, utilizar TERRA prioritariamente para tarefas:

```text
repetitivas
bem especificadas
baixo risco
baixo acoplamento
refactors mecÃ¢nicos
CRUD seguindo padrÃ£o jÃ¡ estabilizado
test generation baseada em contrato existente
documentaÃ§Ã£o
formataÃ§Ã£o
lint fixes
type fixes simples
componentes UI repetitivos
migration boilerplate jÃ¡ definido
fixtures exclusivamente de teste
```

TERRA NÃƒO deverÃ¡ decidir sozinho:

```text
arquitectura
modelo de autorizaÃ§Ã£o
RLS crÃ­tico
criptografia
IAM
segregaÃ§Ã£o de funÃ§Ãµes
mudanÃ§as de schema de alto impacto
threat model
production topology
```

---

# 60. CLASSE SOL â€” ENGENHARIA PRINCIPAL

Utilizar SOL para:

```text
implementaÃ§Ã£o funcional
backend
frontend integrado
business rules
database design
API design
workflows
transactions
RLS implementation
authorization implementation
integration tests
E2E
debug complexo
code review
performance analysis
cross-module integration
```

SOL serÃ¡ o modelo de referÃªncia para a maioria da engenharia substantiva quando disponÃ­vel no ambiente.

---

# 61. CLASSE ASTRA â€” GATES E DECISÃ•ES CRÃTICAS

Quando ASTRA estiver disponÃ­vel no contexto de execuÃ§Ã£o utilizado, reservar prioritariamente para tarefas de maior risco ou maior impacto, tais como:

```text
architecture review
security architecture
threat modelling
IAM review
RBAC/ABAC review
RLS review
schema architecture
concurrency design
transaction correctness
critical incident diagnosis
major refactor decision
production readiness review
milestone gate validation
final acceptance review
```

ASTRA nÃ£o deverÃ¡ ser utilizado indiscriminadamente para tarefas mecÃ¢nicas de grande volume se outro modelo puder executÃ¡-las adequadamente.

---

# 62. REGRA DE ESCALATION

Fluxo:

```text
TERRA
  â†“ se insuficiente / ambÃ­guo / falha repetida
SOL
  â†“ se alto risco / gate crÃ­tico / arquitectura
ASTRA
```

NÃ£o repetir indefinidamente a mesma tarefa num modelo inadequado.

Escalar.

---

# 63. REGRA DE DE-ESCALATION

ApÃ³s uma decisÃ£o arquitectural estabilizada por modelo de maior capacidade:

```text
ASTRA/SOL define padrÃ£o
        â†“
SOL implementa padrÃ£o
        â†“
TERRA replica tarefas mecÃ¢nicas
```

quando tecnicamente apropriado.

---

# 64. CREDIT GOVERNANCE

O agente deverÃ¡ gerir custo sem degradar qualidade.

Antes de usar modelo de maior custo, classificar a tarefa:

```text
L1 â€” Mechanical
L2 â€” Standard Engineering
L3 â€” Complex Engineering
L4 â€” Critical Architecture/Security
L5 â€” Production Gate
```

Mapeamento recomendado:

```text
L1 â†’ TERRA
L2 â†’ TERRA ou SOL
L3 â†’ SOL
L4 â†’ SOL / ASTRA
L5 â†’ ASTRA ou modelo de maior capacidade disponÃ­vel
```

---

# 65. QUALIDADE PREVALECE SOBRE ECONOMIA

Nunca reduzir capacidade do modelo quando isso representar risco significativo para:

```text
seguranÃ§a
integridade de dados
autorizaÃ§Ã£o
RLS
transacÃ§Ãµes
arquitectura
produÃ§Ã£o
auditoria
testes de aceitaÃ§Ã£o
```

Regra:

```text
CUSTO OPTIMIZADO
â‰
QUALIDADE REDUZIDA
```

---

# 66. PROIBIÃ‡ÃƒO DE LOOP DE CRÃ‰DITOS

Evitar:

```text
tentativas repetidas sem diagnÃ³stico
regeneraÃ§Ã£o integral desnecessÃ¡ria
reescrita de mÃ³dulos funcionais
prompts gigantes para tarefas triviais
reviews redundantes
uso de modelo premium para formataÃ§Ã£o mecÃ¢nica
```

Antes de repetir execuÃ§Ã£o:

```text
identificar causa
reduzir escopo
preservar trabalho vÃ¡lido
corrigir somente necessÃ¡rio
```

---

# 67. CHECKPOINTS

Ao terminar cada milestone produzir:

```text
MILESTONE_REPORT.md
TEST_REPORT.md
SECURITY_REPORT.md
TRACEABILITY_UPDATE.md
KNOWN_ISSUES.md
EVIDENCE/
```

---

# 68. GATE INDEPENDENCE

O modelo que implementou uma alteraÃ§Ã£o crÃ­tica nÃ£o deverÃ¡ simplesmente auto-aprovar a sua prÃ³pria conclusÃ£o sem validaÃ§Ã£o.

Para gates crÃ­ticos:

```text
IMPLEMENT
â†“
TEST
â†“
REVIEW
â†“
EVIDENCE
â†“
GATE DECISION
```

Quando os recursos permitirem, usar contexto/revisÃ£o separada para reduzir confirmaÃ§Ã£o automÃ¡tica.

---

# 69. CHANGE CONTROL

Este Master Prompt estÃ¡:

```text
FROZEN
```

AlteraÃ§Ãµes somente atravÃ©s de:

```text
CR â€” CHANGE REQUEST
```

Cada CR deverÃ¡ conter:

```text
ID
Reason
Affected Requirement
Affected Architecture
Security Impact
Database Impact
Compatibility Impact
Migration Impact
Testing Impact
Rollback Plan
Decision
Approver
```

---

# 70. ADR

DecisÃµes arquitecturais relevantes deverÃ£o gerar Architecture Decision Record.

Exemplos:

```text
ADR-001 Authentication Architecture
ADR-002 RLS Context Propagation
ADR-003 Asset Number Strategy
ADR-004 Audit Architecture
ADR-005 Document Storage
ADR-006 Deployment Topology
```

---

# 71. REGRA DE NÃƒO REGRESSÃƒO

Nenhum milestone posterior poderÃ¡ destruir garantia jÃ¡ obtida por milestone anterior.

Antes de merge:

```text
regression tests
authorization tests
RLS tests
core E2E
```

deverÃ£o permanecer verdes.

---

# 72. PERFORMANCE

Definir e validar metas para:

```text
API latency
dashboard queries
search
pagination
report generation
concurrent users
database connection pool
memory
CPU
```

Evitar N+1.

Utilizar Ã­ndices justificados.

---

# 73. PAGINAÃ‡ÃƒO

Listagens potencialmente grandes deverÃ£o usar paginaÃ§Ã£o server-side.

Nunca carregar toda a tabela institucional no browser.

---

# 74. EXPORTAÃ‡Ã•ES

ExportaÃ§Ãµes deverÃ£o:

```text
respeitar RBAC
respeitar ABAC
respeitar RLS
ser auditadas
possuir limites
ser classificadas quando necessÃ¡rio
```

---

# 75. BACKUP

Implementar:

```text
Full backup
WAL / incremental strategy
PITR quando aplicÃ¡vel
Retention
Encryption
Restore testing
Off-host copy conforme infraestrutura
```

Backup nÃ£o validado por restore nÃ£o Ã© suficiente.

---

# 76. RPO / RTO

Definir formalmente antes de produÃ§Ã£o:

```text
RPO
RTO
Retention
Recovery Procedure
Responsible Team
```

---

# 77. OBSERVABILIDADE

ProduÃ§Ã£o deverÃ¡ possuir:

```text
structured logs
metrics
health
readiness
performance metrics
database metrics
security events
audit events
backup monitoring
disk monitoring
certificate monitoring
```

---

# 78. FAIL SAFE

Falhas de autorizaÃ§Ã£o deverÃ£o terminar em:

```text
DENY
```

e nÃ£o em acesso permissivo.

---

# 79. ERROS

Nunca devolver ao cliente:

```text
stack trace
database credentials
SQL internals sensÃ­veis
filesystem path sensÃ­vel
secret
internal token
```

---

# 80. IMPORTAÃ‡ÃƒO DE DADOS REAIS

Quando dados patrimoniais oficiais forem disponibilizados:

```text
Validate
Normalize
Stage
Check duplicates
Review
Import transactionally
Generate reconciliation report
Approve
```

Nunca importar directamente sem validaÃ§Ã£o.

---

# 81. DADOS SENSÃVEIS

Evitar incluir em logs:

```text
password
secret
full authentication token
credentials
classified document content
```

---

# 82. TESTE DE AUTORIZAÃ‡ÃƒO NEGATIVA

Para cada funÃ§Ã£o crÃ­tica deverÃ£o existir testes:

```text
authorized user succeeds
unauthorized user fails
cross-scope user fails
revoked user fails
tampered request fails
direct API access fails
```

---

# 83. TESTE DE RLS

O RLS deverÃ¡ ser testado directamente no PostgreSQL e via aplicaÃ§Ã£o.

NÃ£o aceitar apenas testes de frontend.

---

# 84. TESTE DE TRANSAÃ‡ÃƒO

Testar falha deliberada no meio de workflow para provar rollback.

---

# 85. TESTE DE AUDITORIA

Uma operaÃ§Ã£o crÃ­tica somente passa gate quando o evento de auditoria correspondente puder ser recuperado e correlacionado.

---

# 86. TESTE DE BACKUP E RESTORE

Executar:

```text
backup
destroy disposable environment
restore
validate data
validate application
```

antes de produÃ§Ã£o.

---

# 87. TESTE DE FALHA

Validar comportamento perante:

```text
PostgreSQL unavailable
storage unavailable
invalid token
expired session
network interruption
duplicate request
concurrency conflict
disk pressure
service restart
```

---

# 88. SECURITY ACCEPTANCE

Antes de produÃ§Ã£o:

```text
Threat model reviewed
Attack surface reviewed
Privilege model reviewed
RLS reviewed
Secrets reviewed
Dependencies reviewed
Images scanned
High-risk endpoints reviewed
Uploads reviewed
Exports reviewed
Audit reviewed
```

---

# 89. PRODUCTION DATA RULE

Dados reais de produÃ§Ã£o nÃ£o deverÃ£o ser copiados indiscriminadamente para DEV.

Quando necessÃ¡rio utilizar dados sanitizados mediante processo autorizado.

---

# 90. DOCUMENTAÃ‡ÃƒO OPERACIONAL

RUNBOOK deverÃ¡ cobrir:

```text
start
stop
restart
backup
restore
migration
rollback
user recovery
certificate renewal
log inspection
incident response
service failure
database failure
storage failure
```

---

# 91. ENTREGA FINAL

Entregar:

```text
Source code
Database migrations
Deployment manifests
Environment templates
OpenAPI
Architecture docs
Security docs
Runbooks
Backup/restore docs
Test suites
Test evidence
Traceability matrix
SBOM
Release notes
Production deployment guide
Rollback guide
Administrator guide
User guide
```

---

# 92. CRITÃ‰RIO SUPREMO

Antes de declarar qualquer componente concluÃ­do, perguntar:

> â€œEste componente pode ser utilizado agora numa rede interna real da PolÃ­cia Nacional de Angola com dados reais, controlos reais, persistÃªncia real, auditoria real e seguranÃ§a real?â€

Se:

```text
NÃƒO
```

estado:

```text
NOT DONE
```

---

# 93. PRODUCTION READY

`PRODUCTION_READY` somente poderÃ¡ ser declarado se houver evidÃªncia de:

```text
Functional Completeness
Database Persistence
Authorization
RLS
Auditability
Security
Integration
E2E
UAT
Backup/Restore
Deployment
Monitoring
Documentation
No operational mocks
No fake functionality
No critical vulnerabilities
No critical unresolved TODO
```

---

# 94. DIRECTIVA AO CODEX

NÃ£o gerar apenas interfaces.

NÃ£o simular integraÃ§Ãµes.

NÃ£o inventar dados.

NÃ£o esconder falhas atrÃ¡s de mocks.

NÃ£o marcar tarefas incompletas como concluÃ­das.

NÃ£o enfraquecer seguranÃ§a para acelerar desenvolvimento.

NÃ£o ignorar RLS.

NÃ£o confiar no frontend para autorizaÃ§Ã£o.

NÃ£o apagar histÃ³rico.

NÃ£o permitir operaÃ§Ãµes crÃ­ticas sem auditoria.

NÃ£o promover cÃ³digo sem testes.

NÃ£o declarar produÃ§Ã£o sem evidÃªncia.

---

# 95. LEMA DE ENGENHARIA

```text
BUILD â€” DON'T SIMULATE.

PERSIST â€” DON'T MOCK.

AUTHORIZE â€” DON'T JUST HIDE.

AUDIT â€” DON'T JUST LOG.

TEST â€” DON'T ASSUME.

INTEGRATE â€” DON'T DECORATE.

SECURE â€” DON'T PATCH SECURITY LATER.

PROVE â€” DON'T CLAIM.

SHIP PRODUCTION SOFTWARE â€” NOT A DEMO.
```

---

# 95-A. MATRIZ CONSOLIDADA DE RESPONSABILIDADE DOS DOMÃNIOS

| Milestone | Responsabilidade funcional principal | DomÃ­nios transversais associados |
|---|---|---|
| M0 | FundaÃ§Ã£o e governaÃ§Ã£o | CI/CD, observabilidade baseline, PostgreSQL, containers, documentaÃ§Ã£o |
| M1 | IAM, autorizaÃ§Ã£o e security context | RBAC, ABAC, RLS, classificaÃ§Ã£o, compartments, SoD, sessÃµes, auditoria de seguranÃ§a |
| M2 | Estrutura institucional e referenciais | LocalizaÃ§Ãµes, armazÃ©ns, centros de custo, master data, qualidade de dados |
| M3 | Nascimento e incorporaÃ§Ã£o do activo | AquisiÃ§Ã£o, recepÃ§Ã£o, fornecedor, garantia, documentaÃ§Ã£o, valor, criticidade, intangÃ­veis |
| M4 | CirculaÃ§Ã£o e responsabilidade | CustÃ³dia, transferÃªncias, emprÃ©stimos, cessÃµes, reservas, workflow, notificaÃ§Ãµes |
| M5 | ExistÃªncia fÃ­sica e reconciliaÃ§Ã£o | InventÃ¡rio, mobile, QR/barcode, offline controlado, evidÃªncia e divergÃªncias |
| M6 | Disponibilidade e fim de vida | ManutenÃ§Ã£o, contratos, SLA, stock/sobressalentes, custos, valorizaÃ§Ã£o, abate/alienaÃ§Ã£o |
| M7 | DecisÃ£o, controlo e governanÃ§a | Dashboards, BI, alertas, relatÃ³rios, auditoria, exportaÃ§Ãµes, qualidade |
| M8 | IntegraÃ§Ã£o e robustez operacional | AD/LDAP/OIDC, RH/ERP/FinanÃ§as/SIEM, integration layer, hardening, observabilidade, performance |
| M9 | Prova de prontidÃ£o | MigraÃ§Ã£o, UAT/SAT, backup/restore/PITR, DR, performance, formaÃ§Ã£o, runbooks |
| M10 | ProduÃ§Ã£o | Deployment, cutover, rollback, hypercare, aceite e transiÃ§Ã£o operacional |

## Regra de transversalidade

Um domÃ­nio transversal pode produzir requisitos em milestones anteriores ou posteriores ao seu milestone principal, mas:

1. deve existir um Ãºnico owner funcional principal;
2. a implementaÃ§Ã£o deve respeitar dependÃªncias e gates;
3. nÃ£o pode antecipar funcionalidade de um milestone bloqueado;
4. arquitectura preparatÃ³ria nÃ£o equivale a funcionalidade disponÃ­vel;
5. integraÃ§Ã£o futura pode ser preparada, mas somente Ã© declarada DONE quando o gate responsÃ¡vel for aprovado.

---

# 96. ESTADO DE GOVERNANÃ‡A

```text
MASTER PROMPT:
SGP-DISPO-MASTER-v1.1

STATUS:
FROZEN

AUTHORITY:
CANONICAL

CHANGE POLICY:
CHANGE REQUEST REQUIRED

IMPLEMENTATION AGENT:
CODEX

TARGET:
PNA INTERNAL PRODUCTION

FINAL ACCEPTANCE:
END-TO-END SYSTEM ACCEPTANCE REQUIRED
```

**FIM DA AUTORIDADE CANÃ“NICA â€” SGP-DISPO-MASTER-v1.1-FROZEN-FINAL**

---

# 97. BOOTSTRAP HISTÃ“RICO â€” NÃƒO EXECUTAR NO REPOSITÃ“RIO ACTUAL

> **Estado:** ARQUIVADO PARA RASTREABILIDADE. As SecÃ§Ãµes 97â€“101 documentam o bootstrap original do projecto quando M0 ainda nÃ£o existia. **NÃ£o constituem ordem operacional actual** e nÃ£o autorizam reiniciar M0/M1 nem apagar trabalho existente. No repositÃ³rio em desenvolvimento, a continuidade Ã© determinada pelos gates e pela Ãºltima autorizaÃ§Ã£o de milestone validamente emitida.

## Regra obrigatÃ³ria de utilizaÃ§Ã£o

```text
IF REPOSITORY IS NEW / EMPTY:
    historical bootstrap may be used
ELSE:
    DO NOT RESTART M0
    READ CURRENT GATE EVIDENCE
    PRESERVE EXISTING IMPLEMENTATION
    RESUME ONLY THE CURRENTLY AUTHORIZED MILESTONE
```

# 97-A. PRIMEIRO COMANDO OPERACIONAL HISTÃ“RICO AO CODEX

## CODEX EXECUTION COMMAND â€” M0 ONLY

Copiar e enviar ao Codex **juntamente com este ficheiro**, sem modificar o conteÃºdo do Master Prompt FROZEN:

```text
SGP-DISPO â€” ORDEM DE EXECUÃ‡ÃƒO INICIAL

1. Carregar e tratar o documento `SGP-DISPO-MASTER-v1.1-FROZEN-FINAL` como AUTORIDADE CANÃ“NICA e fonte mÃ¡xima de governaÃ§Ã£o arquitectural, de engenharia, seguranÃ§a, dados, testes e entrega deste projecto.

2. NÃ£o alterar, resumir, reinterpretar, substituir, enfraquecer ou contornar qualquer requisito do Master Prompt sem Change Request formal.

3. Executar EXCLUSIVAMENTE o MILESTONE M0 â€” FOUNDATION & GOVERNANCE.

4. Ã‰ EXPRESSAMENTE PROIBIDO iniciar, antecipar, implementar parcialmente ou preparar funcionalidade do M1 ou de qualquer milestone posterior antes da conclusÃ£o formal do M0.

5. Antes de escrever cÃ³digo, efectuar uma leitura integral do Master Prompt e produzir:
   - compreensÃ£o dos requisitos do M0;
   - lista dos entregÃ¡veis obrigatÃ³rios;
   - lista dos gates obrigatÃ³rios;
   - riscos e dependÃªncias;
   - estrutura proposta do repositÃ³rio;
   - plano de execuÃ§Ã£o do M0;
   - modelo IA recomendado para cada tarefa do M0 segundo a polÃ­tica TERRA / SOL / ASTRA, quando esses modelos estiverem disponÃ­veis.

6. O desenvolvimento nÃ£o Ã© protÃ³tipo, PoC, demo ou simulaÃ§Ã£o.

7. NÃ£o utilizar dados operacionais mockados, fake, dummy, sample ou hardcoded.

8. PostgreSQL real deve estar presente desde o M0 como banco de dados oficial.

9. Frontend, backend, banco de dados, migrations, infraestrutura, logging, health checks, testes e documentaÃ§Ã£o devem ser artefactos reais e executÃ¡veis.

10. Nenhum resultado poderÃ¡ ser marcado como DONE, COMPLETE, SECURE ou PRODUCTION READY sem evidÃªncias verificÃ¡veis.

11. O M0 somente poderÃ¡ ser declarado READY_FOR_GATE depois de todos os seus entregÃ¡veis estarem implementados.

12. Executar o M0-GATE integralmente.

13. O M0-GATE deverÃ¡ comprovar, no mÃ­nimo:

    - Build PASS
    - Lint PASS
    - Typecheck PASS
    - API starts
    - Web starts
    - PostgreSQL real starts
    - Migration PASS
    - /health/live PASS
    - /health/ready PASS
    - No mock operational data
    - No committed secret
    - Container security baseline PASS

14. Ao final do M0 produzir obrigatoriamente:

    - MILESTONE_REPORT.md
    - TEST_REPORT.md
    - SECURITY_REPORT.md
    - TRACEABILITY_UPDATE.md
    - KNOWN_ISSUES.md
    - EVIDENCE/

15. O relatÃ³rio final do M0 deverÃ¡ apresentar claramente uma Ãºnica decisÃ£o:

    M0_GATE = PASS

    ou

    M0_GATE = FAIL

16. Se qualquer requisito crÃ­tico falhar:

    M0_GATE = FAIL

    M1 permanece BLOQUEADO.

17. Mesmo que o M0 obtenha PASS, NÃƒO INICIAR M1 automaticamente.

18. ApÃ³s M0_GATE = PASS, parar a execuÃ§Ã£o e apresentar:
    - resumo tÃ©cnico;
    - evidÃªncias;
    - riscos residuais;
    - decisÃµes ADR tomadas;
    - consumo/estratÃ©gia de modelos IA;
    - recomendaÃ§Ã£o para o M1.

19. Aguardar uma nova ordem explÃ­cita para iniciar o M1.

20. Regra final:

    BUILD â€” DON'T SIMULATE.
    PERSIST â€” DON'T MOCK.
    AUTHORIZE â€” DON'T JUST HIDE.
    AUDIT â€” DON'T JUST LOG.
    TEST â€” DON'T ASSUME.
    PROVE â€” DON'T CLAIM.

EXECUTAR AGORA APENAS M0.
NÃƒO INICIAR M1.
```

---

# 98. PROCEDIMENTO DE REMESSA AO CODEX

## Passo 1 â€” Criar o repositÃ³rio oficial

Criar ou seleccionar o repositÃ³rio Git destinado ao projecto SGP-DISPO.

RecomendaÃ§Ã£o de nome:

```text
sgp-dispo
```

O repositÃ³rio deverÃ¡ tornar-se a fonte oficial do cÃ³digo, documentaÃ§Ã£o, migrations, testes e evidÃªncias.

---

## Passo 2 â€” Colocar este documento na raiz do repositÃ³rio

Guardar este ficheiro como:

```text
SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md
```

RecomendaÃ§Ã£o:

```text
/SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md
```

NÃ£o alterar o conteÃºdo depois do estado FROZEN.

Qualquer alteraÃ§Ã£o futura deverÃ¡ seguir o processo de Change Request definido neste documento.

---

## Passo 3 â€” Criar a estrutura inicial de governaÃ§Ã£o

Antes da execuÃ§Ã£o do agente, preparar no mÃ­nimo:

```text
/docs
/docs/adr
/docs/architecture
/docs/security
/docs/operations
/docs/requirements
/docs/evidence
```

O Codex poderÃ¡ completar a estrutura durante o M0.

---

## Passo 4 â€” Abrir o projecto no ambiente Codex

Disponibilizar ao Codex acesso ao repositÃ³rio oficial.

O agente deverÃ¡ trabalhar directamente sobre o repositÃ³rio real do projecto.

Evitar copiar cÃ³digo manualmente entre projectos ou manter versÃµes paralelas nÃ£o controladas.

---

## Passo 5 â€” Anexar ou referenciar este Master Prompt

No inÃ­cio da sessÃ£o do Codex:

1. disponibilizar `SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md`;
2. indicar que Ã© autoridade canÃ³nica;
3. fornecer o comando da SecÃ§Ã£o 97;
4. autorizar somente o M0.

---

## Passo 6 â€” NÃ£o pedir â€œconstrua o sistema inteiroâ€

NÃ£o utilizar comandos como:

```text
Construa todo o SGP-DISPO.
```

ou:

```text
Implemente todos os mÃ³dulos.
```

A execuÃ§Ã£o deverÃ¡ respeitar:

```text
M0
â†“ GATE
M1
â†“ GATE
M2
â†“ GATE
...
M10
```

Cada milestone deverÃ¡ ser autorizado separadamente.

---

## Passo 7 â€” GestÃ£o de modelos e crÃ©ditos

Para cada milestone, o Codex deverÃ¡ classificar as tarefas:

```text
L1 â€” Mechanical
L2 â€” Standard Engineering
L3 â€” Complex Engineering
L4 â€” Critical Architecture/Security
L5 â€” Production Gate
```

Routing recomendado, quando disponÃ­vel no ambiente:

```text
L1 â†’ TERRA
L2 â†’ TERRA ou SOL
L3 â†’ SOL
L4 â†’ SOL / ASTRA
L5 â†’ ASTRA ou modelo de maior capacidade disponÃ­vel
```

A regra de gestÃ£o Ã©:

```text
CUSTO OPTIMIZADO != QUALIDADE REDUZIDA
```

Tarefas de seguranÃ§a, arquitectura, IAM, RLS, transacÃ§Ãµes, produÃ§Ã£o, auditoria e gates nunca deverÃ£o ser degradadas apenas para economizar crÃ©ditos.

---

## Passo 8 â€” Exigir evidÃªncias antes do PASS

Nunca aceitar apenas uma mensagem do agente dizendo:

```text
M0 concluÃ­do.
```

Exigir evidÃªncias verificÃ¡veis.

O Codex deverÃ¡ demonstrar:

```text
comandos executados
resultados dos testes
migrations aplicadas
serviÃ§os em execuÃ§Ã£o
health checks
estrutura criada
logs relevantes
security checks
artefactos de documentaÃ§Ã£o
```

---

## Passo 9 â€” DecisÃ£o humana do gate

ApÃ³s o Codex produzir:

```text
M0_GATE = PASS
```

rever:

```text
MILESTONE_REPORT.md
TEST_REPORT.md
SECURITY_REPORT.md
TRACEABILITY_UPDATE.md
KNOWN_ISSUES.md
EVIDENCE/
```

Somente depois emitir a ordem seguinte.

---

## Passo 10 â€” Ordem futura para M1

A futura autorizaÃ§Ã£o deverÃ¡ ser enviada separadamente.

Modelo:

```text
SGP-DISPO â€” AUTORIZAÃ‡ÃƒO DE MILESTONE

MASTER:
SGP-DISPO-MASTER-v1.0-FROZEN

M0_GATE:
PASS

AUTORIZAÃ‡ÃƒO:
Iniciar exclusivamente M1 â€” IAM, AUTHORIZATION & SECURITY CONTEXT.

CONDIÃ‡ÃƒO:
NÃ£o iniciar M2 sem PASS formal no M1-GATE.

Executar M1 de acordo com todos os requisitos, DoR, DoD, evidÃªncias, testes e polÃ­ticas do Master Prompt FROZEN.
```

---

# 99. CHECKLIST DO OPERADOR ANTES DE REMETER AO CODEX

Confirmar:

```text
[ ] RepositÃ³rio oficial criado
[ ] Master Prompt FROZEN colocado na raiz
[ ] Nome do ficheiro preservado
[ ] Branch principal definida
[ ] Codex com acesso ao repositÃ³rio
[ ] Primeiro comando preparado
[ ] ExecuÃ§Ã£o limitada a M0
[ ] PostgreSQL real exigido
[ ] Zero mocks operacionais reafirmado
[ ] Gates obrigatÃ³rios reafirmados
[ ] PolÃ­tica SOL/ASTRA/TERRA incluÃ­da
[ ] EvidÃªncias obrigatÃ³rias incluÃ­das
[ ] M1 explicitamente bloqueado
```

---

# 100. REGRA DE CONTINUIDADE DO PROJECTO

A partir deste ponto, toda execuÃ§Ã£o do SGP-DISPO deverÃ¡ seguir o ciclo:

```text
AUTORIZAR MILESTONE
        â†“
IMPLEMENTAR
        â†“
TESTAR
        â†“
REVER
        â†“
PRODUZIR EVIDÃŠNCIAS
        â†“
EXECUTAR GATE
        â†“
PASS / FAIL
        â†“
DECISÃƒO HUMANA
        â†“
AUTORIZAR PRÃ“XIMO MILESTONE
```

Nunca:

```text
PROMPT ÃšNICO
â†“
GERAR SISTEMA TODO
â†“
ASSUMIR QUE ESTÃ PRONTO
```

---

# 101. COMANDO CURTO PARA COLAR NO CODEX

Caso o ficheiro jÃ¡ esteja presente no repositÃ³rio, pode ser utilizado este comando curto:

```text
Leia integralmente `SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.md` e trate-o como autoridade canÃ³nica do projecto. Execute exclusivamente o M0 â€” FOUNDATION & GOVERNANCE. NÃ£o inicie, antecipe ou implemente qualquer parte do M1. Cumpra integralmente DoR, DoD, requisitos de seguranÃ§a, PostgreSQL real, zero mocks operacionais, CI/CD, testes e evidÃªncias. Execute o M0-GATE e produza os artefactos obrigatÃ³rios. Se qualquer gate crÃ­tico falhar, declare `M0_GATE = FAIL` e mantenha M1 bloqueado. Se todos passarem, declare `M0_GATE = PASS`, apresente evidÃªncias e pare a execuÃ§Ã£o. NÃ£o avance para M1 sem nova autorizaÃ§Ã£o explÃ­cita.
```

---

**FIM DO DOCUMENTO CONSOLIDADO DE GOVERNANÃ‡A E HANDOFF AO CODEX**


---

# 101-A. COMANDO DE CONTINUIDADE PARA REPOSITÃ“RIO JÃ INICIADO

Quando este Master for entregue ao Codex num repositÃ³rio que jÃ¡ contÃ©m milestones implementados:

```text
1. Ler integralmente SGP-DISPO-MASTER-v1.1-FROZEN-FINAL.
2. NÃ£o executar o bootstrap histÃ³rico das SecÃ§Ãµes 97â€“101.
3. Identificar HEAD, migrations publicadas, gates e evidÃªncias existentes.
4. Preservar integralmente trabalho vÃ¡lido e migrations publicadas.
5. Determinar o Ãºltimo milestone formalmente aprovado e o milestone actualmente autorizado.
6. Retomar somente o milestone actualmente autorizado.
7. NÃ£o repetir milestones PASS salvo regressÃ£o necessÃ¡ria ou Change Request formal.
8. Aplicar CR-SGP-001 prospectivamente a M2â€“M9.
9. NÃ£o antecipar M2 se M1 ainda nÃ£o tiver o gate necessÃ¡rio.
10. NÃ£o iniciar milestone posterior sem autorizaÃ§Ã£o humana explÃ­cita.
```

### Regra suprema de continuidade

```text
RESUME â€” DO NOT RESTART.
EXTEND â€” DO NOT REWRITE.
MIGRATE FORWARD â€” DO NOT MUTATE HISTORY.
PRESERVE PASSED GATES.
```

---

# 102. CONGELAMENTO FINAL CONSOLIDADO

```text
MASTER:
SGP-DISPO-MASTER-v1.1

STATUS:
FROZEN â€” FINAL CONSOLIDADO

BASELINE ANTERIOR:
SGP-DISPO-MASTER-v1.0-FROZEN
SHA-256: 7CDE06093C1A3F0D7EF7C463BC7EE08CB4FCAC48F4B149D377166C0FF171A667

CHANGE REQUEST:
CR-SGP-001 â€” APPROVED

MILESTONE ORDER:
M0 â†’ M1 â†’ M2 â†’ M3 â†’ M4 â†’ M5 â†’ M6 â†’ M7 â†’ M8 â†’ M9 â†’ M10

COMPATIBILITY RULE:
NO BREAK OF APPROVED M0/M1 IMPLEMENTATION
NO REWRITE OF PUBLISHED MIGRATIONS
NO SECURITY DOWNGRADE
FORWARD-ONLY EVOLUTION

FINAL TARGET:
PRODUCTION_READY â†’ M10 â†’ GO-LIVE APPROVED
```

Qualquer alteraÃ§Ã£o posterior a este documento exige novo `CR â€” CHANGE REQUEST` formal.

**FIM DO DOCUMENTO CONSOLIDADO E FROZEN FINAL â€” SGP-DISPO-MASTER-v1.1-FROZEN-FINAL**
