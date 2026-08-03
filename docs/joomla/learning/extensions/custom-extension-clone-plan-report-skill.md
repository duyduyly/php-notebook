# Custom Joomla Extension Clone Plan Report Skill

A reusable AI skill for inspecting a custom Joomla extension and generating a complete Markdown plan report of everything that must be cloned to another Joomla project.

> **Primary objective:** preserve the original extension logic, clone every required file and database object, produce a valid Joomla structure, and make the extension discoverable without introducing new features or changing business behavior.

---

<a id="table-of-contents"></a>
## Table of Contents

- [1. Skill Definition](#skill-definition)
- [2. When to Use This Skill](#when-to-use)
- [3. Required Inputs](#required-inputs)
- [4. Non-Negotiable Rules](#non-negotiable-rules)
- [5. Joomla Extension Types](#extension-types)
- [6. Inspection Workflow](#inspection-workflow)
  - [6.1 Identify the Extension](#identify-extension)
  - [6.2 Build the Source Inventory](#source-inventory)
  - [6.3 Validate the Structure](#structure-validation)
  - [6.4 Analyze the Manifest](#manifest-analysis)
  - [6.5 Analyze Database Usage](#database-analysis)
  - [6.6 Analyze Discover Requirements](#discover-analysis)
  - [6.7 Find External Dependencies](#dependency-analysis)
  - [6.8 Calculate Coverage](#coverage-calculation)
- [7. Required Markdown Report](#required-report)
- [8. Report Template](#report-template)
- [9. Completion Criteria](#completion-criteria)
- [10. Failure Conditions](#failure-conditions)
- [11. Recommended Commands](#recommended-commands)
- [12. Final Self-Check](#final-self-check)

---

<a id="skill-definition"></a>
## 1. Skill Definition

### Skill name

```text
custom-joomla-extension-clone-plan-report
```

### Purpose

Inspect an existing custom Joomla extension and generate a Markdown plan report containing every file, directory, manifest entry, database object, registration requirement, dependency, and validation step required to clone the extension into another Joomla project.

### Expected output

The skill produces one Markdown report, for example:

```text
reports/
└── com_example-clone-plan-report.md
```

The report is a migration plan and inventory. It must not silently modify the source extension.

[Back to Table of Contents](#table-of-contents)

---

<a id="when-to-use"></a>
## 2. When to Use This Skill

Use this skill when the user asks to:

- Clone a custom extension from one Joomla project to another.
- Create an inventory before moving an extension.
- Confirm whether all extension files have been collected.
- Prepare an extension for Joomla Discover.
- Reconstruct an installable package from installed files.
- Compare the source extension with a cloned copy.
- Identify all database tables and schema objects used by an extension.
- Generate a clone or migration plan without changing business logic.

Do not use this skill to:

- Add new features.
- Redesign the extension architecture.
- Refactor working business logic.
- Replace the extension with another product.
- Automatically rewrite Joomla 3 code into Joomla 6 code unless the user explicitly requests a separate migration task.

[Back to Table of Contents](#table-of-contents)

---

<a id="required-inputs"></a>
## 3. Required Inputs

Collect or resolve the following inputs:

| Input | Required | Description |
|---|---:|---|
| Source project path or repository | Yes | Joomla project containing the custom extension |
| Target project path or repository | Recommended | Joomla project that will receive the extension |
| Extension technical name | Yes | Example: `com_example`, `mod_example`, or `plg_system_example` |
| Extension type | Yes | Component, Module, Plugin, Template, Library, Language, Package, or File |
| Source Joomla version | Yes | Example: Joomla 3.10 or Joomla 6.x |
| Target Joomla version | Yes | Example: Joomla 6.x |
| Source PHP version | Recommended | Used only for compatibility reporting |
| Target PHP version | Recommended | Used only for compatibility reporting |
| Database access or schema export | Required for DB coverage | Needed to verify all database objects |
| Output report path | Recommended | Default to `<extension>-clone-plan-report.md` |

When an important input cannot be resolved, mark it as:

```text
Unknown — verification required
```

Do not invent paths, table names, versions, or dependencies.

[Back to Table of Contents](#table-of-contents)

---

<a id="non-negotiable-rules"></a>
## 4. Non-Negotiable Rules

1. **Do not change business logic.**
2. **Do not create new features.**
3. **Do not delete apparently unused files without proof.**
4. **Do not rename classes, methods, database columns, routes, tasks, views, layouts, or language keys during inventory.**
5. **Do not assume the standard Joomla folder is the complete extension boundary.**
6. **Search for files outside the normal extension paths.**
7. **Use the manifest as an installation map, not as the only source of truth.**
8. **Search the source code for all database table references.**
9. **Separate source-file coverage from functional coverage.**
10. **Do not claim 100% coverage unless every required check passes.**
11. **Do not copy Joomla registration IDs directly when Joomla Installer or Discover can recreate them.**
12. **Never commit secrets, API keys, credentials, production tokens, or private configuration values into the report.**
13. **Report differences; do not silently fix them.**
14. **Preserve filename and directory case exactly.**
15. **Treat Linux paths and namespaces as case-sensitive.**

[Back to Table of Contents](#table-of-contents)

---

<a id="extension-types"></a>
## 5. Joomla Extension Types

The skill must first classify the extension into one of these eight types:

```text
Joomla Extension
├── Component — Main application, MVC, database, backend, site, optional API
├── Module — Template-position output using dispatcher/helper/layout
├── Plugin — Event-driven execution within a plugin group
├── Template — Site or administrator presentation and overrides
├── Library — Shared reusable namespaced code
├── Language — Translation files
├── Package — Bundle of multiple child extensions
└── File — Arbitrary file collection installed by a manifest
```

The expected structure depends on the type. Never apply a Component checklist blindly to a Module or Plugin.

[Back to Table of Contents](#table-of-contents)

---

<a id="inspection-workflow"></a>
## 6. Inspection Workflow

<a id="identify-extension"></a>
### 6.1 Identify the Extension

Determine and report:

- Display name.
- Technical name or element.
- Extension type.
- Plugin group when applicable.
- Client: Site, Administrator, or both.
- Manifest path.
- Installed paths.
- Namespace.
- Version.
- Author or owner.
- Joomla source version.
- Joomla target version.

Read the manifest and record at least:

```text
type
client
method
element
folder/group
namespace
version
files
media
languages
administration
install SQL
uninstall SQL
schema updates
scriptfile
updateservers
```

<a id="source-inventory"></a>
### 6.2 Build the Source Inventory

Inventory every related file and directory.

#### Standard locations

```text
Component
├── administrator/components/com_example/
├── components/com_example/
├── api/components/com_example/
├── media/com_example/
├── language/<tag>/com_example.ini
└── administrator/language/<tag>/com_example*.ini

Module
├── modules/mod_example/
├── administrator/modules/mod_example/
└── media/mod_example/

Plugin
├── plugins/<group>/<name>/
└── media/plg_<group>_<name>/

Template
├── templates/<name>/
├── administrator/templates/<name>/
└── media/templates/<client>/<name>/

Library
└── libraries/<name>/
```

#### Non-standard locations to search

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

For every file, collect:

| Field | Description |
|---|---|
| Source path | Exact source-project path |
| Target path | Expected target-project path |
| File type | PHP, XML, SQL, JS, CSS, image, language, JSON, other |
| Size | File size when available |
| Checksum | SHA-256 recommended |
| Manifest-declared | Yes or No |
| Required for Discover | Yes, No, or Conditional |
| Clone status | Planned, Copied, Missing, Modified, Excluded |
| Notes | Dependency or purpose |

Calculate:

```text
File coverage = cloned files / total required files × 100%
```

A file is considered cloned only when its expected target path exists and its checksum matches, unless an approved compatibility change is documented separately.

<a id="structure-validation"></a>
### 6.3 Validate the Structure

Generate a tree of the detected source structure with comments.

Example:

```text
com_example/
├── example.xml                    # Manifest used by Joomla Installer/Discover
├── script.php                     # Installer lifecycle logic
├── administrator/                 # Backend application
│   ├── services/provider.php      # DI registration
│   ├── src/                       # Namespaced PHP classes
│   ├── forms/                     # Forms and filters
│   ├── tmpl/                      # Backend layouts
│   ├── sql/                       # Install and update schema
│   ├── access.xml                 # ACL definitions
│   └── config.xml                 # Component options
├── site/                          # Frontend application
├── api/                           # Optional API application
├── media/                         # Static assets
└── language/                      # Translation files
```

For each expected structure item, report:

```text
Present
Missing
Partial
Not applicable
Unexpected
```

Calculate:

```text
Structure coverage = complete required structure items / total required structure items × 100%
```

Do not reduce the score for optional items that are proven unnecessary for the extension.

<a id="manifest-analysis"></a>
### 6.4 Analyze the Manifest

Validate that:

- The XML is well-formed.
- The root extension type is correct.
- `client` is correct when required.
- Plugin group/folder is correct.
- The technical name matches the installed folder.
- Every declared file and directory exists.
- Required files are not omitted from the manifest.
- Namespace path matches the actual `src` directory.
- Media destination matches the target path.
- Language paths exist.
- Installer script exists when declared.
- SQL paths exist when declared.
- Schema update directory exists when declared.
- The manifest is located where Joomla Discover expects it.

Produce a manifest validation table:

| Check | Expected | Actual | Status | Action |
|---|---|---|---|---|

<a id="database-analysis"></a>
### 6.5 Analyze Database Usage

Search all source files for:

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

Create an inventory of every database object used by the extension:

- Tables.
- Columns.
- Data types.
- Primary keys.
- Indexes.
- Unique constraints.
- Foreign keys.
- Default values.
- Nullability.
- Auto-increment settings.
- Charset and collation.
- Views.
- Triggers.
- Stored procedures, if any.

For each table, record:

| Table | Used by files | Schema source | Data required | Clone action | Status |
|---|---|---|---:|---|---|

Validate these files when applicable:

```text
sql/install.mysql.utf8mb4.sql
sql/uninstall.mysql.utf8mb4.sql
sql/updates/mysql/<version>.sql
```

Calculate:

```text
Database schema coverage = recreated required schema objects / total required schema objects × 100%
```

The database section must distinguish:

- Schema required for installation.
- Existing business data to migrate.
- Joomla Core relations such as category, user, asset, menu, access, language, field, or tag IDs.
- Records Joomla should recreate through Installer or Discover.

<a id="discover-analysis"></a>
### 6.6 Analyze Discover Requirements

The report must identify the exact installed path required before running Discover.

Examples:

```text
Component: administrator/components/com_example/example.xml
Site module: modules/mod_example/mod_example.xml
Administrator module: administrator/modules/mod_example/mod_example.xml
Plugin: plugins/system/example/example.xml
Template: templates/example/templateDetails.xml
Library: libraries/example/example.xml
```

Validate:

- Installed path is correct.
- Manifest filename and location are correct.
- Manifest type matches the path.
- Plugin group matches the parent directory.
- Client matches the destination.
- Extension does not have a conflicting or broken record in `#__extensions`.
- Declared files exist before Discover installation.
- SQL installation behavior is understood.

The report must clearly state:

```text
Discover readiness: Ready / Not ready / Conditional
```

> Discover readiness does not prove runtime correctness. It only proves that Joomla should detect and register the extension from the installed filesystem structure.

<a id="dependency-analysis"></a>
### 6.7 Find External Dependencies

Search and report:

- Related custom components.
- Modules.
- Plugins.
- Libraries.
- Composer packages.
- Autoload files.
- Template overrides.
- Shared layouts.
- Shared media assets.
- Cron or CLI scripts.
- Joomla Scheduler tasks.
- Web service plugins.
- Environment variables.
- External APIs.
- Storage directories.
- Required PHP extensions.

Search for patterns such as:

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
Composer\Autoload
JPATH_
```

Do not include secret values. Only record the secret name and configuration source.

<a id="coverage-calculation"></a>
### 6.8 Calculate Coverage

The report must contain these separate measurements:

| Coverage area | Formula | Pass target |
|---|---|---:|
| Source files | Matched required files / total required files | 100% |
| Structure | Complete required items / total required items | 100% |
| Manifest | Passed checks / applicable checks | 100% |
| Discover readiness | Required checks passed | Success |
| Database schema | Recreated required objects / total required objects | 100% |
| Logic preservation | Matching checksums for unchanged logic files | 100% |

Do not hide a low score inside one combined percentage. Report each category independently.

Optional summary status:

```text
PASS
```

may be used only when:

```text
Source files = 100%
Structure = 100%
Manifest = 100%
Discover readiness = Ready
Database schema = 100%
Unexpected logic changes = 0
Blocking dependencies = 0
```

[Back to Table of Contents](#table-of-contents)

---

<a id="required-report"></a>
## 7. Required Markdown Report

The generated report must contain these chapters in this order:

1. Executive Summary.
2. Scope and Constraints.
3. Source and Target Environments.
4. Extension Identification.
5. Detected Extension Structure Tree.
6. File Inventory and File Counts.
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

Every chapter must use anchor links and be included in a hierarchical Table of Contents.

[Back to Table of Contents](#table-of-contents)

---

<a id="report-template"></a>
## 8. Report Template

The skill must produce a report based on this template.

```markdown
# `<extension-name>` Custom Extension Clone Plan Report

<a id="table-of-contents"></a>
## Table of Contents

- [1. Executive Summary](#executive-summary)
- [2. Scope and Constraints](#scope-constraints)
- [3. Source and Target Environments](#environments)
- [4. Extension Identification](#extension-identification)
- [5. Detected Extension Structure](#detected-structure)
- [6. File Inventory](#file-inventory)
- [7. Manifest Analysis](#manifest-analysis)
- [8. Source-to-Target Mapping](#path-mapping)
- [9. Database Schema Inventory](#database-schema)
- [10. Data Migration Requirements](#data-migration)
- [11. Discover Plan](#discover-plan)
- [12. Dependencies](#dependencies)
- [13. Logic-Preservation Verification](#logic-preservation)
- [14. Coverage Summary](#coverage-summary)
- [15. Missing Items and Risks](#missing-risks)
- [16. Clone Execution Plan](#execution-plan)
- [17. Validation Checklist](#validation-checklist)
- [18. Final Readiness Decision](#readiness-decision)

<a id="executive-summary"></a>
## 1. Executive Summary

| Field | Value |
|---|---|
| Extension | `<technical-name>` |
| Type | `<type>` |
| Source Joomla | `<version>` |
| Target Joomla | `<version>` |
| Total related files | `<count>` |
| Required database tables | `<count>` |
| Discover readiness | `<Ready / Not ready / Conditional>` |
| Final status | `<PASS / BLOCKED / INCOMPLETE>` |

<a id="scope-constraints"></a>
## 2. Scope and Constraints

- Preserve existing business logic.
- Do not add new features.
- Do not refactor working code.
- Clone all required source and database structure.
- Record compatibility changes separately.

<a id="environments"></a>
## 3. Source and Target Environments

| Item | Source | Target |
|---|---|---|
| Joomla version |  |  |
| PHP version |  |  |
| Database |  |  |
| Web server |  |  |
| Extension version |  |  |

<a id="extension-identification"></a>
## 4. Extension Identification

| Field | Value |
|---|---|
| Display name |  |
| Technical name |  |
| Type |  |
| Client |  |
| Plugin group | N/A |
| Manifest path |  |
| Namespace |  |
| Version |  |

<a id="detected-structure"></a>
## 5. Detected Extension Structure

```text
<generated tree with comments>
```

<a id="file-inventory"></a>
## 6. File Inventory

### 6.1 File Count Summary

| Area | Source files | Planned files | Missing | Modified | Coverage |
|---|---:|---:|---:|---:|---:|
| Administrator |  |  |  |  |  |
| Site |  |  |  |  |  |
| API |  |  |  |  |  |
| Media |  |  |  |  |  |
| Language |  |  |  |  |  |
| External paths |  |  |  |  |  |
| **Total** |  |  |  |  |  |

### 6.2 Detailed File Mapping

| # | Source path | Target path | Type | SHA-256 | Manifest | Status | Notes |
|---:|---|---|---|---|---:|---|---|

<a id="manifest-analysis"></a>
## 7. Manifest Analysis

| Check | Expected | Actual | Status | Required action |
|---|---|---|---|---|

<a id="path-mapping"></a>
## 8. Source-to-Target Mapping

| Source path | Target path | File count | Required | Status |
|---|---|---:|---:|---|

<a id="database-schema"></a>
## 9. Database Schema Inventory

| Table/object | Columns | Indexes | Foreign keys | Data required | Status |
|---|---:|---:|---:|---:|---|

<a id="data-migration"></a>
## 10. Data Migration Requirements

| Data set | Source | Target | ID mapping required | Migration method | Status |
|---|---|---|---:|---|---|

<a id="discover-plan"></a>
## 11. Joomla Registration and Discover Plan

| Check | Result | Blocking | Notes |
|---|---|---:|---|
| Correct installed path |  |  |  |
| Manifest detected |  |  |  |
| Manifest XML valid |  |  |  |
| Extension type correct |  |  |  |
| Client/group correct |  |  |  |
| Existing registration conflict |  |  |  |
| Discover readiness |  |  |  |

<a id="dependencies"></a>
## 12. Dependencies and External Resources

| Dependency | Type | Required by | Clone/install action | Status |
|---|---|---|---|---|

<a id="logic-preservation"></a>
## 13. Logic-Preservation Verification

| Check | Source | Target | Result |
|---|---|---|---|
| PHP file count |  |  |  |
| PHP checksums |  |  |  |
| XML checksums |  |  |  |
| SQL checksums |  |  |  |
| Unexpected code changes | 0 |  |  |

<a id="coverage-summary"></a>
## 14. Coverage Summary

| Area | Coverage | Target | Status |
|---|---:|---:|---|
| Source files |  | 100% |  |
| Structure |  | 100% |  |
| Manifest |  | 100% |  |
| Database schema |  | 100% |  |
| Logic preservation |  | 100% |  |
| Discover readiness |  | Ready |  |

<a id="missing-risks"></a>
## 15. Missing Items and Risks

| Severity | Missing item or risk | Impact | Required action |
|---|---|---|---|

<a id="execution-plan"></a>
## 16. Clone Execution Plan

1. Freeze the source extension version.
2. Export the source file inventory and checksums.
3. Copy files to the mapped target paths.
4. Verify target file counts and checksums.
5. Create or verify the manifest.
6. Create or verify SQL installation and schema update files.
7. Copy non-standard dependencies and overrides.
8. Run Joomla Discover.
9. Confirm the extension registration.
10. Verify the target database schema.
11. Run syntax and smoke tests.
12. Record every approved compatibility change separately.

<a id="validation-checklist"></a>
## 17. Validation Checklist

- [ ] Original file inventory is complete.
- [ ] Target file count matches the required file count.
- [ ] Checksums match for unchanged files.
- [ ] No business logic was intentionally modified.
- [ ] Required folders exist at the correct installed paths.
- [ ] Manifest XML is valid.
- [ ] All manifest-declared files exist.
- [ ] Namespace paths match actual directories.
- [ ] Discover detects the extension.
- [ ] Discover installation succeeds.
- [ ] The extension is registered correctly in Joomla.
- [ ] All required tables exist.
- [ ] Columns, indexes, keys, defaults, and constraints match.
- [ ] Blocking dependencies are installed.
- [ ] PHP syntax validation passes.
- [ ] Backend or frontend entry point loads without a fatal error.

<a id="readiness-decision"></a>
## 18. Final Readiness Decision

```text
Status: <PASS / BLOCKED / INCOMPLETE>

PASS requirements:
- Source files: 100%
- Structure: 100%
- Manifest: 100%
- Database schema: 100%
- Logic preservation: 100%
- Discover readiness: Ready
- Blocking dependencies: 0
```
```

[Back to Table of Contents](#table-of-contents)

---

<a id="completion-criteria"></a>
## 9. Completion Criteria

The skill is complete only when the generated report includes:

- A full structure tree with comments.
- Total source file count.
- File count by extension area.
- Exact source-to-target path mapping.
- SHA-256 verification plan.
- Manifest validation.
- Complete database schema inventory.
- Data migration requirements.
- Discover readiness checks.
- Dependency inventory.
- Separate coverage percentages.
- Missing-item and risk tables.
- Execution steps.
- Final PASS, BLOCKED, or INCOMPLETE decision.

A report with unknown values may still be generated, but it must be marked `INCOMPLETE` until those values are verified.

[Back to Table of Contents](#table-of-contents)

---

<a id="failure-conditions"></a>
## 10. Failure Conditions

Mark the report `BLOCKED` when any of these conditions exist:

- The manifest cannot be found.
- The extension type cannot be determined.
- Required source paths are unavailable.
- Database schema cannot be identified for a database-backed extension.
- Required dependencies are missing and cannot be resolved.
- Discover cannot detect the extension because the installed path or manifest is invalid.
- Source and target checksums differ without an approved compatibility-change record.
- Required SQL files reference missing tables or invalid paths.
- The extension has unresolved hard-coded paths or IDs that prevent safe cloning.

Mark the report `INCOMPLETE` when inspection is possible but evidence is missing.

[Back to Table of Contents](#table-of-contents)

---

<a id="recommended-commands"></a>
## 11. Recommended Commands

### Count files

```bash
find <extension-path> -type f | wc -l
```

### Generate a sorted file inventory

```bash
find <extension-path> -type f -print | sort
```

### Generate checksums

```bash
find <extension-path> -type f -exec sha256sum {} \; | sort > source-checksums.sha256
```

### Find database table references

```bash
grep -RIn --include='*.php' --include='*.xml' --include='*.sql' '#__' <extension-path>
```

### Find related extension references

```bash
grep -RIn --include='*.php' --include='*.xml' \
  -e 'bootComponent' \
  -e 'PluginHelper::importPlugin' \
  -e 'require_once' \
  -e 'include_once' \
  <extension-path>
```

### Validate PHP syntax

```bash
find <extension-path> -name '*.php' -print0 \
  | xargs -0 -n1 php -l
```

### Compare inventories

```bash
diff -u source-checksums.sha256 target-checksums.sha256
```

### Export table schema

```bash
mysqldump --no-data <database> <table1> <table2> > extension-schema.sql
```

### Export required data

```bash
mysqldump --no-create-info <database> <table1> <table2> > extension-data.sql
```

Replace database credentials and paths securely. Do not place passwords directly in committed shell history or Markdown reports.

[Back to Table of Contents](#table-of-contents)

---

<a id="final-self-check"></a>
## 12. Final Self-Check

Before returning the generated report, verify:

- [ ] The extension type was identified correctly.
- [ ] The manifest was inspected.
- [ ] Standard and non-standard paths were searched.
- [ ] All file counts have evidence.
- [ ] All checksum claims have evidence.
- [ ] All database objects have source references.
- [ ] Discover readiness is not confused with runtime correctness.
- [ ] No secret values are exposed.
- [ ] Unknown values are clearly marked.
- [ ] No new feature or business-logic change was proposed.
- [ ] Every missing item has an action.
- [ ] The final status follows the defined PASS rules.

[Back to Table of Contents](#table-of-contents)
