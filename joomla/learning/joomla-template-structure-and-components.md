# Joomla Template Structure and Components

## Table of Contents

- [1. Overview](#1-overview)
- [2. How Many Components Does a Joomla Template Have?](#2-how-many-components-does-a-joomla-template-have)
- [3. Recommended Template Classification](#3-recommended-template-classification)
- [4. Template Core Files](#4-template-core-files)
- [5. Global Page Layout](#5-global-page-layout)
- [6. Module Positions](#6-module-positions)
- [7. Component Overrides](#7-component-overrides)
  - [7.1 Content and Article Overrides](#71-content-and-article-overrides)
  - [7.2 Contact Overrides](#72-contact-overrides)
  - [7.3 User Overrides](#73-user-overrides)
  - [7.4 Search Overrides](#74-search-overrides)
  - [7.5 Product and Third-Party Overrides](#75-product-and-third-party-overrides)
- [8. Module Overrides](#8-module-overrides)
- [9. Alternative Layouts](#9-alternative-layouts)
- [10. Reusable UI Components](#10-reusable-ui-components)
- [11. Content Types](#11-content-types)
- [12. Article Presentation](#12-article-presentation)
- [13. Product Presentation](#13-product-presentation)
- [14. Assets](#14-assets)
- [15. Template Configuration](#15-template-configuration)
- [16. Special Pages](#16-special-pages)
- [17. Example Joomla Template Directory](#17-example-joomla-template-directory)
- [18. Estimated Number of Template Items](#18-estimated-number-of-template-items)
- [19. Recommended Inventory for Migration](#19-recommended-inventory-for-migration)
- [20. Migration Notes for Joomla 3 to Joomla 6](#20-migration-notes-for-joomla-3-to-joomla-6)
- [21. Final Checklist](#21-final-checklist)

---

## 1. Overview

A Joomla template controls the presentation layer of a website. It defines the page structure, module positions, frontend assets, component output overrides, module output overrides, reusable layouts, and template configuration.

A template should primarily control how data is displayed. The business data itself normally belongs to Joomla core components, custom components, or third-party extensions.

For example:

- Articles are managed by `com_content`.
- Contacts are managed by `com_contact`.
- Users are managed by `com_users`.
- Products may be managed by HikaShop, VirtueMart, J2Store, or a custom component.
- The template controls how these items are rendered to the user.

---

## 2. How Many Components Does a Joomla Template Have?

A Joomla template does not have a fixed number of components.

The final number depends on:

- Website size
- Number of pages
- Number of installed extensions
- Number of template overrides
- Number of module positions
- Number of reusable UI elements
- Number of alternative layouts
- Number of template settings
- Amount of custom CSS and JavaScript

For documentation and migration work, a Joomla template can be divided into the following ten main groups:

1. Template core files
2. Global page layout
3. Module positions
4. Component overrides
5. Module overrides
6. Alternative layouts
7. Reusable UI components
8. Assets
9. Template configuration
10. Error, offline, and special pages

A medium custom template may contain approximately 50 to 150 logical files, layouts, configuration items, or UI elements. This is an estimate, not a Joomla limit.

---

## 3. Recommended Template Classification

```text
Joomla Custom Template
├── 1. Template Core Files
├── 2. Global Page Layout
├── 3. Module Positions
├── 4. Component Overrides
├── 5. Module Overrides
├── 6. Alternative Layouts
├── 7. Reusable UI Components
├── 8. Assets
├── 9. Template Configuration
└── 10. Error, Offline, and Special Pages
```

For a feature-oriented report, the same template may also be viewed as:

```text
Custom Template
├── Global Components
├── Content Types
├── Articles
├── Products
├── Module Overrides
├── Shared UI Components
├── Assets
├── Configuration
└── Special Pages
```

The first structure is better for technical inventory. The second structure is better for business and feature reports.

---

## 4. Template Core Files

Template core files allow Joomla to discover, install, configure, and render the template.

Common files include:

| File | Purpose |
|---|---|
| `templateDetails.xml` | Defines template metadata, files, module positions, languages, and parameters |
| `index.php` | Main page layout and document rendering entry point |
| `component.php` | Component-only layout without the complete site chrome |
| `error.php` | Custom error page |
| `offline.php` | Maintenance or offline page |
| `favicon.ico` | Website icon |
| `template_preview.png` | Large preview image shown in the administrator |
| `template_thumbnail.png` | Template thumbnail shown in the administrator |
| `joomla.asset.json` | Defines frontend assets in newer Joomla implementations when used |

Example:

```text
templates/custom_template/
├── templateDetails.xml
├── index.php
├── component.php
├── error.php
├── offline.php
├── joomla.asset.json
├── template_preview.png
└── template_thumbnail.png
```

A typical template has approximately five to nine core files.

---

## 5. Global Page Layout

The global page layout is the shared website frame used around the main component output.

Common global components include:

- Top bar
- Header
- Logo
- Desktop navigation
- Mobile navigation
- Search control or search overlay
- Language switcher
- User account shortcut
- Shopping cart shortcut
- Hero or banner area
- Breadcrumb
- Main content area
- Left sidebar
- Right sidebar
- Footer
- Cookie banner
- Global modal
- Back-to-top button
- Loading indicator

Example hierarchy:

```text
Global Page Layout
├── Top Bar
├── Header
│   ├── Logo
│   ├── Main Navigation
│   ├── Search
│   ├── Language Switcher
│   ├── User Account
│   └── Cart
├── Hero or Banner
├── Breadcrumb
├── Main Content
│   ├── Left Sidebar
│   ├── Component Output
│   └── Right Sidebar
└── Footer
```

A medium website commonly has eight to twenty global layout elements.

---

## 6. Module Positions

A module position is a named area where Joomla modules can be assigned and rendered.

Positions are normally declared in `templateDetails.xml`:

```xml
<positions>
    <position>topbar</position>
    <position>header</position>
    <position>menu</position>
    <position>search</position>
    <position>banner</position>
    <position>breadcrumb</position>
    <position>sidebar-left</position>
    <position>sidebar-right</position>
    <position>content-top</position>
    <position>content-bottom</position>
    <position>footer</position>
    <position>debug</position>
</positions>
```

Common positions:

| Position | Typical purpose |
|---|---|
| `topbar` | Contact information, announcement, language selector |
| `header` | Header content |
| `menu` | Main navigation |
| `search` | Search module |
| `banner` | Hero or promotional banner |
| `breadcrumb` | Breadcrumb navigation |
| `sidebar-left` | Left-side modules |
| `sidebar-right` | Right-side modules |
| `content-top` | Modules before component output |
| `content-bottom` | Modules after component output |
| `footer` | Footer modules |
| `debug` | Debug information |

Typical ranges:

- Simple template: 5 to 10 positions
- Medium template: 10 to 20 positions
- Large template: 20 to 40 or more positions

A position should be counted as used only when at least one page or module assignment depends on it.

---

## 7. Component Overrides

A component override replaces or customizes the HTML output generated by a Joomla component without modifying the component source code.

Overrides are usually stored under:

```text
templates/custom_template/html/
```

Example:

```text
html/
├── com_content/
├── com_contact/
├── com_users/
├── com_finder/
├── com_tags/
├── com_hikashop/
└── com_virtuemart/
```

Component overrides are important migration items because an override created for Joomla 3 may use old markup, removed helper methods, deprecated APIs, or outdated Bootstrap conventions.

### 7.1 Content and Article Overrides

Joomla articles are primarily rendered by `com_content`.

Common override folders:

```text
html/com_content/
├── article/
├── category/
├── categories/
├── featured/
├── archive/
└── form/
```

Common layouts:

| Layout | Purpose |
|---|---|
| Article detail | Displays a complete article |
| Category blog | Displays article cards in blog format |
| Category list | Displays articles in a list or table |
| Featured articles | Displays featured content |
| Archived articles | Displays archived content |
| Article form | Creates or edits an article from the frontend |

Article detail may contain:

- Breadcrumb
- Title
- Category
- Author
- Published date
- Modified date
- Intro image
- Full image
- Full content
- Custom fields
- Tags
- Social sharing
- Previous and next navigation
- Related articles
- Call-to-action block

### 7.2 Contact Overrides

Contact pages are normally rendered by `com_contact`.

```text
html/com_contact/
├── contact/
├── category/
├── categories/
└── featured/
```

Possible presentation items:

- Contact information
- Contact image
- Address
- Telephone number
- Email form
- Map
- Contact category
- Featured contacts

### 7.3 User Overrides

User pages are normally rendered by `com_users`.

```text
html/com_users/
├── login/
├── profile/
├── registration/
├── reset/
└── remind/
```

Possible screens:

- Login
- Logout
- Registration
- User profile
- Edit profile
- Forgot username
- Reset password

### 7.4 Search Overrides

Modern Joomla search normally uses Smart Search through `com_finder`.

```text
html/com_finder/
├── search/
└── filters/
```

Possible elements:

- Search form
- Search query
- Filters
- Result list
- Result metadata
- Pagination
- Empty-result message

Older Joomla projects may also contain `com_search` overrides. These should be reviewed carefully during migration because the search implementation may change.

### 7.5 Product and Third-Party Overrides

Products are not a complete native Joomla content type. They are usually managed by a third-party or custom e-commerce component.

Examples:

- HikaShop
- VirtueMart
- J2Store
- Custom product component

Possible override folders:

```text
html/com_hikashop/
html/com_virtuemart/
html/com_j2store/
html/com_customproduct/
```

Possible product layouts:

- Product listing
- Product detail
- Product card
- Category listing
- Product gallery
- Product filter
- Product comparison
- Wishlist
- Cart
- Checkout
- Customer account
- Order history

The exact folder and file structure depends on the installed extension and version.

---

## 8. Module Overrides

A module override changes the HTML output of a Joomla module.

Examples:

```text
html/
├── mod_menu/
├── mod_custom/
├── mod_breadcrumbs/
├── mod_articles_latest/
├── mod_articles_category/
├── mod_articles_news/
├── mod_login/
├── mod_finder/
├── mod_languages/
└── mod_banners/
```

Common module overrides:

| Module | Purpose |
|---|---|
| `mod_menu` | Main, footer, mobile, or secondary navigation |
| `mod_custom` | Custom HTML content |
| `mod_breadcrumbs` | Breadcrumb output |
| `mod_articles_latest` | Latest articles |
| `mod_articles_category` | Articles from selected categories |
| `mod_articles_news` | News flash or article highlights |
| `mod_login` | Login form |
| `mod_finder` | Search form |
| `mod_languages` | Language switcher |
| `mod_banners` | Banner output |

A medium custom template may contain three to fifteen module overrides.

---

## 9. Alternative Layouts

An alternative layout provides an additional selectable layout instead of replacing only the default layout.

Article example:

```text
html/com_content/article/
├── default.php
├── news.php
├── promotion.php
└── landing-page.php
```

Module example:

```text
html/mod_articles_category/
├── default.php
├── grid.php
├── carousel.php
├── featured.php
└── compact.php
```

Typical alternative layouts include:

- Grid
- List
- Card
- Carousel
- Slider
- Featured
- Compact
- Landing-page section
- Campaign layout
- Print-friendly layout

Alternative layouts should be documented separately because they may be selected through menu items, module settings, or article configuration.

---

## 10. Reusable UI Components

Reusable UI components are shared presentation blocks used across multiple pages or layouts.

They may be implemented as Joomla layouts, template partials, module overrides, or custom PHP includes.

Possible directories:

```text
templates/custom_template/layouts/
templates/custom_template/html/layouts/
templates/custom_template/partials/
```

Common reusable components:

### Content components

- Article card
- News card
- Product card
- Category card
- Author block
- Metadata block
- Tag list
- Related-content block

### Navigation components

- Main navigation
- Mobile navigation
- Breadcrumb
- Pagination
- Tabs
- Anchor navigation

### Interactive components

- Slider
- Carousel
- Accordion
- Modal
- Dropdown
- Tooltip
- Filter
- Sort control
- Load-more button

### Form components

- Input
- Select
- Checkbox
- Radio button
- Textarea
- Search form
- Login form
- Contact form
- Validation message

### Status components

- Alert
- Badge
- Loading state
- Empty state
- Error state
- Success message

A medium website may contain ten to thirty reusable UI components.

---

## 11. Content Types

A content type is a logical group of content with a defined structure and presentation.

Examples:

- News
- Blog
- Promotion
- Event
- FAQ
- Vehicle
- Service
- Dealer
- Testimonial
- Landing page

A content type may be implemented using:

- Joomla articles and categories
- Joomla custom fields
- Tags
- A custom component
- A third-party CCK extension
- A third-party business extension

A template may provide the following layouts for each content type:

- Listing page
- Detail page
- Card layout
- Featured layout
- Category layout
- Search-result layout
- Filter layout
- Related-content layout
- Empty state
- Pagination

Important distinction:

> A content type is not necessarily stored inside the template. The template usually stores only its presentation and override logic.

---

## 12. Article Presentation

Article data belongs to Joomla content management. The template controls the visual presentation.

### Article listing

Typical elements:

- Page title
- Category description
- Filter
- Article cards
- Intro image
- Article title
- Intro text
- Category
- Published date
- Author
- Read-more link
- Pagination

### Article detail

Typical elements:

- Breadcrumb
- Article title
- Category
- Author
- Published date
- Intro image or full image
- Main content
- Custom fields
- Tags
- Social-sharing controls
- Previous and next links
- Related articles
- Call to action

### Article card

```text
Article Card
├── Thumbnail
├── Category
├── Title
├── Published Date
├── Short Description
└── Read More Link
```

### Common implementation paths

```text
templates/custom_template/html/com_content/article/
templates/custom_template/html/com_content/category/
templates/custom_template/html/com_content/featured/
templates/custom_template/html/mod_articles_category/
```

---

## 13. Product Presentation

Product data normally belongs to an e-commerce or custom component. The template controls how that product data is displayed.

### Product listing

Typical elements:

- Category title
- Category description
- Product filters
- Sorting control
- Product grid or list
- Product card
- Pagination or load-more control
- Empty-result state

### Product detail

Typical elements:

- Product title
- Product gallery
- Main image
- Thumbnail images
- Product code or SKU
- Price
- Discount price
- Availability
- Stock status
- Variant selector
- Quantity selector
- Add-to-cart button
- Description
- Specifications
- Related products
- Reviews
- Shipping information
- Warranty information

### Product card

```text
Product Card
├── Product Image
├── Product Badge
├── Product Name
├── Short Description
├── Price
├── Discount Price
├── Stock Status
├── Wishlist Action
├── Compare Action
└── Add to Cart Action
```

### Commerce flow

A complete product-oriented template may also contain:

- Mini cart
- Cart page
- Checkout page
- Customer information form
- Shipping method selection
- Payment method selection
- Order confirmation
- Order history
- Wishlist
- Product comparison

The template must not duplicate the business logic of the commerce extension. Stock calculation, pricing rules, payment processing, and order management should remain in the component or service layer.

---

## 14. Assets

Assets provide styling, behavior, images, icons, and fonts.

Common groups:

1. CSS
2. SCSS or other preprocessor files
3. JavaScript
4. Images
5. Icons
6. Fonts
7. Vendor libraries

Example:

```text
assets/
├── css/
├── scss/
├── js/
├── images/
├── icons/
├── fonts/
└── vendor/
```

Possible SCSS organization:

```text
scss/
├── base/
│   ├── _reset.scss
│   ├── _variables.scss
│   └── _typography.scss
├── layout/
│   ├── _header.scss
│   ├── _footer.scss
│   └── _grid.scss
├── components/
│   ├── _button.scss
│   ├── _card.scss
│   ├── _slider.scss
│   └── _modal.scss
├── pages/
│   ├── _home.scss
│   ├── _article.scss
│   └── _product.scss
├── utilities/
├── vendors/
└── template.scss
```

Possible JavaScript files:

```text
js/
├── template.js
├── navigation.js
├── search.js
├── slider.js
├── article.js
├── product.js
├── forms.js
└── validation.js
```

JavaScript may control:

- Mobile navigation
- Dropdowns
- Search overlay
- Slider or carousel
- Modal
- Accordion and tabs
- Form validation
- Product gallery
- Product filters
- Sticky header
- Lazy loading
- AJAX loading

During inventory, assets should be counted by logical responsibility rather than treating every generated or minified file as a separate feature.

---

## 15. Template Configuration

Template configuration is normally declared in `templateDetails.xml` and managed through Joomla Administrator.

Example:

```xml
<config>
    <fields name="params">
        <fieldset name="advanced">
            <field
                name="logo"
                type="media"
                label="Logo"
            />

            <field
                name="layout"
                type="list"
                label="Layout">
                <option value="boxed">Boxed</option>
                <option value="fluid">Fluid</option>
            </field>
        </fieldset>
    </fields>
</config>
```

Common template parameters:

- Logo
- Favicon
- Theme color
- Font family
- Header style
- Footer style
- Container width
- Boxed or fluid layout
- Sticky header
- Back-to-top control
- Social links
- Contact information
- Custom CSS
- Custom JavaScript
- Analytics code

A template may contain five to thirty or more configuration parameters.

---

## 16. Special Pages

A Joomla template may customize special states and pages.

Common examples:

| Page or state | Purpose |
|---|---|
| 404 | Page not found |
| 403 | Access forbidden |
| 500 | Server or application error |
| Offline | Maintenance mode |
| Component-only view | Displays only component output |
| Print view | Print-oriented presentation |
| Empty state | No data available |
| No search results | Search returned no matches |

Possible files:

```text
error.php
offline.php
component.php
```

Special pages should be tested independently because they may load a reduced set of assets and may not use the normal `index.php` layout.

---

## 17. Example Joomla Template Directory

The following is a conceptual structure. Actual Joomla templates may organize files differently.

```text
templates/custom_template/
├── templateDetails.xml
├── index.php
├── component.php
├── error.php
├── offline.php
├── joomla.asset.json
├── template_preview.png
├── template_thumbnail.png
│
├── html/
│   ├── com_content/
│   │   ├── article/
│   │   ├── category/
│   │   ├── featured/
│   │   └── form/
│   ├── com_contact/
│   ├── com_users/
│   ├── com_finder/
│   ├── com_hikashop/
│   ├── mod_menu/
│   ├── mod_breadcrumbs/
│   ├── mod_articles_category/
│   ├── mod_custom/
│   └── layouts/
│
├── layouts/
│   ├── cards/
│   ├── navigation/
│   ├── forms/
│   └── shared/
│
├── partials/
│   ├── header.php
│   ├── footer.php
│   ├── mobile-menu.php
│   └── search-overlay.php
│
├── media/
│   ├── css/
│   ├── js/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── scss/
│   ├── base/
│   ├── layout/
│   ├── components/
│   ├── pages/
│   ├── utilities/
│   └── template.scss
│
└── language/
    ├── en-GB/
    └── other-language/
```

In modern Joomla projects, public template assets may also be managed through the `/media/templates/site/<template-name>/` structure. The actual installed project must be inspected before defining the final inventory path.

---

## 18. Estimated Number of Template Items

The following values are practical estimates for a medium custom template.

| Group | Estimated quantity |
|---|---:|
| Template core files | 5-9 |
| Global layout components | 8-20 |
| Module positions | 10-20 |
| Component override groups | 3-10 |
| Module override groups | 3-15 |
| Alternative layouts | 2-20 |
| Reusable UI components | 10-30 |
| Asset groups | 5-7 |
| Template parameters | 5-30 |
| Special pages or states | 3-8 |

These numbers must not be added blindly because one item may belong to more than one logical group.

Recommended reporting rule:

> Count logical template items, not every physical file.

For example, an article-card component with one PHP file, one SCSS file, one JavaScript handler, and three icons should normally be recorded as one logical UI component with linked asset dependencies.

---

## 19. Recommended Inventory for Migration

Use a table similar to the following when auditing a Joomla template:

| ID | Group | Template item | Type | Source extension | Path | Used | Risk | Migration action |
|---|---|---|---|---|---|---|---|---|
| TMP-001 | Global | Header | Partial/layout | Custom template | `partials/header.php` | Yes | Medium | Rebuild and test |
| TMP-002 | Global | Main navigation | Module override | `mod_menu` | `html/mod_menu/` | Yes | High | Rewrite for Joomla 6 markup |
| TMP-003 | Article | Article detail | Component override | `com_content` | `html/com_content/article/` | Yes | High | Compare with Joomla 6 core layout |
| TMP-004 | Article | Category blog | Component override | `com_content` | `html/com_content/category/` | Yes | High | Rewrite and regression-test |
| TMP-005 | Product | Product listing | Third-party override | HikaShop | `html/com_hikashop/` | Yes | High | Confirm extension compatibility |
| TMP-006 | Shared UI | Product card | Reusable layout | Custom | `layouts/cards/` | Yes | Medium | Refactor and test |
| TMP-007 | Special | Error page | Template page | Joomla template | `error.php` | Yes | Medium | Update dependencies |
| TMP-008 | Assets | Main JavaScript | JavaScript | Custom | `media/js/template.js` | Yes | Medium | Remove deprecated APIs |
| TMP-009 | Configuration | Logo setting | Template parameter | Template XML | `templateDetails.xml` | Yes | Low | Migrate configuration |

Recommended status values:

- Used
- Possibly used
- Unused
- Unknown

Recommended migration actions:

- Keep
- Review
- Refactor
- Rewrite
- Replace
- Remove
- Confirm with extension vendor

---

## 20. Migration Notes for Joomla 3 to Joomla 6

A Joomla 3 template should not be copied directly to Joomla 6 without review.

Check at least the following areas:

### PHP compatibility

- Removed or deprecated PHP functions
- Old Joomla framework classes
- Namespace changes
- Direct access to deprecated helpers
- Old event or plugin integrations

### Joomla layout compatibility

- Compare each override with the matching Joomla 6 core layout
- Identify new variables and removed variables
- Check updated routing and URL helpers
- Check form rendering changes
- Check pagination output
- Check error handling

### Frontend framework compatibility

- Old Bootstrap markup
- Old jQuery dependencies
- Removed MooTools code
- Custom JavaScript relying on outdated DOM structure
- Accessibility attributes
- Responsive behavior

### Extension compatibility

- Confirm that each third-party component supports Joomla 6
- Obtain the correct extension version
- Compare old and new override files
- Rebuild overrides rather than copying them blindly
- Retest product, cart, checkout, account, and order flows

### Asset compatibility

- Review asset loading order
- Remove duplicate libraries
- Check `joomla.asset.json` when used
- Check whether assets belong under the template or Joomla media directory
- Rebuild SCSS and minified bundles

### Security and quality

- Escape output correctly
- Use Joomla APIs instead of direct SQL where possible
- Preserve CSRF protection in forms
- Validate frontend input
- Avoid exposing sensitive configuration
- Test error pages without debug information

---

## 21. Final Checklist

### Discovery

- [ ] Identify the active site template.
- [ ] Identify all template styles assigned to menu items.
- [ ] Read `templateDetails.xml`.
- [ ] List all module positions.
- [ ] List all component overrides.
- [ ] List all module overrides.
- [ ] List all alternative layouts.
- [ ] List all reusable partials and layouts.
- [ ] List all template parameters.
- [ ] List all special pages.

### Usage analysis

- [ ] Confirm which module positions are used.
- [ ] Confirm which overrides are used.
- [ ] Map layouts to menu items and modules.
- [ ] Map content types to their data sources.
- [ ] Separate article presentation from article data.
- [ ] Separate product presentation from product business logic.
- [ ] Identify unused and duplicate assets.

### Joomla 6 migration

- [ ] Compare overrides with Joomla 6 core files.
- [ ] Confirm third-party extension compatibility.
- [ ] Replace deprecated Joomla APIs.
- [ ] Replace unsupported JavaScript dependencies.
- [ ] Review Bootstrap and responsive markup.
- [ ] Review accessibility.
- [ ] Review output escaping and form security.
- [ ] Test desktop, tablet, and mobile layouts.
- [ ] Test article listing and detail pages.
- [ ] Test product listing and detail pages.
- [ ] Test cart and checkout when applicable.
- [ ] Test login, registration, search, error, and offline pages.

---

## Summary

A Joomla template has no fixed number of components. For technical analysis, it should be divided into ten main groups: core files, global layout, module positions, component overrides, module overrides, alternative layouts, reusable UI components, assets, configuration, and special pages.

For migration, the most important rule is to inventory logical items and verify each override against the target Joomla version. Articles, products, contacts, and users belong to components or extensions; the template should contain only their presentation and frontend integration.