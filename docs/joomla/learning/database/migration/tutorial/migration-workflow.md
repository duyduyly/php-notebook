# End-to-End Database Migration Workflow Tutorial

> Controlled top-down database migration using preserved inventory detail, mapping definitions, one row per workflow step, centralized workflow history, one-time migration-script execution, and validation evidence.

---

## 1. Final Architecture

This document keeps the existing workflow and data model unchanged.

```text
workflow_enum                       hard-coded step definition/order
        ↓
workflow                            one named migration flow, e.g. JOOMLA_CORE
        ↓
workflow_step                       one row for every step in that workflow
        ↓
workflow_execution_history          one final evidence row for every workflow_step
```

Canonical workflow:

```text
INVENTORY_MAPPING
    ↓ PASS
INVENTORY_VERIFY
    ↓ PASS
MAPPING_VERIFY
    ↓ PASS
MIGRATION
    ↓ PASS
VALIDATION_DATA
    ↓ PASS
FINAL_VERIFY
    ↓ PASS
WORKFLOW PASS
```

No rollback step is added to the workflow.

Rollback is only a requirement inside the Codex-generated SQL for the current step.

---

## 2. Core Responsibility

### `migration_inventory`

```text
migration_inventory
│
├── INVENTORY DETAIL
│   ├── database_list
│   ├── inventory_snapshot
│   ├── table_list
│   ├── field_inventory
│   ├── table_dependency
│   └── record_inventory
│
├── WORKFLOW CONTROL
│   ├── workflow
│   ├── workflow_step
│   └── workflow_execution_history
│
├── EXECUTION DETAIL
│   ├── migration_script
│   ├── execute_log
│   ├── migration_step_result
│   └── migration_error
│
└── VALIDATION DETAIL
    ├── validation_result
    └── validation_failure
```

### `migration_mapping`

```text
migration_mapping
├── mapping_release
├── table_mapping
├── field_mapping
└── value_mapping
```

Inventory/mapping definitions remain unchanged. Workflow-level final evidence remains centralized in `workflow_execution_history`.

---

## 3. Hard-Coded Workflow Enum

`workflow_enum` is hard-coded in application/source code and is not a database table.

```text
10 INVENTORY_MAPPING
20 INVENTORY_VERIFY
30 MAPPING_VERIFY
40 MIGRATION
50 VALIDATION_DATA
60 FINAL_VERIFY
```

Recommended PHP enum:

```php
enum MigrationWorkflowStep: string
{
    case INVENTORY_MAPPING = 'INVENTORY_MAPPING';
    case INVENTORY_VERIFY = 'INVENTORY_VERIFY';
    case MAPPING_VERIFY = 'MAPPING_VERIFY';
    case MIGRATION = 'MIGRATION';
    case VALIDATION_DATA = 'VALIDATION_DATA';
    case FINAL_VERIFY = 'FINAL_VERIFY';

    public function order(): int
    {
        return match ($this) {
            self::INVENTORY_MAPPING => 10,
            self::INVENTORY_VERIFY => 20,
            self::MAPPING_VERIFY => 30,
            self::MIGRATION => 40,
            self::VALIDATION_DATA => 50,
            self::FINAL_VERIFY => 60,
        };
    }

    public function previous(): ?self
    {
        return match ($this) {
            self::INVENTORY_MAPPING => null,
            self::INVENTORY_VERIFY => self::INVENTORY_MAPPING,
            self::MAPPING_VERIFY => self::INVENTORY_VERIFY,
            self::MIGRATION => self::MAPPING_VERIFY,
            self::VALIDATION_DATA => self::MIGRATION,
            self::FINAL_VERIFY => self::VALIDATION_DATA,
        };
    }

    public function next(): ?self
    {
        return match ($this) {
            self::INVENTORY_MAPPING => self::INVENTORY_VERIFY,
            self::INVENTORY_VERIFY => self::MAPPING_VERIFY,
            self::MAPPING_VERIFY => self::MIGRATION,
            self::MIGRATION => self::VALIDATION_DATA,
            self::VALIDATION_DATA => self::FINAL_VERIFY,
            self::FINAL_VERIFY => null,
        };
    }
}
```

---

## 4. Workflow

One `workflow` row represents one complete named migration flow.

Recommended columns:

| Column | Type | Purpose |
|---|---|---|
| `id` | bigint UN AI PK | Workflow ID. |
| `workflow_name` | varchar(128) | Scope such as `JOOMLA_CORE`. |
| `workflow_version` | varchar(64) | Workflow version. |
| `source_snapshot_id` | bigint UN NULL | Filled by `INVENTORY_MAPPING`. |
| `target_snapshot_id` | bigint UN NULL | Filled by `INVENTORY_MAPPING`. |
| `mapping_release_id` | bigint UN NULL | Filled by `INVENTORY_MAPPING`. |
| `status` | varchar(16) | `PENDING/RUNNING/PASS/FAIL/LOCKED`. |
| `created_at` | datetime(6) | Created time. |
| `started_at` | datetime(6) NULL | Start time. |
| `completed_at` | datetime(6) NULL | Completion time. |

Recommended identity:

```text
UNIQUE (workflow_name, workflow_version)
```

Example:

```text
workflow_name    = JOOMLA_CORE
workflow_version = V1
```

---

## 5. Workflow Step

Each enum step is a separate row.

| step_order | step_code | Initial status |
|---:|---|---|
| 10 | `INVENTORY_MAPPING` | `PENDING` |
| 20 | `INVENTORY_VERIFY` | `PENDING` |
| 30 | `MAPPING_VERIFY` | `PENDING` |
| 40 | `MIGRATION` | `PENDING` |
| 50 | `VALIDATION_DATA` | `PENDING` |
| 60 | `FINAL_VERIFY` | `PENDING` |

Recommended columns:

```text
id
workflow_id
step_code
step_order
status
started_at
completed_at
updated_at
```

Recommended keys:

```text
UNIQUE (workflow_id, step_code)
UNIQUE (workflow_id, step_order)
```

Current step:

```text
1. RUNNING step if one exists;
2. otherwise the lowest step_order whose status is not PASS.
```

---

## 6. Workflow Execution History

`workflow_execution_history` stores the final reusable summary/evidence for one workflow step.

```text
workflow
   1
   │
   N
workflow_step
   1
   │
   0..1
workflow_execution_history
```

Recommended uniqueness remains:

```text
UNIQUE (workflow_step_id)
```

No `attempt_no`, rollback status, retry status, or additional history lifecycle is added.

Recommended evidence fields remain:

```text
workflow_step_id
mapping_release_id
source_snapshot_id
target_snapshot_id
mapping_version
contract_fingerprint

source_table_count
source_field_count
target_table_count
target_field_count
active_table_mapping_count
active_field_mapping_count

ready_field_count
skip_field_count
missing_field_count
processed_field_count
successful_field_count
failed_field_count

source_record_baseline_total
processed_record_count
successful_record_count
skipped_record_count
rebuilt_record_count
archived_record_count
failed_record_count
unaccounted_record_count

verification_checked_count
verification_passed_count
verification_failed_count

script_count
successful_script_count
failed_script_count

missing_record_count
unexpected_record_count
duplicate_record_count
broken_reference_count
migration_error_count
validation_failure_count

contract_verification
data_migration_verification
status
verified_at
```

Canonical final result:

```text
status = PASS / FAIL
```

The next workflow step is allowed only from a previous `PASS` history row.

---

## 7. Inventory Detail Tables

Keep unchanged:

```text
database_list
inventory_snapshot
table_list
field_inventory
table_dependency
record_inventory
```

```text
inventory detail
= exact discovered evidence

workflow_execution_history
= final step summary / reusable checkpoint
```

---

## 8. Mapping Tables

Keep unchanged:

```text
mapping_release
      ↓
table_mapping
      ↓
field_mapping
      ↓
value_mapping
```

`field_mapping.field_status` remains:

```text
READY
SKIP
MISSING
```

`INVENTORY_MAPPING` creates inventory + mapping definitions.

`INVENTORY_VERIFY` and `MAPPING_VERIFY` verify them separately.

---

## 9. Execution and Validation Detail

### Migration execution

```text
migration_script
      ↓
execute_log
      ↓
migration_step_result
      ↓
migration_error
```

One-time script guard remains unchanged:

```text
UNIQUE (workflow_step_id, script_id)
```

A successful committed MIGRATION execution therefore cannot be run again for the same workflow step.

### Data validation

```text
validation_result
      ↓
validation_failure
```

The workflow-level summary is written to the `VALIDATION_DATA` history row.

---

## 10. Top-Down Step Gate

For requested step `X`:

```text
1. Load the workflow.
2. Load workflow_step rows ordered by step_order.
3. Determine the first non-PASS step.
4. Requested step must equal that step.
5. Resolve the previous enum step.
6. Previous workflow_execution_history.status must be PASS, except for the first step.
7. Current workflow_step must not already have workflow_execution_history.
8. Execute only the current step.
9. Write detail evidence.
10. Insert the final workflow_execution_history row only when the step has reached its final result.
11. Mark the current workflow_step PASS only when history.status = PASS.
12. Never execute the next step automatically.
```

Rollback does not change these workflow rules.

---

## 11. Prompt-Only Rollback Rule

Rollback is intentionally implemented only inside generated SQL/prompt behavior. It is **not** a workflow step and does **not** add any database columns, tables, enums, or statuses.

For SQL that modifies data, Codex must prefer this pattern when technically safe:

```sql
START TRANSACTION;

-- prechecks
-- current-step writes
-- current-step detail evidence
-- verification/assertion queries

-- COMMIT only when every current-step success condition is satisfied.
COMMIT;
```

On a detected failure before commit:

```sql
ROLLBACK;
```

After rollback:

```text
- workflow data returns to its pre-run state for transactional writes;
- no final workflow_execution_history row should remain from the failed transaction;
- no committed execute_log/result row from the failed transaction should block the retry;
- the same workflow step can be corrected and the SQL can be run again;
- the next workflow step remains blocked.
```

Important constraint for Codex:

```text
If a required statement cannot be safely rolled back by the transaction,
Codex must document a compensating rollback block in the generated SQL
using the existing tables/data model only.
Do not add rollback tables, attempt tables, backup tables, or new workflow statuses.
```

This design intentionally does not preserve failed-attempt audit history. Persisting failed attempts while also allowing retries would require a different history/unique-key model, which is outside this workflow.

---

## 12. JOOMLA_CORE Seed Example

```sql
INSERT INTO migration_inventory.workflow (
    workflow_name,
    workflow_version,
    status
) VALUES (
    'JOOMLA_CORE',
    'V1',
    'PENDING'
);

SET @workflow_id = LAST_INSERT_ID();

INSERT INTO migration_inventory.workflow_step (
    workflow_id,
    step_code,
    step_order,
    status
) VALUES
    (@workflow_id, 'INVENTORY_MAPPING', 10, 'PENDING'),
    (@workflow_id, 'INVENTORY_VERIFY',  20, 'PENDING'),
    (@workflow_id, 'MAPPING_VERIFY',    30, 'PENDING'),
    (@workflow_id, 'MIGRATION',         40, 'PENDING'),
    (@workflow_id, 'VALIDATION_DATA',   50, 'PENDING'),
    (@workflow_id, 'FINAL_VERIFY',      60, 'PENDING');
```

Current allowed step:

```sql
SELECT id, workflow_id, step_code, step_order, status
FROM migration_inventory.workflow_step
WHERE workflow_id = @workflow_id
  AND status <> 'PASS'
ORDER BY step_order
LIMIT 1;
```

---

## 13. Codex Output Convention

Every workflow-step prompt must generate exactly two files:

```text
1. <order>-<step-code>-plan.md
2. <order>-<step-code>.sql
```

The plan file must contain:

```text
- complete scope;
- evidence/source list;
- ordered implementation plan;
- 100% scope checklist;
- prechecks;
- PASS/FAIL rules;
- rollback strategy for every write block;
- retry instructions after successful rollback;
- completion checklist.
```

The SQL file must contain numbered comments and this logical structure where applicable:

```text
00. workflow/current-step precheck
01. previous-step PASS gate
02. current-step duplicate/history guard
03. START TRANSACTION
04. current-step SQL writes/checks
05. detail evidence writes
06. current-step verification
07. COMMIT + final history/status update when PASS
08. ROLLBACK path when FAIL
09. compensating rollback SQL only when transaction rollback is insufficient
10. post-rollback checks/instructions showing that the same step may be retried
```

No SQL file may execute the next workflow step.

---

## 14. Codex Prompts Per Workflow Step

### Prompt — `INVENTORY_MAPPING`

```text
# Goal
Build the INVENTORY_MAPPING step for the selected migration workflow. Inventory 100% of the defined source/target schema scope and materialize the reviewed mapping contract without migrating application business data.

# Success criteria
- Confirm INVENTORY_MAPPING is the first allowed non-PASS workflow step.
- Account for every in-scope source/target table and physical field.
- Capture required record baselines and known dependencies.
- Create one mapping_release bound to the exact source/target snapshots.
- Materialize all reviewed table_mapping, field_mapping, and required STATIC value_mapping rows.
- Preserve READY / SKIP / MISSING exactly as defined.
- Update workflow source_snapshot_id, target_snapshot_id, and mapping_release_id.
- Insert the final workflow_execution_history row only when the step succeeds.
- Leave no partial committed preparation data when the step fails.

# Constraints
- Do not invent schema objects, dependencies, mappings, values, or counts.
- Do not silently drop in-scope source tables or fields.
- Do not run later workflow steps.
- Do not change the workflow, database schema, enum, or mapping logic.
- Use transaction rollback for current-step writes where safe.
- If transaction rollback is insufficient for an existing required statement, include compensating rollback SQL using only the existing data model.
- After rollback, leave the current step retryable and do not create a final history row.

# Output
Create exactly two files:
1. `10-inventory-mapping-plan.md` — plan, evidence list, ordered tasks, 100% checklist, PASS/FAIL conditions, rollback plan for every write block, retry instructions, and completion checklist.
2. `10-inventory-mapping.sql` — copy/paste runnable MySQL with numbered comments, workflow gates, START TRANSACTION where applicable, inventory/mapping writes, accounting checks, COMMIT only on success, ROLLBACK/compensating rollback on failure, post-rollback checks, final history insert and current-step PASS update only on success.
```

### Prompt — `INVENTORY_VERIFY`

```text
# Goal
Build the INVENTORY_VERIFY step that independently proves the inventory created by INVENTORY_MAPPING matches the actual selected source and target databases.

# Success criteria
- Confirm INVENTORY_MAPPING history = PASS.
- Confirm INVENTORY_VERIFY is the current first non-PASS step.
- Re-check source/target snapshot identity and schema evidence.
- Verify all in-scope tables, physical fields, record baselines, and required dependencies are accounted.
- Produce explicit missing/duplicate/unresolved counts.
- PASS only when required unresolved failure counts are zero.
- Insert the final workflow_execution_history row only when the step completes successfully.

# Constraints
- Do not change mapping definitions or application business data.
- Do not fabricate expected counts.
- Do not run later workflow steps.
- Do not change schema or workflow logic.
- Any temporary/control writes used by the SQL must be transaction-safe or have compensating cleanup/rollback using existing structures.
- A failed verification run must leave the step retryable and must not leave a final PASS history row.

# Output
Create exactly two files:
1. `20-inventory-verify-plan.md` — verification plan, evidence matrix, 100% checklist, PASS/FAIL rules, rollback/cleanup plan for SQL-side writes, retry instructions.
2. `20-inventory-verify.sql` — runnable MySQL with numbered comments, previous-step gate, inventory reconciliation, transaction/cleanup protection for writes, PASS/FAIL checks, final history insert and current-step PASS update only when successful.
```

### Prompt — `MAPPING_VERIFY`

```text
# Goal
Build the MAPPING_VERIFY step that proves the mapping_release completely and unambiguously covers the inventory already proven by INVENTORY_VERIFY.

# Success criteria
- Confirm INVENTORY_VERIFY history = PASS.
- Confirm MAPPING_VERIFY is the current first non-PASS step.
- Verify release snapshot binding, table mapping coverage, field mapping coverage, READY/SKIP/MISSING validity, required expressions/rules, and contract fingerprint.
- Unmapped, ambiguous, duplicate, invalid, and missing-rule counts must be zero for PASS.
- Insert the final workflow_execution_history row only on a successful completed verification.

# Constraints
- Do not alter mapping decisions to make verification pass.
- Do not migrate application data or run later steps.
- Do not change schema/workflow logic.
- Protect any SQL-side writes with rollback/cleanup using the existing data model only.
- A failed run must leave the current step retryable and must not leave a final PASS history row.

# Output
Create exactly two files:
1. `30-mapping-verify-plan.md` — mapping verification plan, coverage formulas, 100% checklist, zero-tolerance failure list, rollback/cleanup plan, retry instructions.
2. `30-mapping-verify.sql` — runnable MySQL with numbered comments, workflow gate, mapping checks, transaction/cleanup protection for writes, PASS/FAIL decision, final history insert and current-step PASS update only on success.
```

### Prompt — `MIGRATION`

```text
# Goal
Build the MIGRATION step that executes the required MySQL migration scripts from the verified mapping contract, records execution evidence, and fully accounts for migrated fields and records.

# Success criteria
- Confirm MAPPING_VERIFY history = PASS.
- Confirm MIGRATION is the current first non-PASS step.
- Determine all required migration scripts, stable script_id, hash/version, order, and dependencies.
- Enforce existing one-time execute_log guard for committed script execution.
- Every successful committed script has execute_log and migration_step_result evidence.
- Runtime errors are represented by the existing migration_error mechanism where applicable.
- failed_script_count, failed_field_count, failed_record_count, unaccounted_record_count, and migration_error_count must be zero before PASS.
- Insert final MIGRATION workflow_execution_history only after the complete migration transaction/result is successful.

# Constraints
- Do not change verified mapping rules or workflow/database schema.
- Do not run VALIDATION_DATA or FINAL_VERIFY.
- Do not silently continue after a failed migration assertion.
- Structure migration writes so a failure before final commit can be rolled back and the same MIGRATION step can be retried.
- Do not persist a failed execute_log/history row if doing so would trigger the existing uniqueness guard and prevent retry.
- If any existing required operation cannot be safely transaction-rolled back, provide compensating rollback SQL using existing tables only and document exactly how to verify restoration before retry.

# Output
Create exactly two files:
1. `40-migration-plan.md` — complete script inventory, dependency/order plan, 100% checklist, accounting formulas, existing one-time guards, rollback plan per migration block, restoration verification, and retry instructions.
2. `40-migration.sql` — copy/paste runnable MySQL with numbered comments, previous-step/current-step guards, transaction boundary where safe, migration blocks in dependency order, detail evidence writes, assertions, COMMIT only after success, ROLLBACK/compensating rollback on failure, restoration checks, then final workflow history and PASS update only for the successful committed run.
```

### Prompt — `VALIDATION_DATA`

```text
# Goal
Build the VALIDATION_DATA step that verifies actual migrated target data against the verified inventory/mapping contract and migration evidence without changing migrated business data.

# Success criteria
- Confirm MIGRATION history = PASS.
- Confirm VALIDATION_DATA is the current first non-PASS step.
- Verify record counts/identity, mapped field values, structured transformations, runtime ID/value outcomes, duplicates, missing/unexpected records, and broken references.
- Write validation_result / validation_failure evidence using the existing model.
- Required failure counters must be zero before PASS.
- Insert final VALIDATION_DATA history only when the verification step completes successfully.

# Constraints
- Verification only; do not repair migrated business data.
- Do not reinterpret mapping rules or run FINAL_VERIFY.
- Do not change database schema/workflow logic.
- Protect control/evidence writes with transaction rollback or compensating cleanup using existing tables.
- A failed validation run must not leave state that prevents the same VALIDATION_DATA step from being rerun after the cause is corrected.

# Output
Create exactly two files:
1. `50-validation-data-plan.md` — validation matrix, 100% checklist, PASS/FAIL formulas, rollback/cleanup strategy for validation evidence writes, and retry instructions.
2. `50-validation-data.sql` — runnable MySQL with numbered comments, previous-step gate, validation queries, protected evidence writes, failure counters, COMMIT/final history only on success, and ROLLBACK/cleanup path on failure.
```

### Prompt — `FINAL_VERIFY`

```text
# Goal
Build the FINAL_VERIFY step that proves the complete workflow chain executed in order, all previous required steps are PASS, all required data is accounted, and no unresolved migration/validation failure remains before marking the workflow PASS.

# Success criteria
- Confirm VALIDATION_DATA history = PASS.
- Confirm FINAL_VERIFY is the current first non-PASS step.
- Confirm all required previous workflow steps have PASS history.
- Confirm workflow snapshots/mapping release match prior evidence.
- Reconcile workflow history with inventory, mapping, execute_log, migration_step_result, validation_result, and validation_failure detail.
- All required failure/unaccounted counters must be zero.
- Insert FINAL_VERIFY history and set workflow PASS only when every gate succeeds.

# Constraints
- Do not mutate migrated business data or repair earlier steps.
- Do not alter earlier evidence, mapping logic, schema, or workflow.
- Do not mark PASS from workflow_step status alone.
- Protect final control-state updates in a transaction; if final assertions fail, rollback those current-step control writes so FINAL_VERIFY remains retryable.

# Output
Create exactly two files:
1. `60-final-verify-plan.md` — end-to-end reconciliation plan, history/detail checklist, zero-failure gate, rollback plan for final control writes, and retry instructions.
2. `60-final-verify.sql` — runnable MySQL with numbered comments, complete history/detail reconciliation, transaction-protected final history/workflow updates, COMMIT only on complete PASS, and ROLLBACK on any failed assertion.
```

---

## 15. Final Verification Rules

### `INVENTORY_VERIFY` PASS

```text
actual source tables accounted       = 100%
actual source fields accounted       = 100%
actual target tables accounted       = 100%
actual target fields accounted       = 100%
required inventory dependencies      = accounted
missing/duplicate inventory evidence = 0
status                               = PASS
```

### `MAPPING_VERIFY` PASS

```text
required table mappings       = 100% explicit
required field mappings       = 100% explicit
invalid READY/SKIP/MISSING    = 0
unmapped mappings             = 0
ambiguous mappings            = 0
missing migration rules       = 0
missing verification rules    = 0
contract_verification         = PASS
status                        = PASS
```

### `MIGRATION` PASS

```text
failed_script_count          = 0
failed_field_count           = 0
failed_record_count          = 0
unaccounted_record_count     = 0
migration_error_count        = 0
data_migration_verification  = PASS
status                       = PASS
```

### `VALIDATION_DATA` PASS

```text
verification_failed_count = 0
missing_record_count      = 0
unexpected_record_count   = 0
duplicate_record_count    = 0
broken_reference_count    = 0
validation_failure_count  = 0
status                    = PASS
```

### `FINAL_VERIFY` PASS

Required previous history:

```text
INVENTORY_MAPPING.status = PASS
INVENTORY_VERIFY.status  = PASS
MAPPING_VERIFY.status    = PASS
MIGRATION.status         = PASS
VALIDATION_DATA.status   = PASS
```

Only then:

```text
FINAL_VERIFY.status = PASS
workflow.status     = PASS
```

---

## Final Design Check

```text
workflow_enum
    = unchanged 6 hard-coded top-down steps

workflow
    = unchanged named migration flow

workflow_step
    = unchanged one row per step per workflow

workflow_execution_history
    = unchanged one final result/evidence row per workflow_step

inventory detail tables
    = unchanged

mapping tables
    = unchanged

execute_log / migration_step_result / migration_error
    = unchanged

validation_result / validation_failure
    = unchanged

rollback
    = prompt/SQL behavior only; no new workflow step, table, column, enum, status, or unique-key model
```
