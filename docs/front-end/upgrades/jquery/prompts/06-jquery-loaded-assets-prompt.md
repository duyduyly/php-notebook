# Claude Code Prompt 6 — jquery-loaded-assets.csv

## Task

Analyze the Joomla 3.4.6 project for this direct upgrade:

```text
jQuery 1.11.3
      ↓
jQuery 3.5.1
```

Use these reports if available:

```text
reports/jquery-impact/jquery-impact-summary.md
reports/jquery-impact/jquery-file-impact.csv
reports/jquery-impact/jquery-page-impact.csv
reports/jquery-impact/jquery-runtime-errors.csv
reports/jquery-impact/jquery-migrate-warnings.csv
```

Generate:

```text
reports/jquery-impact/jquery-loaded-assets.csv
```

The goal is to record **every JavaScript asset actually loaded at runtime on every tested Joomla page**, with special focus on jQuery, duplicate versions, jQuery plugins, extension-owned assets, load order, and assets that may be affected by the jQuery upgrade.

---

## 1. Main Goal

Build this runtime mapping:

```text
Page
  ↓
Loaded JavaScript Asset
  ↓
Asset Owner
  ↓
jQuery / Plugin / Application JS
  ↓
Version
  ↓
Load Order
  ↓
Static Impact Findings
  ↓
Runtime Errors / Migrate Warnings
```

Answer:

```text
Which JavaScript files are actually loaded?
Where are they loaded?
Which jQuery version is active?
Are multiple jQuery copies loaded?
Which scripts execute before/after jQuery?
Which extensions inject their own jQuery or plugins?
```

---

## 2. Input Pages

Read testable routes from:

```text
reports/jquery-impact/jquery-page-impact.csv
```

Use runtime state from:

```text
reports/jquery-impact/jquery-runtime-errors.csv
```

Attempt all known testable frontend, administrator, authenticated, custom, and third-party component pages.

Do not limit the scan to the homepage.

---

## 3. Browser Runtime Capture

Use Playwright.

For every page capture all JavaScript network resources.

Track:

```text
request URL
response URL
HTTP status
resource type
load sequence
page URL
initiator if available
cache status if available
```

Focus on `script`, `fetch`, and `xhr`, but only JavaScript assets belong in the main CSV.

---

## 4. Detect jQuery Assets

Identify assets matching patterns such as:

```text
jquery.js
jquery.min.js
jquery-1.*
jquery-2.*
jquery-3.*
jquery-migrate*
jquery-ui*
```

Inspect file content/banner where required to determine version.

Record jQuery, Migrate, and jQuery UI versions where detectable.

---

## 5. Verify Active jQuery Version

For each page execute:

```javascript
typeof window.jQuery
window.jQuery && window.jQuery.fn.jquery
typeof window.$
window.$ === window.jQuery
```

Do not automatically classify `$ !== jQuery` as an error because Joomla may use `noConflict()`.

---

## 6. Duplicate jQuery Detection

Detect pages loading more than one jQuery distribution.

Example:

```text
/media/jui/js/jquery.js             3.5.1
/templates/foo/js/jquery-1.8.3.js   1.8.3
```

Classify:

```text
duplicate_jquery = YES
severity = HIGH
```

Also detect when one jQuery version overwrites another global version later in the load sequence.

---

## 7. Load Order

Record script load sequence.

Example:

```text
1 jquery.js
2 jquery-migrate.js
3 bootstrap.js
4 slider.js
5 template.js
```

Detect suspicious ordering:

```text
plugin.js before jquery.js
jquery-migrate before jquery
multiple jquery versions
plugin requiring jQuery loaded before jQuery
```

Classify invalid dependency order as HIGH.

---

## 8. Detect jQuery Plugins

Identify scripts that likely depend on jQuery using filename, static findings, source inspection, `$.fn.*`, and `jQuery.fn.*`.

Examples:

```text
jquery.validate.js
jquery-ui.js
jquery.cookie.js
jquery.colorbox.js
chosen.jquery.js
slick.js
custom slider plugins
```

Record plugin version where detectable.

---

## 9. Extension Ownership

Map each runtime asset to Joomla ownership where possible.

Examples:

```text
/media/jui/              → JOOMLA_CORE
/media/com_hikashop/     → com_hikashop
/components/com_cars/    → com_cars
/modules/mod_slider/     → mod_slider
/plugins/system/foo/     → system/foo
/templates/protostar/    → protostar
```

Use:

```text
JOOMLA_CORE
THIRD_PARTY
CUSTOM
EXTERNAL
UNKNOWN
```

Do not guess silently.

---

## 10. External Assets

Detect CDN or third-party JavaScript such as:

```text
code.jquery.com
cdnjs.cloudflare.com
ajax.googleapis.com
cdn.jsdelivr.net
unpkg.com
```

Record domain, asset URL, and version where possible.

Flag external old jQuery versions as HIGH.

---

## 11. Static Finding Correlation

Use:

```text
jquery-file-impact.csv
```

Map loaded assets to static finding IDs where possible.

Record:

```text
static_finding_ids
static_finding_count
static_highest_risk
```

---

## 12. Runtime Error Correlation

Use:

```text
jquery-runtime-errors.csv
```

Map each loaded asset to runtime error IDs, error count, and highest runtime severity.

---

## 13. jQuery Migrate Warning Correlation

Use:

```text
jquery-migrate-warnings.csv
```

Map warnings to loaded assets where possible.

Record:

```text
migrate_warning_ids
migrate_warning_count
```

This should support:

```text
Asset
↓
Static Risk
↓
Migrate Warning
↓
Runtime Error
```

---

## 14. Detect Missing / Failed Assets

Record scripts that return:

```text
404
403
500
requestfailed
blocked
CORS fail
```

Do not silently exclude them.

A missing critical jQuery/plugin asset should be HIGH.

---

## 15. Detect Conditional Assets

Some scripts may load only on a specific component, view, module, admin page, authenticated page, or AJAX flow.

Record page-level loading instead of assuming every discovered asset is global.

---

## 16. Global Asset Detection

Mark an asset as:

```text
GLOBAL
```

only when evidence shows it appears across all or nearly all applicable pages.

Do not classify one homepage observation as global.

---

## 17. Minified / Source Pair Mapping

If runtime loads:

```text
foo.min.js
```

and static analysis used:

```text
foo.js
```

map them.

Record:

```text
runtime_asset = foo.min.js
source_asset = foo.js
```

Avoid duplicate risk counting.

---

## 18. Required CSV

Generate:

```text
reports/jquery-impact/jquery-loaded-assets.csv
```

Required columns:

```text
asset_id
page_id
page_url
frontend_or_admin
component
view
asset_url
asset_path
asset_name
asset_type
owner
owner_classification
local_or_external
domain
http_status
load_order
initiator
jquery_related
jquery_asset_type
detected_version
active_jquery_version
jquery_copy_count
duplicate_jquery
load_order_issue
source_asset
static_finding_ids
static_finding_count
static_highest_risk
runtime_error_ids
runtime_error_count
runtime_highest_severity
migrate_warning_ids
migrate_warning_count
asset_status
severity
confidence
notes
```

---

## 19. Asset Type

Use:

```text
JQUERY_CORE
JQUERY_MIGRATE
JQUERY_UI
JQUERY_PLUGIN
JOOMLA_CORE_JS
EXTENSION_JS
TEMPLATE_JS
CUSTOM_JS
EXTERNAL_JS
UNKNOWN
```

---

## 20. Severity

Use:

```text
CRITICAL
HIGH
MEDIUM
LOW
INFO
```

### HIGH

Use for duplicate jQuery, legacy jQuery loaded, plugin before jQuery, failed jQuery load, failed critical plugin, or runtime error linked to asset.

### MEDIUM

Use for jQuery plugin with static compatibility findings, Migrate warnings linked to asset, or uncertain load-order dependency.

### LOW

Use for minor/non-critical compatibility concerns.

### INFO

Use for normal successful asset loads with no known problem.

---

## 21. Confidence

Use:

```text
CONFIRMED
HIGH_CONFIDENCE
POTENTIAL
UNKNOWN
```

A directly observed runtime request is CONFIRMED. A version inferred only from filename may be HIGH_CONFIDENCE or POTENTIAL.

---

## 22. One Row per Page + Asset

Use:

```text
one page + one loaded asset = one CSV row
```

Do not collapse all pages into one row because an asset may load only on specific routes.

---

## 23. Runtime Asset Matrix

The report should support analysis like:

| Page | Asset | Version | Owner | jQuery? | Findings | Errors | Risk |
|---|---|---:|---|---|---:|---:|---|
| `/` | `jquery.js` | 3.5.1 | Joomla | Yes | 0 | 0 | INFO |
| `/` | `slider.js` | — | mod_slider | Plugin | 3 | 1 | HIGH |
| `/shop` | `jquery-1.8.js` | 1.8.3 | com_x | Yes | — | — | HIGH |

---

## 24. Duplicate jQuery Summary

Generate a summary such as:

```text
Pages tested: X
Pages loading one jQuery copy: X
Pages loading multiple jQuery copies: X

jQuery versions observed:
1.8.3  → X pages
1.11.3 → X pages
3.5.1  → X pages
```

List every page that still loads a legacy version.

---

## 25. Load Order Summary

Report:

```text
Assets loaded before jQuery: X
Plugins loaded before jQuery: X
Migrate loaded before jQuery: X
Duplicate jQuery overwrite cases: X
```

---

## 26. Runtime Asset Coverage

Calculate:

```text
unique runtime JS assets observed
unique runtime JS assets analyzed
```

Target:

```text
100% observed assets analyzed
```

This does **not** mean 100% application assets because unvisited routes may load additional scripts.

---

## 27. Required Terminal Summary

Print:

```text
Pages scanned: X

Total JS load events: X
Unique JS assets: X

jQuery core assets: X
jQuery Migrate assets: X
jQuery UI assets: X
jQuery plugins: X

Legacy jQuery copies: X
Pages with duplicate jQuery: X
Load-order issues: X
Failed JS assets: X

Assets with static findings: X
Assets linked to Migrate warnings: X
Assets linked to runtime errors: X

HIGH-risk assets: X
MEDIUM-risk assets: X
```

---

## 28. Important Rules

Do not:

- modify JavaScript;
- remove duplicate libraries;
- change load order;
- replace CDN references;
- fix runtime errors;
- assume static files are runtime-loaded;
- assume one page represents the entire site.

Only:

```text
LOAD
→ CAPTURE
→ IDENTIFY
→ VERSION
→ MAP
→ CORRELATE
→ REPORT
```

---

## 29. Completion Criteria

Verify:

- [ ] all testable pages from `jquery-page-impact.csv` were attempted;
- [ ] all runtime JavaScript requests were captured;
- [ ] jQuery assets were identified;
- [ ] jQuery versions were detected where possible;
- [ ] active jQuery version was verified;
- [ ] duplicate jQuery copies were detected;
- [ ] load order was recorded;
- [ ] jQuery plugins were identified;
- [ ] Joomla ownership was mapped;
- [ ] external CDN scripts were recorded;
- [ ] failed assets were preserved;
- [ ] static findings were correlated;
- [ ] runtime errors were correlated;
- [ ] Migrate warnings were correlated;
- [ ] runtime asset coverage was calculated;
- [ ] `jquery-loaded-assets.csv` was generated.

End with:

```text
STATUS: RUNTIME ASSET SCAN COMPLETE / INCOMPLETE

Pages scanned: X / X
Unique JS assets observed: X
Assets analyzed: X / X

Legacy jQuery copies: X
Duplicate-jQuery pages: X
Load-order issues: X
Failed critical assets: X

HIGH-risk assets: X
```

Do not fix any asset problem in this prompt.
