# Joomla 3 Core and Project Architecture

This document provides a practical overview of Joomla 3 for developers who need to understand an existing website, prepare a feature report, or plan a revamp and upgrade. It combines the Joomla extension model with the architecture, request flow, content, routing, templates, permissions, database, integrations, and operational concerns of a complete Joomla 3 project.

> **Scope:** The exact set of core features and components varies between Joomla 3 releases. When auditing a project, always record the exact Joomla version. Joomla 3.10.12 is the final Joomla 3 release and is a useful reference baseline.

<a id="table-of-contents"></a>
## Table of Contents

1. [What Is Joomla Core?](#what-is-joomla-core)
2. [The Main Parts of a Joomla 3 Project](#main-parts)
3. [Frontend and Administrator Applications](#applications)
4. [How Joomla Builds a Page](#page-flow)
5. [Extensions in Joomla 3](#extensions)
6. [Core, Third-party, Custom, and Unknown](#extension-origin)
7. [Core Components](#core-components)
8. [Content Model](#content-model)
9. [Menus, Routing, and Itemid](#routing)
10. [Modules and Module Instances](#modules)
11. [Plugins and Events](#plugins)
12. [Templates, Positions, and Overrides](#templates)
13. [Users, Groups, ACL, and Access Levels](#acl)
14. [Database Structure](#database)
15. [Configuration and Server Environment](#configuration)
16. [External Integrations](#integrations)
17. [Security, Maintenance, and Upgrade Risks](#security-upgrade)
18. [Recommended Audit Workflow](#audit-workflow)
19. [Joomla 3 Project Understanding Checklist](#checklist)

---

<a id="what-is-joomla-core"></a>
## 1. What Is Joomla Core?

**Joomla Core** is the official CMS code and the default extensions delivered by the Joomla Project. It provides the framework and built-in capabilities required to run and administer a Joomla website.

A real Joomla website normally consists of:

```text
Joomla CMS/Core
+ Core extensions
+ Third-party extensions
+ Custom extensions
+ Templates and template overrides
+ Project configuration
+ Database content
+ Media and assets
+ Server configuration and integrations
```

Core is therefore not limited to the files in `/libraries` or to the items visible in the backend **Components** menu. Many built-in Joomla features are implemented as components, modules, plugins, templates, language packages, libraries, packages, or file extensions.

A file located under a standard Joomla directory is not automatically core. Third-party and custom code uses the same extension structure.

[Back to Table of Contents](#table-of-contents)

---

<a id="main-parts"></a>
## 2. The Main Parts of a Joomla 3 Project

| Part | Purpose |
|---|---|
| Joomla CMS/Core | Framework, application lifecycle, APIs, and default behavior |
| Site application | Public frontend used by visitors |
| Administrator application | Backend used to manage the website |
| Extensions | Components, modules, plugins, templates, languages, libraries, packages, and file extensions |
| Database | Content, users, menus, configuration records, and extension data |
| Templates | Page structure, visual presentation, positions, layouts, CSS, and JavaScript |
| Media and assets | Images, documents, fonts, scripts, and styles |
| Configuration | Global settings, database, sessions, cache, email, paths, and routing |
| Infrastructure | PHP, database server, web server, SSL, CDN, cron jobs, backups, and monitoring |
| Integrations | APIs, SSO, payment, analytics, CRM, SMTP, webhooks, and other external systems |

Important paths include:

```text
/administrator
/components
/modules
/plugins
/templates
/language
/libraries
/media
/images
/cache
/logs
/tmp
/configuration.php
```

Do not count extensions only by directory. For example, one component may contain both:

```text
/components/com_example
/administrator/components/com_example
```

These are normally the frontend and backend sides of the same component, not two separate components.

[Back to Table of Contents](#table-of-contents)

---

<a id="applications"></a>
## 3. Frontend and Administrator Applications

Joomla 3 has two main application clients:

| Client | Typical path | Purpose |
|---|---|---|
| Site | `/` | Public pages and visitor-facing functionality |
| Administrator | `/administrator` | Website administration and configuration |

An extension may run in the Site client, Administrator client, or contain code shared by both. For example:

| Extension | Type | Client |
|---|---|---|
| Login module | Module | Site |
| Administrator menu | Module | Administrator |
| Article management | Component | Site and Administrator |
| Vehicle search | Custom module | Site |
| Dashboard widget | Custom module | Administrator |

**Client** describes where an extension operates. It does not identify who created the extension.

[Back to Table of Contents](#table-of-contents)

---

<a id="page-flow"></a>
## 4. How Joomla Builds a Page

The most important flow to understand is:

```text
URL
→ Router and Menu Item
→ Component
→ Model / View / Controller
→ Layout or Template Override
→ Template
→ Module Positions
→ Plugins and Events
→ Final HTML Response
```

Example:

```text
/cars
→ "Cars" menu item
→ com_vehicle
→ vehicles view
→ template override
→ active site template
→ vehicle search and footer modules
→ SEO and tracking plugins
→ rendered page
```

This flow helps answer practical audit questions:

- Which menu item creates the URL context?
- Which component owns the main page output?
- Which view and layout render the content?
- Is the layout provided by the extension or overridden by the template?
- Which module instances appear on this page?
- Which plugins modify the request, data, or final HTML?
- Does the feature use Joomla data, custom tables, hard-coded content, or an external API?

A useful rule is:

```text
Component = main page functionality
Module    = supporting blocks around the component
Plugin    = event-driven behavior
Template  = page structure and presentation
Menu Item = routing and page context
```

[Back to Table of Contents](#table-of-contents)

---

<a id="extensions"></a>
## 5. Extensions in Joomla 3

An **extension** adds or changes Joomla functionality. Joomla 3 supports eight extension types.

| Type | Common technical name | Main responsibility |
|---|---|---|
| Component | `com_*` | Large application or business feature |
| Module | `mod_*` | Small content block placed in a template position |
| Plugin | `plg_*` | Event-driven behavior and request/content processing |
| Template | Template name | Frontend or backend visual structure |
| Language | `en-GB`, `vi-VN` | Translated interface strings |
| Library | `lib_*` | Reusable code shared by extensions |
| Package | `pkg_*` | Installer containing multiple extensions |
| File | `files_*` | Installer for a group of shared files or assets |

### Component

A component is similar to a small application inside Joomla. It normally owns the main content area and may have both frontend and backend code.

Examples: `com_content`, `com_users`, `com_contact`, a third-party backup component, or a custom vehicle-management component.

### Module

A module is a smaller block rendered in a template position, such as a menu, login form, banner, latest-articles list, footer address, or vehicle finder.

The module extension and its module instances are different:

```text
mod_custom extension
├── Homepage promotion instance
├── Footer address instance
└── Campaign banner instance
```

### Plugin

A plugin runs when Joomla dispatches an event. Plugins may process content, authentication, users, requests, forms, installation, search, or editor behavior.

Common plugin groups include `system`, `content`, `user`, `authentication`, `editors`, `captcha`, `finder`, and `extension`.

A plugin in the `system` folder is not automatically Joomla Core. The folder identifies its event group.

### Template

A template controls the visual structure of the Site or Administrator application. It can include template styles, module positions, alternative layouts, overrides, CSS, and JavaScript.

### Language

A language extension provides translated strings for Joomla or another extension. Language packages should be included in an extension inventory.

### Library

A library provides reusable framework or integration code. A library may not render a page, but an incompatible library can break every extension that depends on it.

### Package

A package installs several related extensions together:

```text
pkg_example
├── com_example
├── mod_example
├── plg_system_example
└── lib_example
```

Audit the package and every child extension. Do not record only the parent package.

### File

A file extension installs or updates shared files, fonts, assets, or framework resources that do not fit the normal component, module, or plugin structure.

For more detail, see [extension-in-joomla.md](./extension-in-joomla.md).

[Back to Table of Contents](#table-of-contents)

---

<a id="extension-origin"></a>
## 6. Core, Third-party, Custom, and Unknown

**Extension type** and **extension origin** are separate classifications.

| Origin | Meaning | Example |
|---|---|---|
| Joomla Core | Delivered by the official Joomla distribution | `com_content`, `com_users`, `mod_menu` |
| Third-party | Developed and distributed by an external vendor | Akeeba Backup, JCE Editor |
| Custom | Written specifically for the company or project | `com_dealer`, `mod_vehicle_finder` |
| Unknown | Available evidence is not sufficient | Missing author, documentation, and source history |

Use several signals together:

| Evidence | Joomla Core | Third-party | Custom |
|---|---|---|---|
| Author | Joomla! Project | Vendor name | Internal company/developer |
| Clean Joomla installation | Included | Not included | Not included |
| Update site | Joomla service | Vendor service | Internal or absent |
| Documentation | Joomla documentation | Vendor documentation | Internal documentation |
| Source history | Joomla repository | Vendor package | Project repository |
| Technical name | Standard Joomla name | Product/vendor name | Project/business name |
| Protected flag | Often protected | Usually not | Usually not |

Safe verification process:

1. Open **Extensions → Manage → Manage**.
2. Record name, element, type, folder, client, version, author, status, protected flag, and extension ID.
3. Compare it with a clean installation of the same Joomla version.
4. Inspect **Extensions → Manage → Update Sites**.
5. Inspect the extension manifest XML.
6. Check vendor documentation, project documentation, and Git history.
7. Mark uncertain items as **Unknown – Need verification**.

Do not classify an extension using only its ID, protected status, `system` plugin group, name, or missing update site.

Also note that **Install**, **Manage**, **Update**, **Discover**, **Database**, and **Update Sites** are management screens—not extension types.

[Back to Table of Contents](#table-of-contents)

---

<a id="core-components"></a>
## 7. Core Components

For Joomla 3.10.12, a source-level inventory gives approximately **35 distinct core components** after combining frontend and administrator directories and removing duplicates. The exact number can differ across Joomla 3 releases.

Examples include:

| Component | Purpose |
|---|---|
| `com_content` | Articles |
| `com_categories` | Categories |
| `com_users` | Users |
| `com_contact` | Contacts |
| `com_menus` | Menus and menu items |
| `com_modules` | Module management |
| `com_plugins` | Plugin management |
| `com_templates` | Templates and styles |
| `com_media` | Media management |
| `com_banners` | Banners |
| `com_tags` | Tags |
| `com_fields` | Custom fields |
| `com_finder` | Smart Search |
| `com_search` | Legacy search |
| `com_installer` | Extension installation and management |
| `com_joomlaupdate` | Joomla update |
| `com_privacy` | Privacy tools |
| `com_actionlogs` | User action logs |

Important counting rules:

- Do not add frontend and administrator directory counts directly.
- The backend **Components** menu does not display every installed component.
- Use **Extensions → Manage → Manage**, filter by **Component**, and then classify each result by origin.
- Record the exact Joomla version used as the comparison baseline.

The actual website total is:

```text
Core components
+ Third-party components
+ Custom components
+ Unknown components
= Total installed components
```

[Back to Table of Contents](#table-of-contents)

---

<a id="content-model"></a>
## 8. Content Model

Core content concepts include:

- Articles
- Categories
- Tags
- Custom Fields
- Media
- Contacts
- Banners
- Featured Articles
- Published, unpublished, archived, and trashed states
- Publish start and end dates
- Languages and associations

A simplified relationship is:

```text
Category
└── Article
    ├── Tags
    ├── Custom Fields
    └── Menu Item
```

Frontend content may come from an article, custom component, module instance, template hard-code, page builder, database table, or external API. Do not assume every visible text block is an article.

[Back to Table of Contents](#table-of-contents)

---

<a id="routing"></a>
## 9. Menus, Routing, and Itemid

In Joomla, menus do more than render navigation. A menu item also creates page context and affects routing, module assignment, template style, layout, and permissions.

Important concepts:

- Menu and menu item
- Menu item type
- Alias and hierarchy
- Default/Home menu item
- Hidden menu
- Component view
- SEF URL and URL rewriting
- Redirects
- `Itemid`
- Module menu assignment

Example:

```text
index.php?option=com_content&view=article&id=10&Itemid=123
```

| Parameter | Meaning |
|---|---|
| `option` | Component |
| `view` | Component view |
| `id` | Data record |
| `Itemid` | Menu item context |

The same article opened with a different `Itemid` may use different modules, layout, template style, or access behavior.

[Back to Table of Contents](#table-of-contents)

---

<a id="modules"></a>
## 10. Modules and Module Instances

A module extension can create many module instances. Each instance may have its own:

- Title
- Position
- Published status
- Ordering
- Access level
- Language
- Menu assignment
- Publish start and end date
- Parameters
- Content

An extension audit records `mod_custom` once. A feature audit must also record every relevant instance and the URLs or menu items on which it appears.

[Back to Table of Contents](#table-of-contents)

---

<a id="plugins"></a>
## 11. Plugins and Events

Plugins can silently affect large areas of the website. They may:

- Redirect requests
- Change rendered article content
- Insert analytics or tracking scripts
- Authenticate users
- Connect to SSO
- Validate or change forms
- Send data to an API
- Execute logic when a record is saved
- Modify routing or response output

Record at least:

```text
Plugin group
+ Element
+ Origin
+ Version
+ Status
+ Ordering
+ Parameters
+ Events handled
```

Ordering matters when multiple plugins handle the same event.

[Back to Table of Contents](#table-of-contents)

---

<a id="templates"></a>
## 12. Templates, Positions, and Overrides

| Concept | Meaning |
|---|---|
| Template | Overall frontend or backend visual structure |
| Template style | A configured instance of a template |
| Module position | Named location where modules are rendered |
| Template override | Replacement layout for a component or module |
| Alternative layout | Optional layout selectable through configuration |
| Custom CSS/JS | Project-specific presentation and behavior |

Inspect:

```text
/templates/<template-name>/
/templates/<template-name>/html/
/templates/<template-name>/css/
/templates/<template-name>/js/
```

The highest-risk locations during an upgrade are often:

```text
/templates/<template-name>/html/com_*
/templates/<template-name>/html/mod_*
```

An override is custom project code even when it overrides a core extension. Old Joomla 3 overrides may depend on markup, APIs, or JavaScript that no longer exists in the target Joomla version.

[Back to Table of Contents](#table-of-contents)

---

<a id="acl"></a>
## 13. Users, Groups, ACL, and Access Levels

Joomla permissions follow this model:

```text
User
→ User Group
→ Permissions
→ Viewing Access Level
```

- **Permission** controls which actions a user may perform.
- **Viewing Access Level** controls which content a user may see.

Common actions include Configure, Access Administration Interface, Create, Delete, Edit, Edit State, and Edit Own.

Permissions may be configured at several levels:

```text
Global Configuration
→ Component
→ Category
→ Article
```

Understand the effect of **Inherited**, **Allowed**, and **Denied**. Also document custom user groups, access levels, administrator roles, and any extension-specific permission rules.

[Back to Table of Contents](#table-of-contents)

---

<a id="database"></a>
## 14. Database Structure

Important core tables include:

| Table | Purpose |
|---|---|
| `#__extensions` | Registered extensions |
| `#__content` | Articles |
| `#__categories` | Categories |
| `#__menu` | Menu items |
| `#__modules` | Module instances |
| `#__modules_menu` | Module-to-menu assignment |
| `#__users` | Users |
| `#__user_usergroup_map` | User-to-group mapping |
| `#__assets` | ACL asset tree |
| `#__fields` | Custom fields |
| `#__tags` | Tags |
| `#__template_styles` | Template styles |
| `#__update_sites` | Extension update sources |

`#__` is a placeholder. The real table prefix is configured in `configuration.php`.

Also identify:

- Third-party and custom tables
- Tables left by removed extensions
- Direct SQL usage in custom code
- Database triggers or procedures
- External databases
- Data ownership and migration dependencies

[Back to Table of Contents](#table-of-contents)

---

<a id="configuration"></a>
## 15. Configuration and Server Environment

### Joomla configuration

Review:

- Exact Joomla version
- Offline mode
- Debug and error reporting
- SEF URLs and URL rewriting
- Cache and session handlers
- Mail configuration
- Cookie domain and path
- Log and temporary paths
- Database connection
- Gzip compression

### Server environment

Review:

- PHP version and required extensions
- MySQL or MariaDB version
- Apache or Nginx configuration
- `.htaccess` or rewrite rules
- File ownership and permissions
- Cron jobs and scheduled tasks
- SMTP
- SSL
- CDN and WAF
- Backups and restore process
- Logs and monitoring
- Secrets and environment-specific configuration

A backend-only audit will miss important project behavior stored in server configuration and scheduled processes.

[Back to Table of Contents](#table-of-contents)

---

<a id="integrations"></a>
## 16. External Integrations

Typical integrations include:

- REST or SOAP APIs
- Payment gateways
- CRM or ERP
- SSO or LDAP
- SMTP and email services
- Maps
- Analytics and tag managers
- CAPTCHA
- Social networks
- External search
- CDN or object storage
- Scheduled import/export
- Webhooks

For each integration, record:

| Field | Description |
|---|---|
| Purpose | Business reason for the integration |
| Provider | External service or internal system |
| Code location | Component, module, plugin, library, template, or script |
| Configuration location | Backend parameters, configuration file, environment, or database |
| Authentication | API key, OAuth, certificate, SSO, etc. |
| Data direction | Inbound, outbound, or both |
| Failure behavior | Retry, queue, fallback, alert, or silent failure |
| Owner | Team or vendor responsible |
| Upgrade risk | Compatibility and migration concern |

Never put real passwords, tokens, private keys, or secrets in the report.

[Back to Table of Contents](#table-of-contents)

---

<a id="security-upgrade"></a>
## 17. Security, Maintenance, and Upgrade Risks

Joomla 3 is a legacy branch, so continued operation and migration require explicit risk management.

Check:

- Exact Joomla, PHP, and database versions
- Unsupported or abandoned extensions
- Known extension vulnerabilities
- Super User accounts
- MFA/2FA configuration where available
- File permissions
- Debug and error reporting in production
- Backup schedule and tested restore process
- Logs and monitoring
- Direct edits to Joomla core files
- Extensions installed from untrusted sources
- Outdated template overrides
- Deprecated PHP or Joomla APIs
- Hard-coded credentials and endpoints
- Cron jobs and undocumented integrations

Never upgrade production directly. Build an inventory, take a verified backup, clone the environment, upgrade extensions and infrastructure in a test environment, execute functional tests, and prepare a rollback plan.

[Back to Table of Contents](#table-of-contents)

---

<a id="audit-workflow"></a>
## 18. Recommended Audit Workflow

1. Record Joomla, PHP, database, web server, and operating environment versions.
2. Inventory all eight extension types from **Extensions → Manage → Manage**.
3. Classify every extension as Core, Third-party, Custom, or Unknown.
4. Inventory module instances, positions, parameters, and menu assignments.
5. Inventory enabled plugins, groups, ordering, parameters, and handled events.
6. Map each URL to its menu item, component, view, layout, template, modules, and plugins.
7. Inspect active templates, styles, positions, overrides, and custom CSS/JS.
8. Map content storage: articles, modules, custom components, hard-code, or APIs.
9. Identify core, third-party, custom, orphaned, and external database tables.
10. Document users, groups, access levels, and important ACL rules.
11. Document every integration, cron job, email flow, cache, log, and backup.
12. Search for direct Joomla core modifications.
13. Check vendor support and compatibility with the target Joomla and PHP versions.
14. Assign an upgrade risk and migration action to each feature and dependency.

Recommended report fields:

| Field | Purpose |
|---|---|
| Feature | User or business capability |
| URL/Area | Frontend route or backend location |
| Menu Item | Routing context |
| Main Component | Main feature owner |
| Modules | Supporting instances |
| Plugins | Event-driven dependencies |
| Template/Override | Presentation dependency |
| Data Source | Core table, custom table, content, or API |
| Origin | Core, Third-party, Custom, or Unknown |
| Status | Active, disabled, unused, or unknown |
| Upgrade Risk | Low, Medium, High, or Blocker |
| Migration Action | Keep, update, replace, rebuild, remove, or verify |

[Back to Table of Contents](#table-of-contents)

---

<a id="checklist"></a>
## 19. Joomla 3 Project Understanding Checklist

You understand the project when you can answer all of the following:

- [ ] What exact Joomla 3 version is installed?
- [ ] Which menu item and component generate each important URL?
- [ ] Which view, layout, and template override render each feature?
- [ ] Which extensions are Core, Third-party, Custom, or Unknown?
- [ ] Which extensions are active, disabled, unused, or abandoned?
- [ ] How many module instances exist and where does each appear?
- [ ] Which plugins affect requests, content, login, forms, search, or APIs?
- [ ] Which templates and template styles are active?
- [ ] Which core and extension layouts are overridden?
- [ ] Is each content block stored in an article, module, custom component, hard-coded file, or API?
- [ ] Which custom database tables belong to each feature?
- [ ] Which users, groups, access levels, and ACL rules are important?
- [ ] Which external systems does the website depend on?
- [ ] How do cron jobs, email, cache, logs, monitoring, and backups work?
- [ ] Have any Joomla core files been modified directly?
- [ ] Is each feature compatible with the target Joomla, PHP, and database versions?
- [ ] Is there a tested backup, staging environment, test plan, and rollback plan?

## Final Summary

To understand a Joomla 3 website, do not stop at the extension list. The central relationship is:

```text
URL
→ Menu Item
→ Component
→ View/Layout or Override
→ Template
→ Module Instances
→ Plugin Events
→ Database or External Integration
```

Once this relationship is mapped for every important page and feature, the extension inventory becomes a practical architecture and upgrade report rather than only a list of installed software.
