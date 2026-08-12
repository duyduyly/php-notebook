# End-to-End Database Migration Workflow Tutorial

> Controlled top-down database migration with an isolated test-database preflight, explicit producer/consumer contracts, checklist-driven Codex planning, prompt-only rollback, execution-until-PASS testing, centralized workflow history, and final MySQL files for manual execution.

---

## 1. Final Architecture

This revision changes the workflow only by adding the explicitly requested Step 0:

```text
TEST_DATABASE_SETUP
    ↓ PASS
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

`TEST_DATABASE_SETUP` exists to provide an isolated MySQL environment in which Codex can execute the generated SQL before returning the final files for manual use.

The runtime model remains:

```text
workflow_enum                       hard-coded step definition/order
        ↓
workflow                            one named migration flow, e.g. JOOMLA_CORE
        ↓
workflow_step                       one row for every step in that workflow
        ↓
workflow_execution_history          one final evidence row for every workflow_step
```

Rollback remains SQL/prompt behavior only. No rollback workflow step, attempt model, rollback table, or new rollback status is introduced.

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

The existing inventory, mapping, execution, validation, and workflow data models remain unchanged.

---

## 3. Hard-Coded Workflow Enum

`workflow_enum` is hard-coded in source code and is not a database table.

Canonical order:

```text
 0 TEST_DATABASE_SETUP
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
    case TEST_DATABASE_SETUP = 'TEST_DATABASE_SETUP';
    case INVENTORY_MAPPING = 'INVENTORY_MAPPING';
    case INVENTORY_VERIFY = 'INVENTORY_VERIFY';
    case MAPPING_VERIFY = 'MAPPING_VERIFY';
    case MIGRATION = 'MIGRATION';
    case VALIDATION_DATA = 'VALIDATION_DATA';
    case FINAL_VERIFY = 'FINAL_VERIFY';

    public function order(): int
    {
        return match ($this) {
            self::TEST_DATABASE_SETUP => 0,
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
            self::TEST_DATABASE_SETUP => null,
            self::INVENTORY_MAPPING => self::TEST_DATABASE_SETUP,
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
            self::TEST_DATABASE_SETUP => self::INVENTORY_MAPPING,
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

Recommended columns remain:

```text
id
workflow_name
workflow_version
source_snapshot_id
target_snapshot_id
mapping_release_id
status
created_at
started_at
completed_at
```

Recommended identity:

```text
UNIQUE (workflow_name, workflow_version)
```

Example:

```text
workflow_name    = JOOMLA_CORE
workflow_version = j3-to-j6-20260812-02
```

---

## 5. Workflow Step

Each enum step is a separate row.

| step_order | step_code | Initial status |
|---:|---|---|
| 0 | `TEST_DATABASE_SETUP` | `PENDING` |
| 10 | `INVENTORY_MAPPING` | `PENDING` |
| 20 | `INVENTORY_VERIFY` | `PENDING` |
| 30 | `MAPPING_VERIFY` | `PENDING` |
| 40 | `MIGRATION` | `PENDING` |
| 50 | `VALIDATION_DATA` | `PENDING` |
| 60 | `FINAL_VERIFY` | `PENDING` |

Recommended keys remain:

```text
UNIQUE (workflow_id, step_code)
UNIQUE (workflow_id, step_order)
```

Current step is:

```text
1. the RUNNING step if one exists;
2. otherwise the lowest step_order whose status is not PASS.
```

---

## 6. Workflow Execution History

`workflow_execution_history` remains the final reusable summary/evidence for one workflow step.

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

No `attempt_no`, rollback status, retry status, or alternative history lifecycle is introduced.

Canonical final result remains:

```text
status = PASS / FAIL
```

The next workflow step is allowed only from a previous `PASS` history row.

---

## 7. Step 0 — Test Database Contract

`TEST_DATABASE_SETUP` creates or prepares an isolated MySQL test environment before any generated migration SQL is accepted as final.

### Purpose

```text
Production / real migration databases
            │
            │ must not be used for Codex trial-and-error
            ▼
Isolated test database/environment
            │
            ├── run generated SQL
            ├── verify assertions
            ├── rollback/reset when needed
            ├── fix script
            └── rerun until PASS
```

### Required behavior

Codex must:

1. Detect the databases/schemas referenced by the migration workflow.
2. Create or select an isolated test database environment using names clearly marked as test-only.
3. Never overwrite or mutate the real source/target databases during the generation/test loop.
4. Reproduce enough schema/data baseline for the current step to be meaningfully executed.
5. Keep the real source database read-only during testing whenever possible.
6. If the workflow spans multiple MySQL schemas (`source`, `target`, `migration_inventory`, `migration_mapping`), create corresponding isolated test copies rather than pretending one schema is sufficient.
7. Record the exact test database names in `00-test-database-setup-plan.md`.
8. Do not mark Step 0 PASS until connectivity, schema availability, required permissions, and reset/rebuild capability have all been proven.

Step 0 does not change the existing migration table model. It prepares the environment in which the generated SQL is proven before manual execution.

---

## 8. Cross-Step Producer / Consumer Contract

This rule is mandatory for every plan and every SQL-generation step.

Before Codex generates final executable SQL, it must identify every value consumed by the current step and every value that the next step will consume.

For every required value, record:

```text
consumer step
required value/state
producer step
storage table.column
expected value/state
exact producer SQL block
verification query
```

Required decision rule:

```text
required value has a valid producer + verification
    → continue

required value has no producer
or producer SQL does not populate it
or expected state does not match
    → SCRIPT_CONTRACT_GAP
    → do not finalize SQL
    → fix the producer/current plan and SQL first
```

Example:

| Consumer | Required value | Producer | Storage | Producer SQL exists? |
|---|---|---|---|---|
| `INVENTORY_VERIFY` | source `coverage_status = PASS` | `INVENTORY_MAPPING` | `table_list.coverage_status` | must be PASS |
| `INVENTORY_VERIFY` | target `coverage_status = PASS` | `INVENTORY_MAPPING` | `table_list.coverage_status` | must be PASS |
| `MAPPING_VERIFY` | mapping release identity | `INVENTORY_MAPPING` | `workflow.mapping_release_id` | must be PASS |
| `MIGRATION` | contract verification PASS | `MAPPING_VERIFY` | `workflow_execution_history.status` | must be PASS |
| `VALIDATION_DATA` | migration accounting | `MIGRATION` | `migration_step_result` + history | must be PASS |
| `FINAL_VERIFY` | validation PASS | `VALIDATION_DATA` | `workflow_execution_history.status` | must be PASS |

A step cannot PASS only because its own SQL executed successfully. It can PASS only when:

```text
its own success criteria are satisfied
AND
all outputs required by the next step are actually persisted and verified
```

---

## 9. Mandatory Plan Checklist Format

Every `*-plan.md` must contain explicit Markdown checklists. A prose-only plan is not acceptable.

Each plan must contain these sections exactly or equivalently:

### A. Input and evidence checklist

```markdown
- [ ] Workflow identity resolved.
- [ ] Current workflow step resolved.
- [ ] Previous-step PASS evidence resolved where applicable.
- [ ] Source database/schema confirmed.
- [ ] Target database/schema confirmed.
- [ ] Required migration documents/mapping evidence loaded.
- [ ] No required input is assumed without evidence.
```

### B. Scope coverage checklist

```markdown
- [ ] 100% in-scope tables enumerated.
- [ ] 100% in-scope physical fields enumerated where applicable.
- [ ] 100% required record/accounting scope identified.
- [ ] Required dependencies/ordering identified.
- [ ] Explicit SKIP/IGNORE/ARCHIVE/REBUILD cases accounted where applicable.
- [ ] No unknown or silently omitted object remains.
```

### C. Producer / consumer checklist

```markdown
- [ ] Every value consumed by the current step has a producer.
- [ ] Every producer identifies exact table.column storage.
- [ ] Every producer identifies the SQL block that writes the value.
- [ ] Every consumed value has a verification query.
- [ ] Every output required by the next step is listed.
- [ ] Current SQL persists every required next-step output.
- [ ] SCRIPT_CONTRACT_GAP count = 0.
```

### D. SQL safety and rollback checklist

```markdown
- [ ] Write blocks identified.
- [ ] Transaction-safe blocks use START TRANSACTION/COMMIT/ROLLBACK where safe.
- [ ] Non-transaction-safe operations have compensating rollback/cleanup using existing structures only.
- [ ] Failed run cannot leave a final PASS history row.
- [ ] Failed run leaves the current step retryable.
- [ ] Real production/source data is not modified during Codex testing.
```

### E. Test execution checklist

```markdown
- [ ] Step 0 test environment is available.
- [ ] Generated SQL executed against the isolated test environment.
- [ ] SQL syntax/runtime errors = 0.
- [ ] Workflow gate errors = 0.
- [ ] Producer/consumer contract failures = 0.
- [ ] Required accounting assertions PASS.
- [ ] Rollback/reset tested when a failure path is relevant.
- [ ] Script rerun after correction succeeds from a clean/reset test baseline.
```

### F. PASS gate checklist

```markdown
- [ ] All Success criteria are proven.
- [ ] All required failure counters = 0.
- [ ] Required next-step outputs exist and are verified.
- [ ] Final history/status updates happen only on PASS.
- [ ] No later workflow step is executed automatically.
```

### G. Manual-run readiness checklist

```markdown
- [ ] Final SQL is the exact version that passed the isolated test execution.
- [ ] Test-only database/schema names are replaced by safe runtime variables/placeholders where required.
- [ ] Manual execution order is documented by numbered SQL comments.
- [ ] Required pre-run database names/variables are clearly listed at the top of the SQL file.
- [ ] Rollback instructions are present.
- [ ] Expected PASS result/check query is present at the end of the SQL file.
- [ ] No unresolved TODO/FIXME/placeholder remains except explicit user-supplied DB identifiers.
```

Checklist rules:

```text
- Codex may mark [x] only when it has concrete evidence.
- Every failed item remains [ ] and is listed in Blocking Items.
- Final SQL must not be returned as ready-for-manual-use while any blocking checklist item remains unchecked.
```

---

## 10. Generate → Execute → Fix → Regenerate Rule

For every workflow step, Codex must use this loop before returning the final SQL:

```text
Build/update plan + checklist
        ↓
Generate candidate SQL
        ↓
Execute candidate SQL on Step 0 test environment
        ↓
All required checks PASS?
   ┌────┴────┐
   NO       YES
   │          │
   ↓          ↓
Analyze       Finalize exact tested SQL
root cause        ↓
   ↓          Return plan + SQL for manual execution
Fix plan/SQL
   ↓
Reset/rollback test DB to required baseline
   ↓
Execute again
```

Codex must not stop at “SQL generated”.

Codex stops only when either:

```text
A. all required checks PASS in the test environment
   → return the exact tested SQL for manual execution

OR

B. a real external blocker prevents testing
   → do not claim success
   → list the blocker and the unchecked checklist items
```

A successful generation cycle requires:

```text
SQL parses and executes
workflow gates PASS
producer/consumer contract PASS
step-specific accounting PASS
rollback/reset safety PASS where applicable
next-step required outputs PASS
manual-run readiness checklist PASS
```

---

## 11. Prompt-Only Rollback Rule

Rollback remains prompt/SQL behavior only.

For transactional writes, prefer:

```sql
START TRANSACTION;

-- prechecks
-- current-step writes
-- detail evidence
-- assertions

COMMIT;
```

On failure before successful finalization:

```sql
ROLLBACK;
```

If an operation cannot be safely transaction-rolled back, Codex must document compensating rollback/cleanup SQL using the existing data model only.

Do not add:

```text
rollback workflow step
attempt table
rollback table
backup table as a new workflow feature
attempt_no
rollback_status
new workflow statuses
```

After rollback/reset, the same current step must be testable again from a known baseline.

---

## 12. Top-Down Step Gate

For requested step `X`:

```text
1. Load workflow.
2. Load workflow_step rows ordered by step_order.
3. Determine first non-PASS step.
4. Requested step must equal that step.
5. Resolve previous enum step.
6. Previous workflow_execution_history.status must be PASS, except Step 0.
7. Current workflow_step must not already have final workflow_execution_history.
8. Validate producer/consumer contract.
9. Execute only the current step on the isolated test environment during generation/testing.
10. Write required detail evidence.
11. Insert final workflow_execution_history only after all current-step checks PASS.
12. Mark current workflow_step PASS only when history.status = PASS.
13. Never execute the next workflow step automatically as part of the current step SQL.
```

---

## 13. JOOMLA_CORE Seed Example

```sql
INSERT INTO migration_inventory.workflow (
    workflow_name,
    workflow_version,
    status
) VALUES (
    'JOOMLA_CORE',
    'j3-to-j6-20260812-02',
    'PENDING'
);

SET @workflow_id = LAST_INSERT_ID();

INSERT INTO migration_inventory.workflow_step (
    workflow_id,
    step_code,
    step_order,
    status
) VALUES
    (@workflow_id, 'TEST_DATABASE_SETUP', 0,  'PENDING'),
    (@workflow_id, 'INVENTORY_MAPPING',   10, 'PENDING'),
    (@workflow_id, 'INVENTORY_VERIFY',    20, 'PENDING'),
    (@workflow_id, 'MAPPING_VERIFY',      30, 'PENDING'),
    (@workflow_id, 'MIGRATION',           40, 'PENDING'),
    (@workflow_id, 'VALIDATION_DATA',     50, 'PENDING'),
    (@workflow_id, 'FINAL_VERIFY',        60, 'PENDING');
```

Check current allowed step:

```sql
SELECT id, workflow_id, step_code, step_order, status
FROM migration_inventory.workflow_step
WHERE workflow_id = @workflow_id
  AND status <> 'PASS'
ORDER BY step_order
LIMIT 1;
```

Initially:

```text
CURRENT STEP = TEST_DATABASE_SETUP
```

---

## 14. Codex Output Convention

Every workflow-step prompt generates exactly two files:

```text
1. <order>-<step-code>-plan.md
2. <order>-<step-code>.sql
```

Examples:

```text
00-test-database-setup-plan.md
00-test-database-setup.sql

10-inventory-mapping-plan.md
10-inventory-mapping.sql

20-inventory-verify-plan.md
20-inventory-verify.sql
```

The final `.sql` file must be the **exact candidate that passed the isolated test execution**, except for explicitly documented runtime database-name variables/placeholders required for manual execution.

The SQL file must use numbered comments, for example:

```text
00. required variables / database names
01. workflow/current-step precheck
02. previous-step PASS gate
03. producer/consumer assertions
04. START TRANSACTION where applicable
05. current-step writes/checks
06. detail evidence
07. current-step verification
08. next-step output verification
09. final history/status update
10. COMMIT on PASS
11. ROLLBACK/cleanup instructions on failure
12. final manual PASS verification query
```

---

## 15. Codex Prompts Per Workflow Step

### Prompt — `TEST_DATABASE_SETUP`

```text
# Goal
Create and prove an isolated MySQL test database/environment for the selected migration workflow so every later generated SQL file can be executed, corrected, reset, and rerun safely before it is returned for manual execution.

# Success criteria
- Resolve all schemas/databases referenced by the workflow.
- Create/select clearly named test-only equivalents without modifying real source/target data.
- Confirm MySQL connectivity, required permissions, charset/collation expectations, and required engines.
- Reproduce the minimum source/target/control baseline needed to execute later workflow SQL meaningfully.
- Prove the environment can be reset/recreated after a failed test run.
- Create the TEST_DATABASE_SETUP final history row only when all environment checks PASS.
- Produce explicit test database names and reset instructions for later steps.

# Constraints
- Never use production/real target databases for Codex trial-and-error execution.
- Prefer source data read-only; clone/copy only what is needed for isolated testing.
- If the workflow references multiple schemas, create isolated test equivalents for all required schemas rather than collapsing incompatible schemas into one.
- Do not change the existing workflow-control schema beyond the requested Step 0 row.
- Do not run INVENTORY_MAPPING or any later workflow step.
- Do not claim PASS unless the reset/rebuild path has been demonstrated.

# Output
Create exactly two files:
1. `00-test-database-setup-plan.md` — include the mandatory Input/Evidence, Scope, Producer/Consumer, Safety/Rollback, Test Execution, PASS Gate, and Manual-Run Readiness checklists; list exact test database names, baseline strategy, permissions, reset procedure, and blocking items.
2. `00-test-database-setup.sql` — copy/paste runnable MySQL with numbered comments to create/select the isolated test environment, verify permissions/schema availability, prepare the required baseline, verify reset readiness, and write final Step 0 history/PASS only when all checks succeed.
Execute this SQL against the test MySQL environment. If it fails, fix the plan/SQL and rerun until all required checks PASS before returning the final files.
```

### Prompt — `INVENTORY_MAPPING`

```text
# Goal
Build INVENTORY_MAPPING to inventory 100% of the defined source/target scope and materialize the reviewed mapping contract without migrating application business data.

# Success criteria
- Confirm TEST_DATABASE_SETUP history = PASS.
- Confirm INVENTORY_MAPPING is the current first non-PASS step.
- Account for every in-scope source/target table and physical field.
- Capture record baselines and required dependencies.
- Create mapping_release bound to the exact source/target snapshots.
- Materialize reviewed table_mapping, field_mapping, and required STATIC value_mapping rows.
- Preserve READY / SKIP / MISSING exactly as approved.
- Populate every status/value consumed by INVENTORY_VERIFY and MAPPING_VERIFY, including source and target coverage state.
- Update workflow source_snapshot_id, target_snapshot_id, and mapping_release_id.
- Producer/consumer contract gap count = 0.
- Final history and current-step PASS are written only after every check succeeds.

# Constraints
- Do not invent schema objects, dependencies, mappings, values, or counts.
- Do not silently omit in-scope source or target objects.
- Do not run later workflow steps.
- Use prompt-only rollback/cleanup rules from this document.
- Test only in the Step 0 isolated environment during generation.
- If a downstream-required value has no producer, stop with SCRIPT_CONTRACT_GAP and fix the plan/SQL before finalizing.

# Output
Create exactly two files:
1. `10-inventory-mapping-plan.md` — include all seven mandatory checklist groups, a complete Producer/Consumer Matrix, ordered implementation tasks, 100% scope accounting, rollback/reset strategy, blocking items, and PASS formulas.
2. `10-inventory-mapping.sql` — numbered, copy/paste runnable MySQL with workflow gates, producer/consumer assertions, inventory/mapping writes, source+target coverage updates, accounting checks, rollback/cleanup, next-step output verification, and final history/PASS only on success.
Execute the candidate SQL on the Step 0 test environment. On any failure, identify root cause, update plan/checklist, fix/regenerate SQL, reset/rollback the test baseline, and rerun. Return only the exact SQL version that passes all checks.
```

### Prompt — `INVENTORY_VERIFY`

```text
# Goal
Build INVENTORY_VERIFY to independently prove that INVENTORY_MAPPING matches the actual selected source and target databases and that all inventory evidence required by mapping verification exists.

# Success criteria
- Confirm INVENTORY_MAPPING history = PASS.
- Confirm INVENTORY_VERIFY is the current first non-PASS step.
- Build a consumer list for every status/count/snapshot/table/field/dependency value used by this step.
- Trace every consumed value to its producer table.column and exact producer SQL block.
- Verify source/target snapshot identity, tables, physical fields, record baselines, dependencies, and required coverage statuses.
- Missing, duplicate, unresolved, and SCRIPT_CONTRACT_GAP counts = 0.
- Verify every output required by MAPPING_VERIFY exists.
- Final history/PASS is written only after every verification succeeds.

# Constraints
- Do not repair INVENTORY_MAPPING silently inside the verifier.
- If a required value was not produced by Step 10, report SCRIPT_CONTRACT_GAP and fix the producing plan/SQL rather than hiding the defect.
- Do not change mapping decisions or application business data.
- Do not run later steps.
- Use the isolated Step 0 environment for execution testing.

# Output
Create exactly two files:
1. `20-inventory-verify-plan.md` — include all seven mandatory checklist groups, Producer/Consumer Matrix, evidence matrix, 100% verification checklist, PASS/FAIL formulas, rollback/cleanup plan, and blocking items.
2. `20-inventory-verify.sql` — numbered runnable MySQL with previous-step gate, producer checks, source/target inventory reconciliation, coverage-status checks, failure counters, next-step output verification, protected final history/PASS update, and rollback/cleanup path.
Execute on the isolated test environment and keep fixing/regenerating until all required checks PASS. Return only the successfully tested SQL.
```

### Prompt — `MAPPING_VERIFY`

```text
# Goal
Build MAPPING_VERIFY to prove that the mapping_release completely, uniquely, and executably covers the inventory already proven by INVENTORY_VERIFY.

# Success criteria
- Confirm INVENTORY_VERIFY history = PASS.
- Confirm MAPPING_VERIFY is the current first non-PASS step.
- Trace every consumed mapping/snapshot/status/fingerprint value to a valid producer.
- Verify release snapshot binding, table mapping coverage, field mapping coverage, READY/SKIP/MISSING validity, required migration/verification rules, and contract fingerprint.
- Unmapped, ambiguous, duplicate, invalid, missing-rule, and SCRIPT_CONTRACT_GAP counts = 0.
- Verify every contract/result required by MIGRATION is persisted.
- Final history/PASS is written only when the complete contract verification succeeds.

# Constraints
- Do not alter mapping decisions simply to make verification pass.
- Do not migrate application data or run later steps.
- Do not invent a producer for missing mapping state.
- Use the Step 0 isolated environment for all generated-SQL execution/testing.

# Output
Create exactly two files:
1. `30-mapping-verify-plan.md` — include all seven mandatory checklist groups, Producer/Consumer Matrix, coverage formulas, zero-tolerance failure checklist, rollback/cleanup plan, and blocking items.
2. `30-mapping-verify.sql` — numbered runnable MySQL with workflow gate, producer assertions, mapping coverage checks, READY/SKIP/MISSING checks, fingerprint/contract checks, MIGRATION-output readiness checks, and final history/PASS only on complete success.
Execute, diagnose, fix/regenerate, reset, and rerun in the isolated test environment until all checks PASS; return only the tested SQL.
```

### Prompt — `MIGRATION`

```text
# Goal
Build MIGRATION to execute the required MySQL migration operations from the verified mapping contract, record execution evidence, and fully account for migrated fields and records.

# Success criteria
- Confirm MAPPING_VERIFY history = PASS.
- Confirm MIGRATION is the current first non-PASS step.
- Trace every consumed mapping/ID/value/dependency input to its producer.
- Determine all required migration scripts/blocks, stable script_id, hash/version, execution order, and dependencies.
- Respect the existing one-time execute_log guard for successful committed execution.
- Every required script/block has explicit field/record accounting.
- failed_script_count = 0, failed_field_count = 0, failed_record_count = 0, unaccounted_record_count = 0, migration_error_count = 0.
- Persist every migration result/runtime mapping/evidence required by VALIDATION_DATA.
- Producer/consumer contract gap count = 0.
- Final MIGRATION history/PASS is written only after all migration assertions succeed.

# Constraints
- Do not change verified mapping rules or database/workflow schema.
- Do not run VALIDATION_DATA or FINAL_VERIFY.
- Do not silently continue after a failed assertion.
- Failed test runs must be rollback/reset so they do not consume the one-time execution guard.
- Use only the Step 0 isolated environment while generating/testing.

# Output
Create exactly two files:
1. `40-migration-plan.md` — include all seven mandatory checklist groups, complete script/block inventory, Producer/Consumer Matrix, dependency/order checklist, accounting formulas, one-time guard checks, rollback/reset plan per write block, and blocking items.
2. `40-migration.sql` — numbered copy/paste runnable MySQL with previous-step gate, producer assertions, execution-order guards, migration blocks, execute_log/result/error handling, aggregate accounting, VALIDATION_DATA-output readiness checks, rollback/reset path, and final history/PASS only on success.
Execute the candidate on the isolated test environment. Any failure requires root-cause analysis, plan/checklist correction, SQL regeneration, baseline reset, and rerun. Return only the exact SQL that passes all checks.
```

### Prompt — `VALIDATION_DATA`

```text
# Goal
Build VALIDATION_DATA to verify actual migrated target data against verified inventory, mapping, and migration evidence without repairing business data.

# Success criteria
- Confirm MIGRATION history = PASS.
- Confirm VALIDATION_DATA is the current first non-PASS step.
- Trace every consumed migration result, runtime mapping, expected count, and mapping rule to its producer.
- Verify record counts/identity, mapped field values, transformations, runtime ID/value outcomes, duplicates, missing/unexpected records, and broken references.
- Write validation_result / validation_failure using the existing model.
- verification_failed_count = 0, missing_record_count = 0, unexpected_record_count = 0, duplicate_record_count = 0, broken_reference_count = 0, validation_failure_count = 0.
- Verify every result required by FINAL_VERIFY exists.
- SCRIPT_CONTRACT_GAP count = 0.
- Final history/PASS is written only after complete validation succeeds.

# Constraints
- Verification only; do not repair migrated business data.
- Do not reinterpret mapping rules or run FINAL_VERIFY.
- Missing producer evidence is a contract defect, not permission to infer a value.
- Use the Step 0 isolated environment during SQL generation/testing.

# Output
Create exactly two files:
1. `50-validation-data-plan.md` — include all seven mandatory checklist groups, Producer/Consumer Matrix, validation matrix, table/field/record/reference coverage checklist, PASS/FAIL formulas, rollback/cleanup strategy for evidence writes, and blocking items.
2. `50-validation-data.sql` — numbered runnable MySQL with previous-step gate, producer assertions, validation queries, validation_result/failure writes, failure counters, FINAL_VERIFY-output readiness checks, protected final history/PASS update, and rollback/cleanup path.
Execute/fix/regenerate/reset/rerun until all validation checks PASS in the isolated environment. Return only the exact tested SQL.
```

### Prompt — `FINAL_VERIFY`

```text
# Goal
Build FINAL_VERIFY to prove that the complete workflow chain executed in order, all required prior steps are PASS, all data/evidence is accounted, and no unresolved migration or validation failure remains before marking the workflow PASS.

# Success criteria
- Confirm VALIDATION_DATA history = PASS.
- Confirm FINAL_VERIFY is the current first non-PASS step.
- Confirm one valid PASS history row for every required previous step including TEST_DATABASE_SETUP.
- Trace all final counts/statuses/snapshots/mapping releases/script evidence/validation evidence to their producers.
- Reconcile workflow history with inventory, mapping, execute_log, migration_step_result, validation_result, and validation_failure detail.
- All required failed/unaccounted/missing/unexpected/duplicate/broken-reference/migration-error/validation-failure/SCRIPT_CONTRACT_GAP counts = 0.
- Final history and workflow PASS are written only after every reconciliation check succeeds.

# Constraints
- Do not mutate migrated business data or repair earlier steps.
- Do not alter earlier evidence, mapping logic, schema, or workflow.
- Do not mark PASS from workflow_step status alone.
- Use the isolated Step 0 environment to test the generated final-verification SQL before returning it for manual use.

# Output
Create exactly two files:
1. `60-final-verify-plan.md` — include all seven mandatory checklist groups, complete end-to-end Producer/Consumer Matrix, history/detail reconciliation checklist, zero-failure gate, final control-write rollback plan, and blocking items.
2. `60-final-verify.sql` — numbered runnable MySQL with complete history/detail/producer reconciliation, final zero-failure assertions, transaction-protected final history/workflow PASS updates, rollback on any failed assertion, and final PASS query.
Execute/fix/regenerate/reset/rerun until every final check PASSes on the isolated environment. Return only the exact tested SQL for manual execution.
```

---

## 16. Final Verification Rules

### `TEST_DATABASE_SETUP` PASS

```text
isolated test database/environment available     = YES
real source/target protected from test writes    = YES
required schemas/baseline available              = YES
required MySQL permissions confirmed             = YES
reset/rebuild path proven                        = YES
status                                           = PASS
```

### `INVENTORY_VERIFY` PASS

```text
actual source tables accounted       = 100%
actual source fields accounted       = 100%
actual target tables accounted       = 100%
actual target fields accounted       = 100%
required inventory dependencies      = accounted
required coverage states             = produced + verified
missing/duplicate inventory evidence = 0
SCRIPT_CONTRACT_GAP                  = 0
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
SCRIPT_CONTRACT_GAP           = 0
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
SCRIPT_CONTRACT_GAP          = 0
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
SCRIPT_CONTRACT_GAP       = 0
status                    = PASS
```

### `FINAL_VERIFY` PASS

Required previous history:

```text
TEST_DATABASE_SETUP.status = PASS
INVENTORY_MAPPING.status   = PASS
INVENTORY_VERIFY.status    = PASS
MAPPING_VERIFY.status      = PASS
MIGRATION.status           = PASS
VALIDATION_DATA.status     = PASS
```

And:

```text
all mandatory plan checklist items = checked with evidence
all generated SQL files            = executed successfully on isolated test environment
all producer/consumer contracts     = PASS
all required failure counters       = 0
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
    = 7 top-down steps including explicitly requested Step 0 TEST_DATABASE_SETUP

workflow
    = unchanged named migration flow

workflow_step
    = unchanged one row per enum step per workflow

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
    = prompt/SQL behavior only; no rollback workflow feature added

producer/consumer contract
    = prompt/plan validation rule; no new database table required

Codex generation rule
    = generate → execute on isolated test DB → diagnose/fix/regenerate → reset → rerun until PASS → return exact tested SQL for manual execution
```
