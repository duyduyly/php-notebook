# Claude Code Prompt 3 — jquery-page-impact.csv

## Task

Analyze the current **Joomla 3.4.6** project for this direct upgrade:

```text
jQuery 1.11.3
      ↓
jQuery 3.5.1
```

Do **not modify application code or upgrade jQuery**.

Use these previous reports if available:

```text
reports/jquery-impact/jquery-impact-summary.md
reports/jquery-impact/jquery-file-impact.csv
```

Generate:

```text
reports/jquery-impact/jquery-page-impact.csv
```

The goal is to identify **every known frontend and administrator page that may be affected by the jQuery upgrade**, and map each page to its Joomla component, modules, template, and potentially impacted JavaScript files.

---

## 1. Main Goal

Answer:

```text
Which Joomla pages can potentially execute
jQuery-dependent or jQuery-incompatible code?
```

Build this mapping:

```text
Page / Route
    ↓
Component
    ↓
Modules
    ↓
Template
    ↓
Loaded / Related JS Files
    ↓
Static jQuery Findings
    ↓
Potential Risk
```

Do not perform full runtime interaction testing in this prompt.

---

## 2. Route Discovery Sources

Do **not rely only on sitemap or menu links**.

Discover pages using all available sources:

```text
1. Joomla menu database
2. Installed components
3. Component source code
4. Administrator components
5. Existing links/routes in templates
6. Runtime-discovered links if available
```

Each route must record where it came from.

---

## 3. Frontend Menu Routes

Inspect:

```text
#__menu
```

for frontend records where:

```text
client_id = 0
```

Collect:

```text
id
menutype
title
alias
path
link
component_id
parent_id
level
published
access
language
home
```

Include published and unpublished routes, but classify them separately.

Do not assume unpublished routes are production-visible.

---

## 4. Administrator Routes

Inspect:

```text
#__extensions
#__menu
```

for administrator components.

At minimum identify candidate pages such as:

```text
/administrator/index.php?option=com_content
/administrator/index.php?option=com_users
/administrator/index.php?option=com_modules
/administrator/index.php?option=com_plugins
/administrator/index.php?option=com_templates
```

Also include installed third-party/custom administrator components.

---

## 5. Non-Menu Component Routes

Important: `#__menu` does **not** represent every Joomla page.

Search:

```text
components/*/
administrator/components/*/
```

for:

```text
view=
layout=
task=
controller=
option=com_
```

Inspect:

```text
controllers/
views/
models/
tmpl/
```

Build candidate routes where technically possible and mark them as:

```text
SOURCE_DISCOVERED
```

Do not claim a route is valid until runtime-tested.

---

## 6. Component Inventory

For each page determine:

```text
component_name
component_id
frontend/admin
view
layout
task
```

Example:

```text
/index.php?option=com_content&view=article&id=10
```

becomes:

```text
component = com_content
view      = article
```

---

## 7. Module Mapping

Use:

```text
#__modules
#__modules_menu
```

Determine which modules can appear on each menu/page.

Capture:

```text
module_id
module_name
module_type
position
published
menu_assignment
```

Pay attention to `menuid = 0` or equivalent Joomla "all pages" assignments.

A global jQuery-dependent module may affect many pages.

---

## 8. Template Mapping

Determine frontend and administrator templates.

Use:

```text
#__template_styles
```

and project structure.

Map each page to:

```text
template
template style
client
```

Identify template JavaScript files from:

```text
templates/<template>/js/
administrator/templates/<template>/js/
```

---

## 9. Map Static jQuery Findings

Use:

```text
reports/jquery-impact/jquery-file-impact.csv
```

For every page, map relevant findings from:

```text
component files
module files
template files
shared media assets
global plugins
```

Examples:

```text
templates/foo/js/template.js
components/com_cars/assets/cars.js
modules/mod_slider/assets/slider.js
media/com_hikashop/js/hikashop.js
```

This is a **potential page-impact mapping**, not runtime proof.

---

## 10. Global Plugins

Identify enabled plugins from:

```text
#__extensions
```

especially system/content/user/authentication/editor-related plugins.

If a plugin injects JavaScript globally, record it against all applicable pages.

Do not blindly map every plugin to every page. Use plugin type, event hooks, and source evidence where possible.

---

## 11. Shared / Global JavaScript

Identify JS that may load globally:

```text
media/jui/js/*
template global JS
bootstrap.js
jquery plugins
system plugin JS
shared libraries
```

Mark:

```text
scope = GLOBAL
```

only when evidence supports it.

---

## 12. Page Classification

Classify pages into:

```text
FRONTEND_PUBLIC
FRONTEND_AUTHENTICATED
ADMINISTRATOR
SYSTEM
ERROR
UNKNOWN
```

Also record likely authentication requirements.

---

## 13. Special Pages to Include

Do not forget:

```text
homepage
login
logout
registration
search
contact
article
category
featured articles
404/error page
offline page if applicable
administrator login
administrator dashboard
component list pages
component edit pages
module manager
plugin manager
template manager
```

Also include third-party/custom components discovered in the project.

---

## 14. Dynamic Route Limitations

Explicitly track routes that cannot be fully enumerated, such as:

```text
article IDs
category IDs
product IDs
search results
pagination
filters
AJAX-only views
user-specific pages
```

Represent them as route families where appropriate.

Example:

```text
/index.php?option=com_content&view=article&id={id}
```

Do not generate thousands of duplicate rows unless useful.

---

## 15. Risk Classification

Use:

```text
CRITICAL
HIGH
MEDIUM
LOW
INFO
```

For this report:

- `HIGH`: page includes one or more HIGH-risk static jQuery findings or duplicate/legacy jQuery is potentially associated.
- `MEDIUM`: page includes behavior-sensitive DOM/event/plugin findings.
- `LOW`: page uses jQuery but no known breaking pattern found.
- `INFO`: route discovered but no jQuery relationship identified yet.

Do not use CRITICAL unless existing confirmed runtime breakage evidence exists.

---

## 16. Confidence

Use:

```text
CONFIRMED_MAPPING
HIGH_CONFIDENCE
POTENTIAL
UNKNOWN
```

A direct menu-to-component mapping may be `CONFIRMED_MAPPING`; a route inferred only from source may be `POTENTIAL`.

---

## 17. Required CSV

Generate:

```text
reports/jquery-impact/jquery-page-impact.csv
```

Required columns:

```text
page_id
url
route_pattern
page_title
frontend_or_admin
page_type
route_source
menu_id
component_id
component_name
view
layout
task
template
module_ids
module_types
global_plugins
related_js_files
jquery_impacted_files
jquery_finding_count
highest_static_risk
authentication_required
access_level
published
language
confidence
runtime_tested
runtime_result
status
notes
```

---

## 18. Deduplication

Avoid duplicate rows caused by equivalent routes.

Keep separate rows when there are materially different:

```text
module assignments
template styles
access levels
frontend/admin contexts
```

---

## 19. Coverage Metrics

At the end calculate:

```text
Frontend menu routes discovered: X
Administrator component routes: X
Source-discovered route families: X
Published routes: X
Unpublished routes: X
Authenticated routes: X

Pages mapped to impacted files: X
Pages with HIGH risk: X
Pages with MEDIUM risk: X
Pages with LOW risk: X
Pages with no static jQuery impact: X
Unknown/unresolved mappings: X
```

Do **not** say "100% of all application pages covered" unless every dynamic route is provably enumerable.

Instead report:

```text
Known Route Coverage
```

and define its denominator.

---

## 20. Traceability

Every page with findings should trace back to `jquery-file-impact.csv` through finding IDs.

Example:

```text
PAGE-023
    ↓
JQ-FILE-014
    ↓
components/com_cars/assets/cars.js:188
    ↓
.success()
    ↓
HIGH
```

---

## 21. Do Not Test Interactions Yet

Do not perform:

```text
click automation
form submissions
AJAX interaction testing
modal testing
slider testing
checkout flows
```

A normal non-destructive route validation is acceptable if useful.

---

## 22. Required Terminal Summary

Print:

```text
Known frontend routes: X
Known administrator routes: X
Source-discovered routes: X
Total unique route records: X

Pages mapped to jQuery-related files: X
Pages potentially impacted: X

HIGH: X
MEDIUM: X
LOW: X
INFO: X

Unknown page mappings: X
Dynamic route families: X
Runtime-tested pages: X
```

---

## 23. Completion Criteria

Verify:

- [ ] frontend menu routes were inventoried;
- [ ] administrator components were inventoried;
- [ ] non-menu component routes were searched;
- [ ] component/view/layout mappings were created;
- [ ] module-to-page assignments were mapped;
- [ ] template mappings were created;
- [ ] enabled/global plugins were considered;
- [ ] impacted JS files were mapped from `jquery-file-impact.csv`;
- [ ] route families were used for dynamic URLs where appropriate;
- [ ] duplicates were controlled;
- [ ] unknown routes/mappings were explicitly retained;
- [ ] known-route coverage was calculated;
- [ ] `jquery-page-impact.csv` was generated.

End with:

```text
STATUS: PAGE IMPACT DISCOVERY COMPLETE / INCOMPLETE

Known routes discovered: X
Known routes mapped: X / X
Pages potentially impacted: X
HIGH-risk pages: X
Dynamic/unknown route families: X
```

Do not upgrade jQuery and do not fix application code.
