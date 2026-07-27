# Joomla Template Structure and Components

## Table of Contents

- [1. Overview](#1-overview)
- [2. Main Template Components](#2-main-template-components)
- [3. Recommended Directory Structure](#3-recommended-directory-structure)
- [4. Component and Module Overrides](#4-component-and-module-overrides)
- [5. Article and Product Presentation](#5-article-and-product-presentation)
- [6. Template Inventory](#6-template-inventory)
- [7. Direct Joomla 3 to Joomla 6 Theme Migration](#7-direct-joomla-3-to-joomla-6-theme-migration)
- [8. Recommended Migration Tickets](#8-recommended-migration-tickets)
- [9. Definition of Done](#9-definition-of-done)

---

## 1. Overview

A Joomla template controls the website presentation layer, including page structure, module positions, overrides, assets, reusable layouts, and template configuration.

The template should contain presentation logic only. Business data and business rules belong to Joomla components, modules, plugins, or third-party extensions.

Examples:

- Articles are managed by `com_content`.
- Users are managed by `com_users`.
- Contacts are managed by `com_contact`.
- Products are usually managed by HikaShop, VirtueMart, J2Store, or a custom component.
- The template controls how this data is displayed.

A Joomla template has no fixed number of components. For migration and reporting, count logical items instead of every physical file.

---

## 2. Main Template Components

A custom Joomla template can be divided into ten main groups:

| Group | Purpose |
|---|---|
| Template core files | Install, configure, and render the template |
| Global page layout | Header, navigation, content area, sidebars, and footer |
| Module positions | Named areas where modules are displayed |
| Component overrides | Customized component output |
| Module overrides | Customized module output |
| Alternative layouts | Additional selectable layouts |
| Reusable UI components | Cards, sliders, forms, tabs, and shared blocks |
| Assets | CSS, JavaScript, images, icons, and fonts |
| Template configuration | Logo, colors, layout settings, and parameters |
| Special pages | Error, offline, print, and component-only pages |

### Core files

Common files include:

```text
templateDetails.xml
index.php
component.php
error.php
offline.php
```

Modern templates may also use:

```text
media/templates/site/<template-name>/joomla.asset.json
```

### Global layout

Typical global elements include:

- Header and logo
- Desktop and mobile navigation
- Search
- Language switcher
- Breadcrumb
- Main component output
- Left and right sidebars
- Footer
- Global modal or cookie notice

### Module positions

Common positions include:

```text
topbar
header
menu
search
banner
breadcrumb
sidebar-left
sidebar-right
content-top
content-bottom
footer
debug
```

A position is considered used only when a module or page depends on it.

---

## 3. Recommended Directory Structure

```text
templates/custom_template/
├── templateDetails.xml
├── index.php
├── component.php
├── error.php
├── offline.php
├── html/
│   ├── com_content/
│   ├── com_contact/
│   ├── com_users/
│   ├── com_finder/
│   ├── com_hikashop/
│   ├── mod_menu/
│   ├── mod_breadcrumbs/
│   ├── mod_articles_category/
│   └── mod_custom/
├── layouts/
├── partials/
└── language/

media/templates/site/custom_template/
├── css/
├── js/
├── images/
├── icons/
├── fonts/
└── joomla.asset.json
```

The exact structure depends on the template and installed extensions.

---

## 4. Component and Module Overrides

### Component overrides

Component overrides are stored under:

```text
templates/<template-name>/html/com_*/
```

Common examples:

```text
com_content
com_contact
com_users
com_finder
com_hikashop
com_virtuemart
```

Important rule:

> Do not copy Joomla 3 overrides directly into Joomla 6. Rebuild them by comparing the required Joomla 3 presentation with the Joomla 6 component layout and data structure.

### Module overrides

Module overrides are stored under:

```text
templates/<template-name>/html/mod_*/
```

Common examples:

```text
mod_menu
mod_breadcrumbs
mod_custom
mod_articles_category
mod_articles_latest
mod_login
mod_finder
mod_languages
```

### Alternative layouts

Alternative layouts provide selectable display variations, for example:

```text
html/com_content/article/news.php
html/com_content/article/promotion.php
html/mod_articles_category/carousel.php
html/mod_articles_category/grid.php
```

Document each alternative layout because it may be selected by a menu item, module, category, or article.

---

## 5. Article and Product Presentation

### Article presentation

Typical article layouts include:

- Article listing
- Article detail
- Category blog
- Category list
- Featured articles
- Article card
- Related articles
- Custom fields
- Tags and metadata

Common paths:

```text
html/com_content/article/
html/com_content/category/
html/com_content/featured/
html/mod_articles_category/
```

### Product presentation

Products normally belong to a third-party or custom component. The template may contain layouts for:

- Product listing
- Product detail
- Product card
- Product filters
- Product gallery
- Mini cart
- Cart
- Checkout
- Customer account
- Order history

The template must not duplicate pricing, stock, payment, checkout, or order business logic.

---

## 6. Template Inventory

Use one row for each logical template item.

| ID | Group | Item | Source | Path | Used | Risk | Action |
|---|---|---|---|---|---|---|---|
| TMP-001 | Global | Header | Custom template | `partials/header.php` | Yes | Medium | Rebuild |
| TMP-002 | Navigation | Main menu | `mod_menu` | `html/mod_menu/` | Yes | High | Rewrite |
| TMP-003 | Article | Article detail | `com_content` | `html/com_content/article/` | Yes | High | Rewrite |
| TMP-004 | Product | Product detail | HikaShop | `html/com_hikashop/` | Yes | High | Review extension version |
| TMP-005 | Assets | Main JavaScript | Custom | `media/js/template.js` | Yes | Medium | Refactor |

Recommended actions:

```text
Keep
Review
Refactor
Rewrite
Replace
Remove
Confirm with vendor
```

---

## 7. Direct Joomla 3 to Joomla 6 Theme Migration

This approach creates a new Joomla 6 project and moves the theme presentation one part at a time. It is not an in-place Joomla upgrade.

Recommended migration rule:

```text
Joomla 3 layout
    ↓ analyze
Required data, appearance, and behavior
    ↓ rebuild
Joomla 6 layout
```

Only simple assets such as images or independent CSS may be copied directly. Core layouts, overrides, forms, menus, and commerce flows should be rebuilt.

### Main error groups

| Error group | Typical problems |
|---|---|
| Template foundation | Invalid manifest, missing files, incorrect asset paths, blank frontend |
| Global layout | Missing component output, broken header/footer, incorrect body classes |
| Module positions | Missing positions, outdated position names, incorrect menu assignments |
| Component overrides | Removed variables, outdated helpers, incorrect routing, broken forms |
| Module overrides | Broken menu hierarchy, active states, breadcrumbs, login, or language switcher |
| PHP compatibility | Legacy Joomla classes, missing namespaces, deprecated methods, hard-coded paths |
| CSS compatibility | Bootstrap 2/3 classes, broken grid, forms, responsive layout, and icons |
| JavaScript compatibility | Old jQuery plugins, duplicate libraries, broken sliders, menus, modals, or AJAX |
| Third-party extensions | Unsupported Joomla 6 version, changed views, layouts, fields, or commerce flow |
| Quality and security | PHP warnings, console errors, unescaped output, missing CSRF protection |

---

## 8. Recommended Migration Tickets

### Initial inventory tickets

| ID | Ticket | Priority |
|---|---|---|
| THEME-001 | Inventory old template files | P0 |
| THEME-002 | Inventory component and module overrides | P0 |

### Phase 1: Discovery

| Ticket | Scope |
|---|---|
| THEME-003 | Identify used module positions and menu assignments |

### Phase 2: Joomla 6 foundation

| Ticket | Scope |
|---|---|
| THEME-004 | Create Joomla 6 template skeleton |
| THEME-005 | Create `templateDetails.xml` and asset registry |
| THEME-006 | Rebuild the main document and global page layout |

### Phase 3: Global interface

| Ticket | Scope |
|---|---|
| THEME-007 | Migrate header and desktop/mobile navigation |
| THEME-008 | Migrate footer, breadcrumb, and page title |
| THEME-009 | Map module positions and update assignments |
| THEME-010 | Migrate sidebars and module chrome |

### Phase 4: Joomla content

| Ticket | Scope |
|---|---|
| THEME-011 | Migrate article detail layout |
| THEME-012 | Migrate category blog, category list, and featured layouts |
| THEME-013 | Migrate article custom fields and reusable cards |
| THEME-014 | Migrate article, search, login, and language module overrides |

### Phase 5: Products and third-party extensions

| Ticket | Scope |
|---|---|
| THEME-015 | Confirm Joomla 6 compatibility for each third-party extension |
| THEME-016 | Migrate product listing and product detail layouts |
| THEME-017 | Migrate mini cart, cart, and checkout layouts |
| THEME-018 | Migrate each remaining third-party override as a separate ticket |

### Phase 6: Technical modernization

| Ticket | Scope |
|---|---|
| THEME-019 | Replace Joomla 3 PHP APIs and hard-coded paths |
| THEME-020 | Migrate CSS, Bootstrap markup, fonts, and responsive behavior |
| THEME-021 | Migrate JavaScript, Web Asset Manager dependencies, and AJAX interactions |
| THEME-022 | Move database queries and business logic out of the template |

### Phase 7: Testing and release

| Ticket | Scope |
|---|---|
| THEME-023 | Fix PHP runtime errors and browser console errors |
| THEME-024 | Run desktop, tablet, and mobile visual regression tests |
| THEME-025 | Test articles, search, login, products, cart, and checkout |
| THEME-026 | Review accessibility, SEO, escaping, forms, and CSRF protection |
| THEME-027 | Validate error, offline, print, and component-only pages |

### Recommended execution order

```text
Inventory
→ Joomla 6 template skeleton
→ Global layout
→ Module positions
→ Article layouts
→ Module overrides
→ Third-party and product layouts
→ PHP, CSS, and JavaScript modernization
→ Regression testing
```

---

## 9. Definition of Done

A migration ticket is complete only when:

- The feature renders correctly on Joomla 6.
- No Joomla 3 API remains in the migrated scope.
- No PHP warning or fatal error is produced.
- No browser console error is produced.
- Desktop and mobile layouts work.
- Empty and error states are handled.
- Guest and logged-in states are tested when relevant.
- Output escaping and form security are verified.
- Required screenshots or test evidence are attached.

---

## Summary

A Joomla template should be inventoried by logical presentation items. For a direct Joomla 3 to Joomla 6 migration, create a clean Joomla 6 template and rebuild each layout, override, asset group, and page flow separately. Do not blindly copy Joomla 3 core or extension overrides into Joomla 6.
