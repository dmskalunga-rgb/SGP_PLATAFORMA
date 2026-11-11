# SGP-DISPO
## SISTEMA INTEGRADO DE GESTÃO DO PATRIMÓNIO DA DIRECÇÃO DE SEGURANÇA PÚBLICA E OPERAÇÕES — POLÍCIA NACIONAL DE ANGOLA

### MASTER PROMPT CANÓNICO DE ENGENHARIA, ARQUITECTURA, SEGURANÇA, GOVERNANÇA E ENTREGA

**Identificador:** `SGP-DISPO-MASTER-v1.0`  
**Estado:** `FROZEN`  
**Autoridade:** CANÓNICA  
**Natureza:** Enterprise / Sistema Institucional Crítico  
**Destino:** Infraestrutura interna da Polícia Nacional de Angola  
**Modo de implantação:** On-Premises / Rede privada institucional  
**Agente principal de engenharia:** Codex  
**Base de dados oficial:** PostgreSQL  
**Estado final exigido:** `PRODUCTION_READY`  
**Protótipo / Demo / PoC:** PROIBIDO como resultado final  
**Dados operacionais mock/fake/demo:** PROIBIDOS  
**Frontend desacoplado de dados reais:** PROIBIDO  
**Funcionalidades decorativas:** PROIBIDAS

---

# 0. AUTORIDADE CANÓNICA

Este documento constitui a autoridade máxima de governação técnica do projecto SGP-DISPO.

Quando existir conflito entre:

- implementação;
- documentação;
- decisões anteriores;
- prompts auxiliares;
- sugestões do agente;
- conveniência de desenvolvimento;
- atalhos técnicos;

prevalece este documento.

Nenhuma decisão do agente poderá reduzir os requisitos definidos neste Master Prompt.

O agente pode propor melhorias.

O agente não pode unilateralmente:

- remover controlos;
- substituir requisitos críticos;
- reduzir segurança;
- desactivar auditoria;
- enfraquecer RLS;
- introduzir mocks;
- alterar arquitectura fundamental;
- eliminar testes;
- contornar gates;
- declarar produção sem evidências.

---

# 1. OBJECTIVO FINAL

Construir um sistema real, completo, auditável, seguro e operacional para gestão do património da DISPO/PNA.

O sistema deverá poder ser instalado numa infraestrutura real da Polícia Nacional e operar com dados institucionais verdadeiros sem necessidade posterior de:

- substituir mocks;
- reconstruir backend;
- refazer banco de dados;
- reconstruir autenticação;
- reconstruir autorização;
- adicionar auditoria retroactivamente;
- refazer arquitectura;
- substituir dashboards fictícios;
- reimplementar workflows;
- reescrever páginas para integração real.

O produto deverá nascer como sistema de produção.

---

# 2. PRINCÍPIO FUNDAMENTAL

O SGP-DISPO:

**É:**

- aplicação enterprise;
- sistema transaccional;
- sistema institucional;
- sistema auditável;
- sistema multi-unidade;
- sistema seguro;
- sistema on-premises;
- sistema operacional;
- sistema com base de dados persistente;
- sistema pronto para ambientes DEV, TEST, STAGING e PRODUCTION.

**NÃO É:**

- protótipo;
- demonstração;
- mockup;
- PoC;
- aplicação académica;
- template;
- sistema visual;
- projecto frontend;
- conjunto de páginas;
- dashboard estático;
- simulação.

---

# 3. REGRA ABSOLUTA — ZERO MOCK OPERACIONAL

É proibida a utilização de:

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
Math.random() para dados de negócio
IDs inventados apresentados como informação institucional
```

Nenhuma tela deverá aparentar possuir dados que não existam efectivamente no PostgreSQL.

Quando não existirem dados:

```text
Total de activos: 0
```

é correcto.

Inventar:

```text
Total de activos: 3.842
```

é incorrecto.

---

# 4. EXCEPÇÃO CONTROLADA PARA TESTES

Dados efémeros poderão ser criados exclusivamente em:

```text
TEST
CI
E2E
INTEGRATION TEST ENVIRONMENT
```

para execução automatizada de testes.

Esses dados:

- não poderão chegar a produção;
- deverão possuir lifecycle controlado;
- deverão poder ser apagados/recriados;
- deverão ser claramente identificáveis como dados de teste.

Test doubles poderão existir em testes unitários quando tecnicamente apropriados.

Mocks nunca deverão ser usados para mascarar uma integração ausente no produto.

---

# 5. PRINCÍPIO DATA-DRIVEN

Fluxo obrigatório:

```text
Frontend
   ↓
API
   ↓
Application Services
   ↓
Domain / Business Rules
   ↓
Authorization
   ↓
Repository / Data Access
   ↓
PostgreSQL
```

Cada elemento visual que apresente informação operacional deverá possuir origem rastreável até uma fonte real.

---

# 6. STACK DE REFERÊNCIA

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
Redis quando tecnicamente necessário
Object Storage interno
Monitoring interno
Backup interno
SIEM interno quando disponível
```

A stack poderá ser refinada através de ADR.

Não deverá ser alterada por simples preferência do agente.

---

# 7. REPOSITÓRIO

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

O sistema deverá modelar dinamicamente:

```text
PNA
└── Comando-Geral
    └── DISPO
        ├── Direcção
        ├── Direcção Adjunta
        ├── Secretariado
        └── Departamentos
            └── Secções
                └── Unidades
                    └── Localizações
```

A hierarquia nunca deverá ser rigidamente codificada na interface.

Utilizar relação hierárquica configurável.

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

# 9. DOMÍNIOS FUNCIONAIS OBRIGATÓRIOS

A plataforma deverá contemplar, no mínimo:

```text
Organização Institucional
IAM
Utilizadores
Perfis
Permissões
Classificação da Informação
Departamentos
Secções
Localizações
Edifícios
Pisos
Salas
Armazéns

Património
Activos
Categorias
Subcategorias
Marcas
Modelos
Números de série
QR Code
Barcode

Aquisições
Recepção
Entrada
Armazenamento
Afectação
Custódia
Transferência
Devolução
Inventário físico
Reconciliação

Manutenção
Avaria
Reparação
Garantias
Prestadores

Abate
Alienação
Reclassificação

Viaturas
Equipamento TIC
Equipamento operacional
Mobiliário
Consumíveis
Instalações

Fornecedores
Contratos
Documentos

Workflow
Aprovações
Notificações

Auditoria
Eventos de segurança
Relatórios
Dashboard
Exportações autorizadas
Administração
Configuração
Observabilidade
```

---

# 10. MODELO DO ACTIVO

Cada activo deverá separar obrigatoriamente:

```text
PROPRIEDADE
AFECTAÇÃO ORGANIZACIONAL
LOCALIZAÇÃO FÍSICA
CUSTÓDIA
RESPONSABILIDADE
CLASSIFICAÇÃO
ESTADO OPERACIONAL
ESTADO PATRIMONIAL
```

Nunca tratar estes elementos como se fossem o mesmo conceito.

---

# 11. IDENTIFICAÇÃO PATRIMONIAL

Cada activo terá:

```text
internal_id = UUID/UUIDv7
asset_number = código patrimonial humano
```

Exemplo:

```text
PNA-DISPO-DOP-TIC-000001
```

O código humano não substitui o identificador interno.

---

# 12. POSTGRESQL COMO SOURCE OF TRUTH

PostgreSQL será a fonte autoritativa do sistema.

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

A integridade nunca poderá depender exclusivamente do frontend.

---

# 13. MIGRATIONS

Toda alteração estrutural será executada mediante migration versionada.

Proibido:

```text
alterar schema manualmente em produção
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

Seed proibido para fabricar inventário institucional fictício.

---

# 15. AUTENTICAÇÃO

O sistema deverá suportar inicialmente autenticação interna robusta e arquitectura pronta para integração futura com:

```text
Active Directory
LDAP
OIDC
SSO
MFA
```

A integração futura não deverá exigir reconstrução do IAM.

---

# 16. AUTORIZAÇÃO

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

A autorização deverá ser aplicada no servidor.

Esconder um botão no frontend não constitui autorização.

---

# 17. ROW LEVEL SECURITY

Tabelas sensíveis deverão utilizar PostgreSQL RLS.

Quando aplicável:

```sql
ENABLE ROW LEVEL SECURITY;
FORCE ROW LEVEL SECURITY;
```

Testes deverão provar:

```text
permitido → retorna dados
não autorizado → não retorna dados
tentativa de bypass → bloqueada
```

---

# 18. CLASSIFICAÇÃO

Implementar estrutura parametrizável.

Exemplo:

```text
Uso Geral
Uso Interno
Reservado
Confidencial
Secreto
```

A nomenclatura definitiva será validada pela PNA.

Activos e documentos poderão possuir classificação.

---

# 19. COMPARTIMENTAÇÃO

A política poderá considerar:

```text
organização
departamento
secção
unidade
localização
função
role
classification
clearance
categoria
missão
tipo de activo
operação
```

---

# 20. SEGREGAÇÃO DE FUNÇÕES — SoD

Operações críticas deverão utilizar maker-checker ou workflows equivalentes.

Exemplo:

```text
SOLICITANTE
     ↓
APROVADOR
     ↓
ENTREGADOR
     ↓
RECEPTOR
```

Quando aplicável, o mesmo utilizador não poderá acumular etapas incompatíveis.

---

# 21. MOVIMENTAÇÃO E CADEIA DE CUSTÓDIA

Uma transferência deverá produzir registo permanente.

Nunca sobrescrever silenciosamente a localização.

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

Eventos críticos deverão possuir:

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

A auditoria deverá ser separada de logs técnicos comuns.

---

# 23. HISTÓRICO IMUTÁVEL

Um activo deverá permitir reconstrução de:

```text
Aquisição
→ Recepção
→ Registo
→ Etiquetagem
→ Armazenamento
→ Afectação
→ Custódia
→ Transferência
→ Manutenção
→ Devolução
→ Inventário
→ Reclassificação
→ Abate
```

Nunca apagar a cadeia histórica por mera alteração do registo corrente.

---

# 24. APIs

Adoptar:

```text
/api/v1
```

Todas as funções deverão ter contrato real.

OpenAPI será obrigatório.

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

# 25. TRANSAÇÕES

Operações compostas deverão utilizar transacções.

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

# 26. CONCORRÊNCIA

Implementar, quando necessário:

```text
optimistic locking
version columns
transactions
appropriate isolation
idempotency
```

Dois utilizadores não poderão produzir estados contraditórios para o mesmo activo sem detecção.

---

# 27. DOCUMENTOS

Facturas, contratos, termos, fotografias e documentos não deverão ser expostos directamente em pasta pública.

Implementar:

```text
controlled object storage
authorization
metadata
hash
classification
audit
versioning quando aplicável
```

---

# 28. QR CODE

QR Code deverá representar referência segura.

Nunca deverá transportar dados sensíveis directamente.

Fluxo:

```text
Scan
 ↓
Authentication
 ↓
Authorization
 ↓
RLS/ABAC
 ↓
Asset view
```

---

# 29. FRONTEND ENTERPRISE

O frontend deverá ser completamente implementado pelo agente Codex.

Não existe separação entre “frontend visual” e “engenharia real”.

Cada página deverá possuir:

```text
API real
loading state
empty state
error state
authorization
validation
responsive behavior
accessibility adequada
persistência
telemetria necessária
```

---

# 30. ZERO BOTÕES FALSOS

Proibido:

```text
alert("Em breve")
console.log("TODO")
TODO buttons
disabled fake functionality
placeholder submit
```

Uma acção visível deverá:

```text
FUNCIONAR
```

ou não deverá ser publicada como disponível.

---

# 31. ZERO ROTAS DECORATIVAS

Toda rota deve executar o seu propósito real.

Uma rota visual sem backend/persistência não está concluída.

---

# 32. DASHBOARD

Todos os KPIs deverão ser produzidos a partir de consultas reais.

Nenhum número hardcoded.

Exemplos:

```text
Total de activos
Valor patrimonial
Distribuição por departamento
Distribuição por categoria
Activos em manutenção
Activos avariados
Activos sem custódia válida
Inventários em atraso
Transferências pendentes
```

---

# 33. SEGURANÇA DE APLICAÇÃO

Implementar quando aplicável:

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

É proibido colocar no repositório:

```text
password
API key
database credential
JWT secret
private key
production token
```

Produção deverá utilizar mecanismo seguro de secrets.

---

# 35. CONTAINERS

Containers de produção:

```text
non-root
minimal image
healthcheck
read-only filesystem quando possível
version pinning
resource limits quando aplicável
```

---

# 36. AMBIENTES

Manter separação:

```text
DEV
TEST
STAGING
PRODUCTION
```

PRODUCTION nunca deverá ser ambiente de experimentação.

---

# 37. CI/CD

Pipeline deverá executar gates como:

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

Falha de gate crítico bloqueia promoção.

---

# 38. ARTEFACTOS OBRIGATÓRIOS

Manter no repositório:

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

Cada requisito terá identificador.

Exemplo:

```text
SGP-IAM-001
SGP-AST-017
SGP-RLS-004
```

Fluxo:

```text
REQUIREMENT
   ↓
DESIGN
   ↓
ADR
   ↓
CODE
   ↓
MIGRATION
   ↓
API
   ↓
TEST
   ↓
EVIDENCE
```

Nenhum requisito crítico poderá permanecer sem teste ou evidência.

---

# 40. DEFINITION OF READY — DoR

Uma tarefa só entra em implementação quando possuir:

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

# 41. DEFINITION OF DONE — DoD

Uma funcionalidade somente está DONE quando, conforme aplicável, possuir:

```text
Frontend real
Backend real
Persistência real
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
No TODO crítico
```

Se faltar requisito obrigatório:

```text
NOT DONE
```

---

# 42. ESTADOS PERMITIDOS

O agente utilizará:

```text
PLANNED
IN_PROGRESS
BLOCKED
READY_FOR_GATE
GATE_FAILED
GATE_PASSED
DONE
```

`PRODUCTION_READY` só existe no fim do projecto.

---

# 43. PROIBIÇÃO DE CLAIM SEM EVIDÊNCIA

O agente não poderá dizer:

```text
DONE
COMPLETE
SECURE
PRODUCTION READY
TESTED
IMPLEMENTED
```

sem apresentar evidência verificável.

---

# 44. MILESTONE M0 — FOUNDATION & GOVERNANCE

## Objectivo

Criar a fundação empresarial do SGP-DISPO.

## Entregáveis

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

Obrigatório:

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

Se qualquer requisito crítico falhar:

```text
M0 = FAILED
```

M1 não pode iniciar.

---

# 45. MILESTONE M1 — IAM, AUTHORIZATION & SECURITY CONTEXT

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

Todos os cenários críticos deverão passar.

---

# 46. MILESTONE M2 — ORGANIZAÇÃO E LOCALIZAÇÕES

Implementar:

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
```

CRUD real + autorização + RLS + audit.

## M2-GATE

Demonstrar:

```text
criar unidade
editar
mover na hierarquia de forma controlada
desactivar
consultar
filtrar
impedir ciclo hierárquico
proteger cross-scope access
auditar alterações
```

---

# 47. MILESTONE M3 — CADASTRO PATRIMONIAL

Implementar:

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
acquisition metadata
attachments
QR/barcode
```

## M3-GATE

Fluxo E2E:

```text
Login
→ Create Asset
→ Persist PostgreSQL
→ Generate asset number
→ Retrieve through API
→ Display frontend
→ Audit event
→ Authorization validation
```

Todos os passos devem ser reais.

---

# 48. MILESTONE M4 — AFECTAÇÃO, MOVIMENTAÇÃO E CUSTÓDIA

Implementar:

```text
assignment
custody
transfer
delivery
receipt
return
chain of custody
approval
maker-checker
documents
transactional integrity
```

## M4-GATE

Teste E2E obrigatório:

```text
Solicitar transferência
→ Aprovar
→ Confirmar entrega
→ Confirmar recepção
→ Actualizar localização
→ Actualizar custódia
→ Preservar histórico
→ Gerar auditoria
```

Falha parcial deverá produzir rollback apropriado.

---

# 49. MILESTONE M5 — INVENTÁRIO FÍSICO

Implementar:

```text
inventory campaigns
scope
counting
QR scan
manual verification
reconciliation
missing asset
unexpected asset
location discrepancy
custody discrepancy
approval
closure
reports
```

## M5-GATE

Executar inventário completo em TEST com dados efémeros reais em PostgreSQL.

Validar reconciliação.

---

# 50. MILESTONE M6 — MANUTENÇÃO E CICLO DE VIDA

Implementar:

```text
incident
breakdown
maintenance request
work order
provider
warranty
repair
cost
status
return to service
retirement proposal
retirement approval
asset retirement
```

## M6-GATE

Validar ciclo integral:

```text
Operational
→ Fault
→ Maintenance
→ Repaired
→ Operational
```

e:

```text
Operational
→ Retirement Request
→ Approval
→ Retired
```

com histórico integral.

---

# 51. MILESTONE M7 — AUDITORIA, RELATÓRIOS E DASHBOARD

Implementar:

```text
executive dashboard
operational dashboard
audit search
asset reports
movement reports
inventory reports
maintenance reports
department reports
controlled exports
filters
pagination
aggregation
```

## M7-GATE

Provar que:

```text
todos os indicadores provêm do PostgreSQL
nenhum KPI é hardcoded
filtros respeitam autorização
exports respeitam RLS/ABAC
audit trail está íntegro
```

---

# 52. MILESTONE M8 — HARDENING

Executar:

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
backup validation
restore test
```

## M8-GATE

Vulnerabilidades críticas abertas:

```text
0
```

Vulnerabilidades altas sem decisão formal:

```text
0
```

---

# 53. MILESTONE M9 — SYSTEM ACCEPTANCE & PRODUCTION READINESS

Executar testes ponta-a-ponta completos.

## UAT / SAT

Cobrir:

```text
Authentication
Authorization
Administration
Organization
Locations
Assets
Custody
Transfers
Inventory
Maintenance
Retirement
Documents
Dashboard
Reports
Audit
Backup
Restore
Security
Failure Recovery
```

## E2E institucional

Executar cenário integral:

```text
Administrador cria estrutura
↓
Gestor cadastra activo
↓
Activo é recebido
↓
É etiquetado
↓
É afectado
↓
Custodiante recebe
↓
Activo é transferido
↓
Outro custodiante recebe
↓
Inventário confirma
↓
Activo entra em manutenção
↓
Regressa ao serviço
↓
Relatório mostra histórico
↓
Auditor reconstrói toda a cadeia
```

Tudo através de interfaces e APIs reais.

---

# 54. M9-GATE — PRODUCTION READINESS REVIEW

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
Backup PASS
Restore PASS
Deployment PASS
Rollback PASS
Monitoring PASS
Documentation PASS
No operational mocks
No fake buttons
No critical TODO
No critical vulnerability
```

Resultado permitido:

```text
PRODUCTION_READY
```

ou:

```text
NOT_PRODUCTION_READY
```

Não existe aprovação parcial fictícia.

---

# 55. MILESTONE M10 — PRODUCTION DEPLOYMENT

M10 somente poderá iniciar após M9 PASS.

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

# 57. MODELO DE EXECUÇÃO DO AGENTE CODEX

Codex é o responsável por:

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

Não deverá delegar a integridade arquitectural a geradores exclusivamente visuais.

---

# 58. POLÍTICA DE UTILIZAÇÃO DE MODELOS IA

A escolha do modelo é uma decisão de engenharia e gestão de custo.

Princípio:

> Utilizar o modelo menos dispendioso capaz de executar a tarefa com qualidade e segurança adequadas, elevando capacidade quando complexidade, risco ou impacto justificarem.

Os nomes SOL, ASTRA e TERRA deverão ser utilizados apenas quando estiverem efectivamente disponíveis no ambiente do agente.

---

# 59. CLASSE TERRA — EXECUÇÃO DE VOLUME

Quando disponível, utilizar TERRA prioritariamente para tarefas:

```text
repetitivas
bem especificadas
baixo risco
baixo acoplamento
refactors mecânicos
CRUD seguindo padrão já estabilizado
test generation baseada em contrato existente
documentação
formatação
lint fixes
type fixes simples
componentes UI repetitivos
migration boilerplate já definido
fixtures exclusivamente de teste
```

TERRA NÃO deverá decidir sozinho:

```text
arquitectura
modelo de autorização
RLS crítico
criptografia
IAM
segregação de funções
mudanças de schema de alto impacto
threat model
production topology
```

---

# 60. CLASSE SOL — ENGENHARIA PRINCIPAL

Utilizar SOL para:

```text
implementação funcional
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

SOL será o modelo de referência para a maioria da engenharia substantiva quando disponível no ambiente.

---

# 61. CLASSE ASTRA — GATES E DECISÕES CRÍTICAS

Quando ASTRA estiver disponível no contexto de execução utilizado, reservar prioritariamente para tarefas de maior risco ou maior impacto, tais como:

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

ASTRA não deverá ser utilizado indiscriminadamente para tarefas mecânicas de grande volume se outro modelo puder executá-las adequadamente.

---

# 62. REGRA DE ESCALATION

Fluxo:

```text
TERRA
  ↓ se insuficiente / ambíguo / falha repetida
SOL
  ↓ se alto risco / gate crítico / arquitectura
ASTRA
```

Não repetir indefinidamente a mesma tarefa num modelo inadequado.

Escalar.

---

# 63. REGRA DE DE-ESCALATION

Após uma decisão arquitectural estabilizada por modelo de maior capacidade:

```text
ASTRA/SOL define padrão
        ↓
SOL implementa padrão
        ↓
TERRA replica tarefas mecânicas
```

quando tecnicamente apropriado.

---

# 64. CREDIT GOVERNANCE

O agente deverá gerir custo sem degradar qualidade.

Antes de usar modelo de maior custo, classificar a tarefa:

```text
L1 — Mechanical
L2 — Standard Engineering
L3 — Complex Engineering
L4 — Critical Architecture/Security
L5 — Production Gate
```

Mapeamento recomendado:

```text
L1 → TERRA
L2 → TERRA ou SOL
L3 → SOL
L4 → SOL / ASTRA
L5 → ASTRA ou modelo de maior capacidade disponível
```

---

# 65. QUALIDADE PREVALECE SOBRE ECONOMIA

Nunca reduzir capacidade do modelo quando isso representar risco significativo para:

```text
segurança
integridade de dados
autorização
RLS
transacções
arquitectura
produção
auditoria
testes de aceitação
```

Regra:

```text
CUSTO OPTIMIZADO
≠
QUALIDADE REDUZIDA
```

---

# 66. PROIBIÇÃO DE LOOP DE CRÉDITOS

Evitar:

```text
tentativas repetidas sem diagnóstico
regeneração integral desnecessária
reescrita de módulos funcionais
prompts gigantes para tarefas triviais
reviews redundantes
uso de modelo premium para formatação mecânica
```

Antes de repetir execução:

```text
identificar causa
reduzir escopo
preservar trabalho válido
corrigir somente necessário
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

O modelo que implementou uma alteração crítica não deverá simplesmente auto-aprovar a sua própria conclusão sem validação.

Para gates críticos:

```text
IMPLEMENT
↓
TEST
↓
REVIEW
↓
EVIDENCE
↓
GATE DECISION
```

Quando os recursos permitirem, usar contexto/revisão separada para reduzir confirmação automática.

---

# 69. CHANGE CONTROL

Este Master Prompt está:

```text
FROZEN
```

Alterações somente através de:

```text
CR — CHANGE REQUEST
```

Cada CR deverá conter:

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

Decisões arquitecturais relevantes deverão gerar Architecture Decision Record.

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

# 71. REGRA DE NÃO REGRESSÃO

Nenhum milestone posterior poderá destruir garantia já obtida por milestone anterior.

Antes de merge:

```text
regression tests
authorization tests
RLS tests
core E2E
```

deverão permanecer verdes.

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

Utilizar índices justificados.

---

# 73. PAGINAÇÃO

Listagens potencialmente grandes deverão usar paginação server-side.

Nunca carregar toda a tabela institucional no browser.

---

# 74. EXPORTAÇÕES

Exportações deverão:

```text
respeitar RBAC
respeitar ABAC
respeitar RLS
ser auditadas
possuir limites
ser classificadas quando necessário
```

---

# 75. BACKUP

Implementar:

```text
Full backup
WAL / incremental strategy
PITR quando aplicável
Retention
Encryption
Restore testing
Off-host copy conforme infraestrutura
```

Backup não validado por restore não é suficiente.

---

# 76. RPO / RTO

Definir formalmente antes de produção:

```text
RPO
RTO
Retention
Recovery Procedure
Responsible Team
```

---

# 77. OBSERVABILIDADE

Produção deverá possuir:

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

Falhas de autorização deverão terminar em:

```text
DENY
```

e não em acesso permissivo.

---

# 79. ERROS

Nunca devolver ao cliente:

```text
stack trace
database credentials
SQL internals sensíveis
filesystem path sensível
secret
internal token
```

---

# 80. IMPORTAÇÃO DE DADOS REAIS

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

Nunca importar directamente sem validação.

---

# 81. DADOS SENSÍVEIS

Evitar incluir em logs:

```text
password
secret
full authentication token
credentials
classified document content
```

---

# 82. TESTE DE AUTORIZAÇÃO NEGATIVA

Para cada função crítica deverão existir testes:

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

O RLS deverá ser testado directamente no PostgreSQL e via aplicação.

Não aceitar apenas testes de frontend.

---

# 84. TESTE DE TRANSAÇÃO

Testar falha deliberada no meio de workflow para provar rollback.

---

# 85. TESTE DE AUDITORIA

Uma operação crítica somente passa gate quando o evento de auditoria correspondente puder ser recuperado e correlacionado.

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

antes de produção.

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

Antes de produção:

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

Dados reais de produção não deverão ser copiados indiscriminadamente para DEV.

Quando necessário utilizar dados sanitizados mediante processo autorizado.

---

# 90. DOCUMENTAÇÃO OPERACIONAL

RUNBOOK deverá cobrir:

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

# 92. CRITÉRIO SUPREMO

Antes de declarar qualquer componente concluído, perguntar:

> “Este componente pode ser utilizado agora numa rede interna real da Polícia Nacional de Angola com dados reais, controlos reais, persistência real, auditoria real e segurança real?”

Se:

```text
NÃO
```

estado:

```text
NOT DONE
```

---

# 93. PRODUCTION READY

`PRODUCTION_READY` somente poderá ser declarado se houver evidência de:

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

Não gerar apenas interfaces.

Não simular integrações.

Não inventar dados.

Não esconder falhas atrás de mocks.

Não marcar tarefas incompletas como concluídas.

Não enfraquecer segurança para acelerar desenvolvimento.

Não ignorar RLS.

Não confiar no frontend para autorização.

Não apagar histórico.

Não permitir operações críticas sem auditoria.

Não promover código sem testes.

Não declarar produção sem evidência.

---

# 95. LEMA DE ENGENHARIA

```text
BUILD — DON'T SIMULATE.

PERSIST — DON'T MOCK.

AUTHORIZE — DON'T JUST HIDE.

AUDIT — DON'T JUST LOG.

TEST — DON'T ASSUME.

INTEGRATE — DON'T DECORATE.

SECURE — DON'T PATCH SECURITY LATER.

PROVE — DON'T CLAIM.

SHIP PRODUCTION SOFTWARE — NOT A DEMO.
```

---

# 96. ESTADO DE GOVERNANÇA

```text
MASTER PROMPT:
SGP-DISPO-MASTER-v1.0

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

**FIM DA AUTORIDADE CANÓNICA — SGP-DISPO-MASTER-v1.0-FROZEN**

---

# 97. PRIMEIRO COMANDO OPERACIONAL A ENTREGAR AO CODEX

## CODEX EXECUTION COMMAND — M0 ONLY

Copiar e enviar ao Codex **juntamente com este ficheiro**, sem modificar o conteúdo do Master Prompt FROZEN:

```text
SGP-DISPO — ORDEM DE EXECUÇÃO INICIAL

1. Carregar e tratar o documento `SGP-DISPO-MASTER-v1.0-FROZEN` como AUTORIDADE CANÓNICA e fonte máxima de governação arquitectural, de engenharia, segurança, dados, testes e entrega deste projecto.

2. Não alterar, resumir, reinterpretar, substituir, enfraquecer ou contornar qualquer requisito do Master Prompt sem Change Request formal.

3. Executar EXCLUSIVAMENTE o MILESTONE M0 — FOUNDATION & GOVERNANCE.

4. É EXPRESSAMENTE PROIBIDO iniciar, antecipar, implementar parcialmente ou preparar funcionalidade do M1 ou de qualquer milestone posterior antes da conclusão formal do M0.

5. Antes de escrever código, efectuar uma leitura integral do Master Prompt e produzir:
   - compreensão dos requisitos do M0;
   - lista dos entregáveis obrigatórios;
   - lista dos gates obrigatórios;
   - riscos e dependências;
   - estrutura proposta do repositório;
   - plano de execução do M0;
   - modelo IA recomendado para cada tarefa do M0 segundo a política TERRA / SOL / ASTRA, quando esses modelos estiverem disponíveis.

6. O desenvolvimento não é protótipo, PoC, demo ou simulação.

7. Não utilizar dados operacionais mockados, fake, dummy, sample ou hardcoded.

8. PostgreSQL real deve estar presente desde o M0 como banco de dados oficial.

9. Frontend, backend, banco de dados, migrations, infraestrutura, logging, health checks, testes e documentação devem ser artefactos reais e executáveis.

10. Nenhum resultado poderá ser marcado como DONE, COMPLETE, SECURE ou PRODUCTION READY sem evidências verificáveis.

11. O M0 somente poderá ser declarado READY_FOR_GATE depois de todos os seus entregáveis estarem implementados.

12. Executar o M0-GATE integralmente.

13. O M0-GATE deverá comprovar, no mínimo:

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

15. O relatório final do M0 deverá apresentar claramente uma única decisão:

    M0_GATE = PASS

    ou

    M0_GATE = FAIL

16. Se qualquer requisito crítico falhar:

    M0_GATE = FAIL

    M1 permanece BLOQUEADO.

17. Mesmo que o M0 obtenha PASS, NÃO INICIAR M1 automaticamente.

18. Após M0_GATE = PASS, parar a execução e apresentar:
    - resumo técnico;
    - evidências;
    - riscos residuais;
    - decisões ADR tomadas;
    - consumo/estratégia de modelos IA;
    - recomendação para o M1.

19. Aguardar uma nova ordem explícita para iniciar o M1.

20. Regra final:

    BUILD — DON'T SIMULATE.
    PERSIST — DON'T MOCK.
    AUTHORIZE — DON'T JUST HIDE.
    AUDIT — DON'T JUST LOG.
    TEST — DON'T ASSUME.
    PROVE — DON'T CLAIM.

EXECUTAR AGORA APENAS M0.
NÃO INICIAR M1.
```

---

# 98. PROCEDIMENTO DE REMESSA AO CODEX

## Passo 1 — Criar o repositório oficial

Criar ou seleccionar o repositório Git destinado ao projecto SGP-DISPO.

Recomendação de nome:

```text
sgp-dispo
```

O repositório deverá tornar-se a fonte oficial do código, documentação, migrations, testes e evidências.

---

## Passo 2 — Colocar este documento na raiz do repositório

Guardar este ficheiro como:

```text
SGP-DISPO-MASTER-v1.0-FROZEN.md
```

Recomendação:

```text
/SGP-DISPO-MASTER-v1.0-FROZEN.md
```

Não alterar o conteúdo depois do estado FROZEN.

Qualquer alteração futura deverá seguir o processo de Change Request definido neste documento.

---

## Passo 3 — Criar a estrutura inicial de governação

Antes da execução do agente, preparar no mínimo:

```text
/docs
/docs/adr
/docs/architecture
/docs/security
/docs/operations
/docs/requirements
/docs/evidence
```

O Codex poderá completar a estrutura durante o M0.

---

## Passo 4 — Abrir o projecto no ambiente Codex

Disponibilizar ao Codex acesso ao repositório oficial.

O agente deverá trabalhar directamente sobre o repositório real do projecto.

Evitar copiar código manualmente entre projectos ou manter versões paralelas não controladas.

---

## Passo 5 — Anexar ou referenciar este Master Prompt

No início da sessão do Codex:

1. disponibilizar `SGP-DISPO-MASTER-v1.0-FROZEN.md`;
2. indicar que é autoridade canónica;
3. fornecer o comando da Secção 97;
4. autorizar somente o M0.

---

## Passo 6 — Não pedir “construa o sistema inteiro”

Não utilizar comandos como:

```text
Construa todo o SGP-DISPO.
```

ou:

```text
Implemente todos os módulos.
```

A execução deverá respeitar:

```text
M0
↓ GATE
M1
↓ GATE
M2
↓ GATE
...
M10
```

Cada milestone deverá ser autorizado separadamente.

---

## Passo 7 — Gestão de modelos e créditos

Para cada milestone, o Codex deverá classificar as tarefas:

```text
L1 — Mechanical
L2 — Standard Engineering
L3 — Complex Engineering
L4 — Critical Architecture/Security
L5 — Production Gate
```

Routing recomendado, quando disponível no ambiente:

```text
L1 → TERRA
L2 → TERRA ou SOL
L3 → SOL
L4 → SOL / ASTRA
L5 → ASTRA ou modelo de maior capacidade disponível
```

A regra de gestão é:

```text
CUSTO OPTIMIZADO != QUALIDADE REDUZIDA
```

Tarefas de segurança, arquitectura, IAM, RLS, transacções, produção, auditoria e gates nunca deverão ser degradadas apenas para economizar créditos.

---

## Passo 8 — Exigir evidências antes do PASS

Nunca aceitar apenas uma mensagem do agente dizendo:

```text
M0 concluído.
```

Exigir evidências verificáveis.

O Codex deverá demonstrar:

```text
comandos executados
resultados dos testes
migrations aplicadas
serviços em execução
health checks
estrutura criada
logs relevantes
security checks
artefactos de documentação
```

---

## Passo 9 — Decisão humana do gate

Após o Codex produzir:

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

## Passo 10 — Ordem futura para M1

A futura autorização deverá ser enviada separadamente.

Modelo:

```text
SGP-DISPO — AUTORIZAÇÃO DE MILESTONE

MASTER:
SGP-DISPO-MASTER-v1.0-FROZEN

M0_GATE:
PASS

AUTORIZAÇÃO:
Iniciar exclusivamente M1 — IAM, AUTHORIZATION & SECURITY CONTEXT.

CONDIÇÃO:
Não iniciar M2 sem PASS formal no M1-GATE.

Executar M1 de acordo com todos os requisitos, DoR, DoD, evidências, testes e políticas do Master Prompt FROZEN.
```

---

# 99. CHECKLIST DO OPERADOR ANTES DE REMETER AO CODEX

Confirmar:

```text
[ ] Repositório oficial criado
[ ] Master Prompt FROZEN colocado na raiz
[ ] Nome do ficheiro preservado
[ ] Branch principal definida
[ ] Codex com acesso ao repositório
[ ] Primeiro comando preparado
[ ] Execução limitada a M0
[ ] PostgreSQL real exigido
[ ] Zero mocks operacionais reafirmado
[ ] Gates obrigatórios reafirmados
[ ] Política SOL/ASTRA/TERRA incluída
[ ] Evidências obrigatórias incluídas
[ ] M1 explicitamente bloqueado
```

---

# 100. REGRA DE CONTINUIDADE DO PROJECTO

A partir deste ponto, toda execução do SGP-DISPO deverá seguir o ciclo:

```text
AUTORIZAR MILESTONE
        ↓
IMPLEMENTAR
        ↓
TESTAR
        ↓
REVER
        ↓
PRODUZIR EVIDÊNCIAS
        ↓
EXECUTAR GATE
        ↓
PASS / FAIL
        ↓
DECISÃO HUMANA
        ↓
AUTORIZAR PRÓXIMO MILESTONE
```

Nunca:

```text
PROMPT ÚNICO
↓
GERAR SISTEMA TODO
↓
ASSUMIR QUE ESTÁ PRONTO
```

---

# 101. COMANDO CURTO PARA COLAR NO CODEX

Caso o ficheiro já esteja presente no repositório, pode ser utilizado este comando curto:

```text
Leia integralmente `SGP-DISPO-MASTER-v1.0-FROZEN.md` e trate-o como autoridade canónica do projecto. Execute exclusivamente o M0 — FOUNDATION & GOVERNANCE. Não inicie, antecipe ou implemente qualquer parte do M1. Cumpra integralmente DoR, DoD, requisitos de segurança, PostgreSQL real, zero mocks operacionais, CI/CD, testes e evidências. Execute o M0-GATE e produza os artefactos obrigatórios. Se qualquer gate crítico falhar, declare `M0_GATE = FAIL` e mantenha M1 bloqueado. Se todos passarem, declare `M0_GATE = PASS`, apresente evidências e pare a execução. Não avance para M1 sem nova autorização explícita.
```

---

**FIM DO DOCUMENTO CONSOLIDADO DE GOVERNANÇA E HANDOFF AO CODEX**
