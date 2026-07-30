# Joomla 3 Project Structure

A practical guide to reading, auditing, documenting, and upgrading a Joomla 3 project.

> Baseline: Joomla 3.10.x. A real project may contain additional folders created by third-party extensions, custom development, deployment tooling, or the hosting environment.

## Table of Contents

- [1. Overview Structure](#1-overview-structure)
- [2. The Two Joomla Applications](#2-the-two-joomla-applications)
- [3. Components](#3-components)
- [4. Modules](#4-modules)
- [5. Plugins](#5-plugins)
- [6. Templates and Overrides](#6-templates-and-overrides)
- [7. Libraries, Layouts, and Includes](#7-libraries-layouts-and-includes)
- [8. Media and Images](#8-media-and-images)
- [9. Language Files](#9-language-files)
- [10. Runtime Directories](#10-runtime-directories)
- [11. Configuration](#11-configuration)
- [12. Database Structure](#12-database-structure)
- [13. Extension Manifest XML](#13-extension-manifest-xml)
- [14. How a Feature Spans the Project](#14-how-a-feature-spans-the-project)
- [15. Joomla 3 Request Lifecycle](#15-joomla-3-request-lifecycle)
- [16. Core, Third-party, and Custom Code](#16-core-third-party-and-custom-code)
- [17. Upgrade Risk Areas](#17-upgrade-risk-areas)
- [18. Recommended Project Audit Order](#18-recommended-project-audit-order)
- [19. Project Understanding Checklist](#19-project-understanding-checklist)

## 1. Overview Structure

The following tree shows the standard Joomla 3 project structure. The comments explain the purpose of each location directly in the structure.

```text
joomla-project/
├── administrator/                    # Backend application available at /administrator
│   ├── cache/                        # Administrator-side runtime cache
│   ├── components/                   # Backend side of components, such as com_content
│   ├── help/                         # Backend help resources
│   ├── includes/                     # Backend bootstrap and helper files
│   ├── language/                     # Administrator translation files
│   ├── logs/                         # Legacy/default backend log location in some installs
│   ├── manifests/                    # Core package, library, and file-extension manifests
│   ├── modules/                      # Modules displayed in the administrator dashboard
│   ├── templates/                    # Administrator templates, such as Isis or Hathor
│   └── index.php                     # Backend entry point
│
├── bin/                              # Command-line executable files shipped with the project
├── cache/                            # Frontend runtime cache; not permanent source code
├── cli/                              # Joomla and custom command-line scripts or scheduled jobs
├── components/                       # Frontend side of components
│   └── com_example/                  # Example frontend component
│       ├── controllers/              # Receives tasks/actions from the request
│       ├── models/                   # Retrieves data and contains business logic
│       ├── views/                    # Prepares data for presentation
│       │   └── items/
│       │       ├── tmpl/             # PHP layout files that render HTML
│       │       └── view.html.php     # HTML view class
│       ├── helpers/                  # Shared component helper logic
│       ├── router.php                # Builds and parses SEF URLs
│       └── example.php               # Legacy component entry point
│
├── images/                           # User-managed content images and uploaded media
├── includes/                         # Core bootstrap files used to initialize Joomla
├── language/                         # Frontend translation files, grouped by language code
│   ├── en-GB/
│   └── vi-VN/
├── layouts/                          # Reusable Joomla layout fragments shared across extensions
├── libraries/                        # Joomla framework, CMS libraries, and Composer dependencies
│   ├── cms/                          # Legacy Joomla CMS library classes
│   ├── joomla/                       # Joomla Framework packages
│   ├── src/                          # Namespaced Joomla CMS classes in later Joomla 3 releases
│   └── vendor/                       # Composer-managed dependencies
│
├── logs/                             # Application logs; actual path can be configured elsewhere
├── media/                            # CSS, JavaScript, images, and assets owned by extensions
│   └── com_example/                  # Assets belonging to a specific component
├── modules/                          # Frontend module extension code
│   └── mod_example/
│       ├── tmpl/                     # Module display layouts
│       ├── helper.php                # Data retrieval and processing
│       ├── mod_example.php           # Module entry point
│       └── mod_example.xml           # Installation manifest and configuration fields
│
├── plugins/                          # Event-driven extensions, organized by plugin group
│   ├── system/                       # Request and application lifecycle plugins
│   ├── content/                      # Content preparation and transformation plugins
│   ├── authentication/               # Login authentication providers
│   ├── user/                         # User lifecycle handlers
│   ├── editors/                      # Content editor integrations
│   ├── editors-xtd/                  # Buttons displayed below editors
│   ├── captcha/                      # CAPTCHA providers
│   ├── finder/                       # Smart Search index integrations
│   └── search/                       # Legacy Search integrations
│
├── templates/                        # Frontend site templates
│   └── mytemplate/
│       ├── html/                     # Component/module/layout overrides
│       ├── css/                      # Template stylesheets
│       ├── js/                       # Template JavaScript
│       ├── images/                   # Template-owned images
│       ├── language/                 # Template translation files
│       ├── index.php                 # Main page skeleton and module positions
│       ├── component.php             # Component-only rendering layout
│       ├── error.php                 # Template error page
│       └── templateDetails.xml       # Template manifest, positions, files, and settings
│
├── tmp/                              # Temporary files used during upload, install, and update
├── configuration.php                # Runtime configuration; may contain credentials and secrets
├── htaccess.txt                      # Apache rewrite/security template; often copied to .htaccess
├── index.php                         # Frontend application entry point
├── robots.txt.dist                   # Default search-engine crawler rules template
└── web.config.txt                    # IIS rewrite configuration template
```

The structure should be read as four connected layers:

| Layer | Main locations | Responsibility |
|---|---|---|
| Joomla Core | `includes`, `libraries`, core extensions | CMS framework and standard behavior |
| Extensions | `components`, `modules`, `plugins` | Business features and event-driven behavior |
| Presentation | `templates`, `layouts`, `media`, `images` | Page composition, overrides, styles, scripts, and content media |
| Runtime and data | `configuration.php`, database, `cache`, `logs`, `tmp`, server config | Configuration, persisted state, operational behavior, and infrastructure |

A Joomla project is therefore not completely represented by its filesystem:

```text
Complete project understanding
= source code
+ database configuration and content
+ server/runtime configuration
+ external integrations
```

## 2. The Two Joomla Applications

### Site application

The public frontend starts at:

```text
/index.php
```

Its principal locations are:

```text
/components
/modules
/templates
/language
```

A typical page is resolved through:

```text
URL
→ index.php
→ menu item and Itemid context
→ frontend component
→ model, view, and layout
→ template or template override
→ assigned module instances
→ plugin events
→ HTML response
```

### Administrator application

The backend is normally available at `/administrator` and starts at:

```text
/administrator/index.php
```

Its component, module, template, and language code is stored under `/administrator`.

These paths usually represent two sides of one component:

```text
/components/com_content
/administrator/components/com_content
```

The first renders or handles frontend content. The second manages that content in the backend. They must not be counted as two independent components.

## 3. Components

A component is a major application-level feature. Joomla 3 components normally follow an MVC-style structure.

### Frontend component

```text
/components/com_example/
├── controller.php
├── controllers/
├── models/
├── views/
├── helpers/
├── router.php
└── example.php
```

### Administrator component

```text
/administrator/components/com_example/
├── controllers/
├── models/
├── views/
├── tables/
├── helpers/
├── sql/
├── config.xml
├── access.xml
└── example.php
```

| Part | Responsibility |
|---|---|
| Controller | Receives a task and selects the action |
| Model | Loads data and applies business rules |
| View | Prepares data for a response |
| `tmpl` | Produces HTML using PHP layouts |
| Table | Maps and stores database records |
| Helper | Shares reusable extension logic |
| Router | Builds and parses SEF routes |
| `config.xml` | Defines configurable component options |
| `access.xml` | Declares ACL actions |
| `sql` | Contains install, uninstall, and update scripts |

Example resolution:

```text
index.php?option=com_vehicle&view=vehicles
→ components/com_vehicle
→ vehicles model
→ vehicles view
→ views/vehicles/tmpl/default.php
```

## 4. Modules

Frontend and backend module code is stored separately:

```text
/modules/mod_example
/administrator/modules/mod_example
```

Typical structure:

```text
mod_example/
├── mod_example.php       # Entry point
├── helper.php            # Data retrieval and processing
├── tmpl/
│   └── default.php       # HTML output
├── language/             # Translation files
└── mod_example.xml       # Manifest and settings
```

A module extension is not the same as a module instance:

```text
Extension: mod_custom
└── Instances
    ├── Homepage Promotion
    ├── Footer Address
    ├── Contact Information
    └── Campaign Banner
```

Instances are primarily stored in `#__modules`, while their page assignments are stored in `#__modules_menu`. Each instance can have a different title, position, status, ordering, access level, language, schedule, parameters, and menu assignment.

For a feature report, inspect both the module extension source and every configured module instance.

## 5. Plugins

Plugins respond to Joomla events and are organized as:

```text
/plugins/<group>/<element>/
```

Example:

```text
plugins/system/example/
├── example.php
├── example.xml
└── language/
```

Its technical name is commonly represented as `plg_system_example`.

Important groups include `system`, `content`, `authentication`, `user`, `extension`, `editors`, `editors-xtd`, `captcha`, `finder`, and `search`.

A group name describes when or where the plugin participates. It does not prove that the plugin is Joomla Core. For example, a `system` plugin can be core, third-party, or custom.

Audit the plugin group, element, enabled status, ordering, parameters, events, and external dependencies. Ordering matters when multiple plugins handle the same event.

## 6. Templates and Overrides

Frontend templates are stored in `/templates`; administrator templates are stored in `/administrator/templates`.

A typical site template contains:

```text
templates/example/
├── index.php
├── templateDetails.xml
├── component.php
├── error.php
├── html/
├── css/
├── js/
├── images/
└── language/
```

A template extension may have several template styles. Their configuration is stored in `#__template_styles`.

Overrides replace the original output without editing the extension itself:

```text
Original:
components/com_content/views/article/tmpl/default.php

Override:
templates/mytemplate/html/com_content/article/default.php
```

Module overrides follow the same principle:

```text
templates/mytemplate/html/mod_menu/default.php
```

Overrides are high-risk upgrade areas because they may rely on Joomla 3 markup, methods, fields, JavaScript, or extension behavior that changed in later versions.

## 7. Libraries, Layouts, and Includes

- `/libraries` contains Joomla framework code, CMS libraries, and dependencies.
- `/layouts` contains smaller reusable presentation fragments.
- `/includes` contains bootstrap files that initialize Joomla.

These locations are mostly Core. Direct core modifications can be overwritten by updates and make migration analysis difficult. Compare them against a clean copy of the exact Joomla version when auditing.

## 8. Media and Images

`/images` normally contains content uploaded or managed by site users, such as article, product, banner, and campaign images.

`/media` normally contains extension-owned CSS, JavaScript, icons, and other assets:

```text
/media/com_example/css/
/media/com_example/js/
/media/mod_example/images/
```

During an audit, distinguish uploaded content from application assets and record ownership, references, unused files, and migration requirements.

## 9. Language Files

Frontend translations are usually under `/language/<locale>`; administrator translations are under `/administrator/language/<locale>`.

Common names:

```text
en-GB.com_example.ini
en-GB.com_example.sys.ini
```

The `.ini` file contains runtime translations. The `.sys.ini` file commonly contains extension names and descriptions shown by the Joomla extension system. Extensions may also package language files inside their own directories.

## 10. Runtime Directories

| Directory | Purpose |
|---|---|
| `cache` | Frontend cached data |
| `administrator/cache` | Backend cached data |
| `logs` | Error, debug, and application logs |
| `tmp` | Temporary upload, install, and update files |

These are not primary source-code locations. However, invalid paths or permissions can break extension installation, logging, caching, or Joomla updates. Actual paths may be overridden in `configuration.php`.

## 11. Configuration

`configuration.php` is the principal Joomla runtime configuration file. It commonly contains settings for:

- Database host, name, user, and prefix.
- SEF URLs and rewrite behavior.
- Cache and session handlers.
- Email transport.
- Cookies.
- Logging and temporary directories.
- Debug and error reporting.
- Offline mode.

It may contain credentials and secrets. Never copy real passwords, tokens, private paths, or API keys into an audit report or Git repository.

Server behavior can also depend on `.htaccess`, Nginx/IIS rules, PHP settings, environment variables, cron, SSL, CDN/WAF, filesystem permissions, and hosting configuration.

## 12. Database Structure

Many essential Joomla relationships are stored in the database rather than source files.

| Table | Purpose |
|---|---|
| `#__extensions` | Registered extensions |
| `#__content` | Articles |
| `#__categories` | Categories |
| `#__menu` | Menu items and routing context |
| `#__modules` | Module instances |
| `#__modules_menu` | Module-to-menu assignments |
| `#__template_styles` | Template style instances |
| `#__users` | Users |
| `#__usergroups` | User groups |
| `#__user_usergroup_map` | User-to-group relationships |
| `#__assets` | ACL asset hierarchy |
| `#__fields` | Custom Field definitions |
| `#__fields_values` | Custom Field values |
| `#__tags` | Tags |
| `#__update_sites` | Extension update sources |
| `#__redirect_links` | Redirect records |

`#__` is a placeholder. The real prefix is configured in `configuration.php`. Custom and third-party components may add their own tables, indexes, triggers, or external data sources.

## 13. Extension Manifest XML

An extension manifest describes the extension package and may declare:

- Type, name, version, author, and creation date.
- Installed files and folders.
- Language files.
- Configuration fields.
- Database install and update scripts.
- Update server.

Example:

```xml
<extension type="module" client="site" method="upgrade">
    <name>mod_example</name>
    <version>1.0.0</version>
    <author>Example Company</author>
    <files>
        <filename module="mod_example">mod_example.php</filename>
        <filename>helper.php</filename>
        <folder>tmpl</folder>
    </files>
</extension>
```

The manifest is important evidence when identifying extension ownership, version, installation footprint, and update capability.

## 14. How a Feature Spans the Project

A business feature rarely belongs to one folder.

```text
Vehicle Search
├── Menu item                 # Creates URL and page context
├── com_vehicle               # Main controller/model/view behavior
├── mod_vehicle_filter        # Search/filter UI in a module position
├── plg_system_vehicle        # Request-wide behavior
├── plg_finder_vehicle        # Smart Search integration
├── Template overrides        # Project-specific output
├── CSS/JavaScript/images     # Feature assets
├── Custom database tables    # Persisted vehicle data
└── Vehicle API               # External source or synchronization
```

Recommended feature mapping:

| Feature | URL | Menu item | Component | Modules | Plugins | Override | Data source |
|---|---|---|---|---|---|---|---|
| Vehicle Search | `/cars` | Cars | `com_vehicle` | `mod_vehicle_filter` | `plg_finder_vehicle` | Yes | Custom tables/API |

This mapping is more useful for revamp and upgrade work than a folder inventory alone.

## 15. Joomla 3 Request Lifecycle

A simplified frontend lifecycle is:

```text
Browser
→ web server
→ index.php
→ Joomla bootstrap
→ system plugin events
→ routing and menu/Itemid context
→ component controller
→ model
→ view and layout
→ template override resolution
→ module rendering
→ content and system plugin events
→ template
→ HTML response
```

Plugins can participate after initialization, routing, dispatch, content preparation, rendering, and response generation. If behavior cannot be found in the component or template, inspect enabled `system` and `content` plugins and their ordering.

## 16. Core, Third-party, and Custom Code

Location alone does not identify ownership:

```text
Core:        components/com_content
Third-party: components/com_akeeba
Custom:      components/com_vehicle
```

Use multiple forms of evidence:

| Evidence | Core | Third-party | Custom |
|---|---|---|---|
| Author | Joomla Project | Product vendor | Internal developer/company |
| Present in clean Joomla | Yes | No | No |
| Update site | Joomla | Vendor | Internal or absent |
| Source repository | Joomla CMS | Vendor | Project/internal repository |
| Documentation | Joomla Docs | Vendor docs | Internal docs |
| Git history | Joomla source | Installed package | Internal development |

Verification process:

1. Export `Extensions → Manage → Manage`.
2. Record type, element, version, author, enabled state, and client.
3. Inspect the manifest XML.
4. Compare with a clean copy of the exact Joomla version.
5. Inspect Update Sites.
6. Review Git history.
7. Find vendor or internal documentation.
8. Mark uncertain items as `Unknown – Need verification`.

## 17. Upgrade Risk Areas

### Very high risk

- Direct modifications to Joomla Core.
- Custom components and system plugins.
- Template overrides.
- Abandoned extensions.
- Old Joomla or PHP APIs.
- Hard-coded database queries.
- Custom authentication, SSO, payment, or API integrations.

### Medium risk

- Custom modules and content plugins.
- Third-party templates.
- CLI and cron scripts.
- Custom Fields integrations.
- JavaScript depending on obsolete libraries.

### Lower risk

- Standard articles.
- Language files.
- Static images.
- Module instance configuration.

Lower risk means lower inspection priority, not that the item can be ignored.

## 18. Recommended Project Audit Order

1. Identify the exact Joomla, PHP, and database versions.
2. Review `configuration.php` without copying secrets.
3. Identify active frontend and administrator templates.
4. Export every registered extension.
5. Classify each extension as Core, Third-party, Custom, or Unknown.
6. Inspect menus, aliases, hidden menus, routing, and `Itemid`.
7. Map every important URL to its component and view.
8. Inspect module instances and menu assignments.
9. Inspect enabled plugins, events, ordering, and parameters.
10. Inventory template overrides and custom assets.
11. Find custom database tables and their owning feature.
12. Identify APIs, email, payment, SSO, imports, exports, webhooks, and cron jobs.
13. Compare the codebase with a clean Joomla package to detect core modifications.
14. Convert the findings into a URL-to-feature dependency report.
15. Assess compatibility with the target Joomla, PHP, database, and extension versions.

## 19. Project Understanding Checklist

- [ ] Exact Joomla, PHP, database, and web-server versions are known.
- [ ] Every important URL is mapped to a menu item, component, view, and `Itemid`.
- [ ] Every extension is classified as Core, Third-party, Custom, or Unknown.
- [ ] Frontend and backend halves of a component are counted correctly.
- [ ] Active and unused extensions are distinguished.
- [ ] Module instances, positions, and menu assignments are documented.
- [ ] Enabled plugins, ordering, events, and side effects are documented.
- [ ] Active templates, styles, positions, and overrides are documented.
- [ ] Content storage is identified: article, module, component, hard-code, database, or API.
- [ ] Custom database tables are mapped to their owning features.
- [ ] ACL, users, groups, and viewing access levels are understood.
- [ ] External integrations, cron jobs, email, cache, logs, and backups are known.
- [ ] Direct Joomla Core modifications have been checked.
- [ ] Secrets have been excluded from documentation.
- [ ] Every feature has an upgrade compatibility and risk assessment.

## Conclusion

To understand a Joomla 3 project, trace each important page with this formula:

```text
URL
→ menu item and Itemid
→ component
→ controller/model/view/layout
→ template override
→ module instances
→ plugins
→ database or external API
```

When this chain is documented for the important URLs and business features, the project structure is understood well enough to support a reliable feature report, revamp plan, and upgrade assessment.
