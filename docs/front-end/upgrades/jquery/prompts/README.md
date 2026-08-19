# jQuery Impact Analysis Prompts

This folder contains six Claude Code prompts used to analyze the impact of upgrading the Joomla 3.4.6 bundled jQuery from `1.11.3` to `3.5.1`.

The purpose of splitting the work into six prompts is to avoid treating one scan as proof of full compatibility. Each prompt validates a different layer of the application, and the results should be correlated before making a GO / NO-GO decision.

## Upgrade Scope

```text
Joomla 3.4.6
media/jui/js/jquery.js
jQuery 1.11.3
      ↓
Direct upgrade
      ↓
jQuery 3.5.1
```

## Why Six Prompts?

A jQuery upgrade can affect more than files that directly contain `$()` or `jQuery()` calls. The real impact surface includes source code, Joomla routes, runtime execution, jQuery Migrate diagnostics, duplicate libraries, load order, third-party plugins, and scripts that are conditionally loaded.

The six prompts therefore provide six complementary layers of evidence:

```text
01 Discovery / Baseline
        ↓
02 Static File Impact
        ↓
03 Page / Route Impact
        ↓
04 Runtime Error Validation
        ↓
05 jQuery Migrate Diagnostics
        ↓
06 Runtime Loaded Asset Mapping
```

No single prompt guarantees complete application compatibility by itself.

---

## 1. `01-jquery-impact-summary-prompt.md`

### Why it exists

This prompt creates the baseline before deeper analysis begins.

It identifies the current environment, verifies the actual jQuery version, inventories jQuery copies, finds Joomla jQuery loaders, and records which extensions may be involved.

### What it verifies

- Joomla version and runtime environment.
- `media/jui/js/jquery.js` exists and its actual version is known.
- jQuery copies bundled across the repository are discovered.
- duplicate or legacy jQuery versions are visible.
- Joomla loaders such as `JHtml::_('jquery.framework')` are inventoried.
- installed components, modules, plugins, templates, and libraries are inventoried where possible.
- initial risk areas and unknown areas are explicitly documented.

### What it does not guarantee

It does not prove that a file is incompatible with jQuery 3.5.1 and does not prove that any page breaks at runtime.

### Expected report

```text
jquery-impact-summary.md
```

---

## 2. `02-jquery-file-impact-prompt.md`

### Why it exists

This prompt scans the source code for APIs and behaviors that changed, were deprecated, or were removed between jQuery 1.11.3 and 3.5.1.

This is the main **static compatibility analysis** layer.

### What it verifies

- all eligible source files are scanned.
- inline JavaScript inside PHP/templates is included.
- removed APIs such as `.size()` and `.andSelf()` are detected.
- legacy jqXHR callbacks such as `.success()`, `.error()`, and `.complete()` are detected.
- deprecated events such as `.bind()`, `.unbind()`, `.delegate()`, and `.undelegate()` are detected.
- Deferred/Promise usage is identified.
- AJAX usage is inventoried.
- DOM/HTML manipulation affected by jQuery 3.5 behavior is identified.
- custom selectors and jQuery internals are identified.
- jQuery plugins and their owners are mapped where possible.
- each finding is linked to a file, line, risk, and official documentation reference.

### What it does not guarantee

A static finding is only a **potential impact** until the relevant code path is executed. Dead code, unused plugins, or conditionally loaded code can appear in this report without causing runtime failure.

### Expected report

```text
jquery-file-impact.csv
```

---

## 3. `03-jquery-page-impact-prompt.md`

### Why it exists

A file-level report does not tell us which Joomla pages can actually load or use that code.

This prompt maps the static findings to Joomla frontend and administrator routes.

### What it verifies

- frontend menu routes are discovered from Joomla data.
- administrator components and candidate routes are inventoried.
- non-menu component routes are searched from source code.
- component, view, layout, and task information is recorded where possible.
- module-to-menu/page assignments are mapped.
- templates and global plugins are considered.
- impacted JavaScript files are associated with the pages that may use them.
- dynamic route families and unknown routes remain visible instead of being silently ignored.
- known-route coverage has a defined denominator.

### What it does not guarantee

It does not prove that every dynamic Joomla URL exists, and it does not prove that the mapped JavaScript code executes after the page loads.

`100% known route coverage` must not be interpreted as `100% of every possible application route`.

### Expected report

```text
jquery-page-impact.csv
```

---

## 4. `04-jquery-runtime-errors-prompt.md`

### Why it exists

Static analysis tells us what **may** be affected. Runtime analysis tells us what actually fails when pages execute with jQuery 3.5.1.

This prompt converts potential findings into browser evidence.

### What it verifies

- the expected jQuery version is actually loaded at runtime.
- known pages can be opened by a real browser.
- console errors and warnings are captured.
- JavaScript exceptions and unhandled errors are captured.
- failed JavaScript/AJAX/network requests are captured.
- jQuery version mismatches are detected.
- duplicate jQuery copies observed at runtime are detected.
- runtime failures are correlated back to page IDs and static findings where possible.
- successful page-load results are also recorded as evidence.
- blocked or untested pages are not incorrectly counted as PASS.

### What it does not guarantee

A successful initial page load does **not** prove that every interaction on that page works.

Code that runs only after click, change, submit, modal, slider, pagination, filter, checkout, or another user action may still remain untested.

### Expected report

```text
jquery-runtime-errors.csv
```

---

## 5. `05-jquery-migrate-warnings-prompt.md`

### Why it exists

jQuery Migrate is useful for identifying legacy behavior that may still appear to work only because the compatibility layer is present.

This prompt isolates those warnings so they can be reviewed separately from hard runtime errors.

### What it verifies

- jQuery Migrate 3.x is loaded as a diagnostic tool during testing.
- every `JQMIGRATE:` warning is captured.
- equivalent warnings are normalized and deduplicated.
- warning frequency is preserved.
- warnings are mapped to pages, files, lines, extensions, and static findings where evidence allows.
- warnings are classified by compatibility gap and severity.
- warnings linked to actual runtime failures can be distinguished from warning-only cases.
- unresolved warning sources remain visible as `UNKNOWN_SOURCE` instead of being guessed.

### What it does not guarantee

A jQuery Migrate warning is not automatically a broken feature.

Also, an application that only works while jQuery Migrate is present is not considered fully migrated. Migrate should remain a temporary diagnostic aid unless there is a separately approved production decision.

### Expected report

```text
jquery-migrate-warnings.csv
```

---

## 6. `06-jquery-loaded-assets-prompt.md`

### Why it exists

Repository files and static dependencies are not the same as assets that the browser actually loads.

This prompt records the **runtime asset graph** and is especially important for Joomla extensions that bundle their own old jQuery copy or dynamically inject JavaScript.

### What it verifies

- every observed JavaScript resource is recorded per tested page.
- active jQuery version is verified per page.
- jQuery, jQuery Migrate, jQuery UI, and jQuery plugins are identified.
- duplicate jQuery copies are detected at runtime.
- legacy jQuery versions loaded by templates/extensions are detected.
- script load order is captured.
- jQuery plugins loaded before jQuery or other suspicious orderings are detectable.
- external/CDN JavaScript is inventoried.
- Joomla/core/third-party/custom ownership is mapped where possible.
- runtime assets are correlated with static findings, Migrate warnings, and runtime errors.
- failed and conditionally loaded assets remain visible.

### What it does not guarantee

It only covers assets observed on the pages and flows that were actually visited. Untested routes or interactions may load additional scripts.

### Expected report

```text
jquery-loaded-assets.csv
```

---

# What the Six Reports Make Sure Of

Together, the six prompts provide evidence across these dimensions:

| Coverage Area | Report | What it helps prove |
|---|---|---|
| Environment baseline | `jquery-impact-summary.md` | We know what is installed and where jQuery comes from. |
| Source compatibility | `jquery-file-impact.csv` | We know which files contain APIs or behaviors that may be incompatible. |
| Route/page mapping | `jquery-page-impact.csv` | We know which known Joomla pages may expose those impacted files. |
| Runtime execution | `jquery-runtime-errors.csv` | We know which tested pages actually produce browser/runtime failures. |
| Legacy compatibility diagnostics | `jquery-migrate-warnings.csv` | We know which tested code paths still depend on deprecated/legacy jQuery behavior. |
| Runtime asset graph | `jquery-loaded-assets.csv` | We know which JavaScript assets and jQuery versions are actually loaded on tested pages. |

The correlation target is:

```text
Static file
    ↓
Joomla extension
    ↓
Page / route
    ↓
Loaded runtime asset
    ↓
jQuery Migrate warning
    ↓
Runtime error / PASS
```

This makes the analysis auditable instead of relying on a single grep command or page crawler.

---

# What These Six Prompts Still Do NOT Guarantee

Even when all six reports are complete, do not claim absolute `100% application compatibility` unless the remaining dimensions are also controlled.

Possible remaining gaps include:

- user interactions not executed during runtime scans;
- AJAX code paths triggered only by specific actions;
- role-specific or authenticated pages not tested;
- unpublished or dynamically generated routes;
- mobile/responsive-only behavior;
- browser-specific behavior;
- third-party code loaded only under special conditions;
- scheduled/background JavaScript behavior;
- rare error paths;
- data-dependent conditions that were not reproduced.

For release approval, these reports should therefore feed a final **coverage + interaction + GO / NO-GO review**.

---

# Recommended Execution Order

```text
01-jquery-impact-summary-prompt.md
        ↓
02-jquery-file-impact-prompt.md
        ↓
03-jquery-page-impact-prompt.md
        ↓
04-jquery-runtime-errors-prompt.md
        ↓
05-jquery-migrate-warnings-prompt.md
        ↓
06-jquery-loaded-assets-prompt.md
        ↓
Final correlation / coverage review
```

Do not skip an earlier report unless equivalent evidence already exists and is documented.

---

# Minimum Release Confidence

Before approving the jQuery upgrade, the combined evidence should at minimum show:

- `100%` eligible source-file scan coverage;
- `100%` known-route mapping coverage, with the denominator documented;
- all critical frontend and administrator pages runtime-tested;
- all observed JavaScript assets analyzed;
- no unexplained duplicate legacy jQuery on critical pages;
- no unresolved HIGH/CRITICAL runtime regression;
- jQuery Migrate warnings reviewed and mapped where possible;
- untested or unknown areas explicitly listed;
- rollback remains available.

The correct conclusion is not simply `PASS` or `FAIL`.

The final decision should state:

```text
CONFIRMED SAFE AREAS
POTENTIAL IMPACT AREAS
CONFIRMED REGRESSIONS
UNTESTED / UNKNOWN AREAS
GO / GO WITH CONDITIONS / NO-GO
```
