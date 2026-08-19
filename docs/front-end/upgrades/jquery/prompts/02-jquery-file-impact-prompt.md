# Claude Code Prompt 2 — jquery-file-impact.csv

## Task

Analyze the current **Joomla 3.4.6** project for a direct jQuery upgrade:

```text
jQuery 1.11.3
      ↓
jQuery 3.5.1
```

Do **not modify application code**.

Use the previous discovery report if available:

```text
reports/jquery-impact/jquery-impact-summary.md
```

Generate:

```text
reports/jquery-impact/jquery-file-impact.csv
```

---

## 1. Scan Scope

Scan the entire project for jQuery-related usage in:

```text
*.js
*.php
*.html
*.htm
*.tmpl
*.xml
```

Include at least:

```text
administrator/
components/
modules/
plugins/
templates/
media/
libraries/
```

Exclude only clearly irrelevant directories such as:

```text
.git/
node_modules/
cache/
tmp/
```

Do not exclude Joomla extensions.

---

## 2. Find jQuery Usage

Detect:

```javascript
$(
jQuery(
$.*
jQuery.*
$.fn.*
jQuery.fn.*
```

Also detect inline JavaScript inside PHP/template files.

---

## 3. Detect Removed / Breaking APIs

Scan at minimum for:

```javascript
.size(
.andSelf(

.success(
.error(
.complete(

.load(
.unload(
.error(

.context
.selector
```

Classify actual executable usages of removed APIs as HIGH.

Example replacements to recommend, but do not apply:

```javascript
// Old
$(".item").size()

// New
$(".item").length
```

```javascript
// Old
$.ajax(...).success(...)

// New
$.ajax(...).done(...)
```

Reference:

```text
https://jquery.com/upgrade-guide/3.0/
```

---

## 4. Detect Deprecated Event APIs

Scan:

```javascript
.bind(
.unbind(
.delegate(
.undelegate(
```

Recommended replacements:

```javascript
.on(
.off(
```

Normally classify as MEDIUM unless runtime evidence shows breakage.

---

## 5. Detect Deferred / Promise Usage

Scan:

```javascript
$.Deferred(
$.when(
.then(
.pipe(
.promise(
```

Pay special attention to `.then()` because jQuery 3 changed Deferred behavior.

Classify:

```text
simple Deferred usage   → MEDIUM
complex .then() chains  → HIGH
```

Reference:

```text
https://jquery.com/upgrade-guide/3.0/#deferred
```

---

## 6. Detect AJAX Impact

Scan:

```javascript
$.ajax(
$.get(
$.post(
$.getJSON(
$.getScript(
```

For each AJAX usage inspect whether it includes:

```text
dataType
crossDomain
jsonp
script
```

Flag:

```text
jqXHR.success()
jqXHR.error()
jqXHR.complete()
```

as HIGH.

Also flag cross-domain requests without explicit `dataType` for manual review.

Reference:

```text
https://jquery.com/upgrade-guide/3.0/#ajax
```

---

## 7. Detect HTML / DOM Manipulation Impact

Scan:

```javascript
.html(
.append(
.prepend(
.before(
.after(
.replaceWith(
.wrap(
.wrapAll(
.wrapInner(
```

Also detect HTML strings passed to jQuery:

```javascript
$("<div>")
$("<div/>")
$("<span/>")
```

Pay special attention to self-closing non-void tags such as:

```text
<div/>
<span/>
<a/>
<section/>
```

Classify suspicious HTML construction as MEDIUM or HIGH depending on usage.

Reference:

```text
https://jquery.com/upgrade-guide/3.5/
```

---

## 8. Detect Event Compatibility Risks

Scan:

```javascript
.on(
.off(
.trigger(
.triggerHandler(
```

Also detect:

```javascript
$(document).on("ready", ...)
```

or equivalent legacy ready-event patterns.

Flag old ready event usage as HIGH.

Reference:

```text
https://jquery.com/upgrade-guide/3.0/#breaking-change-on-ready-event
```

---

## 9. Detect Selector Risks

Scan for:

```text
:visible
:hidden
:first
:last
:eq(
```

Also detect custom selector extensions:

```javascript
$.expr
jQuery.expr
$.expr[':']
```

Custom selector internals should be at least MEDIUM risk.

---

## 10. Detect jQuery Plugin Definitions

Detect:

```javascript
$.fn.somePlugin =
jQuery.fn.somePlugin =
$.fn.extend(
```

Map:

```text
plugin name
definition file
extension owner
usage files
```

Third-party or custom plugins should receive compatibility review status.

---

## 11. Detect Private / Internal jQuery API Usage

Scan:

```javascript
$._data
jQuery._data
$.cache
jQuery.cache
$.support
jQuery.support
```

Also detect direct manipulation of jQuery internal event/data structures where possible.

Classify as HIGH.

---

## 12. Detect jQuery Loader Usage

Include static references such as:

```php
JHtml::_('jquery.framework');
JHtml::_('bootstrap.framework');
addScript(...)
```

Also direct asset references:

```text
media/jui/js/jquery.js
jquery.min.js
code.jquery.com
cdnjs
ajax.googleapis.com
```

These are primarily INFO unless they load duplicate/legacy jQuery.

---

## 13. Extension Ownership

For each finding determine the owner where possible.

Examples:

```text
components/com_cars/      → component: com_cars
modules/mod_slider/       → module: mod_slider
plugins/system/foo/       → plugin: system/foo
templates/protostar/      → template: protostar
media/com_hikashop/       → component: com_hikashop
```

Classify:

```text
JOOMLA_CORE
THIRD_PARTY
CUSTOM
UNKNOWN
```

Do not guess silently. If ownership cannot be determined use `UNKNOWN`.

---

## 14. Avoid Double Counting

If both exist:

```text
foo.js
foo.min.js
```

prefer `foo.js` for source analysis.

Record `foo.min.js` as a related/minified asset but do not double-count findings.

Also separate comments, documentation, source maps, test fixtures, and demo files from executable findings.

---

## 15. Required CSV Columns

Generate exactly one main report:

```text
reports/jquery-impact/jquery-file-impact.csv
```

Recommended columns:

```text
finding_id
file_path
line_number
extension_type
extension_name
owner_classification
language
jquery_category
api_pattern
code_snippet
occurrence_count
source_version
target_version
gap_type
severity
confidence
reason
official_reference
recommended_action
minified_source
runtime_loaded
runtime_pages
status
notes
```

---

## 16. Severity

Use:

```text
CRITICAL
HIGH
MEDIUM
LOW
INFO
```

Guideline:

- `CRITICAL`: confirmed runtime failure only. Normally not assigned during this static phase.
- `HIGH`: removed API, private API, legacy jqXHR callback, old ready event, duplicate jQuery loader, high-risk Deferred behavior.
- `MEDIUM`: deprecated API, DOM/HTML behavior-sensitive usage, selectors, complex events, plugins needing review.
- `LOW`: still-supported but noteworthy usage.
- `INFO`: normal jQuery usage or loader inventory.

---

## 17. Confidence

Use:

```text
CONFIRMED
HIGH_CONFIDENCE
POTENTIAL
INFORMATIONAL
```

Do not classify every regex match as confirmed application impact.

---

## 18. Official Documentation

Each compatibility finding must contain a relevant URL.

Use at minimum:

```text
https://jquery.com/upgrade-guide/3.0/
https://jquery.com/upgrade-guide/3.5/
```

Useful release references:

```text
https://blog.jquery.com/2016/06/09/jquery-3-0-final-released/
https://blog.jquery.com/2020/04/10/jquery-3-5-0-released/
https://blog.jquery.com/2020/05/04/jquery-3-5-1-released-fixing-a-regression/
```

Do not put one generic URL on every finding if a more specific official reference exists.

---

## 19. Required Summary

After generating the CSV, print:

```text
Files scanned: X
Files containing jQuery usage: X
Potentially impacted files: X

HIGH: X
MEDIUM: X
LOW: X
INFO: X

Removed API findings: X
Deprecated API findings: X
AJAX findings: X
Deferred findings: X
DOM/HTML findings: X
Event findings: X
Selector findings: X
Plugin findings: X
Private API findings: X

Joomla core impacted files: X
Third-party impacted files: X
Custom impacted files: X
Unknown ownership: X
```

---

## 20. Important Rules

Do not:

- modify source code;
- replace jQuery;
- automatically fix findings;
- claim a static finding definitely breaks runtime;
- claim 100% application compatibility;
- remove duplicate libraries.

Only:

```text
SCAN
→ IDENTIFY
→ CLASSIFY
→ MAP
→ REPORT
```

---

## 21. Completion Criteria

Before finishing verify:

- [ ] all eligible source files were scanned;
- [ ] inline JS in PHP/templates was included;
- [ ] removed APIs were checked;
- [ ] deprecated APIs were checked;
- [ ] AJAX usage was checked;
- [ ] Deferred/Promise usage was checked;
- [ ] DOM/HTML manipulation was checked;
- [ ] event APIs were checked;
- [ ] selectors were checked;
- [ ] plugin definitions were checked;
- [ ] private jQuery APIs were checked;
- [ ] loader usage was checked;
- [ ] extension ownership was mapped;
- [ ] minified duplicates were not double-counted;
- [ ] official documentation URL exists for compatibility findings;
- [ ] `jquery-file-impact.csv` was generated.

End with:

```text
STATUS: STATIC FILE IMPACT SCAN COMPLETE / INCOMPLETE

Eligible files scanned: X / X
jQuery-related files: X
Potentially impacted files: X
HIGH findings: X
Unknown ownership findings: X
```

Do not start route or browser runtime testing in this prompt.
