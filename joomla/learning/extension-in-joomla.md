# Joomla Extensions

This document explains what Joomla extensions are, the eight extension types available in Joomla 3, how extension types differ from extension origins, and how to identify Joomla Core, third-party, and custom extensions during an audit or upgrade.

<a id="table-of-contents"></a>
## Table of Contents

1. [What Is a Joomla Extension?](#what-is-a-joomla-extension)
2. [Key Concepts](#key-concepts)
3. [The Eight Joomla Extension Types](#the-eight-joomla-extension-types)
   - [Component](#component)
   - [Module](#module)
   - [Plugin](#plugin)
   - [Template](#template)
   - [Language](#language)
   - [Library](#library)
   - [Package](#package)
   - [File](#file)
4. [Extension Origins](#extension-origins)
5. [How to Check Extensions in Joomla 3](#how-to-check-extensions-in-joomla-3)
6. [How to Identify Core, Third-Party, and Custom Extensions](#how-to-identify-extension-origin)
7. [Install, Manage, and Update Screens](#management-screens)
8. [Recommended Report Structure](#recommended-report-structure)
9. [Extension Audit Checklist](#extension-audit-checklist)
10. [Quick Reference](#quick-reference)
11. [How Many Extension Categories Are There?](#how-many-extension-categories)
12. [What Is an Extension Family?](#extension-family)
13. [Conclusion](#conclusion)
14. [References](#references)

---

<a id="what-is-a-joomla-extension"></a>
## 1. What Is a Joomla Extension?

A **Joomla extension** is an installable or built-in software unit that adds, changes, or supports functionality in a Joomla website.

Extensions can:

- Manage articles, users, contacts, or other business data.
- Display menus, banners, login forms, or content blocks.
- React to system events such as login, content saving, or page rendering.
- Integrate payment services, APIs, analytics, or backup tools.
- Define the frontend or administrator interface.
- Add languages or shared code libraries.

Many built-in Joomla features are also implemented as extensions. Therefore, an extension is not automatically third-party simply because Joomla calls it an extension.

> Do not confuse an **extension type** with an **extension origin** or with management screens such as **Install**, **Manage**, and **Update**.

[Back to Table of Contents](#table-of-contents)

<a id="key-concepts"></a>
## 2. Key Concepts

| Concept | Question it answers | Examples |
|---|---|---|
| Type | How does the extension work? | Component, Module, Plugin |
| Origin | Who provides and maintains it? | Joomla Core, Third-party, Custom |
| Client | Where does it run? | Site, Administrator |
| Folder/Group | Which event group does a plugin belong to? | system, content, user |
| Family | Which product ecosystem or dependency group does it belong to? | AcyMailing, HikaShop, Custom Product Management |
| Status | Is the extension active? | Enabled, Disabled |
| Management screen | What operation is being performed? | Install, Manage, Update |

These properties are independent. For example, a system-group plugin can be Joomla Core, third-party, or custom.

[Back to Table of Contents](#table-of-contents)

<a id="the-eight-joomla-extension-types"></a>
## 3. The Eight Joomla Extension Types

Joomla 3 supports **eight extension types**:

| # | Type | Common technical name | Primary responsibility |
|---:|---|---|---|
| 1 | Component | `com_*` | Major application or business feature |
| 2 | Module | `mod_*` | Small content block placed in a template position |
| 3 | Plugin | `plg_*` | Event-based processing |
| 4 | Template | Template name | Site or administrator presentation |
| 5 | Language | `en-GB`, `vi-VN` | Translated interface strings |
| 6 | Library | `lib_*` | Shared code used by other extensions |
| 7 | Package | `pkg_*` | Installer bundle containing multiple extensions |
| 8 | File | `files_*` | Installation or update of a group of files |

<a id="component"></a>
### 3.1. Component

A **component** is a major application inside Joomla. It commonly has an administrator interface, a site interface, or both.

Examples:

- `com_content`: article management.
- `com_users`: user management.
- `com_contact`: contact management.
- `com_akeeba`: Akeeba Backup functionality.
- `com_vehicle`: a possible custom vehicle-management component.

A component is comparable to a small application running inside Joomla.

<a id="module"></a>
### 3.2. Module

A **module** is a smaller content or interface block displayed in a template position.

Examples include:

- Navigation menus.
- Login forms.
- Banners.
- Latest article lists.
- Vehicle search blocks.
- Footer contact details.

One module extension can create multiple module instances. For example, a website may contain twenty Custom HTML blocks created from `mod_custom`, while Extension Manager still lists `mod_custom` as one extension.

<a id="plugin"></a>
### 3.3. Plugin

A **plugin** runs when a Joomla event occurs, such as:

- A user logs in.
- An article is saved.
- Content is rendered.
- A request is initialized.
- An extension is installed.

Common plugin groups include:

| Plugin group | Responsibility |
|---|---|
| `system` | System-wide events |
| `content` | Article and content processing |
| `user` | User-related events |
| `authentication` | Login authentication |
| `editors` | Content editors |
| `editors-xtd` | Extra editor buttons |
| `captcha` | CAPTCHA integrations |
| `finder` | Smart Search |
| `extension` | Extension installation events |

> `Folder = system` does not mean that a plugin belongs to Joomla Core. It only identifies the plugin event group.

<a id="template"></a>
### 3.4. Template

A **template** controls presentation and page layout.

Joomla uses two main template clients:

- **Site Template**: the public frontend.
- **Administrator Template**: the backend administration interface.

Templates can contain layout overrides under:

```text
/templates/template_name/html/
```

A template override customizes output from a component or module, but the override itself is **not a separate extension**. Overrides must still be reviewed during an upgrade because they may depend on old Joomla markup or APIs.

<a id="language"></a>
### 3.5. Language

A **language extension** provides translated interface strings for Joomla or another extension.

Examples:

- `en-GB`: English.
- `vi-VN`: Vietnamese.
- `zh-CN`: Simplified Chinese.

Language extensions should be included in an audit, even when they are installed with Joomla or another extension package.

<a id="library"></a>
### 3.6. Library

A **library** contains reusable code shared by one or more extensions.

Examples include:

- Framework code.
- API clients.
- Helper classes.
- Shared file or data-processing utilities.

Libraries normally do not create a visible page. However, an incompatible library can break every component, module, or plugin that depends on it.

<a id="package"></a>
### 3.7. Package

A **package** is an installer bundle that contains multiple extensions.

```text
pkg_example
├── com_example
├── mod_example
├── plg_system_example
└── lib_example
```

During an upgrade audit, record both the package and its child extensions. Each child may have a separate version, dependency, configuration, and compatibility risk.

<a id="file"></a>
### 3.8. File

A **file extension** installs or updates a collection of files that does not use the normal component, module, or plugin structure.

It may contain:

- Framework files.
- Fonts or assets.
- Shared system files.
- Supporting files required by other extensions.

File extensions are less common, but they should not be omitted from an inventory.

[Back to Table of Contents](#table-of-contents)

<a id="extension-origins"></a>
## 4. Extension Origins

Core, third-party, and custom describe an extension's **origin**, not its technical type.

| Origin | Meaning | Examples |
|---|---|---|
| Joomla Core | Included in the official Joomla distribution | `com_content`, `com_users`, `mod_menu` |
| Third-party | Developed by an external vendor and installed separately | Akeeba Backup, JCE Editor |
| Custom | Developed specifically for the website or organization | `com_dealer`, `mod_vehicle_finder` |
| Unknown – Need verification | Available evidence is insufficient | Missing author, documentation, and source history |

Any extension type can have any origin:

| Extension | Type | Origin |
|---|---|---|
| `com_content` | Component | Joomla Core |
| `com_akeeba` | Component | Third-party |
| `com_dealer` | Component | Custom |
| `mod_menu` | Module | Joomla Core |
| `mod_vehicle_finder` | Module | Custom |
| `plg_system_cache` | Plugin | Joomla Core |
| `plg_system_akeeba` | Plugin | Third-party |

[Back to Table of Contents](#table-of-contents)

<a id="how-to-check-extensions-in-joomla-3"></a>
## 5. How to Check Extensions in Joomla 3

Open the Joomla administrator interface:

```text
https://your-domain.com/administrator
```

Then navigate to:

```text
Extensions → Manage → Manage
```

This is the primary screen for collecting the registered extension inventory. Filter by **Type** and review all eight types:

- Component.
- Module.
- Plugin.
- Template.
- Language.
- Library.
- Package.
- File.

Capture these fields where available:

- Name.
- Technical Name or Element.
- Type.
- Folder.
- Client.
- Version.
- Author.
- Status.
- Protected.
- Extension ID.

Do not use only the **Components** menu for an inventory. It does not provide a complete list of modules, plugins, templates, languages, libraries, packages, or file extensions.

[Back to Table of Contents](#table-of-contents)

<a id="how-to-identify-extension-origin"></a>
## 6. How to Identify Core, Third-Party, and Custom Extensions

No single field proves an extension's origin with complete certainty. Combine several sources of evidence.

| Evidence | Joomla Core | Third-party | Custom |
|---|---|---|---|
| Author | Joomla! Project | External vendor | Internal company or developer |
| Included in a clean Joomla installation | Yes | No | No |
| Protected | Often Yes | Usually No | Usually No |
| Update Site | Joomla server | Vendor server | Internal server or none |
| Documentation | Joomla documentation | Vendor documentation | Internal documentation |
| Technical Name | Standard Joomla name | Product or vendor name | Project or business-domain name |
| Source history | Joomla source | Vendor package/repository | Project repository |

### Safe verification process

1. Check `Author`, `Version`, and `Element` in **Manage**.
2. Compare the extension with a clean installation of the exact Joomla version.
3. Review `Extensions → Manage → Update Sites`.
4. Find the vendor and its official documentation.
5. Inspect the extension manifest XML file.
6. Review Git history, the project repository, and internal documentation.
7. If the evidence is still insufficient, classify it as `Unknown – Need verification`.

Do not classify an extension based only on:

- A low Extension ID.
- `Protected = Yes`.
- The `system` plugin folder.
- The word `custom` in its name.
- The absence of an Update Site.

These are indicators, not proof.

[Back to Table of Contents](#table-of-contents)

<a id="management-screens"></a>
## 7. Install, Manage, and Update Screens

**Install**, **Manage**, and **Update** are management screens, not extension types.

| Screen | Purpose |
|---|---|
| Install | Install a new extension |
| Manage | View and manage registered extensions |
| Update | Display extensions with an available update |
| Discover | Find extension source code present on the server but not registered correctly |
| Database | Check or repair the Joomla database schema |
| Warnings | Display installation environment warnings |
| Install Languages | Install language packages |
| Update Sites | Manage URLs used to check for extension updates |

Typical lifecycle:

```text
Install an extension
        ↓
The extension appears in Manage
        ↓
Its Update Site checks for a newer version
        ↓
If an update exists, it appears in Update
```

Therefore:

- **Manage** contains registered extensions.
- **Update** contains only extensions with detected updates.
- **Install** is used to add extensions.
- **Discover** identifies extension code copied to the server without a complete installation process.

[Back to Table of Contents](#table-of-contents)

<a id="recommended-report-structure"></a>
## 8. Recommended Report Structure

| Extension Name | Technical Name | Type | Client/Folder | Origin | Version | Status | Upgrade Risk |
|---|---|---|---|---|---|---|---|
| Content | `com_content` | Component | Site/Admin | Joomla Core | 3.x | Enabled | Covered by the Joomla upgrade process |
| Akeeba Backup | `com_akeeba` | Component | Administrator | Third-party | 7.x | Enabled | Verify vendor compatibility |
| Vehicle Finder | `mod_vehicle_finder` | Module | Site | Custom | 1.0 | Enabled | Source review required |
| Custom Tracking | `plg_system_customtracking` | Plugin | `system` | Custom | Unknown | Enabled | High risk |

Keep **Type** and **Origin** in separate columns. This prevents labels such as Component or System from being incorrectly treated as evidence of ownership.

[Back to Table of Contents](#table-of-contents)

<a id="extension-audit-checklist"></a>
## 9. Extension Audit Checklist

- [ ] Open `Extensions → Manage → Manage`.
- [ ] Filter and inspect all eight extension types.
- [ ] Check both Site and Administrator clients.
- [ ] Include enabled and disabled extensions.
- [ ] Record Author, Version, Element, Client, Folder, and Status.
- [ ] Review Update Sites.
- [ ] Run Discover, but do not install discovered items before verification and backup.
- [ ] Record packages and all child extensions.
- [ ] Review template overrides separately.
- [ ] Use `Unknown – Need verification` when evidence is insufficient.
- [ ] Check vendor support and Joomla/PHP compatibility before upgrading.
- [ ] Review custom source code and dependencies.

[Back to Table of Contents](#table-of-contents)

<a id="quick-reference"></a>
## 10. Quick Reference

```text
Type   = How does the extension work?
Origin = Who provides and maintains the extension?
Client = Does it run on the Site or Administrator side?
Folder = Which event group does a plugin belong to?
Status = Is the extension enabled or disabled?
Screen = Which management operation is being performed?
```

[Back to Table of Contents](#table-of-contents)

<a id="how-many-extension-categories"></a>
## 11. How Many Extension Categories Are There?

The answer depends on the classification dimension being discussed. There is not one single list that should be used for every purpose.

### Classification by technical type: eight types

Joomla 3 registers these eight extension types:

```text
Component | Module | Plugin | Template
Language | Library | Package | File
```

This dimension answers:

> What technical role does the extension perform?

### Classification by origin: four audit values

For a complete project audit, use four origin values:

| Origin | Meaning | Required audit action |
|---|---|---|
| `Core` | Included in the official Joomla distribution | Compare with a clean Joomla package and check for Core modifications |
| `Third-party` | Supplied by an external vendor or community developer | Verify vendor support, license, update path, and Joomla 6 compatibility |
| `Custom` | Built specifically for the website or organization | Review source code, dependencies, ownership, and rewrite effort |
| `Unknown` | Available evidence is not sufficient | Investigate; do not guess or silently classify it as Custom |

This dimension answers:

> Who created, supplies, and maintains the extension?

If the discussion excludes Joomla Core extensions, most identified extensions fall into two main origins:

```text
Non-Core extension
├── Third-party / Vendor
└── Custom
```

However, an audit must retain `Unknown` until evidence confirms one of those origins. Therefore, saying “the project has only two extension types” is inaccurate. A safer statement is:

> Identified non-Core extensions are usually either Third-party/Vendor or Custom; unverified extensions remain Unknown.

### A custom module is not a separate top-level origin

`Module` is a technical type. `Custom` is an origin. Their combination is called a **Custom module**.

```text
Extension
├── Type
│   ├── Component
│   ├── Module
│   ├── Plugin
│   ├── Template
│   ├── Language
│   ├── Library
│   ├── Package
│   └── File
└── Origin
    ├── Core
    ├── Third-party
    ├── Custom
    └── Unknown
```

Examples:

| Technical name | Type | Origin | Correct name |
|---|---|---|---|
| `com_content` | Component | Core | Core component |
| `com_akeeba` | Component | Third-party | Third-party component |
| `com_vehicle` | Component | Custom | Custom component |
| `mod_menu` | Module | Core | Core module |
| `mod_vendor_slider` | Module | Third-party | Third-party module |
| `mod_vehicle_search` | Module | Custom | Custom module |
| `plg_system_abc` | Plugin | Unknown | Unknown plugin requiring verification |

### Status is a third dimension, not an extension type

The following terms describe condition or audit status. They are not additional origins or technical types:

| Status | Meaning |
|---|---|
| `Core modified` | A Core extension whose source differs from the clean Joomla package |
| `Abandoned` | The vendor or maintainer no longer supports the extension |
| `Orphan` | Files or database records remain although the extension is no longer properly used |
| `Missing source` | The database contains an extension record, but its source files are missing |
| `Unregistered` | Source files exist, but the extension is not correctly registered in Joomla |
| `Disabled` | The extension is installed but not enabled |

For example, `com_content` can be recorded as:

```text
Type: Component
Origin: Core
Status: Core modified
```

Do not change its origin to Custom merely because developers modified its source.

### Practical classification rule

```text
Is it included in a clean package of the exact Joomla version?
├── Yes
│   ├── Source matches the clean package → Core
│   └── Source differs → Core + Status: Core modified
└── No
    ├── Vendor, package, license, or official update server exists → Third-party
    ├── Project team or contractor built it specifically for the site → Custom
    └── Evidence is insufficient → Unknown
```

Use at least these columns in the extension inventory:

| Extension | Type | Origin | Status | Evidence | Upgrade action |
|---|---|---|---|---|---|
| `mod_vehicle_search` | Module | Custom | Active | Internal Git history and manifest author | Rewrite and test |
| `com_akeeba` | Component | Third-party | Active | Vendor manifest and update server | Find supported Joomla 6 release |
| `com_content` | Component | Core | Core modified | Diff against clean Joomla package | Remove or port modification |
| `plg_system_abc` | Plugin | Unknown | Need verification | Author and source history missing | Investigate before migration |

### Naming formula for reports

Use this formula consistently:

```text
[Origin] + [Type]
```

Examples:

- Core component.
- Third-party module.
- Custom plugin.
- Unknown library.

Keep `Status` in a separate column. This structure prevents Custom extension and Custom module from being counted as two unrelated top-level categories.

[Back to Table of Contents](#table-of-contents)

<a id="extension-family"></a>
## 12. What Is an Extension Family?

An **Extension Family** is a reporting and inventory concept used to group related Joomla extensions that belong to the same product, business feature, installation package, or dependency set.

It is **not an official Joomla extension type**. Joomla still registers each family member separately as a Component, Module, Plugin, Template, Language, Library, Package, or File extension.

Example:

```text
FAM-001: AcyMailing
├── com_acymailing
├── mod_acymailing
├── plg_acymailing_tagsubscriber
├── plg_acymailing_tagsubscription
└── plg_acymailing_urltracker
```

The family groups these records for analysis, but it does not replace their individual extension types.

### Family, type, and origin are separate dimensions

| Dimension | Question it answers | Example |
|---|---|---|
| Extension Type | What technical role does it perform? | Component, Module, Plugin |
| Extension Origin | Who supplies and maintains it? | Core, Third-party, Custom |
| Extension Family | Which product or dependency group does it belong to? | AcyMailing |
| Status | Is it enabled, disabled, active, or unused? | Enabled, In Use |

Example inventory:

| Extension | Type | Origin | Family |
|---|---|---|---|
| `com_acymailing` | Component | Third-party | AcyMailing |
| `mod_acymailing` | Module | Third-party | AcyMailing |
| `plg_acymailing_tagsubscriber` | Plugin | Third-party | AcyMailing |
| `com_company_product` | Component | Custom | Product Management |
| `plg_webservices_companyproduct` | Plugin | Custom | Product Management |

### Which extension types can belong to a family?

All eight Joomla extension types can be family members:

| Extension type | Can belong to a family? | Typical role |
|---|---:|---|
| Component | Yes | Main application or administration interface |
| Module | Yes | Display block or frontend entry point |
| Plugin | Yes | Events, content processing, authentication, or integration |
| Template | Yes | Product-specific presentation |
| Language | Yes | Translation package |
| Library | Yes | Shared framework or reusable code |
| Package | Yes | Installer bundle for the family |
| File | Yes | Shared assets or supporting files |

The most common family structure is:

```text
Component + Modules + Plugins + Libraries
```

Third-party products commonly form families because one vendor package may install several related extensions. Custom project features can also form families even when their extensions are deployed separately.

Joomla Core extensions can be grouped by feature—for example, Smart Search may include `com_finder`, `mod_finder`, and finder plugins—but Core families are usually unnecessary when a report covers only Third-party and Custom extensions.

### When to assign the same Family ID

Assign extensions to the same family when one or more of these conditions are supported by evidence:

- They belong to the same named product.
- They are installed by the same package.
- A main component has supporting modules, plugins, or libraries.
- They share a library, schema, configuration, or update lifecycle.
- They must normally be upgraded, tested, or removed together.
- One member depends on another member to work correctly.
- Custom extensions jointly implement the same business feature.

Do not group extensions only because they:

- Have the same technical type.
- Belong to the same plugin group such as `system` or `content`.
- Have the same vendor but represent independent products.
- Have similar names without a confirmed functional or dependency relationship.

### Integration extensions

An integration can connect two separate families. For example:

```text
plg_acymailing_hikashop
Primary Family: AcyMailing
Related Family: HikaShop
Relationship: Integration
```

For migration reporting, either assign the integration its own Family ID or retain the primary family and add relationship columns. The second approach usually makes dependencies clearer:

| Extension | Primary Family | Related Family | Relationship |
|---|---|---|---|
| `plg_acymailing_hikashop` | AcyMailing | HikaShop | Integration |

### Recommended family fields in an inventory

| Field | Purpose |
|---|---|
| Family ID | Stable report identifier, such as `FAM-001` |
| Family Name | Product or business-feature name |
| Family Role | Main, Supporting, Shared Library, or Integration |
| Primary Family | Main product that owns the extension |
| Related Family | Another product required by an integration |
| Relationship | Dependency, Integration, Optional Add-on, or Shared Library |
| Evidence | Package manifest, vendor documentation, dependency, or source history |

Use a Family ID only when the relationship is known. If the evidence is insufficient, leave the family as `Unknown – Need verification` instead of grouping by guesswork.

> An Extension Family is a report-level grouping. It helps plan installation, upgrade, migration, dependency analysis, and regression testing, but Joomla continues to install and manage each registered extension according to its actual technical type.

[Back to Table of Contents](#table-of-contents)

---

<a id="conclusion"></a>
## 13. Conclusion

Joomla 3 has **eight extension types**: Component, Module, Plugin, Template, Language, Library, Package, and File.

For an accurate inventory, classify every extension with at least two separate values:

```text
Extension Type + Extension Origin
```

Use one of these origin values:

- Joomla Core.
- Third-party.
- Custom.
- Unknown – Need verification.

The Joomla administrator interface provides the initial inventory and useful metadata. Accurate classification—especially for custom extensions—also requires checking manifest XML files, Update Sites, source code, Git history, vendor information, and project documentation.

[Back to Table of Contents](#table-of-contents)

<a id="references"></a>
## 14. References

- [Joomla Extension Types](https://docs.joomla.org/Extension_types_%28general_definitions%29)
- [Joomla 3 Extension Manager](https://docs.joomla.org/Help310%3AExtensions_Extension_Manager_Manage)
- [Joomla Manifest Files](https://docs.joomla.org/manifest_files)
- [Joomla Discover](https://docs.joomla.org/Help310%3AExtensions_Extension_Manager_Discover)

[Back to Table of Contents](#table-of-contents)
