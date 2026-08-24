# Controlled Vocabulary

CSV values are uppercase ASCII unless a field stores prose, a Joomla identifier, path, URL, version, date, or key. Use
`UNKNOWN` for unresolved required values and empty only when not applicable.

| Concept | Allowed values |
|---|---|
| Boolean | `YES`, `NO`, `UNKNOWN` |
| Profile | `CATALOG`, `COMPLETE` |
| Run status | `DRAFT`, `IN_PROGRESS`, `INCOMPLETE`, `BLOCKED`, `COMPLETE` |
| Record status | `ACTIVE`, `INACTIVE`, `CONDITIONAL`, `UNKNOWN`, `EXCLUDED`, `BLOCKED` |
| Evidence level | `VERIFIED`, `STATIC`, `INFERRED`, `UNKNOWN`, `BLOCKED` |
| Validation result | `PASS`, `FAIL`, `NOT_RUN`, `MANUAL`, `BLOCKED`, `NOT_APPLICABLE` |
| Surface | `SITE`, `ADMIN`, `API`, `CLI`, `BACKGROUND`, `SHARED` |
| Criticality/severity | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| Compatibility | `COMPATIBLE`, `PARTIAL`, `INCOMPATIBLE`, `UNKNOWN`, `NOT_APPLICABLE` |
| Ownership | `JOOMLA_CORE`, `CUSTOM`, `THIRD_PARTY`, `SHARED`, `EXTERNAL`, `UNKNOWN` |
| Implementation type | `COMPONENT`, `MODULE`, `PLUGIN`, `TEMPLATE`, `OVERRIDE`, `LIBRARY`, `PACKAGE`, `LANGUAGE`, `FILE`, `CLI_JOB`, `SCHEDULED_TASK`, `API`, `CUSTOM_SCRIPT`, `CONTENT`, `OTHER` |
| Data classification | `CONFIGURATION`, `CONTENT`, `TRANSACTION`, `REFERENCE`, `IDENTITY`, `SESSION`, `LOG`, `HISTORY`, `CACHE`, `GENERATED`, `ARCHIVE`, `UNKNOWN` |
| Migration disposition | `MIGRATE`, `TRANSFORM`, `REBUILD`, `REUSE_TARGET`, `ARCHIVE`, `DEFER`, `EXCLUDE`, `NOT_APPLICABLE`, `UNKNOWN`, `BLOCKED` |
| Dependency type | `DIRECT`, `INDIRECT`, `CONDITIONAL`, `DATA`, `RUNTIME`, `PRESENTATION`, `EXTERNAL`, `AUTHORIZATION`, `UNKNOWN` |
| Exception classification | `UNKNOWN`, `BLOCKER`, `AMBIGUITY`, `MISMATCH`, `EXCLUSION`, `MISSING_DEPENDENCY`, `MISSING_DATA`, `RUNTIME_FAILURE`, `MANUAL_DECISION` |
| Exception status | `OPEN`, `ACCEPTED`, `RESOLVED`, `DEFERRED`, `BLOCKED` |

Project-specific values such as feature categories, page types, usage types, evidence types, and coverage areas must be
declared in run notes or a project-local vocabulary before validation. Normalize synonyms before freezing a run.
