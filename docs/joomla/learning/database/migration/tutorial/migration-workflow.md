# End-to-End Joomla Database Migration Workflow

> Canonical seven-step specification for every workflow version created after this revision. Existing workflow rows, artifacts, and PASS history are immutable legacy evidence.

## 1. Guarantee and scope

This workflow is bound to [`docs/05-joomla-core-j3-j6-migration-contract.md`](docs/05-joomla-core-j3-j6-migration-contract.md), [`docs/06-joomla-core-table-mapping-migration.md`](docs/06-joomla-core-table-mapping-migration.md), and [`docs/07-joomla-core-field-mapping-migration.md`](docs/07-joomla-core-field-mapping-migration.md).

| Gate | Required result |
|---|---:|
| Source inventory | 100% of physical objects in the frozen included-source scope |
| Clean-target inventory | 100% of physical objects in the frozen Joomla 6 installer baseline |
| Unique source-field decisions | Active included source fields / active included source fields |
| Missing, duplicate, or unresolved source decisions | 0 |
| Resolved relationships | Required relationships / required relationships |
| Required target population strategies | Required target fields / required target fields |
| Executable field contracts | Executable fields / executable fields |
| Unbound templates, pseudo-calls, or producer gaps | 0 |

```text
DIRECT + TRANSFORM + ID_MAP + VALUE_MAP + SPLIT + MERGE
+ DERIVED + REBUILD + ARCHIVE + IGNORE + UNSUPPORTED
  = ACTIVE_INCLUDED_SOURCE_FIELDS
UNRESOLVED = 0
```

Counts such as 78/711 source objects, 76/832 target objects, 168 relationships, or 206 rebuild decisions are legacy/reference observations, not reusable PASS constants. Every new workflow derives its denominators from its own frozen scope and snapshots. Table/field dispositions such as `IGNORE`, `REBUILD`, `DERIVED`, `ARCHIVE`, or third-party deferral must be explicitly persisted and accounted by that workflow's contract; they are never inherited merely because an earlier workflow used them. A source table explicitly named in the frozen contract but physically absent from the selected version may be persisted only as `SKIP_ABSENT_SOURCE`: Step 1 records the exact absence and reason; the entry has zero fields/rows and is excluded from Steps 2–6 field, migration, and validation denominators. No present table may be skipped.

Here, 100% means complete source-field decisions, row/cell dispositions, eligible business-data preservation, required target population, and zero unexplained loss, rejection, orphan, duplicate, or failed verification. Pinned counts are expectations, never substitutes for live inventory. This specification does not mutate existing databases or workflow history.

## 2. Canonical architecture

Every new workflow version has exactly seven steps:

```text
00 TEST_DATABASE_SETUP
        ↓ PASS
10 INVENTORY_MAPPING
        ↓ PASS
20 INVENTORY_MAPPING_VERIFY
        ↓ PASS
30 FIELD_MAPPING
        ↓ PASS
40 MIGRATION_DATA
        ↓ PASS
50 VALIDATION_DATA
        ↓ PASS
60 FINAL_VERIFY
        ↓ PASS
   WORKFLOW PASS
```

1. `TEST_DATABASE_SETUP` prepares and proves the isolated environment.
2. `INVENTORY_MAPPING` inventories both schemas, classifies drift, creates one draft release, and maps tables.
3. `INVENTORY_MAPPING_VERIFY` independently verifies inventory and table contracts without repair.
4. `FIELD_MAPPING` creates, compiles, and self-verifies every field decision, named map/value implementation, archive/no-write operation, target strategy, and external rebuild handoff before freezing the executable contract fingerprint.
5. `MIGRATION_DATA` executes only that frozen contract, persists runtime mappings, and migrates SQL-owned target data atomically; application rebuilds use the explicit prepared/external/continuation barrier in Section 9.
6. `VALIDATION_DATA` independently validates migrated data without repair.
7. `FINAL_VERIFY` reconciles the complete history and marks the workflow PASS.

No rollback step, repair step, attempt table, or new status is introduced.

## 3. Failure retrospective

| Observed failure | Root cause | Binding correction |
|---|---|---|
| Wrong first non-PASS step | Scripts used copied workflow IDs/stale statuses | Resolve immutable workflow name/version at runtime, lock it, then calculate the first non-PASS step |
| Duplicate keys on rerun | Partial/non-idempotent writes without scoped cleanup | One DML transaction and deterministic current-step cleanup/upsert |
| Coverage mismatches | Stale snapshots and mixed clean-target, test-target, and live-drift counts | Immutable environment-bound snapshots; label every count and reject mismatched bindings |
| MySQL error 1175 | `@@SESSION.sql_safe_updates` was not managed | Save, temporarily set, and restore it on success and exception |
| Step 0 failures | Unproven grants, target drift from the installer baseline, unequal clone structure, missing backup proof | Prove grants, the exact installer baseline, equality, backups, restore, and reset before PASS |
| Empty-baseline failure on rerun | Successful migration was rerun without resetting disposable target | Keep the correct guard; reset the target from its immutable baseline |
| File proliferation | Candidates, variants, reset scripts, manifests, helpers, and executed copies became deliverables | Keep one plan and one exact tested SQL per step; iterate ephemerally |
| Corrupted `08/09` files | Target identifiers were textually substituted after testing | Bind exact names before testing; never edit tested bytes |
| Backtracking | Downstream producer needs were discovered after upstream PASS | Freeze producer/consumer contracts before execution; correct forward by default |
| Frozen but non-executable field contracts | Generic `COPY`, generic runtime-map templates, pseudo-functions, or missing writer bodies passed semantic-only checks | Compile every executable field against actual persisted release/mapping IDs and require all compilation gates to be zero before freeze |
| Abbreviated archive producers | Stored `...`, `(...)`, symbolic column lists, or reconstructed test SQL was treated as executable | Persist the complete `INSERT ... SELECT`, parse the exact stored text, and require complete duplicate/read-back/hash/accounting contracts |
| External rebuild rebinding | A workflow-specific command/helper was copied or text-rebound to a newer release | Use one reusable operator-owned tool with explicit validated workflow/release/hash/target/domain inputs and reject every mismatch |

The correction model is mandatory intake, frozen contracts, exact environment binding, deterministic retries, and objective upstream invalidation only.

## 4. Model, enum, and seed

```text
workflow enum (source code only)
  → workflow (immutable name/version identity)
  → workflow_step (seven rows)
  → workflow_execution_history (zero or one immutable PASS certificate per step)
```

```php
enum MigrationWorkflowStep: string
{
    case TEST_DATABASE_SETUP = 'TEST_DATABASE_SETUP';
    case INVENTORY_MAPPING = 'INVENTORY_MAPPING';
    case INVENTORY_MAPPING_VERIFY = 'INVENTORY_MAPPING_VERIFY';
    case FIELD_MAPPING = 'FIELD_MAPPING';
    case MIGRATION_DATA = 'MIGRATION_DATA';
    case VALIDATION_DATA = 'VALIDATION_DATA';
    case FINAL_VERIFY = 'FINAL_VERIFY';

    public function order(): int
    {
        return match ($this) {
            self::TEST_DATABASE_SETUP => 0,
            self::INVENTORY_MAPPING => 10,
            self::INVENTORY_MAPPING_VERIFY => 20,
            self::FIELD_MAPPING => 30,
            self::MIGRATION_DATA => 40,
            self::VALIDATION_DATA => 50,
            self::FINAL_VERIFY => 60,
        };
    }

    public function previous(): ?self
    {
        return match ($this) {
            self::TEST_DATABASE_SETUP => null,
            self::INVENTORY_MAPPING => self::TEST_DATABASE_SETUP,
            self::INVENTORY_MAPPING_VERIFY => self::INVENTORY_MAPPING,
            self::FIELD_MAPPING => self::INVENTORY_MAPPING_VERIFY,
            self::MIGRATION_DATA => self::FIELD_MAPPING,
            self::VALIDATION_DATA => self::MIGRATION_DATA,
            self::FINAL_VERIFY => self::VALIDATION_DATA,
        };
    }
}
```

Use `UNIQUE (workflow_name, workflow_version)`, `UNIQUE (workflow_id, step_code)`, and `UNIQUE (workflow_id, step_order)`. Step statuses remain `PENDING`, `RUNNING`, and `PASS`. Failure rolls back to `PENDING`. Current step is the single RUNNING step, otherwise the lowest-order non-PASS step.

The following is an illustrative seed shape. Before this block, the final Step 0 artifact assigns every named variable to a validated literal from the completed intake; no variable is accepted from an untrusted caller and no placeholder remains when testing begins:

```sql
START TRANSACTION;
INSERT INTO migration_inventory.workflow
    (workflow_name, workflow_version, bootstrap_version, bootstrap_checksum,
     source_database_name, target_database_name, test_target_database_name,
     status, created_at)
VALUES
    (@workflow_name, @workflow_version, @bootstrap_version, @bootstrap_checksum,
     @source_database_name, @target_database_name, @test_target_database_name,
     'PENDING', UTC_TIMESTAMP());
SET @workflow_id := LAST_INSERT_ID();
INSERT INTO migration_inventory.workflow_step
    (workflow_id, step_code, step_order, status)
VALUES
    (@workflow_id, 'TEST_DATABASE_SETUP',       0, 'PENDING'),
    (@workflow_id, 'INVENTORY_MAPPING',        10, 'PENDING'),
    (@workflow_id, 'INVENTORY_MAPPING_VERIFY', 20, 'PENDING'),
    (@workflow_id, 'FIELD_MAPPING',            30, 'PENDING'),
    (@workflow_id, 'MIGRATION_DATA',           40, 'PENDING'),
    (@workflow_id, 'VALIDATION_DATA',          50, 'PENDING'),
    (@workflow_id, 'FINAL_VERIFY',             60, 'PENDING');
COMMIT;
```

Step 0 owns the versioned control bootstrap, schema upgrade, workflow insert, and seven-row seed inside `00-test-database-setup.sql`; there is no third bootstrap artifact or hidden prerequisite. Before seeding, it must install or upgrade the control schemas to the canonical seven-step model. It verifies all required columns, constraints, keys and checksums and ensures the `workflow_step.step_code` constraint accepts exactly the seven canonical names. Existing workflow/release/history rows are immutable evidence and must be preserved. A compatible non-empty control schema is normal: Step 0 resolves or creates only the requested immutable workflow name/version and its seven rows, rejecting conflicting duplicates. If a required schema upgrade cannot preserve non-empty control data, Step 0 stops before destructive DDL and requires an operator-approved compatible upgrade or new isolated control schema; it never rewrites prior workflow evidence.

## 5. Mandatory information gate

No runnable SQL may be generated until its plan has a completed intake. Unknown required facts become named blockers; the agent must not invent them.

Step 0 gathers:

- Workflow name/version and migration scope.
- Source/target database names, prefixes, Joomla versions, and ownership classification.
- Exact isolated MySQL instance/container where those same schema names are safe.
- Source read-only and target/control write credential identities.
- Clean Joomla 6.1.2 installer baseline and immutable reset source.
- Charset, collation, engine, SQL mode, time zone, lower-case-name behavior, and safe-update mode.
- Source/target table, field, FK, and baseline-record expectations.
- Included/excluded core, custom, and third-party tables.
- Required mapping documents and approved unresolved decisions.
- Backup locations, hashes, restore proof, retention policy, and maintenance window.
- Manual client and stop-on-first-error behavior.

For new workflows, schema identity and server identity are separate facts. `workflow.source_database_name` and `workflow.target_database_name` store the exact schema identifiers embedded in every final SQL artifact. The isolated test instance must expose those same identifiers. The legacy-required `workflow.test_target_database_name` column is set equal to `target_database_name` for the canonical workflow; isolation is proven by the server fingerprint, not by appending `_test` to a schema name. The immutable reset-source schema/dump identity is stored in Step 0 evidence. Final SQL must never be tested under one schema name and later rewritten for another.

Later steps ask only for changed and step-specific facts.

Every plan begins with:

```markdown
## Intake and blockers
- Workflow name/version:
- Step code/order:
- Exact isolated MySQL server identity:
- Exact manual MySQL server identity:
- Exact source/target databases and prefixes:
- Control databases:
- Credential identities and proven grants:
- Source/target snapshot IDs and fingerprints:
- Mapping release ID/status/fingerprint, if applicable:
- Required predecessor PASS certificate:
- Changed facts since predecessor:
- Step-specific inputs and expected counters:
- Backup/hash/restore evidence:
- Reset source and reset proof:
- Execution client and stop-on-error setting:
- Maintenance-window/write-freeze evidence, if applicable:
- External Joomla rebuild owner/command, if applicable:
- Named blockers: None | BLOCKER-<name>: <missing fact and owner>
- Intake complete: YES | NO
```

If intake is incomplete, a blocker plan is allowed but runnable SQL is not.

## 6. Frozen producer/consumer contract

Resolve and freeze this producer/consumer matrix progressively at the owning step.

Before Step 0, freeze only the workflow architecture and required producer/consumer schema.
Step 0 freezes environment and database bindings.
Step 1 freezes physical source/target snapshots, inventories, dependencies, and the DRAFT release/table mappings.
Step 3 freezes the complete executable field producer/consumer contract against the actual persisted release and mapping IDs.
Step 4 freezes execution/runtime-map/disposition evidence.
A missing, stale, ambiguous, or differently bound required producer causes SCRIPT_CONTRACT_GAP before its consumer writes.

| Producer | Persisted output | Consumer | Assertion |
|---|---|---|---|
| Step 0 bootstrap block | Canonical control schema version/checksum, workflow row, and seven step rows | Step 0 finalization block | Exact checksum, required columns/constraints, and canonical list |
| Step 0 | Environment fingerprint, bindings, grants, Joomla 6.1.2 baseline, reset identity, backup/restore proof | Steps 1–6 | Exact isolated, resettable match |
| Step 1 | Immutable source/target snapshots | Steps 2–6 | IDs, fingerprints, environment match |
| Step 1 | Physical inventory, classifications, baselines, dependencies | Step 2 | Complete and unique live reconciliation |
| Step 1 | One draft release and complete table mappings | Steps 2–3 | One draft, 100% table coverage |
| Step 2 | Inventory/table verification PASS | Step 3 | Correct predecessor and bindings |
| Step 3 | Field decisions, STATIC value mappings, relationships, target strategies, named runtime-map lookups, executable per-field SQL operations, archive/no-write accounting, and verification rules | Steps 4–6 | Complete, unique, executable, and compiled against actual persisted IDs |
| Step 3 | Exact external rebuild bindings for every approved Joomla-owned rebuild domain | Step 4 | Reusable operator validates workflow/release/hash/target/domain inputs; command and continuation contract are complete |
| Step 3 | Normalized executable contract SHA-256 and PASS release | Steps 4–6 | Independent recalculation matches only after every semantic/compilation gate is zero |
| Step 4 | Runtime maps, target writes, dispositions, migration evidence | Steps 5–6 | Complete; no failure/unaccounted rows |
| Step 5 | Independent validation PASS evidence | Step 6 | No repair; all counters reconcile |
| Step 6 | Complete reconciliation | Workflow | Seven canonical PASS certificates |

Step 2 owns only inventory/table verification. Step 3 owns all field-contract creation and verification. Step 0's bootstrap block precedes its finalization block inside the same SQL artifact. No producer occurs after its consumer.

```text
Contract version:
Workflow name/version:
Resolved physical outputs/types:
Normalized contract hash:
Operator approval/timestamp:
Generator acknowledgement/timestamp:
Status: FROZEN | BLOCKED
```

## 7. Universal SQL and retry contract

Every SQL file must:

1. Bind the literal workflow name/version and canonical step code from the completed plan, never copied numeric IDs. Steps 1–6 resolve the existing IDs at runtime. Step 0 acquires the name/version lock first, installs/upgrades the control schema, creates the workflow, and then resolves its IDs.
2. Acquire and prove ownership of a workflow-scoped advisory lock with `GET_LOCK`; release it with `RELEASE_LOCK` on every exit path. The lock name is derived from workflow name/version and therefore exists before the Step 0 row.
3. Inside the lock, prove the current-step rule. Step 0 is the sole no-predecessor exception and must prove that no canonical step has PASS history before finalization. Steps 1–6 must be the first non-PASS step and must have exactly one predecessor PASS certificate.
4. Save/restore `foreign_key_checks`, `sql_safe_updates`, and every modified session setting on success and exception.
5. Use a stored procedure for guarded DML with `EXIT HANDLER FOR SQLEXCEPTION`, `ROLLBACK`, durable post-rollback diagnostics where the control schema exists, session restoration, lock release, and `RESIGNAL`.
6. Keep successful transactional DML, detail evidence, execution logs, PASS history, and status changes in one transaction. Never insert PASS or a successful guard outside that transaction. The only deliberate non-PASS commit is Step 4's prepared external-rebuild phase: its one transaction contains the SQL-owned maps/writes, prepared evidence, and `RUNNING` status, but no PASS certificate or successful guard.
7. After a failed Steps 1–6 transaction, the handler may open a separate diagnostic transaction containing only an `ERROR` execution/error record with no successful guard. Step 0 failures before the control schema exists are captured by the stop-on-error client and embedded in the plan test history; failures after bootstrap use the same durable diagnostic rule.
8. Deterministically clean/upsert only current-step non-PASS detail before rebuilding it. Never edit PASS history. Retried diagnostic inserts must use a deterministic error identity or tolerate an existing identical diagnostic.
9. Leave no PASS certificate, successful execution guard, or partial transactional target DML after failure. Durable `ERROR` diagnostics are allowed and are not predecessor evidence.
10. Business/control-schema DDL is permitted only in Step 0 after exact isolated-server and allowlisted-schema checks; compensate/reset implicit commits. Ephemeral `DROP PROCEDURE IF EXISTS` / `CREATE PROCEDURE` / final `DROP PROCEDURE` statements are a narrow routine-DDL exception for every step and may not alter application or control tables.
11. Begin every invocation with deterministic `DROP PROCEDURE IF EXISTS`, then create and call the uniquely workflow/step-named routine. A failed stop-on-error invocation may leave the routine behind; the next invocation removes it before doing work. A successful invocation removes it at the end.
12. Stop with `SCRIPT_CONTRACT_GAP` before business-data or mapping writes when a producer is missing.
13. Preserve the Joomla installer-baseline guard. A normal second migration requires resetting the disposable target; the only allowed populated-target re-entry is the exact Step 4 external-rebuild continuation described in Section 9, bound to its persisted prepared-phase evidence.
14. Prove a complete baseline-reset-and-rerun cycle before finalization.
15. Never run the next step automatically.

Required Steps 1–6 control shape (Step 0 uses the specialized bootstrap sequence in Section 9):

```sql
DELIMITER $$
CREATE PROCEDURE run_current_step()
main: BEGIN
    DECLARE v_old_fk INT DEFAULT @@SESSION.foreign_key_checks;
    DECLARE v_old_safe INT DEFAULT @@SESSION.sql_safe_updates;
    DECLARE v_lock_name VARCHAR(255);
    DECLARE v_lock_owned INT DEFAULT 0;
    DECLARE v_step_id BIGINT UNSIGNED;
    DECLARE v_sqlstate CHAR(5);
    DECLARE v_message TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_sqlstate = RETURNED_SQLSTATE,
            v_message = MESSAGE_TEXT;
        ROLLBACK;
        SET SESSION foreign_key_checks = v_old_fk;
        SET SESSION sql_safe_updates = v_old_safe;
        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
            IF v_step_id IS NOT NULL THEN
                START TRANSACTION;
                /* Insert/upsert deterministic ERROR-only diagnostic; no PASS guard. */
                COMMIT;
            END IF;
        END;
        IF v_lock_owned = 1 THEN DO RELEASE_LOCK(v_lock_name); END IF;
        RESIGNAL;
    END;
    /* Resolve immutable identity, lock, and assert step/predecessor contracts. */
    SET SESSION foreign_key_checks = 0;
    SET SESSION sql_safe_updates = 0;
    START TRANSACTION;
    /* Scoped cleanup, producer checks, writes, evidence, status, PASS. */
    COMMIT;
    SET SESSION foreign_key_checks = v_old_fk;
    SET SESSION sql_safe_updates = v_old_safe;
    DO RELEASE_LOCK(v_lock_name);
    SET v_lock_owned = 0;
END$$
DELIMITER ;
```

Final scripts replace every comment with executable, schema-compatible assertions. They use a unique routine name derived from workflow version and step code, clean it at invocation start, and remove it after success. Step 0 documents compensating cleanup after DDL failure in its plan and performs all possible cleanup in its one SQL artifact.

## 8. Artifact and integrity standard

Each step folder contains exactly:

```text
<order>-<step>-plan.md
<order>-<step>.sql
```

```text
00-test-database-setup-plan.md       00-test-database-setup.sql
10-inventory-mapping-plan.md         10-inventory-mapping.sql
20-inventory-mapping-verify-plan.md  20-inventory-mapping-verify.sql
30-field-mapping-plan.md             30-field-mapping.sql
40-migration-data-plan.md            40-migration-data.sql
50-validation-data-plan.md           50-validation-data.sql
60-final-verify-plan.md              60-final-verify.sql
```

Iterations live in an ephemeral workspace. Deliverables exclude checksum sidecars, candidate/test/environment variants, executed copies, reset helpers, standalone manifests, manual-order reports, and application helper scripts. Diagnostics go in the final plan test history.

The plan embeds the final SQL SHA-256; workflow identity; database bindings; MySQL server/compatibility facts; snapshot, release, and contract fingerprints; every SQL invocation and external rebuild command with timestamps, exit codes, and warnings; reset proof; prepared/continuation evidence when applicable; PASS counters/evidence IDs; and concise failed-candidate diagnoses. The Step 4 plan also embeds the complete migration-disposition report, and the Step 5 plan embeds the independently executed post-migration no-data-loss tutorial and its results. These are plan sections, not additional artifacts.

Test byte-identical final SQL on a separate isolated instance using the exact manual schema identifiers. Bind identifiers before testing. After hashing, do not substitute targets or edit bytes. Placeholders and TODOs are forbidden.

Application Joomla rebuilds are numbered blocks owned and verified by Step 4. If MySQL cannot invoke one, Step 3 freezes the complete handoff semantics and the Step 4 plan renders the operator-owned exact command, working directory/runtime, required inputs, expected output/evidence fingerprint, idempotency/reset rule, and stop condition without interpreting new semantics. The reusable operator-owned tool must require and validate explicit workflow name/version, mapping-release identity, normalized contract SHA-256, exact target database, and approved rebuild domains; it must reject mismatches and must not silently rebind an older workflow. The command is an execution instruction in the plan, not a workflow-specific canonical helper artifact. The two-phase continuation protocol in Section 9 applies; Step 4 cannot PASS merely because the external command returned exit code zero. Do not silently add PHP or PowerShell helper files.

## 9. Step contracts

### Step 0 — `TEST_DATABASE_SETUP`

One SQL file owns and verifies the canonical control-schema install/upgrade and seven-row seed, then proves isolated exact-name schemas; clean Joomla 6.1.2 baseline; restricted accounts; compatibility; backup hashes and restore; immutable reset source; structural/data clone equality; destructive reset allowlisting; and reset-and-rerun. It proves the target has the exact installer-owned baseline rows and no migrated business data. Step 0 alone may use business/control-schema DDL, restricted to validated test and control schemas. Its sequence is: acquire the name/version lock; prove server/schema allowlists; preserve all unrelated workflow evidence; reject only an incompatible schema or conflicting immutable identity; install/upgrade and checksum the canonical schema; seed or deterministically resolve the one requested workflow and seven steps; run environment proofs; transactionally write Step 0 evidence/PASS; restore settings; release the lock.

### Step 1 — `INVENTORY_MAPPING`

Capture immutable source/clean-target snapshots; exact tables, fields, indexes and FKs; frozen record baselines; core/custom/third-party ownership and inclusion; drift; dependencies; exactly one draft `mapping_release`; and complete included-source table mappings. Label source snapshot, clean target, disposable target, and live drift counts separately. Do not create field mappings, value mappings, relationships, target strategies, runtime maps, or business data.

### Step 2 — `INVENTORY_MAPPING_VERIFY`

Independently compare live bound schemas to Step 1 snapshots. Verify inventory coverage, classifications, dependencies, counts, table mappings, duplicates, and snapshot/release binding. Do not repair Step 1. Do not create or verify field-level contracts.

### Step 3 — `FIELD_MAPPING`

Consume the one existing DRAFT release created by Step 1. Create exactly one decision per active included source field, all required `STATIC` value mappings, every relationship, one strategy per required target field, and deterministic migration/verification rules. The current five-table mapping model persists each relationship on its owning `field_mapping.relationship_strategy`; Step 3 derives the required relationship denominator from the frozen Step 1/Step 2 inventory and table scope, then requires every identified relationship row to contain a nonempty normalized strategy. Step 2 still performs no field-contract verification.

`mapping_type` and physical target status are independent. Executable decisions are `DIRECT`, `TRANSFORM`, `ID_MAP`, `VALUE_MAP`, `SPLIT`, `MERGE`, `DERIVED`, `REBUILD`, `ARCHIVE`, `IGNORE`, and `UNSUPPORTED`; `UNRESOLVED` must be zero. `SKIP` is legacy display only.

Step 3 is the complete executable-contract boundary. For every SQL-owned field it persists the exact source and target fields, exact SQL expression, dependency order, preserved-ID or named runtime-map behavior, map lookup and persistence point, FK/reference rewrite, NULL/default/reset handling, insert/update behavior, archive/defer/rebuild/target-owned disposition, row/cell accounting, and post-write verification. Generic `COPY`, generic or unqualified `RUNTIME_ID_MAP`, `CONTRACT_TABLE:*`, symbolic functions, ellipses, and equivalent placeholders are forbidden. Semantic identities and named map domains must be deterministic and must define uniqueness, zero-match, multi-match, persistence, and every dependent rewrite without numeric-ID fallback unless that fallback is explicitly approved and evidenced.

Compile expressions against the actual persisted DRAFT `mapping_release.id`, `table_mapping.id`, and `field_mapping.id` values. Former pseudo-calls are resolved before freeze: value mapping becomes an exact SQL expression or named persisted value-map implementation; neutral-user handling becomes the approved USER runtime-map plus archive/neutral behavior; archive handling becomes the exact executable archive-write contract; no-write behavior becomes an explicit accounted disposition; and Joomla rebuild behavior becomes the exact reusable external-operator handoff. MySQL-owned SQL and external-command-owned work must be separable without Step 4 interpreting or inventing producer semantics.

For every archive producer, persist the complete Step 4 `INSERT ... SELECT` statement with the physical insert column list, physical select expression list, exact source table and alias, deterministic source identity everywhere it is used, workflow/release binding, reason/disposition, payload or value, hash, duplicate-prevention predicate, accounting contribution, read-back query, and hash verification. Parse/syntax-check the exact persisted SQL text, not a reconstructed equivalent, without executing the archive write in Step 3. A frozen zero-row archive producer must assert its bound snapshot count remains zero and stop with `SCRIPT_CONTRACT_GAP` if it changes; it may not invent a synthetic identity.

For every approved external rebuild domain, Step 3 persists the reusable operator identity and executable owner; exact command contract; workflow name/version, release ID, normalized contract hash, target database and approved-domain inputs; expected database effects and deterministic evidence; failure/reset behavior; and continuation verifier. Step 4's plan may render those frozen inputs into the command, but may not add semantics.

The DRAFT release must pass this pre-freeze audit:

```text
GENERIC_COPY_TEMPLATES = 0
GENERIC_RUNTIME_MAP_TEMPLATES = 0
UNQUALIFIED_RUNTIME_MAP_TEMPLATES = 0
UNRESOLVED_CONTRACT_TABLE_MARKERS = 0
UNBOUND_PSEUDO_CALLS = 0
MISSING_FIELD_SQL_EXPRESSIONS = 0
MISSING_NAMED_MAP_LOOKUPS = 0
MISSING_FK_REWRITES = 0
MISSING_VALUE_MAP_IMPLEMENTATIONS = 0
MISSING_NEUTRAL_USER_IMPLEMENTATIONS = 0
MISSING_ARCHIVE_IMPLEMENTATIONS = 0
MISSING_NO_WRITE_ACCOUNTING = 0
MISSING_EXTERNAL_REBUILD_BINDINGS = 0
ARCHIVE_SQL_PLACEHOLDERS = 0
ARCHIVE_SQL_PARSE_ERRORS = 0
EXECUTABLE_ARCHIVE_PRODUCERS = REQUIRED_ARCHIVE_PRODUCERS / REQUIRED_ARCHIVE_PRODUCERS
ARCHIVE_CONTRACT_GAPS = 0
RUNTIME_COMPILATION_ERRORS = 0
AMBIGUOUS_WRITER_SEMANTICS = 0
```

All semantic coverage counters and every compilation counter above must independently be zero (or exact numerator/denominator equality) before freeze. While any gate is non-zero, keep the release DRAFT, fix and recompile Step 3 transactionally, and do not generate Step 4. Only then normalize the complete executable SQL/external-handoff contract, calculate and independently recalculate its SHA-256, freeze the release, mark it PASS, and write the Step 3 PASS certificate. A defect found while the release is still DRAFT is corrected in the same workflow/release; an objective defect found after freeze follows Section 11 and never rewrites the frozen evidence.

### Step 4 — `MIGRATION_DATA`

Step 4 is execution only: it introduces no field, identity, mapping, archive, accounting, or rebuild semantics. Consume only the exact PASS release/snapshots and independently recompute the normalized contract hash before writes. The plan embeds the SHA-256 of the byte-identical final SQL and renders the exact external operator command from Step 3's frozen binding; pre-execution tooling verifies that file hash because an SQL file cannot derive its own source-file bytes. Execution evidence records the verified hash and the SQL rechecks the bound persisted evidence.

Persist every runtime ID/value resolution in `migration_mapping.value_mapping` with `mapping_scope = 'RUNTIME'`; temporary maps may assist execution but never satisfy the handoff. Every RUNTIME row requires a non-NULL `field_mapping_id`, deterministic non-NULL `source_record_identity`, source-value hash, and the applicable resolved `target_record_identity` and/or `target_value`. Because nullable columns can weaken MySQL unique keys, Step 4 must independently reject duplicate logical runtime identities and verify the required one-to-one or many-to-one cardinality declared by each field contract. Runtime rows are bound to the exact release and must pass completeness, uniqueness, cardinality, unmapped-value, orphan, and target-resolution checks. In one guarded SQL transaction, construct these persisted maps at their frozen persistence points, perform dependency-ordered Joomla target writes, apply every frozen FK/reference rewrite and disposition, execute the complete archive producers, and record exact table/row/cell accounting.

Step 4 must produce a complete human-readable **Migration Disposition Report** in `40-migration-data-plan.md`, backed by result sets from the exact `40-migration-data.sql`. The report lists every included source table and field and groups every source row/cell into exactly one frozen disposition: `MIGRATED`, `ARCHIVED`, `REBUILT`, `TARGET_OWNED`, `DEFERRED_OUT_OF_SCOPE`, `INTENTIONAL_IGNORE`, or `SKIP_ABSENT_SOURCE`. It records source and target identities, expected and actual counts, owning producer or external owner, runtime-map domain where applicable, archive evidence identity/hash, reason, verification result, and accounting contribution. `ARCHIVED` values require persisted payload read-back and hash equality. `DEFERRED_OUT_OF_SCOPE` requires preserved source evidence and a named later-workflow owner. `SKIP_ABSENT_SOURCE` requires snapshot-proven physical absence and zero rows/fields. `MISSING_EXPECTED`, an unexplained skip, a row/cell with no disposition, or two dispositions for the same source identity is a blocking failure and can never be relabelled as an approved skip merely to reach PASS.

The baseline guard means **the exact immutable Joomla 6.1.2 installer baseline, including its required installer-owned rows, with zero migrated business rows**. It never means an all-tables-zero database. A populated target is rejected unless it is the exact prepared external-rebuild continuation below.

If every required `REBUILD` decision is implementable and verifiable in MySQL, Step 4 completes atomically in one invocation. If Joomla application/CLI work is required, SQL-owned maps and base writes are atomic in a prepared phase, but the whole cross-process step cannot truthfully be one database transaction. The exact same `40-migration-data.sql` therefore implements two guarded invocations without adding files or statuses:

1. **Prepare invocation:** require the installer baseline, perform and verify all SQL-owned maps/writes in one transaction, persist a content fingerprint and prepared evidence in existing execution/result evidence, leave `MIGRATION_DATA` as `RUNNING`, commit, restore settings, release the lock, and stop without PASS.
2. **External barrier:** the operator runs only the exact command recorded in the plan and must validate the frozen workflow name/version, release identity, normalized contract hash, exact target database, and approved rebuild-domain set before Joomla bootstrap or writes. The command must be idempotent or require a documented full baseline reset after failure. Its command output is captured in the plan, while its database effects remain the authoritative input to SQL verification. A workflow-specific copied/rebound helper is forbidden; reusable operator-owned tooling is outside the two canonical Step 4 artifacts.
3. **Continuation invocation:** invoke the same byte-identical `40-migration-data.sql`. Allow the populated target only when the current step is `RUNNING` and the persisted prepared fingerprint, workflow/release/snapshots, target fingerprint, SQL hash, operator inputs, and approved rebuild domains match. Do not trust an operator-supplied PASS flag and do not rebuild base data or runtime maps. Recalculate target state and invariants directly from the database, verify every required rebuild decision and continuation check, verify archive persistence/read-back/hashes, FK integrity, runtime maps, target population, and complete accounting, then transactionally insert the one PASS certificate and mark the step PASS.

Any mismatch or failed external rebuild leaves Step 4 non-PASS. If safe idempotent retry cannot be proven, restore the immutable installer baseline, deterministically clear Step 4 non-PASS evidence, and rerun the complete Step 4 test. This continuation is not a weakened empty-target guard.

### Step 5 — `VALIDATION_DATA`

Independently derive expected results from frozen source and PASS contract; validate identities, hashes/values, transformations, counts, NULL/sentinel handling, distributions, payloads, archives, rebuilds, duplicates, orphans, required target population, and dispositions. Never repair target, runtime maps, rules, or prior evidence.

`50-validation-data-plan.md` must include a reproducible **Post-Migration No-Data-Loss Tutorial** and the evidence from executing each numbered block with `50-validation-data.sql`. The tutorial is an operator procedure, not a separate report file, and must:

1. Reconfirm workflow/release/contract/SQL/snapshot/target bindings and the Step 4 PASS certificate.
2. Recalculate frozen source table, field, row, and cell denominators without using Step 4's totals as expected values.
3. Reconcile every source identity to exactly one Migration Disposition Report entry and prove missing and duplicate dispositions are zero.
4. Compare per-table source expectations to migrated, archived, rebuilt, target-owned, deferred, ignored, and absent-source outcomes.
5. Recalculate full-field values or deterministic hashes for every migrated field; sampling alone cannot satisfy PASS.
6. Verify every named runtime map for completeness, uniqueness, cardinality, target existence, and dependent FK/reference rewrites.
7. Read back every archive identity and payload/value; recalculate hashes and detect missing or duplicate archive evidence.
8. Verify every deferred/ignored/absent-source decision has its frozen reason, owner, source evidence, and exact accounting contribution.
9. Detect unexpected target rows, duplicate business identities, broken relationships, invalid neutral/default values, and orphans.
10. Verify every Joomla rebuild domain and its continuation evidence directly from target state.
11. Print per-table/per-field exceptions and final integer numerators/denominators; PASS only when every failure counter is zero.

The tutorial must tell the operator how to run the exact validation SQL, what result sets to inspect, the expected zero/equality gates, and that any failure stops the workflow at Step 5. It must never instruct the operator to repair data; a failure follows Section 11.

### Step 6 — `FINAL_VERIFY`

Verify exact seven-step order; one PASS certificate per predecessor; no extra/later history; all environment, snapshot, release, contract, and SQL fingerprints; all producer/consumer contracts; counters; and independent validation. Then atomically mark the step and workflow PASS. Do not migrate, repair, or waive gates.

## 10. PASS formulas and history

```text
TEST_DATABASE_SETUP:
  isolated exact names, grants, clean Joomla 6.1.2, equal clone,
  backup/hash/restore, reset/rerun = proven

INVENTORY_MAPPING:
  frozen source and clean-target denominators = 100% live-reconciled
  baselines/classifications/dependencies complete
  exactly one draft release; table mappings = 100%

INVENTORY_MAPPING_VERIFY:
  live/snapshot mismatches, inventory duplicates/gaps,
  unknown classifications, table-map/dependency/count mismatches = 0
  field-contract checks performed = 0

FIELD_MAPPING:
  decisions = active included source fields / active included source fields, unique
  relationships = required / required; strategies = required target fields / required
  generic templates, unqualified maps, contract markers, pseudo-calls = 0
  missing SQL/map/FK/value-map/neutral/archive/no-write/external bindings = 0
  archive SQL placeholders/parse errors/contract gaps = 0
  executable archive producers = required / required
  runtime compilation errors and ambiguous writer semantics = 0
  normalized executable contract hash recomputes equal; release = PASS

MIGRATION_DATA:
  persisted RUNTIME maps complete/unique and bound to the PASS release
  prepared/external/continuation fingerprints = exact match when rebuild barrier applies
  all required REBUILD decisions and domain continuation checks independently verified
  unresolved/ambiguous/orphan/unaccounted/rejected = 0
  archive missing/duplicate/read-back/hash failures = 0
  disposition report tables/fields/rows/cells = frozen denominators / frozen denominators
  missing expected, unexplained skip, duplicate disposition, deferred evidence gap = 0
  row/cell accounting, eligible preservation, target population = 100.00%

VALIDATION_DATA:
  missing/unexpected/duplicate/broken/unmapped/invalid/hash/rebuild failures = 0
  independently recalculated dispositions = frozen source identities / frozen source identities
  post-migration no-data-loss tutorial blocks executed and PASS = 11/11
  independent accounting/preservation = 100.00%; repairs = 0

FINAL_VERIFY:
  canonical predecessor PASS certificates = 6/6
  every frozen fingerprint exact; gaps/failures = 0
  all definition, relationship, row/cell, preservation, target coverage = 100.00%
  step and workflow = PASS
```

The final canonical history must contain exactly:

```text
TEST_DATABASE_SETUP.status       = PASS
INVENTORY_MAPPING.status         = PASS
INVENTORY_MAPPING_VERIFY.status  = PASS
FIELD_MAPPING.status             = PASS
MIGRATION_DATA.status            = PASS
VALIDATION_DATA.status           = PASS
FINAL_VERIFY.status              = PASS
workflow.status                  = PASS
```

```text
TOTAL_SOURCE_CELLS = SUM(frozen owning-table row count for every source field)
ACCOUNTED_SOURCE_CELLS = ACTIVE_TARGET_VERIFIED + REBUILD_VERIFIED
  + ARCHIVE_VERIFIED + INTENTIONAL_IGNORE_VERIFIED + UNSUPPORTED_VERIFIED + REJECTED
ELIGIBLE_SOURCE_CELLS = TOTAL_SOURCE_CELLS
  - INTENTIONAL_IGNORE_VERIFIED - UNSUPPORTED_VERIFIED
PRESERVED_ELIGIBLE_CELLS = ACTIVE_TARGET_VERIFIED + REBUILD_VERIFIED + ARCHIVE_VERIFIED
```

Every cell has one disposition. `REJECTED` and current-contract `UNSUPPORTED` are zero for PASS. Print integer numerators/denominators.

```text
unaccounted_source_table_count = 0
unaccounted_source_field_count = 0
unaccounted_source_row_count = 0
unaccounted_source_cell_count = 0
duplicate_source_disposition_count = 0
missing_expected_source_table_count = 0
missing_expected_source_field_count = 0
missing_expected_source_row_count = 0
unexplained_skip_count = 0
missing_deferred_evidence_count = 0
rejected_source_row_count = 0
rejected_source_cell_count = 0
unresolved_count = 0
ambiguous_count = 0
unmapped_id_count = 0
unmapped_value_count = 0
orphan_count = 0
unexpected_duplicate_count = 0
invalid_structured_payload_count = 0
archive_missing_count = 0
archive_duplicate_identity_count = 0
archive_read_back_failure_count = 0
archive_hash_mismatch_count = 0
rebuild_failure_count = 0
required_target_population_failure = 0
SCRIPT_CONTRACT_GAP = 0
```

`workflow_execution_history` remains an immutable one-row PASS certificate (`UNIQUE (workflow_step_id)`). Failed attempts use existing detail/error evidence and rollback; no FAIL history or attempt number is introduced. Retries never edit PASS certificates.

## 11. Forward-only correction

Earlier PASS is revisited only when persisted output is objectively defective. Ordinary runtime failures are fixed and retried in the current step.

| Finding | Action |
|---|---|
| Syntax, safe-update, duplicate retry evidence, transaction/handler bug | Fix current SQL; reset current state if required; retry current step |
| Target non-empty because Step 4 already passed | Reset disposable target; keep guard |
| Runtime map implementation fails but PASS rule is correct | Fix/retry Step 4 |
| Producer row missing, duplicated, stale, ambiguous, or wrong fingerprint | Stop `SCRIPT_CONTRACT_GAP`; preserve evidence; use operator-controlled invalidation/new workflow |
| Live schema changed after snapshot | Stop and create a new workflow/snapshot unless explicit controlled invalidation is approved |
| Validation finds migration wrong but contract correct | Reset target; correct Step 4; rerun Steps 4–6 |
| Validation proves persisted field decision wrong | Objective Step 3 defect; operator-approved invalidation/new workflow from Step 3 |
| Desired business behavior changed | New workflow version and contract |

Automatic PASS history deletion/rewriting is forbidden. Exceptional invalidation is operator governed and preserves old evidence.

### Single-workflow convergence and new-workflow threshold

The normal test cycle converges inside one workflow; a retry is not a new workflow version. While the current release is DRAFT and Step 3 has no PASS certificate, correct syntax, quoting, generated SQL, generic templates, pseudo-calls, map qualification, archive producers, accounting, operator bindings, and compiler/verifier defects transactionally in that same workflow/release. A DRAFT release created before canonical Step 1 is preparation-only state: it is not predecessor evidence, and Step 1 must deterministically resolve/reinitialize it to table-mapping-only state before PASS without changing the workflow identity.

Use the same workflow for:

- Step 0–2 script defects, retry cleanup, and evidence regeneration while their persisted PASS outputs remain objectively correct or do not yet exist;
- any Step 3 semantic/compiler correction while its release is DRAFT;
- Step 4 implementation/runtime failure when the frozen Step 3 contract remains correct, after resetting the disposable target when required;
- Step 5 discovery that the migration implementation is wrong but the frozen contract is correct, by resetting and rerunning Steps 4–6;
- repeated static, reset/run, and reset/rerun tests of the byte-identical candidate before the owning step PASS.

Create a new workflow only when at least one objectively versioned input must change: a frozen/PASS Step 3 decision is defective; the live schema changed after its snapshot; migration scope or approved business policy changed; environment/schema identity changed; or an immutable predecessor PASS output must be invalidated. Before creating it, the current plan records the exact changed input, evidence, affected producer/consumers, operator authorization, and why a current-step retry cannot correct it. “A test failed,” “SQL has a bug,” or “a gate is non-zero” is never sufficient by itself.

Before a step is finalized, prove one convergence cycle in the same workflow:

1. **Static compiler pass:** exact persisted contract/SQL text parses and every producer/consumer/binding gate passes without target business writes.
2. **Isolated execution pass:** reset the disposable target when applicable, execute the byte-identical candidate, and verify all owning-step counters.
3. **Reset-and-rerun pass:** restore the immutable baseline, rerun the same bytes, and prove identical bindings, outcomes, hashes, and zero retry residue.

Candidate iterations stay ephemeral. Only the final plan and exact tested SQL enter the active step folder. This convergence cycle adds no workflow step, status, attempt table, candidate artifact, or automatic next-step execution.

## 12. Embedded step prompts

Each prompt inherits Sections 5–11: complete intake, freeze physical contracts, test exact final SQL on the isolated instance, prove reset/rerun, embed integrity/test evidence, and never run the next step.

### Prompt — `TEST_DATABASE_SETUP`

```text
Goal: Create and prove the exact-name isolated MySQL environment.
Require: Own and verify the canonical control-schema install/upgrade and seven-row seed;
verify grants and negative write test, clean Joomla 6.1.2 installer baseline,
compatibility, backups/hashes/restore, structural equality, DDL allowlist, reset/rerun.
Output exactly:
00-test-database-setup-plan.md
00-test-database-setup.sql
```

### Prompt — `INVENTORY_MAPPING`

```text
Goal: Freeze source/clean-target inventories and draft table-mapping release.
Require: Confirm Step 0 PASS; inventory/classify all objects, baselines, drift,
dependencies; create one draft release and complete table mappings; no field contract.
Output exactly:
10-inventory-mapping-plan.md
10-inventory-mapping.sql
```

### Prompt — `INVENTORY_MAPPING_VERIFY`

```text
Goal: Independently verify Step 1 inventory/table mapping against bound schemas.
Require: Confirm Step 1 PASS; reconcile fingerprints, inventory, classification,
dependencies, baselines, table coverage, duplicates, release and snapshot binding.
Do not repair Step 1 or inspect/create field-contract content.
Output exactly:
20-inventory-mapping-verify-plan.md
20-inventory-mapping-verify.sql
```

### Prompt — `FIELD_MAPPING`

```text
Goal: Create and self-verify the complete executable field contract.
Require: Confirm Step 2 PASS; create one decision/source field, STATIC value maps,
relationships, target strategies and exact per-field SQL; bind every named runtime-map
lookup, FK rewrite, value-map, neutral-user, archive, no-write, accounting and verification
operation against actual persisted DRAFT IDs; bind every Joomla rebuild domain to the
validated reusable operator command and continuation contract. Parse the exact persisted
archive SQL and require all semantic, placeholder, producer and runtime-compilation gates
to be zero before normalize/hash/independent rehash/freeze/PASS. Keep the release DRAFT
and do not generate Step 4 while any gate is non-zero.
Output exactly:
30-field-mapping-plan.md
30-field-mapping.sql
```

### Prompt — `MIGRATION_DATA`

```text
Goal: Execute the frozen contract, build runtime mappings, and migrate the target.
Require: Confirm Step 3/release PASS; enforce the exact installer baseline; persist and
verify all named RUNTIME maps; perform only the frozen dependency-ordered SQL writers,
FK rewrites, archives/dispositions and accounting; introduce no new semantics. When
external Joomla work is required, render the frozen validated operator binding in the plan
and implement the exact prepared/external/continuation protocol with the same SQL, matching
workflow/release/hash/target/domain fingerprints. Require unresolved, ambiguous, orphan,
unaccounted and every archive/rebuild/continuation failure counter to be zero; stop on gaps
and reset when required. Embed a complete Migration Disposition Report in the plan covering
every source table, field, row and cell, including archived, rebuilt, target-owned, deferred,
intentionally ignored and snapshot-proven absent-source items. Missing or unexplained skips
are failures, not approved dispositions.
Output exactly:
40-migration-data-plan.md
40-migration-data.sql
```

### Prompt — `VALIDATION_DATA`

```text
Goal: Independently validate the migrated target without repair.
Require: Confirm Step 4 PASS; derive expectations from frozen evidence; verify IDs,
values/hashes, transforms, counts, distributions, payloads, archives, rebuilds,
relationships, duplicates, orphans, target population, and row/cell accounting. Embed and
execute the numbered Post-Migration No-Data-Loss Tutorial in the plan using the exact SQL;
independently reconcile every source identity to one disposition, fully verify migrated
values/hashes and archives, and print all per-table/per-field exceptions. Do not sample,
repair, waive, or convert a missing result into a skip.
Output exactly:
50-validation-data-plan.md
50-validation-data.sql
```

### Prompt — `FINAL_VERIFY`

```text
Goal: Reconcile the canonical workflow and mark it PASS.
Require: Confirm Step 5 PASS; verify six predecessor PASS certificates, order,
fingerprints, contracts, formulas, zero failures, reset and manual-run evidence;
atomically mark this step/workflow PASS only when complete; perform no repair.
Output exactly:
60-final-verify-plan.md
60-final-verify.sql
```

## 13. Operator run order

1. Complete global intake and sign the frozen contract.
2. Run `00-test-database-setup.sql`; it owns the control bootstrap/upgrade, workflow seed, environment proof, and Step 0 PASS. Confirm the canonical schema checksum, seven step rows, and one Step 0 PASS certificate.
3. For `10` and `20`, verify the embedded SQL hash/binding, run with the approved stop-on-first-error client, capture evidence, and stop unless the current step reaches its documented gate.
4. Run `30-field-mapping.sql` only against its bound DRAFT release. Do not freeze or mark Step 30 PASS until every semantic and runtime-compilation gate is independently zero and the normalized executable contract hash matches.
5. Before Step 40, prove backup/restore, freeze application/cron/CLI writes, recheck fingerprints, prove the exact Joomla 6.1.2 installer baseline, verify the final SQL file hash externally, and validate the frozen reusable-operator workflow/release/hash/target/domain binding. Step 40 may intentionally stop at its persisted prepared barrier and require that exact external command plus a second invocation of the same SQL before PASS.
6. Before leaving Step 40, inspect the embedded Migration Disposition Report. Confirm every frozen source table, field, row and cell has exactly one approved disposition and that missing, unexplained-skip, duplicate-disposition, archive and deferred-evidence failure counters are zero.
7. Run `50-validation-data.sql` and follow all eleven blocks in the Post-Migration No-Data-Loss Tutorial. Stop at Step 50 on any exception; never repair during validation.
8. Run `60` only after Step 50 PASS; capture evidence and stop on the first failed gate.
9. Never auto-run, skip, or satisfy a gate using an older workflow.

No separate manual-order report is required.

## 14. Legacy compatibility and preserved evidence

Workflow 8 and older step names `INVENTORY_VERIFY`, `MAPPING_VERIFY`, `MIGRATION_MAPPING`, or `MIGRATION` keep their original meaning in archived evidence. Their former live control-table rows were intentionally cleared on 2026-08-13 after a safety dump. The control schemas are no longer assumed empty: newer workflow/release rows may coexist and remain immutable audit evidence. The Workflow 8 archive and dump are never renamed, rewritten, restored into a new workflow, or used to seed, satisfy, or bypass a new seven-step gate.

Verified 2026-08-13 legacy evidence:

| Item | Value |
|---|---|
| Workflow | ID `8`, `JOOMLA_CORE`, `j3-to-j6-20260813-05` |
| Source/reference/test target | `honda_corp` / `honda_v6_fresh` / `honda_v6_test` |
| Source snapshot | ID `19`, `f87ffc6160aa7a87f41d5acab63cd5446859ad4c7919adc410216e5d3547b49c` |
| Target snapshot | ID `20`, `2408ca6377deb5cba43771b20f13b1d2a35da75a671897103397381d5af62dad` |
| Mapping release | ID `12`, `j3-core-to-j6-test-20260813-06`, PASS |
| Contract fingerprint | `fe958c82f8847f8f049fb787fcaccac1a3435bd0e5f136f907871ab4c96c0182` |
| Relationship fingerprint | `838bf4c7bdd66e43e26eb5cc652b9571ebd4bb023549e7b70a822bcca60a941e` |
| Target-population fingerprint | `b17f8b3ee5b5a6df19569b3c7a744e3bb7fe5c37ef69f72b0cae7f9d37203d7f` |
| Environment fingerprint | `cb454bae241020a9a9c0d98dbf49778cf9adccf5c86f8c7de9e01c626a200a6c` |
| Coverage | 78 tables, 711 fields, 168 relationships, 832 target strategies |
| Migration | 3,742 runtime maps; 78/78 tables; 6,217/6,217 rows; 72,451/72,451 cells; 49,578/49,578 eligible cells; zero errors |
| Clean baseline | Joomla 6.1.2; 434 total/76 official tables; 5,079 columns; 36 FKs; 888 installer rows; zero clone count mismatches |

Workflow 8 used its legacy single migration history. It remains auditable in `.codex/reports/v6/database/joomla-core/old/step-legacy-20260813/` and `mysql/dump/legacy-migration-control-20260813-before-clear.sql` (SHA-256 `BB52B37678F55A6442C8407F6013D00DA611878D103BA69B59CAAA7C81EE1D4B`). Every new workflow resolves one new immutable identity in the active control schemas, creates exactly seven workflow-step rows for that identity, and creates a fresh signed contract without altering earlier workflows.

## 15. Final design check

```text
new workflow steps = 7
inventory/table verification = Step 2 only
field creation and verification = Step 3 only
executable SQL/archive/no-write/external-handoff compilation = Step 3 only
persisted runtime maps and SQL target writes = Step 4 SQL-owned transaction only
external application rebuilds = frozen reusable operator binding plus Step 4 prepared/external/continuation barrier, same two canonical files
human-readable migration disposition report = embedded in Step 4 plan, no extra artifact
post-migration no-data-loss tutorial and results = embedded in Step 5 plan, no extra artifact
independent no-repair validation = Step 5
history reconciliation = Step 6
artifacts/step = one plan + one byte-identical tested SQL
integrity evidence = embedded in plan
retry = deterministic current-step cleanup and target reset when required
rollback = SQL behavior only; no new status/table/step
legacy = immutable evidence, never a new-workflow gate
```
