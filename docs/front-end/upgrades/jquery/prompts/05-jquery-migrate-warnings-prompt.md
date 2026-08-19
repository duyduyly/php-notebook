# Claude Code Prompt 5 — jquery-migrate-warnings.csv

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
```

Generate:

```text
reports/jquery-impact/jquery-migrate-warnings.csv
```

The goal is to capture, normalize, deduplicate, classify, and trace every **jQuery Migrate warning** produced when the application runs with:

```text
jQuery 3.5.1
+
jQuery Migrate 3.x development build
```

Do not fix application code in this task.

---

## 1. Main Goal

Build this traceability chain:

```text
JQMIGRATE warning
      ↓
Page / Route
      ↓
Source file + line
      ↓
Joomla extension
      ↓
Static finding
      ↓
Compatibility GAP
      ↓
Recommended fix
```

Every warning must be treated as evidence of legacy compatibility behavior, not automatically as a runtime failure.

---

## 2. Use jQuery Migrate as Diagnostic Only

Load:

```text
jQuery 3.5.1
jQuery Migrate 3.x development build
```

Capture messages containing:

```text
JQMIGRATE:
```

Do not suppress or clear warnings before recording them.

---

## 3. Input Pages

Use routes from:

```text
reports/jquery-impact/jquery-page-impact.csv
```

and runtime-tested pages from:

```text
reports/jquery-impact/jquery-runtime-errors.csv
```

Attempt all testable frontend, administrator, authenticated, third-party, and custom component pages.

---

## 4. Capture Warning Evidence

For every warning collect:

```text
warning text
page URL
page ID
timestamp
console type
stack trace
source file
line
column
jQuery version
jQuery Migrate version
```

If the browser provides a stack trace, preserve it.

Do not invent source mappings.

---

## 5. Normalize Warning Messages

Equivalent warnings should share the same normalized warning code.

Example:

```text
JQMIGRATE: jQuery.fn.size() is deprecated and removed
```

Normalize to something like:

```text
JQM-SIZE-REMOVED
```

Possible categories:

```text
JQM-SIZE-REMOVED
JQM-ANDSELF
JQM-EVENT-SHORTHAND
JQM-READY-EVENT
JQM-DEFERRED
JQM-DATA
JQM-SELECTOR
JQM-HTML
JQM-AJAX
JQM-PRIVATE-API
JQM-OTHER
```

Do not create multiple codes for the same root warning.

---

## 6. Deduplicate Correctly

Do not lose frequency information.

If the same warning occurs 50 times on the same page/file, store one normalized finding plus:

```text
occurrence_count = 50
```

Keep separate rows when the same warning comes from different source files, lines, extensions, pages, or code paths.

---

## 7. Map to Source File

Attempt mapping using:

```text
stack trace
console location
loaded JS assets
jquery-file-impact.csv
```

Required output where possible:

```text
source_file
line_number
column_number
static_finding_id
```

If unresolved:

```text
source_file = UNKNOWN_SOURCE
```

Do not guess.

---

## 8. Map to Joomla Extension

Determine ownership from path.

Examples:

```text
components/com_cars/    → com_cars
modules/mod_slider/     → mod_slider
plugins/system/foo/     → system/foo
templates/foo/          → template foo
media/com_hikashop/     → com_hikashop
```

Classify:

```text
JOOMLA_CORE
THIRD_PARTY
CUSTOM
UNKNOWN
```

---

## 9. Map to Compatibility GAP

For each warning identify the relevant jQuery migration gap, such as:

```text
Removed API
Deprecated API
Event behavior
Deferred / Promise behavior
Selector behavior
DOM / HTML compatibility
Data API behavior
AJAX behavior
Private/internal API
```

Reference official jQuery migration documentation.

---

## 10. Severity

Use:

```text
HIGH
MEDIUM
LOW
INFO
```

Normally do not assign CRITICAL based only on a Migrate warning.

### HIGH

Use for removed API, legacy behavior required for active code, private API, or critical page dependency.

### MEDIUM

Use for deprecated API, behavior-sensitive compatibility issue, or plugin compatibility concern.

### LOW

Use for low-risk legacy usage that still works.

### INFO

Use for diagnostic-only warnings with no compatibility consequence identified.

---

## 11. Runtime Importance

Separate severity from runtime importance.

Use:

```text
CRITICAL_FLOW
NORMAL_FLOW
LOW_USAGE
UNKNOWN
```

Example:

```text
checkout page + removed API warning → CRITICAL_FLOW
unused admin demo page            → LOW_USAGE
```

---

## 12. Resolution Status

Use:

```text
OPEN
ACCEPTED_TEMPORARILY
FALSE_POSITIVE
FIXED
UNRESOLVED_SOURCE
```

For this task findings normally start as `OPEN`.

Do not mark FIXED unless evidence already proves it.

---

## 13. Required CSV

Generate:

```text
reports/jquery-impact/jquery-migrate-warnings.csv
```

Required columns:

```text
warning_id
normalized_warning_code
warning_message
page_id
url
frontend_or_admin
component
view
layout
extension_name
owner_classification
source_file
line_number
column_number
stack_trace
static_finding_id
runtime_finding_id
jquery_version
jquery_migrate_version
occurrence_count
gap_category
severity
runtime_importance
confidence
official_reference
recommended_action
status
first_seen
last_seen
notes
```

---

## 14. Correlate With Runtime Errors

Use:

```text
jquery-runtime-errors.csv
```

If a Migrate warning and runtime exception relate to the same page/file/line/API, record the linked runtime finding ID.

This distinguishes:

```text
warning only
```

from:

```text
warning + actual regression
```

---

## 15. Coverage

Calculate:

```text
pages with Migrate enabled
/
runtime-testable pages
```

Also report:

```text
pages with warnings
unique warning types
total warning occurrences
warnings mapped to source
warnings with unknown source
warnings mapped to static findings
warnings linked to runtime errors
```

---

## 16. Required Terminal Summary

Print:

```text
Pages scanned with jQuery Migrate: X / X
Pages with warnings: X

Unique warning types: X
Total warning occurrences: X

HIGH warnings: X
MEDIUM warnings: X
LOW warnings: X

Warnings mapped to source: X
Warnings with UNKNOWN_SOURCE: X
Warnings mapped to static findings: X
Warnings linked to runtime errors: X
```

---

## 17. Important Rules

Do not:

- modify application code;
- remove deprecated APIs;
- suppress warnings;
- classify every warning as runtime failure;
- discard duplicate occurrence counts;
- guess source file mappings;
- use jQuery Migrate as permanent production remediation.

Only:

```text
CAPTURE
→ NORMALIZE
→ DEDUPLICATE
→ MAP
→ CLASSIFY
→ REPORT
```

---

## 18. Official References

Use relevant URLs:

```text
https://github.com/jquery/jquery-migrate/
https://jquery.com/upgrade-guide/
https://jquery.com/upgrade-guide/3.0/
https://jquery.com/upgrade-guide/3.5/
```

Where possible map a warning to the most specific official documentation section.

---

## 19. Completion Criteria

Verify:

- [ ] jQuery `3.5.1` was confirmed at runtime.
- [ ] jQuery Migrate 3.x development build was confirmed.
- [ ] all runtime-testable pages were attempted.
- [ ] every `JQMIGRATE:` warning was captured.
- [ ] duplicate occurrences were counted correctly.
- [ ] warnings were normalized.
- [ ] source files were mapped where possible.
- [ ] Joomla extension ownership was mapped.
- [ ] static finding IDs were linked where possible.
- [ ] runtime error IDs were linked where possible.
- [ ] unknown-source warnings were retained.
- [ ] severity was assigned.
- [ ] official references were added.
- [ ] coverage was calculated.
- [ ] `jquery-migrate-warnings.csv` was generated.

End with:

```text
STATUS: JQUERY MIGRATE WARNING SCAN COMPLETE / INCOMPLETE

Pages scanned: X / X
Unique warnings: X
Total occurrences: X

HIGH: X
MEDIUM: X

Mapped to source: X
Unknown source: X

Warnings linked to confirmed runtime regressions: X
```

Do not fix the warnings in this prompt.
