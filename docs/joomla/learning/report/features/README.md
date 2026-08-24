# Joomla Feature Inventory Report

This directory defines a reusable reporting model for identifying and documenting the feature set of a single Joomla website or project.

> **Scope:** This is not a comparison report. It describes one Joomla project at a time.
>
> **Core objective:** answer three questions: **What features exist? What pages exist? Which pages use which features?**

<a id="table-of-contents"></a>
## Table of Contents

1. [Purpose](#purpose)
2. [Core Reporting Model](#core-reporting-model)
3. [Required Reports](#required-reports)
4. [Feature Rules](#feature-rules)
5. [Page Rules](#page-rules)
6. [Page-to-Feature Mapping](#page-feature-map)
7. [Optional Reports](#optional-reports)
8. [Workflow](#workflow)
9. [Directory Structure](#directory-structure)

---

<a id="purpose"></a>
## 1. Purpose

The minimum useful report should allow a developer to answer:

```text
What does this project do?
→ 01-feature-inventory.csv

What pages or route classes exist?
→ 02-page-inventory.csv

Where is each feature used?
→ 03-page-feature-map.csv
```

The core report intentionally avoids deep dependency tracing unless it is needed later.

[Back to Table of Contents](#table-of-contents)

---

<a id="core-reporting-model"></a>
## 2. Core Reporting Model

```text
01-feature-inventory.csv
        │
        │ feature_id
        ▼
03-page-feature-map.csv
        ▲
        │ page_id
        │
02-page-inventory.csv
```

The three files have separate responsibilities:

| Report | Responsibility |
|---|---|
| `01-feature-inventory.csv` | Define the capabilities that exist in the project |
| `02-page-inventory.csv` | Define the pages or route classes that exist |
| `03-page-feature-map.csv` | Define which features are used on which pages |

Do not duplicate page lists in `01-feature-inventory.csv`. The authoritative Feature ↔ Page relationship belongs in `03-page-feature-map.csv`.

[Back to Table of Contents](#table-of-contents)

---

<a id="required-reports"></a>
## 3. Required Reports

### `01-feature-inventory.csv`

Canonical list of project capabilities.

Core fields:

```text
feature_id
feature_name
category
surface
description
primary_implementation
status
access
notes
```

This file should stay compact. It should not contain:

```text
page lists
technical dependency lists
formal evidence records
coverage measurements
```

Those concerns belong to other reports.

### `02-page-inventory.csv`

Canonical list of pages and route classes.

Typical information includes:

```text
page_id
page_name
surface
page_type
url
route_pattern
menu_id
component
view
layout
access
language
dynamic
status
notes
```

For large dynamic URL families, prefer a route class instead of one row for every entity.

Example:

```text
/vehicles/civic
/vehicles/city
/vehicles/crv

↓

/vehicles/{alias}
```

### `03-page-feature-map.csv`

Canonical many-to-many mapping between pages and features.

Core fields:

```text
map_id
page_id
feature_id
usage_type
visibility
position
trigger
condition
is_primary
```

This file answers both directions:

```text
Feature → Pages
Page → Features
```

Example:

```text
P001 + F001 → Main Navigation on Home
P002 + F001 → Main Navigation on Vehicle Listing
P002 + F014 → Vehicle Search on Vehicle Listing
```

[Back to Table of Contents](#table-of-contents)

---

<a id="feature-rules"></a>
## 4. Feature Rules

A feature describes a capability, not only a Joomla implementation.

Good feature names:

```text
Main Navigation
Article Listing
Article Detail
Vehicle Search
Contact Form
Shopping Cart
Newsletter Signup
```

Implementation names are discovery signals, not ideal final feature names:

```text
com_content
mod_menu
plg_system_example
#__custom_table
```

Example:

```text
mod_menu instance 42
position = navigation

↓

Feature = Main Navigation
```

One Joomla extension may implement several features, and one feature may depend on several Joomla mechanisms.

[Back to Table of Contents](#table-of-contents)

---

<a id="page-rules"></a>
## 5. Page Rules

Do not assume `#__menu` contains every page.

Page discovery may use:

```text
#__menu
runtime crawling
component-generated routes
dynamic detail routes
search results
filters
pagination
forms
authenticated routes
administrator routes when in scope
```

A page inventory should represent behavior, not unnecessarily duplicate every data record.

[Back to Table of Contents](#table-of-contents)

---

<a id="page-feature-map"></a>
## 6. Page-to-Feature Mapping

`03-page-feature-map.csv` is the source of truth for feature usage by page.

To find where a feature is used:

```text
Filter 03 by feature_id
↓
Get page_id values
↓
Join with 02-page-inventory.csv
```

Example:

```text
F001 Main Navigation
↓
P001
P002
P003
↓
Home
Vehicle Listing
Vehicle Detail
```

To find the features used on a page:

```text
Filter 03 by page_id
↓
Get feature_id values
↓
Join with 01-feature-inventory.csv
```

This separation keeps the model normalized and avoids maintaining the same relationship in multiple files.

[Back to Table of Contents](#table-of-contents)

---

<a id="optional-reports"></a>
## 7. Optional Reports

These reports are not required for the normal feature inventory.

### `04-feature-dependency-map.csv`

Use when deep technical dependency tracing is required.

Answers:

> What does this feature technically depend on?

### `05-feature-evidence.csv`

Use when formal evidence or confidence grading is required.

Answers:

> What proves that this feature or mapping exists?

### `06-feature-coverage.csv`

Use when measurable audit coverage is required.

Answers:

> How complete is the discovery process?

[Back to Table of Contents](#table-of-contents)

---

<a id="workflow"></a>
## 8. Workflow

The core workflow is intentionally small:

```text
STEP 1
Feature Inventory
      ↓
01-feature-inventory.csv

STEP 2
Page Inventory
      ↓
02-page-inventory.csv

STEP 3
Page → Feature Mapping
      ↓
03-page-feature-map.csv

STEP 4
Validate Core Inventory
      ↓
Need deeper analysis?
      │
   YES│NO
      │ └────────────→ STOP
      ↓
Optional 04 / 05 / 06
```

See [`WORKFLOW.md`](./WORKFLOW.md) for execution details.

[Back to Table of Contents](#table-of-contents)

---

<a id="directory-structure"></a>
## 9. Directory Structure

```text
report/features/
├── README.md
├── WORKFLOW.md
└── templates/
    ├── 01-feature-inventory-template.csv
    ├── 02-page-inventory-template.csv
    ├── 03-page-feature-map-template.csv
    ├── 04-feature-dependency-map-template.csv
    ├── 05-feature-evidence-template.csv
    └── 06-feature-coverage-template.csv
```

The first three templates are the core reporting model. Templates `04-06` are optional deep-analysis extensions.

[Back to Table of Contents](#table-of-contents)
