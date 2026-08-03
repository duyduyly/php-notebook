---
name: custom-joomla-extension-clone-plan-report
description: Inspect a custom Joomla extension and generate a Markdown clone plan report covering every file, directory, manifest entry, database object, dependency, Discover requirement, and validation step needed to move it without changing business logic.
---

# Custom Joomla Extension Clone Plan Report

## Objective

Inspect one custom Joomla extension in a source project and generate a complete Markdown plan report describing everything that must be cloned into a target Joomla project.

The plan must preserve the original behavior, avoid missing logic, reconstruct the required database schema, and make the extension ready for Joomla Discover.

## Use this skill when

- Moving a custom Joomla extension between projects.
- Reconstructing an installable or discoverable extension from installed files.
- Creating a file, structure, manifest, and database inventory before migration.
- Verifying that a cloned extension contains all original logic.
- Producing a repeatable migration plan without implementing new features.

## Do not use this skill to

- Add features.
- Refactor working business logic.
- Rename classes, methods, routes, tasks, views, tables, columns, or language keys.
- Delete files because they appear unused without evidence.
- Automatically convert Joomla 3 code to Joomla 6 code unless requested separately.

## Required inputs

Resolve these inputs from the repository, filesystem, database, or user-provided context:

| Input | Required |
|---|---:|
| Source project path or repository | Yes |
| Extension technical name | Yes |
| Extension type | Yes |
| Source Joomla version | Yes |
| Target Joomla version | Yes |
| Target project path or repository | Recommended |
| Database schema or database access | Required for database coverage |
| Source and target PHP versions | Recommended |
| Output report path | Recommended |

When a required fact cannot be verified, write `Unknown — verification required`. Never invent paths, table names, versions, or dependencies.

## Non-negotiable rules

1. Preserve business logic exactly unless an approved compatibility change is documented separately.
2. Inspect both standard and non-standard paths.
3. Treat the manifest as an installation map, not the only source of truth.
4. Search source code for database tables, shared files, dependencies, and hard-coded paths.
5. Preserve path and filename case exactly.
6. Use checksums to detect unexpected logic changes.
7. Keep source-file, structure, manifest, Discover, and database coverage separate.
8. Do not claim 100% coverage when evidence is incomplete.
9. Do not copy Joomla-generated IDs blindly when Installer or Discover should recreate them.
10. Never write secrets or production credentials into the report.

## Extension classification

Classify the extension before applying checks:

```text
Joomla Extension
├── Component — MVC application, backend, frontend, optional API and database
├── Module — Dispatcher/helper/layout output in a template position
├── Plugin — Event subscriber inside a plugin group
├── Template — Presentation, positions, assets, and overrides
├── Library — Shared reusable PHP code
├── Language — Translation package
├── Package — Bundle of child extensions
└── File — Arbitrary file collection installed by a manifest
```

Use `../../joomla-6-extension-structure.md` as the structure reference. Do not apply the Component structure blindly to another extension type.

## Workflow

### 1. Identify the extension

Record:

- Display name.
- Technical name or element.
- Extension type.
- Plugin group when applicable.
- Client: Site, Administrator, API, or multiple clients.
- Manifest path and filename.
- Version.
- Namespace.
- Installed paths.
- Source and target Joomla/PHP versions.

Read the manifest and capture:

```text
type
client
method
element
folder/group
namespace
version
files
administration
media
languages
install SQL
uninstall SQL
schema updates
scriptfile
updateservers
```

### 2. Build the complete source inventory

Inspect standard locations for the detected type and search outside them.

Typical non-standard locations:

```text
layouts/
cli/
images/
media/vendor/
libraries/
templates/<template>/html/
administrator/templates/<template>/html/
plugins/
modules/
administrator/modules/
```

For every related file, collect:

| Field | Description |
|---|---|
| Source path | Exact path in source project |
| Target path | Expected path in target project |
| File type | PHP, XML, SQL, JS, CSS, image, language, JSON, other |
| Size | File size when available |
| SHA-256 | Checksum for logic-preservation verification |
| Manifest-declared | Yes or No |
| Required for Discover | Yes, No, or Conditional |
| Clone status | Planned, Copied, Missing, Modified, Excluded |
| Notes | Purpose, dependency, or risk |

Calculate:

```text
File coverage = matched required files / total required files × 100%
```

### 3. Validate the extension structure

Generate a detected tree with inline comments explaining each directory and file.

For every expected item, assign one status:

```text
Present
Missing
Partial
Not applicable
Unexpected
```

Calculate:

```text
Structure coverage = complete required items / total required items × 100%
```

Optional items proven unnecessary must not lower the score.

### 4. Validate the manifest

Check that:

- XML is well-formed.
- Extension type is correct.
- Client and plugin group are correct.
- Technical name matches installed paths.
- Every declared file and folder exists.
- Required files are not omitted.
- Namespace path matches `src`.
- Media and language destinations are correct.
- Installer script exists when declared.
- Install, uninstall, and update SQL paths exist when declared.
- Manifest is placed where Joomla Discover expects it.

Produce a table:

| Check | Expected | Actual | Status | Required action |
|---|---|---|---|---|

### 5. Analyze database requirements

Search source files for:

```text
#__
CREATE TABLE
ALTER TABLE
DROP TABLE
INSERT INTO
UPDATE
DELETE FROM
JOIN
FOREIGN KEY
getTable
Table::getInstance
```

Inventory every required database object:

- Tables and columns.
- Data types and nullability.
- Defaults and auto-increment.
- Primary, unique, and normal indexes.
- Foreign keys.
- Charset and collation.
- Views, triggers, and procedures when present.
- Business data that must be migrated.
- Relations to Joomla Core IDs.

Validate applicable SQL files:

```text
sql/install.mysql.utf8mb4.sql
sql/uninstall.mysql.utf8mb4.sql
sql/updates/mysql/<version>.sql
```

Calculate:

```text
Database schema coverage = recreated required schema objects / total required schema objects × 100%
```

Separate:

- Schema required for installation.
- Business data migration.
- Joomla Core relation mapping.
- Records Joomla should recreate through Installer or Discover.

### 6. Validate Discover readiness

Determine the exact installed manifest path. Examples:

```text
Component: administrator/components/com_example/example.xml
Site module: modules/mod_example/mod_example.xml
Administrator module: administrator/modules/mod_example/mod_example.xml
Plugin: plugins/system/example/example.xml
Template: templates/example/templateDetails.xml
Library: libraries/example/example.xml
```

Check:

- Correct installed path.
- Correct manifest filename and location.
- Correct type, client, element, and plugin group.
- No broken or conflicting `#__extensions` record.
- All declared files exist before Discover.
- SQL installation behavior is documented.

Report exactly one status:

```text
Ready
Conditional
Not ready
```

Discover readiness does not prove runtime correctness.

### 7. Find dependencies and external resources

Search for:

- Components, modules, plugins, libraries, and packages.
- Composer packages and autoloaders.
- Template overrides and shared layouts.
- Shared media assets.
- CLI scripts, cron jobs, Scheduler tasks, and web-service plugins.
- Environment variables and PHP extensions.
- External APIs, storage paths, and writable directories.

Useful search patterns:

```text
require
require_once
include
include_once
class_exists
interface_exists
trait_exists
bootComponent
PluginHelper::importPlugin
JLoader
Composer\\Autoload
JPATH_
```

Record secret names and sources only, never secret values.

### 8. Verify logic preservation

For all files not approved for compatibility modification:

- Compare source and target file counts.
- Compare relative paths.
- Compare SHA-256 checksums.
- Run PHP syntax checks.
- Record every changed file and its approved reason.

Pass condition:

```text
Missing logic files = 0
Unexpected modified logic files = 0
```

### 9. Calculate coverage

Report each category independently:

| Coverage area | Pass target |
|---|---:|
| Source files | 100% |
| Structure | 100% |
| Manifest | 100% |
| Database schema | 100% |
| Logic preservation | 100% |
| Discover readiness | Ready |

Do not hide weak areas in a combined percentage.

Use `PASS` only when all targets are reached and blocking dependencies equal zero. Otherwise use `INCOMPLETE` or `BLOCKED`.

## Required output

Create one Markdown report from `templates/clone-plan-report-template.md`.

The report must include:

1. Executive Summary.
2. Scope and Constraints.
3. Source and Target Environments.
4. Extension Identification.
5. Detected Structure Tree.
6. File Inventory and Counts.
7. Manifest Analysis.
8. Source-to-Target Path Mapping.
9. Database Schema Inventory.
10. Data Migration Requirements.
11. Joomla Registration and Discover Plan.
12. Dependencies and External Resources.
13. Logic-Preservation Verification.
14. Coverage Summary.
15. Missing Items and Risks.
16. Clone Execution Plan.
17. Validation Checklist.
18. Final Readiness Decision.

Use a hierarchical Table of Contents with anchor links.

## Recommended commands

```bash
find <path> -type f | sort
find <path> -type f | wc -l
find <path> -type f -exec sha256sum {} \; | sort
php -l <file.php>
grep -R "#__" <extension-path>
grep -R "com_example\|mod_example\|plg_.*_example" <project-root>
grep -R "require\|include\|bootComponent\|PluginHelper::importPlugin" <extension-path>
mysqldump --no-data <database> <table-list> > schema.sql
```

Exclude generated runtime directories such as cache, tmp, logs, and Git metadata unless the extension intentionally stores required assets there.

## Completion criteria

Mark the report `PASS` only when:

```text
Source files = 100%
Structure = 100%
Manifest = 100%
Database schema = 100%
Logic preservation = 100%
Discover readiness = Ready
Missing required files = 0
Unexpected logic changes = 0
Blocking dependencies = 0
```

A successful Discover operation alone is insufficient.

## Final self-check

Before returning the report, verify:

- Every file count is evidence-based.
- Every required path has source and target mapping.
- Every manifest reference was checked.
- Every detected table has a schema source and clone action.
- Discover readiness is justified.
- Missing information is marked unknown rather than guessed.
- No secret value appears in the report.
- No business logic change is proposed as part of the clone plan.
