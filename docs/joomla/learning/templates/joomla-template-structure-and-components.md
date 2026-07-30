# Joomla Template Structure and Components

## Table of Contents

- [1. Overview](#1-overview)
- [2. Template Responsibilities](#2-template-responsibilities)
- [3. Main Template Building Blocks](#3-main-template-building-blocks)
- [4. Recommended Directory Structure](#4-recommended-directory-structure)
- [5. Component and Module Overrides](#5-component-and-module-overrides)
- [6. Article and Product Presentation](#6-article-and-product-presentation)
- [7. Template Inventory](#7-template-inventory)
- [8. Joomla 3 to Joomla 6 Migration](#8-joomla-3-to-joomla-6-migration)
- [9. Recommended Migration Tickets](#9-recommended-migration-tickets)
- [10. Definition of Done](#10-definition-of-done)
- [11. Summary](#11-summary)

---

## 1. Overview

A Joomla template controls the presentation layer of a website. It defines page structure, module positions, output overrides, reusable layouts, assets, and visual configuration.

A template should contain presentation logic only. Business data and business rules belong to components, modules, plugins, libraries, or third-party extensions.

Examples:

- Articles are managed by `com_content`.
- Users are managed by `com_users`.
- Contacts are managed by `com_contact`.
- Products are normally managed by HikaShop, VirtueMart, J2Store, or a custom component.
- The template controls how the resulting data is displayed.

A Joomla template has no fixed number of components. For migration and reporting, inventory logical presentation items instead of counting every physical file.

---

## 2. Template Responsibilities

A template is responsible for:

- Global page structure
- Header, navigation, sidebars, and footer
- Module positions
- Component and module output overrides
- Reusable layouts and partials
- CSS, JavaScript, images, icons, and fonts
- Template parameters and branding
- Error, offline, print, and component-only pages

A template should not contain:

- Product pricing calculations
- Inventory management
- Payment processing
- Order processing
- User authorization rules
- Direct business-data updates
- Extension-specific business logic

When these responsibilities are mixed into a template, migration risk and maintenance cost increase significantly.

---

## 3. Main Template Building Blocks

| Group | Purpose |
|---|---|
| Template core files | Install, configure, and render the template |
| Global page layout | Define header, navigation, content, sidebars, and footer |
| Module positions | Provide named locations where modules can render |
| Component overrides | Customize component output |
| Module overrides | Customize module output |
| Alternative layouts | Provide selectable display variations |
| Reusable UI components | Provide cards, sliders, forms, tabs, and shared blocks |
| Assets | Store CSS, JavaScript, images, icons, and fonts |
| Template configuration | Configure logo, colors, layout, and template parameters |
| Special pages | Render error, offline, print, and component-only views |

### 3.1 Core files

Common template files include:

```text
templateDetails.xml
index.php
component.php
error.php
offline.php
```

Modern Joomla templates may also register assets through:

```text
media/templates/site/<template-name>/joomla.asset.json
```

### 3.2 Global layout

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

### 3.3 Module positions

Common position names include:

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

A module position should be considered in use only when an enabled module, page, or application flow depends on it.

---

## 4. Recommended Directory Structure

A modern Joomla site template may use the following structure:

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

The exact structure depends on the template architecture and installed extensions.

### 4.1 Directory purpose

| Path | Purpose |
|---|---|
| `html/` | Component and module overrides |
| `layouts/` | Reusable Joomla layout files |
| `partials/` | Project-specific reusable page fragments |
| `language/` | Template language files |
| `media/templates/site/.../css/` | Compiled or maintained CSS assets |
| `media/templates/site/.../js/` | JavaScript assets |
| `joomla.asset.json` | Web Asset Manager asset definitions |

---

## 5. Component and Module Overrides

### 5.1 Component overrides

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

> Do not copy Joomla 3 overrides directly into Joomla 6. Rebuild them by comparing the required Joomla 3 appearance and behavior with the Joomla 6 component layouts, data, routing, and APIs.

### 5.2 Module overrides

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

### 5.3 Alternative layouts

Alternative layouts provide selectable display variations, for example:

```text
html/com_content/article/news.php
html/com_content/article/promotion.php
html/mod_articles_category/carousel.php
html/mod_articles_category/grid.php
```

Document every alternative layout because it may be selected by a menu item, module, category, article, field, or extension configuration.

### 5.4 Override review checklist

- [ ] Identify the original Core or extension layout.
- [ ] Confirm whether the override is currently used.
- [ ] Record menu, module, category, and template-style assignments.
- [ ] Compare Joomla 3 and Joomla 6 layout inputs.
- [ ] Remove copied business logic and direct database queries.
- [ ] Verify output escaping and form security.
- [ ] Test empty, error, guest, and authenticated states.

---

## 6. Article and Product Presentation

### 6.1 Article presentation

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

### 6.2 Product presentation

Products normally belong to a third-party or custom component. The template may contain presentation layouts for:

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

The template must not duplicate pricing, stock, payment, checkout, or order-processing logic.

### 6.3 Third-party extension rule

Before migrating a third-party override:

1. Confirm that the extension supports Joomla 6.
2. Install the target extension version.
3. Compare its Joomla 6 layouts with the Joomla 3 layouts.
4. Rebuild only the required presentation changes.
5. Test the complete user flow, not only the individual page.

---

## 7. Template Inventory

Use one row for each logical template item.

| ID | Group | Item | Source | Path | Used | Risk | Action |
|---|---|---|---|---|---|---|---|
| TMP-001 | Global | Header | Custom template | `partials/header.php` | Yes | Medium | Rebuild |
| TMP-002 | Navigation | Main menu | `mod_menu` | `html/mod_menu/` | Yes | High | Rewrite |
| TMP-003 | Article | Article detail | `com_content` | `html/com_content/article/` | Yes | High | Rewrite |
| TMP-004 | Product | Product detail | HikaShop | `html/com_hikashop/` | Yes | High | Review extension version |
| TMP-005 | Assets | Main JavaScript | Custom | `media/js/template.js` | Yes | Medium | Refactor |

Recommended action values:

```text
Keep
Review
Refactor
Rewrite
Replace
Remove
Confirm with vendor
```

### 7.1 Recommended inventory fields

| Field | Meaning |
|---|---|
| ID | Stable migration identifier |
| Group | Logical presentation area |
| Item | Feature or layout name |
| Source | Joomla Core, custom code, or third-party extension |
| Path | Current source location |
| Used | Confirmed runtime usage |
| Risk | Migration complexity or business impact |
| Action | Required migration decision |
| Evidence | URL, screenshot, assignment, or code reference |
| Owner | Responsible developer or team |

---

## 8. Joomla 3 to Joomla 6 Migration

For a direct Joomla 3 to Joomla 6 rebuild, create a clean Joomla 6 project and migrate the presentation layer one verified item at a time. This is not an in-place copy of the Joomla 3 template.

Recommended migration model:

```text
Joomla 3 layout
    ↓ analyze
Required data, appearance, and behavior
    ↓ rebuild
Joomla 6 layout
```

Only independent assets, such as validated images or reusable CSS tokens, may sometimes be copied directly. Core layouts, overrides, forms, menus, and commerce flows should be rebuilt and retested.

### 8.1 Main migration risk groups

| Risk group | Typical problems |
|---|---|
| Template foundation | Invalid manifest, missing files, incorrect asset paths, blank frontend |
| Global layout | Missing component output, broken header or footer, incorrect body classes |
| Module positions | Missing positions, obsolete names, incorrect menu assignments |
| Component overrides | Removed variables, outdated helpers, broken routing or forms |
| Module overrides | Broken menu hierarchy, active states, breadcrumbs, login, or language switcher |
| PHP compatibility | Legacy Joomla classes, missing namespaces, deprecated APIs, hard-coded paths |
| CSS compatibility | Bootstrap 2 or 3 classes, broken grid, forms, responsive layout, and icons |
| JavaScript compatibility | Old jQuery plugins, duplicate libraries, broken sliders, modals, AJAX, or menus |
| Third-party extensions | Unsupported Joomla version, changed layouts, fields, or business flows |
| Quality and security | PHP warnings, console errors, unescaped output, missing CSRF protection |

### 8.2 Migration principles

- Rebuild against Joomla 6 APIs and layouts.
- Preserve required business behavior, not obsolete implementation details.
- Keep business logic outside the template.
- Use Joomla's Web Asset Manager for managed assets.
- Avoid hard-coded Joomla installation paths.
- Verify responsive behavior and accessibility.
- Test against the actual extension versions selected for Joomla 6.

---

## 9. Recommended Migration Tickets

### Phase 1: Discovery

| ID | Ticket | Priority |
|---|---|---|
| THEME-001 | Inventory old template files | P0 |
| THEME-002 | Inventory component and module overrides | P0 |
| THEME-003 | Identify used module positions and menu assignments | P0 |

### Phase 2: Joomla 6 foundation

| ID | Ticket | Priority |
|---|---|---|
| THEME-004 | Create the Joomla 6 template skeleton | P0 |
| THEME-005 | Create `templateDetails.xml` and the asset registry | P0 |
| THEME-006 | Rebuild the main document and global page layout | P0 |

### Phase 3: Global interface

| ID | Ticket | Priority |
|---|---|---|
| THEME-007 | Migrate header and desktop/mobile navigation | P1 |
| THEME-008 | Migrate footer, breadcrumb, and page title | P1 |
| THEME-009 | Map module positions and update assignments | P1 |
| THEME-010 | Migrate sidebars and module chrome | P1 |

### Phase 4: Joomla content

| ID | Ticket | Priority |
|---|---|---|
| THEME-011 | Migrate article detail layout | P1 |
| THEME-012 | Migrate category blog, category list, and featured layouts | P1 |
| THEME-013 | Migrate article custom fields and reusable cards | P1 |
| THEME-014 | Migrate article, search, login, and language module overrides | P1 |

### Phase 5: Products and third-party extensions

| ID | Ticket | Priority |
|---|---|---|
| THEME-015 | Confirm Joomla 6 compatibility for each third-party extension | P0 |
| THEME-016 | Migrate product listing and product detail layouts | P1 |
| THEME-017 | Migrate mini cart, cart, and checkout layouts | P1 |
| THEME-018 | Migrate each remaining third-party override separately | P1 |

### Phase 6: Technical modernization

| ID | Ticket | Priority |
|---|---|---|
| THEME-019 | Replace Joomla 3 PHP APIs and hard-coded paths | P0 |
| THEME-020 | Migrate CSS, Bootstrap markup, fonts, and responsive behavior | P1 |
| THEME-021 | Migrate JavaScript, Web Asset Manager dependencies, and AJAX interactions | P1 |
| THEME-022 | Move database queries and business logic out of the template | P0 |

### Phase 7: Testing and release

| ID | Ticket | Priority |
|---|---|---|
| THEME-023 | Fix PHP runtime errors and browser console errors | P0 |
| THEME-024 | Run desktop, tablet, and mobile visual regression tests | P1 |
| THEME-025 | Test articles, search, login, products, cart, and checkout | P0 |
| THEME-026 | Review accessibility, SEO, escaping, forms, and CSRF protection | P0 |
| THEME-027 | Validate error, offline, print, and component-only pages | P1 |

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

## 10. Definition of Done

A migration ticket is complete only when:

- [ ] The feature renders correctly on Joomla 6.
- [ ] No Joomla 3 API remains in the migrated scope.
- [ ] No PHP warning or fatal error is produced.
- [ ] No browser console error is produced.
- [ ] Desktop, tablet, and mobile layouts work.
- [ ] Empty and error states are handled.
- [ ] Guest and logged-in states are tested when relevant.
- [ ] Output escaping and form security are verified.
- [ ] Required screenshots or test evidence are attached.
- [ ] The migrated item is mapped back to its inventory record.

---

## 11. Summary

A Joomla template should be inventoried by logical presentation items. For a direct Joomla 3 to Joomla 6 migration, create a clean Joomla 6 template and rebuild each layout, override, asset group, and user flow separately.

Do not blindly copy Joomla 3 Core layouts or third-party extension overrides into Joomla 6. Preserve verified requirements, use Joomla 6 APIs and asset management, and test every migrated feature in its complete runtime flow.
