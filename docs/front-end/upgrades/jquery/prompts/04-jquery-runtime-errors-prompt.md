# Claude Code Prompt 4 — jquery-runtime-errors.csv

## Task

Analyze the Joomla 3.4.6 project for this direct upgrade:

```text
jQuery 1.11.3
      ↓
jQuery 3.5.1
```

Use these previous reports if available:

```text
reports/jquery-impact/jquery-impact-summary.md
reports/jquery-impact/jquery-file-impact.csv
reports/jquery-impact/jquery-page-impact.csv
```

Generate:

```text
reports/jquery-impact/jquery-runtime-errors.csv
```

The goal is to determine which potential static impacts become **actual runtime warnings or errors** when pages run with jQuery `3.5.1`.

---

## 1. Main Goal

Validate:

```text
Static finding
      ↓
Page
      ↓
Loaded JavaScript
      ↓
Browser execution
      ↓
Warning / Error / PASS
```

Distinguish:

```text
Potential Impact
Confirmed Runtime Impact
Observed Regression
PASS
Untested
```

Do not automatically modify application code.

---

## 2. Test Environment

Run only against:

```text
DEV
TEST
STAGING
LOCAL
```

Never production unless explicitly configured.

Record:

```text
base URL
Joomla version
Git commit
PHP version
Node version
Playwright version
browser/version
jQuery version
jQuery Migrate version
scan timestamp
```

---

## 3. jQuery Test Version

Verify at runtime:

```javascript
window.jQuery && window.jQuery.fn.jquery
```

Expected:

```text
3.5.1
```

If a page still loads `1.11.3` or another old version, record:

```text
JQUERY_VERSION_MISMATCH
```

and continue scanning.

---

## 4. jQuery Migrate

During testing, use:

```text
jQuery 3.5.1
+
jQuery Migrate 3.x development build
```

Capture all warnings starting with:

```text
JQMIGRATE:
```

Do not suppress warnings.

Do not treat "page works with jQuery Migrate" as proof that it works without Migrate.

---

## 5. Input Pages

Read page candidates from:

```text
reports/jquery-impact/jquery-page-impact.csv
```

Prioritize HIGH, MEDIUM, LOW, INFO but attempt all known/testable routes.

Include frontend, administrator, authenticated, error, third-party, and custom component pages where credentials/environment allow.

---

## 6. Browser Scanner

Use Playwright if available.

For every route perform:

```text
open page
↓
wait for DOMContentLoaded
↓
wait for reasonable network idle/stable state
↓
capture jQuery state
↓
capture loaded JS
↓
capture console
↓
capture page errors
↓
capture failed network requests
↓
record result
```

Do not fail the entire scan because one page crashes. Record failure and continue.

---

## 7. Browser Console Capture

Capture:

```text
console.log
console.info
console.warn
console.error
```

Store at minimum:

```text
type
message
URL
page
timestamp
source file if available
line
column
```

Separate:

```text
JQMIGRATE
JQUERY
APPLICATION_JS
THIRD_PARTY_JS
UNKNOWN
```

---

## 8. JavaScript Exceptions

Capture:

```text
pageerror
uncaught exceptions
unhandled promise rejections
```

Examples:

```text
TypeError
ReferenceError
SyntaxError
RangeError
```

If possible capture stack trace, source file, line, and column.

---

## 9. Network Failures

Capture failed requests:

```text
requestfailed
HTTP 4xx
HTTP 5xx
blocked scripts
missing JavaScript assets
AJAX failures
```

Record request URL, method, resource type, status, failure reason, and initiator when available.

Do not classify unrelated missing images as a jQuery regression unless evidence connects them.

---

## 10. Loaded JavaScript Assets

Capture all JavaScript resources loaded by each page.

Detect duplicate jQuery copies and record version where possible.

Example:

```text
/media/jui/js/jquery.js        3.5.1
/templates/foo/js/jquery.js    1.8.3
```

Classify this as HIGH / `DUPLICATE_JQUERY`.

---

## 11. Runtime jQuery State

For each page evaluate:

```javascript
typeof window.jQuery
window.jQuery?.fn?.jquery
typeof window.$
```

Also inspect jQuery Migrate loaded, multiple jQuery globals, and `noConflict()` usage where possible.

Do not automatically classify `$ !== jQuery` as an error because Joomla may use `noConflict()`.

---

## 12. Correlate With Static Findings

Use:

```text
jquery-file-impact.csv
jquery-page-impact.csv
```

Map runtime issues back to page ID, finding ID, file, line, and extension where evidence allows.

Do not invent mappings.

---

## 13. jQuery Migrate Warning Mapping

When a JQMIGRATE warning appears, attempt to map it to file, line, static finding, page, and extension.

If stack traces are available, use them.

If unresolved use:

```text
UNKNOWN_SOURCE
```

---

## 14. Runtime Result Classification

Use:

```text
PASS
WARNING
FAIL
BLOCKED
UNTESTED
```

### PASS

- page loaded successfully;
- expected jQuery version loaded;
- no unexplained JavaScript errors;
- no relevant Migrate warning.

### WARNING

- page works but has relevant JQMIGRATE or non-blocking jQuery warning.

### FAIL

- confirmed JavaScript/runtime regression;
- critical JS asset missing;
- page breaks because of jQuery compatibility.

### BLOCKED

- authentication unavailable;
- environment issue;
- server error unrelated to jQuery;
- route invalid.

### UNTESTED

- page not executed.

---

## 15. Severity

Use:

```text
CRITICAL
HIGH
MEDIUM
LOW
INFO
```

- `CRITICAL`: login/checkout/admin or other critical business flow unusable; page JS completely stops.
- `HIGH`: uncaught jQuery-related exception, removed API executed, duplicate legacy jQuery active, critical AJAX failure.
- `MEDIUM`: JQMIGRATE warning, non-critical plugin issue, partial regression.
- `LOW`: minor non-blocking compatibility warning.
- `INFO`: normal runtime information.

---

## 16. Confidence

Use:

```text
CONFIRMED
HIGH_CONFIDENCE
POTENTIAL
UNKNOWN
```

A stack trace pointing to an exact removed API can be CONFIRMED. An unresolved console error should remain POTENTIAL/UNKNOWN.

---

## 17. Required CSV

Generate:

```text
reports/jquery-impact/jquery-runtime-errors.csv
```

Required columns:

```text
runtime_id
page_id
url
page_title
frontend_or_admin
component
view
layout
jquery_expected_version
jquery_actual_version
jquery_copy_count
jquery_assets
jquery_migrate_loaded
error_type
error_category
message
source_file
line_number
column_number
stack_trace
static_finding_id
extension_name
network_url
http_status
severity
confidence
runtime_result
is_jquery_related
is_regression
evidence
recommended_action
notes
```

---

## 18. One Row per Runtime Finding

Prefer one runtime issue per CSV row.

A page with 3 Migrate warnings, 1 TypeError, and 1 failed AJAX request should normally produce five findings.

---

## 19. PASS Rows

For pages with no issue, create one row with:

```text
error_type = NONE
runtime_result = PASS
severity = INFO
```

This allows runtime coverage to be calculated.

---

## 20. Screenshot / Raw Evidence

For HIGH/CRITICAL failures capture screenshots when useful under:

```text
reports/jquery-impact/evidence/runtime/
```

Preserve raw runtime logs where useful under:

```text
reports/jquery-impact/raw/runtime/
```

Do not create unnecessary screenshots for every successful page.

---

## 21. Authentication

If admin credentials are available through environment variables, support authenticated scans.

Never commit credentials.

If authentication is unavailable:

```text
runtime_result = BLOCKED
notes = ADMIN_AUTH_NOT_AVAILABLE
```

Do not mark it PASS.

---

## 22. Runtime Coverage

Calculate:

```text
pages discovered
pages attempted
pages successfully loaded
pages blocked
pages failed
pages untested
```

Also calculate HIGH-risk and MEDIUM-risk pages tested versus discovered.

---

## 23. Required Summary

Print:

```text
Runtime pages discovered: X
Runtime pages attempted: X
PASS: X
WARNING: X
FAIL: X
BLOCKED: X
UNTESTED: X

JQMIGRATE warnings: X
JavaScript exceptions: X
Network failures: X
Duplicate jQuery pages: X
jQuery version mismatches: X

CRITICAL findings: X
HIGH findings: X
MEDIUM findings: X

Static findings confirmed at runtime: X
Static findings not observed at runtime: X
Unmapped runtime findings: X
```

---

## 24. Important Limitation

A successful page load does **not** mean the page is fully compatible.

Code triggered by click/change/submit/modal/slider/AJAX/pagination/checkout/filter belongs to a separate interaction scan.

Explicitly state this in the output.

---

## 25. Official References

Use relevant references:

```text
https://jquery.com/upgrade-guide/3.0/
https://jquery.com/upgrade-guide/3.5/
https://github.com/jquery/jquery-migrate/
https://blog.jquery.com/2016/06/09/jquery-3-0-final-released/
https://blog.jquery.com/2020/04/10/jquery-3-5-0-released/
https://blog.jquery.com/2020/05/04/jquery-3-5-1-released-fixing-a-regression/
```

---

## 26. Important Rules

Do not:

- fix source code;
- suppress Migrate warnings;
- ignore failed pages;
- classify environment failures as compatibility failures;
- claim page-load PASS means interaction PASS;
- claim 100% jQuery compatibility.

Only:

```text
LOAD
→ OBSERVE
→ CAPTURE
→ CORRELATE
→ CLASSIFY
→ REPORT
```

---

## 27. Completion Criteria

Verify:

- [ ] pages were loaded from `jquery-page-impact.csv`;
- [ ] runtime jQuery version was checked;
- [ ] duplicate jQuery assets were detected;
- [ ] JS assets were captured;
- [ ] console messages were captured;
- [ ] JQMIGRATE warnings were captured;
- [ ] page exceptions were captured;
- [ ] network failures were captured;
- [ ] runtime findings were mapped to static findings where possible;
- [ ] PASS pages were recorded;
- [ ] blocked pages were not counted as PASS;
- [ ] runtime coverage was calculated;
- [ ] HIGH/CRITICAL evidence was preserved;
- [ ] `jquery-runtime-errors.csv` was generated.

End with:

```text
STATUS: RUNTIME PAGE SCAN COMPLETE / INCOMPLETE

Pages tested: X / X
PASS: X
WARNING: X
FAIL: X
BLOCKED: X

Confirmed jQuery regressions: X
JQMIGRATE warnings: X
Unmapped runtime errors: X

IMPORTANT:
Initial page-load runtime testing is complete.
User interaction coverage is NOT yet complete.
```

Do not perform full interaction automation in this prompt.
