# Joomla Administrator Templates: Hathor, Isis, and Atum

## Table of Contents

- [1. Overview](#1-overview)
- [2. Official Joomla Evidence](#2-official-joomla-evidence)
- [3. Administrator Templates in Joomla 3](#3-administrator-templates-in-joomla-3)
  - [3.1 Isis](#31-isis)
  - [3.2 Hathor](#32-hathor)
- [4. Hathor vs. Isis](#4-hathor-vs-isis)
- [5. Administrator Template in Joomla 6](#5-administrator-template-in-joomla-6)
  - [5.1 Atum](#51-atum)
- [6. Joomla 3 to Joomla 6 Mapping](#6-joomla-3-to-joomla-6-mapping)
- [7. Migration Rules](#7-migration-rules)
- [8. Customization Assessment](#8-customization-assessment)
- [9. Recommended Migration Actions](#9-recommended-migration-actions)
- [10. Inventory Records](#10-inventory-records)
- [11. Validation Checklist](#11-validation-checklist)
- [12. Official References](#12-official-references)
- [13. Summary](#13-summary)

---

## 1. Overview

Joomla templates are separated by application area:

| Application | Purpose | Typical path |
|---|---|---|
| Site | Renders public website pages | `templates/<template-name>/` |
| Administrator | Renders the backend administration interface | `administrator/templates/<template-name>/` |

**Hathor and Isis are Joomla 3 Core administrator templates.** They are not frontend website themes and should not be classified as custom or third-party extensions unless the project contains direct modifications to their source files.

The official Joomla 3 documentation lists **ISIS as the default administrator template** and **Hathor as the alternative administrator template**.

From Joomla 4 onward, the Joomla 3 administrator templates are no longer supported. Joomla introduced **Atum** as the new administrator template. Therefore, a Joomla 3 to Joomla 6 migration should use Atum instead of attempting to migrate Isis or Hathor.

---

## 2. Official Joomla Evidence

The administrator-template change is documented by Joomla in the following official sources:

| Evidence | Official statement | Source |
|---|---|---|
| Joomla 3 template list | Joomla 3 includes `ISIS` as the default administrator template and `Hathor` as another administrator template. | [J3.x: Templates supplied with Joomla!](https://docs.joomla.org/J3.x%3ATemplates_supplied_with_Joomla%21/en) |
| Hathor removal announcement | Joomla states that Hathor was not updated for newer Joomla 3 functionality and would be removed from the Joomla 4 distribution. | [J3.x: Hathor admin template has not been updated](https://docs.joomla.org/J3.x%3AHathor_admin_template_has_not_been_updated_to_work_with_the_new_features/en) |
| Joomla 4 compatibility change | Joomla states that the Joomla 3 backend templates, Isis and Hathor, are no longer supported and that the new backend template is Atum. | [Potential backward compatibility issues in Joomla 4](https://docs.joomla.org/Potential_backward_compatibility_issues_in_Joomla_4/en) |
| Atum introduction | Joomla documentation identifies Atum as the administrator template used for site management in Joomla 4. | [J4.x: Template Basics](https://docs.joomla.org/Special%3AMyLanguage/J4.x%3ATemplate_Basics) |
| Joomla 4 installed templates | Joomla documentation states that Joomla 4 comes with one administrator template: Atum. | [J4.x: Switching Templates](https://docs.joomla.org/J4.x%3ASwitching_Templates) |

### Verified transition

```text
Joomla 3
├── Isis — default administrator template
└── Hathor — alternative administrator template

        ↓ Removed / no longer supported from Joomla 4

Joomla 4, Joomla 5, and Joomla 6
└── Atum — Core administrator template
```

> The official removal announcement is tied to Joomla 4 because that is the release in which the template architecture changed. Joomla 6 continues on the newer Joomla architecture and does not restore Isis or Hathor.

---

## 3. Administrator Templates in Joomla 3

A standard Joomla 3 installation normally includes:

```text
administrator/
└── templates/
    ├── hathor/
    └── isis/
```

### 3.1 Isis

Isis is the default administrator template in Joomla 3.

It controls backend areas such as:

- Control Panel
- Article and Category Managers
- Menu and Module Managers
- Plugin and Extension Managers
- Component forms and views
- Administrator toolbars and system messages

| Attribute | Value |
|---|---|
| Element | `isis` |
| Type | Administrator template |
| Source | Joomla Core |
| Default in Joomla 3 | Yes |
| Recommended for Joomla 3 | Yes |
| Joomla 6 compatible | No |
| Joomla 6 replacement | Atum |

Official proof: [J3.x: Templates supplied with Joomla!](https://docs.joomla.org/J3.x%3ATemplates_supplied_with_Joomla%21/en)

### 3.2 Hathor

Hathor is an alternative Joomla 3 administrator template originally designed with accessibility as its main goal.

Its design focused on:

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
| Support for later Joomla 3 features | Limited |
| Joomla 6 compatible | No |
| Joomla 6 replacement | Atum |

Joomla officially recommended using Isis because Hathor had not been updated for newer Joomla 3 features. Joomla also announced that Hathor would be removed from Joomla 4.

Official proof: [J3.x: Hathor admin template has not been updated](https://docs.joomla.org/J3.x%3AHathor_admin_template_has_not_been_updated_to_work_with_the_new_features/en)

---

## 4. Hathor vs. Isis

| Criterion | Isis | Hathor |
|---|---|---|
| Included in Joomla 3 Core | Yes | Yes |
| Administrator template | Yes | Yes |
| Joomla 3 default | Yes | No |
| Main design goal | General administrator experience | Accessibility |
| Later Joomla 3 feature support | Better | Limited |
| Recommended on later Joomla 3 releases | Yes | No |
| Available in Joomla 6 | No | No |
| Migration target | Atum | Atum |

**Recommended Joomla 3 configuration:** use Isis as the default administrator template unless a verified project requirement depends on Hathor.

---

## 5. Administrator Template in Joomla 6

### 5.1 Atum

Atum was introduced as the Joomla 4 administrator template and remains the Core administrator-template foundation used by later Joomla generations, including Joomla 6.

```text
administrator/templates/atum/
```

Static assets are normally stored under:

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
| Separate installation required | No |
| Migration replacement for Isis/Hathor | Yes |

Official proof:

- [J4.x: Template Basics](https://docs.joomla.org/Special%3AMyLanguage/J4.x%3ATemplate_Basics)
- [J4.x: Switching Templates](https://docs.joomla.org/J4.x%3ASwitching_Templates)
- [J4.x: Administrator Modules](https://docs.joomla.org/J4.x%3AAdministrator_Modules)

---

## 6. Joomla 3 to Joomla 6 Mapping

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

The official compatibility documentation explicitly states that Isis and Hathor are no longer supported and identifies Atum as the replacement backend template:

- [Potential backward compatibility issues in Joomla 4](https://docs.joomla.org/Potential_backward_compatibility_issues_in_Joomla_4/en#Templates)

---

## 7. Migration Rules

### Rule 1: Do not copy Joomla 3 administrator templates

Do not copy these directories into Joomla 6:

```text
administrator/templates/isis/
administrator/templates/hathor/
```

The backend markup, layouts, assets, Bootstrap usage, JavaScript behavior, APIs, and extension integration points differ between Joomla 3 and newer Joomla versions.

### Rule 2: Use Atum as the Joomla 6 baseline

For a clean Joomla 6 installation:

1. Keep Atum as the administrator-template baseline.
2. Install Joomla 6-compatible extensions.
3. Test every administrator component and configuration screen.
4. Reimplement only verified project-specific customizations.

### Rule 3: Do not edit Atum Core directly

Direct changes under these paths can be overwritten by Joomla updates:

```text
administrator/templates/atum/
media/templates/administrator/atum/
```

Prefer extension-owned assets, administrator modules, plugins, supported template customization, or carefully maintained overrides.

### Rule 4: Keep extension styling with the extension

CSS or JavaScript required by a custom administrator component should normally be owned and registered by that component instead of being inserted directly into the Core administrator template.

---

## 8. Customization Assessment

Migration effort is minimal when Isis and Hathor remain unchanged Joomla Core files. Additional work is required when the project modified them directly.

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

Useful search:

```bash
grep -RniE "templates/(isis|hathor)|administrator/templates" \
  administrator/components \
  administrator/modules \
  plugins \
  templates
```

Compare the project against a clean Joomla 3 package:

```bash
diff -ru \
  joomla3-clean/administrator/templates/isis \
  current-project/administrator/templates/isis
```

Run the same comparison for Hathor when it exists or is used.

---

## 9. Recommended Migration Actions

| Joomla 3 customization | Joomla 6 action |
|---|---|
| No customization | Use Atum without template migration |
| Login logo or simple branding | Reconfigure or reimplement for Atum |
| Backend color changes | Use supported configuration or extension-owned CSS |
| Component-specific CSS | Move it into the corresponding component assets |
| Custom JavaScript | Register it through Joomla's Web Asset Manager |
| Isis/Hathor layout override | Rewrite against Joomla 6 layouts |
| Custom dashboard | Rebuild using Joomla administrator modules and dashboards |
| Hard-coded Isis/Hathor path | Replace it with dynamic APIs or extension-owned paths |

### Estimated effort

| Current condition | Estimated effort |
|---|---:|
| Unmodified Core templates | 0–1 hour |
| Logo and simple colors only | 2–4 hours |
| Custom backend CSS or JavaScript | 4–12 hours |
| Multiple overrides or template dependencies | 1–3+ days |

These figures are planning estimates. Actual effort depends on modified files, extension compatibility, and regression-test scope.

---

## 10. Inventory Records

| Name | Element | Type | Source | Location | Joomla 3 status | Joomla 6 action |
|---|---|---|---|---|---|---|
| Isis | `isis` | Template | Joomla Core | Administrator | Default or installed | Do not migrate; replace with Atum |
| Hathor | `hathor` | Template | Joomla Core | Administrator | Installed, possibly unused | Remove from scope; use Atum |
| Atum | `atum` | Template | Joomla Core | Administrator | Not available | Use Joomla 6 Core template |

Recommended classification:

```text
Category: Joomla Core
Extension type: Administrator Template
Migration strategy: Replace with the Joomla 6 Core equivalent
```

Do not classify Isis or Hathor as third-party extensions merely because they appear in the Joomla Extension Manager.

---

## 11. Validation Checklist

### Joomla 3 discovery

- [ ] Confirm whether Isis or Hathor is the default administrator template.
- [ ] Check whether Hathor is assigned to any administrator users or workflows.
- [ ] Compare both directories with clean Joomla 3 Core files.
- [ ] Inventory custom CSS, JavaScript, images, and overrides.
- [ ] Search the project for hard-coded Isis or Hathor paths.
- [ ] Identify administrator extensions that depend on template-specific markup.

### Joomla 6 implementation

- [ ] Use Atum as the administrator-template baseline.
- [ ] Reimplement only confirmed business-required customizations.
- [ ] Move component-specific assets into their owning extensions.
- [ ] Register JavaScript and CSS through supported Joomla mechanisms.
- [ ] Test all custom and third-party administrator components.
- [ ] Test administrator login, dashboard, menus, forms, modals, and messages.
- [ ] Confirm keyboard navigation and accessibility behavior.
- [ ] Confirm Joomla updates do not overwrite project customization.

---

## 12. Official References

All sources below are hosted on official Joomla domains.

1. [J3.x: Templates supplied with Joomla!](https://docs.joomla.org/J3.x%3ATemplates_supplied_with_Joomla%21/en)  
   Confirms that Joomla 3 includes Isis as the default administrator template and Hathor as another administrator template.

2. [J3.x: Hathor admin template has not been updated to work with the new features](https://docs.joomla.org/J3.x%3AHathor_admin_template_has_not_been_updated_to_work_with_the_new_features/en)  
   Confirms Joomla's recommendation to use Isis and announces that Hathor would be removed in Joomla 4.

3. [Potential backward compatibility issues in Joomla 4](https://docs.joomla.org/Potential_backward_compatibility_issues_in_Joomla_4/en#Templates)  
   Confirms that the Joomla 3 backend templates Isis and Hathor are no longer supported and that Atum is the new backend template.

4. [J4.x: Template Basics](https://docs.joomla.org/Special%3AMyLanguage/J4.x%3ATemplate_Basics)  
   Identifies Atum as the administrator template used for site management.

5. [J4.x: Switching Templates](https://docs.joomla.org/J4.x%3ASwitching_Templates)  
   States that Joomla 4 comes with one administrator template, Atum.

6. [J4.x: Administrator Modules](https://docs.joomla.org/J4.x%3AAdministrator_Modules)  
   Documents the Atum administrator interface and its administrator module positions.

---

## 13. Summary

- Hathor and Isis are Joomla 3 Core administrator templates.
- Official Joomla documentation identifies Isis as the Joomla 3 default.
- Joomla officially announced that Hathor would be removed in Joomla 4.
- Joomla's compatibility documentation states that Isis and Hathor are no longer supported.
- Atum replaced them as the new Joomla administrator template.
- Joomla 6 should use Atum rather than copying or upgrading Isis or Hathor.
- Migration work is required only when the Joomla 3 project contains custom branding, overrides, assets, or hard-coded template dependencies.
