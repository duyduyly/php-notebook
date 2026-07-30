# Joomla Administrator Templates: Hathor, Isis, and Atum

## Table of Contents

- [1. Overview](#1-overview)
- [2. Administrator Templates in Joomla 3](#2-administrator-templates-in-joomla-3)
  - [2.1 Isis](#21-isis)
  - [2.2 Hathor](#22-hathor)
- [3. Hathor vs. Isis](#3-hathor-vs-isis)
- [4. Administrator Template in Joomla 6](#4-administrator-template-in-joomla-6)
  - [4.1 Atum](#41-atum)
- [5. Joomla 3 to Joomla 6 Mapping](#5-joomla-3-to-joomla-6-mapping)
- [6. Migration Rules](#6-migration-rules)
- [7. Customization Assessment](#7-customization-assessment)
- [8. Recommended Migration Actions](#8-recommended-migration-actions)
- [9. Inventory Records](#9-inventory-records)
- [10. Validation Checklist](#10-validation-checklist)
- [11. Summary](#11-summary)

---

## 1. Overview

Joomla templates are separated by application area:

| Application | Purpose | Typical path |
|---|---|---|
| Site | Renders public website pages | `templates/<template-name>/` |
| Administrator | Renders the backend administration interface | `administrator/templates/<template-name>/` |

**Hathor and Isis are Joomla 3 administrator templates.** They are not frontend website themes and should not be classified as custom or third-party extensions unless the project contains direct modifications to their source files.

In Joomla 6, Hathor and Isis are no longer available. The standard administrator template is **Atum**.

---

## 2. Administrator Templates in Joomla 3

A standard Joomla 3 installation normally includes the following backend templates:

```text
administrator/
└── templates/
    ├── hathor/
    └── isis/
```

### 2.1 Isis

Isis is the default administrator template in Joomla 3.

It controls the appearance of backend areas such as:

- Control Panel
- Article Manager
- Category Manager
- Menu Manager
- Module Manager
- Plugin Manager
- Template Manager
- Extension Manager
- Component forms and views
- Administrator toolbars and system messages

| Attribute | Value |
|---|---|
| Element | `isis` |
| Type | Administrator template |
| Source | Joomla Core |
| Default in Joomla 3 | Yes |
| Responsive | Yes |
| Recommended for Joomla 3 | Yes |
| Joomla 6 compatible | No |
| Joomla 6 replacement | Atum |

Isis is the preferred administrator template for Joomla 3 because it supports the Joomla 3 backend interface and third-party administrator views more consistently than Hathor.

### 2.2 Hathor

Hathor is an alternative Joomla 3 administrator template originally designed with accessibility as its main goal.

Its design focused on use cases such as:

- Keyboard navigation
- Screen-reader usage
- High-contrast presentation
- Reduced dependence on color

| Attribute | Value |
|---|---|
| Element | `hathor` |
| Type | Administrator template |
| Source | Joomla Core |
| Default in Joomla 3 | No |
| Primary purpose | Accessibility-focused backend UI |
| Full support for later Joomla 3 features | Limited |
| Recommended for a modern Joomla 3 backend | No |
| Joomla 6 compatible | No |
| Joomla 6 replacement | Atum |

Hathor was not maintained to the same level as Isis for later Joomla 3 functionality. A project still using Hathor should be reviewed carefully for outdated layouts and administrator extension compatibility issues.

---

## 3. Hathor vs. Isis

| Criterion | Isis | Hathor |
|---|---|---|
| Included in Joomla 3 Core | Yes | Yes |
| Administrator template | Yes | Yes |
| Frontend template | No | No |
| Joomla 3 default | Yes | No |
| Responsive backend | Better support | More limited |
| Main design goal | General administrator experience | Accessibility |
| Later Joomla 3 feature support | Better | Limited |
| Recommended on Joomla 3 | Yes | No |
| Available in Joomla 6 | No | No |
| Migration target | Atum | Atum |

**Recommended Joomla 3 configuration:** use Isis as the default administrator template unless a verified project requirement depends on Hathor.

---

## 4. Administrator Template in Joomla 6

### 4.1 Atum

Atum is the Joomla administrator template introduced with Joomla 4 and used by later Joomla versions, including Joomla 6.

```text
administrator/templates/atum/
```

Its static assets are normally stored under:

```text
media/templates/administrator/atum/
├── css/
├── images/
├── js/
└── scss/
```

| Attribute | Value |
|---|---|
| Element | `atum` |
| Type | Administrator template |
| Source | Joomla Core |
| Default in Joomla 6 | Yes |
| Separate installation required | No |
| Replaces Isis and Hathor | Yes |

Atum is installed with Joomla 6. It should normally remain the default backend template unless the project has a documented requirement for a supported custom administrator template.

---

## 5. Joomla 3 to Joomla 6 Mapping

```text
Joomla 3 Administrator
├── Isis
└── Hathor

        ↓ Do not copy or upgrade directly

Joomla 6 Administrator
└── Atum
```

| Joomla 3 item | Joomla 6 decision |
|---|---|
| Isis | Do not migrate; use Atum |
| Hathor | Remove from migration scope; use Atum |
| Custom Isis branding | Reimplement through supported Joomla 6 mechanisms |
| Isis or Hathor overrides | Review and rewrite for Joomla 6 |
| Hard-coded template paths | Replace with Joomla APIs or extension-owned assets |

---

## 6. Migration Rules

### Rule 1: Do not copy Joomla 3 administrator templates

Do not copy these directories into Joomla 6:

```text
administrator/templates/isis/
administrator/templates/hathor/
```

The backend markup, layouts, assets, Bootstrap usage, JavaScript behavior, APIs, and extension integration points differ significantly between Joomla 3 and Joomla 6.

### Rule 2: Use Atum as the Joomla 6 baseline

For a clean Joomla 6 installation:

1. Keep Atum as the default administrator template.
2. Install Joomla 6-compatible extensions.
3. Test every administrator component and configuration screen.
4. Reimplement only verified project-specific customizations.

### Rule 3: Do not edit Atum Core directly

Direct changes under the following paths can be overwritten by Joomla updates:

```text
administrator/templates/atum/
media/templates/administrator/atum/
```

Prefer extension-owned assets, administrator modules, plugins, supported template customization, or carefully maintained overrides.

### Rule 4: Keep extension styling with the extension

CSS or JavaScript required by a custom administrator component should normally be owned and registered by that component instead of being inserted directly into the Core administrator template.

---

## 7. Customization Assessment

The migration effort is minimal when Isis and Hathor are unchanged Joomla Core files. Additional work is required when the project modified them directly.

Review these Joomla 3 paths:

```text
administrator/templates/isis/
administrator/templates/hathor/
```

Focus on:

```text
index.php
component.php
error.php
templateDetails.xml
css/
js/
images/
html/
```

Common customizations include:

- Company logo on the administrator login screen
- Custom backend colors and branding
- CSS fixes for third-party administrator components
- Custom JavaScript
- Template overrides under `html/`
- Custom administrator dashboard output
- Hard-coded references to Isis or Hathor assets

Useful searches:

```bash
grep -RniE "templates/(isis|hathor)|administrator/templates" \
  administrator/components \
  administrator/modules \
  plugins \
  templates
```

Compare the project with a clean Joomla 3 package:

```bash
diff -ru \
  joomla3-clean/administrator/templates/isis \
  current-project/administrator/templates/isis
```

Run the same comparison for Hathor when it exists or is used.

---

## 8. Recommended Migration Actions

| Joomla 3 customization | Joomla 6 action |
|---|---|
| No customization | Use Atum without template migration |
| Login logo or simple branding | Reconfigure or reimplement for Atum |
| Backend color changes | Use supported Atum configuration or extension-owned CSS |
| Component-specific CSS | Move it into the corresponding component assets |
| Custom JavaScript | Register it through Joomla's Web Asset Manager |
| Isis/Hathor layout override | Rewrite against Joomla 6 layouts |
| Custom dashboard | Rebuild using Joomla 6 administrator modules and dashboards |
| Hard-coded Isis/Hathor path | Replace it with dynamic APIs or extension-owned paths |

### Estimated effort

| Current condition | Estimated effort |
|---|---:|
| Unmodified Core templates | 0–1 hour |
| Logo and simple colors only | 2–4 hours |
| Custom backend CSS or JavaScript | 4–12 hours |
| Multiple overrides or template dependencies | 1–3+ days |

These figures are planning estimates. Actual effort depends on the number of modified files, extension compatibility, and regression-test scope.

---

## 9. Inventory Records

Recommended migration inventory entries:

| Name | Element | Type | Source | Location | Joomla 3 status | Joomla 6 action |
|---|---|---|---|---|---|---|
| Isis | `isis` | Template | Joomla Core | Administrator | Default or installed | Do not migrate; replace with Atum |
| Hathor | `hathor` | Template | Joomla Core | Administrator | Installed, possibly unused | Remove from scope; use Atum |
| Atum | `atum` | Template | Joomla Core | Administrator | Not available | Use Joomla 6 default |

Recommended classification:

```text
Category: Joomla Core
Extension type: Administrator Template
Migration strategy: Replace by Joomla 6 Core equivalent
```

Do not classify Isis or Hathor as third-party extensions merely because they appear in the Joomla Extension Manager.

---

## 10. Validation Checklist

### Joomla 3 discovery

- [ ] Confirm whether Isis or Hathor is the default administrator template.
- [ ] Check whether Hathor is assigned to any administrator users or workflows.
- [ ] Compare both directories with clean Joomla 3 Core files.
- [ ] Inventory custom CSS, JavaScript, images, and overrides.
- [ ] Search the project for hard-coded Isis or Hathor paths.
- [ ] Identify administrator extensions that depend on template-specific markup.

### Joomla 6 implementation

- [ ] Keep Atum as the default administrator template.
- [ ] Reimplement only confirmed business-required customizations.
- [ ] Move component-specific assets into their owning extensions.
- [ ] Register JavaScript and CSS through supported Joomla 6 mechanisms.
- [ ] Test all custom and third-party administrator components.
- [ ] Test administrator login, dashboard, menus, forms, modals, and messages.
- [ ] Confirm keyboard navigation and accessibility behavior.
- [ ] Confirm Joomla updates do not overwrite project customization.

---

## 11. Summary

- Hathor and Isis are Joomla 3 Core administrator templates.
- Isis is the Joomla 3 default and is generally more suitable than Hathor.
- Hathor was accessibility-focused but has limited support for later Joomla 3 functionality.
- Neither template is available or compatible with Joomla 6.
- Atum is the Joomla 6 Core administrator template and requires no separate installation.
- Do not copy Isis or Hathor into Joomla 6.
- Migration work is required only when the Joomla 3 project contains custom branding, overrides, assets, or hard-coded dependencies.
