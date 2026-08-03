# `<extension-name>` Custom Extension Clone Plan Report

<a id="table-of-contents"></a>
## Table of Contents

- [1. Executive Summary](#executive-summary)
- [2. Scope and Constraints](#scope-constraints)
- [3. Source and Target Environments](#environments)
- [4. Extension Identification](#extension-identification)
- [5. Detected Structure Tree](#detected-structure)
- [6. File Inventory and Counts](#file-inventory)
- [7. Manifest Analysis](#manifest-analysis)
- [8. Source-to-Target Path Mapping](#path-mapping)
- [9. Database Schema Inventory](#database-schema)
- [10. Data Migration Requirements](#data-migration)
- [11. Joomla Registration and Discover Plan](#discover-plan)
- [12. Dependencies and External Resources](#dependencies)
- [13. Logic-Preservation Verification](#logic-verification)
- [14. Coverage Summary](#coverage-summary)
- [15. Missing Items and Risks](#missing-risks)
- [16. Clone Execution Plan](#execution-plan)
- [17. Validation Checklist](#validation-checklist)
- [18. Final Readiness Decision](#readiness-decision)

---

<a id="executive-summary"></a>
## 1. Executive Summary

| Item | Result |
|---|---|
| Extension | `<technical-name>` |
| Type | `<component/module/plugin/...>` |
| Source files | `<matched>/<required>` |
| Missing files | `<count>` |
| Unexpected logic changes | `<count>` |
| Required database objects | `<count>` |
| Discover readiness | `Ready / Conditional / Not ready` |
| Final status | `PASS / INCOMPLETE / BLOCKED` |

### Conclusion

`<Short evidence-based conclusion>`

---

<a id="scope-constraints"></a>
## 2. Scope and Constraints

### In scope

- `<items>`

### Out of scope

- New features.
- Business-logic refactoring.
- Unapproved schema or API changes.

### Preservation rules

- [ ] Preserve all original business behavior.
- [ ] Preserve paths and filename case.
- [ ] Preserve routes, tasks, views, layouts, tables, columns, and language keys.
- [ ] Document compatibility changes separately.

---

<a id="environments"></a>
## 3. Source and Target Environments

| Property | Source | Target | Status |
|---|---|---|---|
| Project | `<path/repository>` | `<path/repository>` | `<status>` |
| Joomla | `<version>` | `<version>` | `<status>` |
| PHP | `<version>` | `<version>` | `<status>` |
| Database | `<engine/version>` | `<engine/version>` | `<status>` |
| Web server | `<value>` | `<value>` | `<status>` |

---

<a id="extension-identification"></a>
## 4. Extension Identification

| Field | Value | Evidence |
|---|---|---|
| Display name | `<value>` | `<source>` |
| Technical name | `<value>` | `<source>` |
| Type | `<value>` | `<source>` |
| Client | `<value>` | `<source>` |
| Plugin group | `<value/N/A>` | `<source>` |
| Manifest path | `<path>` | `<source>` |
| Version | `<value>` | `<source>` |
| Namespace | `<value>` | `<source>` |

---

<a id="detected-structure"></a>
## 5. Detected Structure Tree

```text
<detected tree with inline comments>
```

### Structure validation

| Structure item | Expected | Actual | Status | Action |
|---|---|---|---|---|
| `<item>` | `<value>` | `<value>` | `Present/Missing/Partial/N/A` | `<action>` |

---

<a id="file-inventory"></a>
## 6. File Inventory and Counts

### Counts by area

| Area | Required | Matched | Missing | Modified | Coverage |
|---|---:|---:|---:|---:|---:|
| Administrator | 0 | 0 | 0 | 0 | 0% |
| Site | 0 | 0 | 0 | 0 | 0% |
| API | 0 | 0 | 0 | 0 | 0% |
| Media | 0 | 0 | 0 | 0 | 0% |
| Language | 0 | 0 | 0 | 0 | 0% |
| External paths | 0 | 0 | 0 | 0 | 0% |
| **Total** | **0** | **0** | **0** | **0** | **0%** |

### Detailed inventory

| Source path | Target path | Type | Size | SHA-256 | Manifest | Discover | Status | Notes |
|---|---|---|---:|---|---:|---:|---|---|
| `<path>` | `<path>` | `<type>` | `<size>` | `<hash>` | `Yes/No` | `Yes/No/Conditional` | `<status>` | `<notes>` |

---

<a id="manifest-analysis"></a>
## 7. Manifest Analysis

| Check | Expected | Actual | Status | Required action |
|---|---|---|---|---|
| XML well-formed | Yes | `<value>` | `<status>` | `<action>` |
| Extension type | `<value>` | `<value>` | `<status>` | `<action>` |
| Client | `<value>` | `<value>` | `<status>` | `<action>` |
| Element/name | `<value>` | `<value>` | `<status>` | `<action>` |
| Namespace mapping | `<value>` | `<value>` | `<status>` | `<action>` |
| Declared files exist | 100% | `<value>` | `<status>` | `<action>` |
| SQL paths exist | Yes/N/A | `<value>` | `<status>` | `<action>` |
| Discover location valid | Yes | `<value>` | `<status>` | `<action>` |

---

<a id="path-mapping"></a>
## 8. Source-to-Target Path Mapping

| # | Source path | Target path | Required | Status | Notes |
|---:|---|---|---:|---|---|
| 1 | `<path>` | `<path>` | Yes | `<status>` | `<notes>` |

---

<a id="database-schema"></a>
## 9. Database Schema Inventory

| Database object | Used by | Schema source | Target action | Status |
|---|---|---|---|---|
| `<table/index/view>` | `<files>` | `<SQL/export>` | `<create/compare/migrate>` | `<status>` |

### Table detail

| Table | Columns | PK | Indexes | FKs | Charset/collation | Coverage |
|---|---:|---|---:|---:|---|---:|
| `<table>` | 0 | `<value>` | 0 | 0 | `<value>` | 0% |

---

<a id="data-migration"></a>
## 10. Data Migration Requirements

| Data set | Required | Source | Target strategy | ID mapping required | Status |
|---|---:|---|---|---:|---|
| `<data>` | `Yes/No` | `<source>` | `<strategy>` | `Yes/No` | `<status>` |

### Joomla Core relationships

| Relation | Old reference | Target resolution | Status |
|---|---|---|---|
| Category/User/Asset/Menu/etc. | `<value>` | `<mapping strategy>` | `<status>` |

---

<a id="discover-plan"></a>
## 11. Joomla Registration and Discover Plan

| Check | Result | Evidence/Action |
|---|---|---|
| Installed manifest path | `<path>` | `<details>` |
| Type/client/group match | `<status>` | `<details>` |
| Declared files present | `<status>` | `<details>` |
| `#__extensions` conflict | `<status>` | `<details>` |
| SQL behavior understood | `<status>` | `<details>` |
| Discover readiness | `Ready/Conditional/Not ready` | `<reason>` |

### Discover steps

1. Copy the verified extension structure to the target installed paths.
2. Back up the target database.
3. Open `System → Install → Discover`.
4. Run `Discover`.
5. Select the extension and install it.
6. Verify the `#__extensions` and `#__schemas` records when applicable.
7. Execute the approved database schema plan if Discover does not create it automatically.

---

<a id="dependencies"></a>
## 12. Dependencies and External Resources

| Dependency | Type | Required version/configuration | Location/source | Blocking | Status |
|---|---|---|---|---:|---|
| `<dependency>` | `<plugin/library/API/etc.>` | `<value>` | `<source>` | `Yes/No` | `<status>` |

### Secrets and environment variables

| Name | Configuration source | Required | Value included in report |
|---|---|---:|---:|
| `<name>` | `<source>` | Yes/No | No |

---

<a id="logic-verification"></a>
## 13. Logic-Preservation Verification

| Check | Expected | Actual | Status |
|---|---|---|---|
| File count match | 100% | `<value>` | `<status>` |
| Relative paths match | 100% | `<value>` | `<status>` |
| Unchanged file checksums match | 100% | `<value>` | `<status>` |
| Missing logic files | 0 | `<value>` | `<status>` |
| Unexpected modified logic files | 0 | `<value>` | `<status>` |
| PHP syntax errors | 0 | `<value>` | `<status>` |

### Approved compatibility changes

| File | Original checksum | New checksum | Reason | Approval/reference |
|---|---|---|---|---|
| `<path>` | `<hash>` | `<hash>` | `<reason>` | `<reference>` |

---

<a id="coverage-summary"></a>
## 14. Coverage Summary

| Coverage area | Result | Pass target | Status |
|---|---:|---:|---|
| Source files | 0% | 100% | `<status>` |
| Structure | 0% | 100% | `<status>` |
| Manifest | 0% | 100% | `<status>` |
| Database schema | 0% | 100% | `<status>` |
| Logic preservation | 0% | 100% | `<status>` |
| Discover readiness | `<value>` | Ready | `<status>` |

---

<a id="missing-risks"></a>
## 15. Missing Items and Risks

| Severity | Missing item or risk | Impact | Required action | Owner/status |
|---|---|---|---|---|
| Blocker/High/Medium/Low | `<item>` | `<impact>` | `<action>` | `<value>` |

---

<a id="execution-plan"></a>
## 16. Clone Execution Plan

| Step | Action | Inputs | Expected output | Validation | Status |
|---:|---|---|---|---|---|
| 1 | `<action>` | `<inputs>` | `<output>` | `<check>` | Planned |

---

<a id="validation-checklist"></a>
## 17. Validation Checklist

### Files and structure

- [ ] Required file count matches the source.
- [ ] Required relative paths match.
- [ ] Unchanged-file checksums match.
- [ ] Manifest-declared files exist.
- [ ] No required external path is missing.

### Database

- [ ] All required tables exist.
- [ ] Columns, types, defaults, indexes, and foreign keys match.
- [ ] Required business data is planned.
- [ ] Joomla Core ID mappings are defined.

### Discover

- [ ] Manifest is in the correct installed path.
- [ ] Type, client, element, and plugin group are correct.
- [ ] No conflicting extension record exists.
- [ ] Joomla detects the extension.
- [ ] Discover installation succeeds.

### Runtime smoke checks

- [ ] PHP syntax checks pass.
- [ ] Backend entry point opens when applicable.
- [ ] Frontend entry point opens when applicable.
- [ ] Required plugin events execute when applicable.
- [ ] Required assets and language files load.

---

<a id="readiness-decision"></a>
## 18. Final Readiness Decision

```text
Status: PASS / INCOMPLETE / BLOCKED
```

### Decision reasons

- `<reason>`

### PASS requirements

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
