# jQuery 1.12.4 → 3.5.1 Controlled Patching Workflow

> **Goal:** Upgrade directly from jQuery `1.12.4` to `3.5.1`, keep the change scope minimal, fix only code that is broken or unsafe under jQuery `3.5.1`, and prove the result through traceable testing and security verification.
>
> **Strategy:** This is a **controlled direct patch**, not a full frontend modernization. The target is to achieve **100% control of the known scope**: every active jQuery source, known dependency, tested user flow, compatibility issue, security finding, and rollback decision must be documented.

---

## Documentation Location

```text
docs/
└── front-end/
    └── upgrades/
        └── jquery/
            ├── 1.12.4-to-3.5.1-migration-plan.md
            └── jquery-3.5.1-controlled-patching-workflow.md
```

---

## Table of Contents

- [Overview](#overview)
- [Target State](#target-state)
- [Workflow](#workflow)
- [Control Principles](#control-principles)
- [Step 01 — Identify the Active jQuery Root](#step-01--identify-the-active-jquery-root)
- [Step 02 — Inventory All jQuery Copies](#step-02--inventory-all-jquery-copies)
- [Step 03 — Map jQuery Dependencies](#step-03--map-jquery-dependencies)
- [Step 04 — Build the Test Baseline](#step-04--build-the-test-baseline)
- [Step 05 — Prepare Backup and Rollback](#step-05--prepare-backup-and-rollback)
- [Step 06 — Upgrade Active jQuery to 3.5.1](#step-06--upgrade-active-jquery-to-351)
- [Step 07 — Detect Compatibility Issues](#step-07--detect-compatibility-issues)
- [Step 08 — Fix Only Broken or Unsafe Code](#step-08--fix-only-broken-or-unsafe-code)
- [Step 09 — Regression Testing](#step-09--regression-testing)
- [Step 10 — Security Verification](#step-10--security-verification)
- [Step 11 — GO / NO-GO Release Gate](#step-11--go--no-go-release-gate)
- [Step 12 — Production Verification](#step-12--production-verification)
- [Issue Handling Loop](#issue-handling-loop)
- [Traceability Matrix](#traceability-matrix)
- [Required Deliverables](#required-deliverables)
- [Definition of Done](#definition-of-done)
- [Residual Risk](#residual-risk)
- [References](#references)

---

# Overview

## Objective

Move directly from:

```text
jQuery 1.12.4
      ↓
jQuery 3.5.1
```

without introducing unrelated frontend changes.

The workflow is intentionally optimized for the following requirement:

> **Apply jQuery 3.5.1 first, identify actual compatibility failures, and fix only the affected code.**

This differs from a staged migration through every jQuery minor version. Intermediate versions may still be useful for investigation, but they are not deployment checkpoints in this workflow.

## High-Level Flow

```text
01. Identify Active jQuery Root
        ↓
02. Inventory All jQuery Copies
        ↓
03. Map jQuery Dependencies
        ↓
04. Build Test Baseline
        ↓
05. Prepare Backup & Rollback
        ↓
06. Upgrade → jQuery 3.5.1
        ↓
07. Detect Compatibility Issues
        ↓
08. Fix Only Broken / Unsafe Code
        ↓
09. Regression Test
        ↓
10. Verify Security
        ↓
11. GO / NO-GO Gate
        ↓
12. Production Verification
        ↓
DONE
```

---

# Target State

The final target must satisfy all of the following:

```text
Runtime jQuery = 3.5.1
No active legacy jQuery copy
No unexplained critical console error
No broken critical user flow
No unresolved jQuery compatibility blocker
Target CVEs no longer reported against the active jQuery runtime
Rollback path documented and tested
Production behavior matches the approved baseline
```

## Target Security Findings

The upgrade specifically addresses the jQuery-version exposure associated with:

| CVE | Category | Expected state on jQuery 3.5.1 |
|---|---|---|
| CVE-2015-9251 | Cross-domain Ajax / XSS-related behavior | Resolved by version |
| CVE-2019-11358 | Prototype Pollution | Resolved by version |
| CVE-2020-11022 | DOM manipulation / XSS | Resolved by version |
| CVE-2020-11023 | DOM manipulation / XSS | Resolved by version |

> Reaching jQuery `3.5.1` removes these vulnerabilities from the jQuery version itself. It does **not** prove that the entire application is free from application-level XSS or unsafe third-party code.

---

# Workflow

## Workflow Control Model

Each step has four parts:

```text
INPUT
  ↓
ACTION
  ↓
EVIDENCE
  ↓
EXIT GATE
```

A step is not complete just because the action was performed. It is complete only when evidence exists and the exit gate passes.

## Status Model

Use one of the following statuses:

| Status | Meaning |
|---|---|
| `PENDING` | Not started |
| `IN_PROGRESS` | Work started |
| `PASS` | Exit gate satisfied |
| `BLOCKED` | Cannot continue until issue is resolved |
| `FAIL` | Validation failed |
| `N/A` | Confirmed not applicable with reason |

---

# Control Principles

## Rule 1 — Keep the scope minimal

Allowed:

```text
jQuery 1.12.4 → 3.5.1
Compatibility fixes required by that change
Security fixes related to the discovered jQuery usage
Tests and diagnostics required to verify the patch
```

Not allowed in the same patch unless required to restore behavior:

```text
Frontend redesign
JavaScript framework migration
Large refactors
Unrelated CSS changes
Business-logic changes
Plugin replacement without evidence
General code cleanup
```

## Rule 2 — Fix by evidence

```text
No failure
    ↓
Do not change the code

Warning only
    ↓
Review and classify

Actual broken behavior
    ↓
Fix minimally

Security-sensitive unsafe pattern
    ↓
Fix even if the UI still appears to work
```

## Rule 3 — Every critical change must be reversible

Every change must be linked to a commit, patch, or equivalent rollback point.

## Rule 4 — Do not trust repository search alone

A file can exist without being loaded, and a CDN asset can be loaded without existing in the repository.

Always verify the runtime through browser DevTools or automated browser inspection.

---

# Step 01 — Identify the Active jQuery Root

## Objective

Determine exactly which jQuery asset is being executed by the browser before touching any code.

## Actions

### Check the runtime version

Browser console:

```javascript
jQuery.fn.jquery
```

Expected baseline example:

```text
"1.12.4"
```

### Inspect browser-loaded assets

Check:

```text
DevTools
├── Network
├── Sources
└── Initiator / Request chain
```

Record:

- loaded jQuery URL;
- local file or CDN;
- version;
- owner/template/component;
- load order;
- whether multiple copies are loaded.

## Evidence

| Field | Value |
|---|---|
| Runtime version | |
| Runtime URL/path | |
| Asset owner | |
| Loaded from | Local / CDN / Bundle |
| Multiple jQuery versions | Yes / No |
| Verified pages | |

## Exit Gate

- [ ] Runtime jQuery version is known.
- [ ] Runtime jQuery source is known.
- [ ] Asset ownership is known.
- [ ] Duplicate runtime loads are documented.

---

# Step 02 — Inventory All jQuery Copies

## Objective

Find all jQuery copies that may affect the application, including inactive or conditionally loaded copies.

## Repository Search

```bash
find . \
  \( -iname "jquery.js" \
  -o -iname "jquery.min.js" \
  -o -iname "jquery-*.js" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*"
```

Search embedded version headers:

```bash
grep -RIn "jQuery v" . \
  --include="jquery*.js" \
  --exclude-dir=node_modules \
  --exclude-dir=.git
```

Search CDN references:

```bash
grep -RInE "jquery[^\"']*\.js|code\.jquery\.com|ajax\.googleapis\.com.*jquery" . \
  --include="*.php" \
  --include="*.html" \
  --include="*.js" \
  --include="*.xml" \
  --exclude-dir=node_modules \
  --exclude-dir=.git
```

## Inventory Table

| ID | Asset | Owner | Version | Runtime? | Conditional? | Action |
|---:|---|---|---:|---|---|---|
| JQ-001 | | | | | | |
| JQ-002 | | | | | | |

Recommended actions:

```text
UPGRADE
REMOVE_DUPLICATE
KEEP_INACTIVE
INVESTIGATE
N/A
```

## Exit Gate

- [ ] All repository jQuery copies are inventoried.
- [ ] All known CDN copies are inventoried.
- [ ] Each copy has an owner.
- [ ] Each copy has a disposition.
- [ ] No unexplained active copy remains.

---

# Step 03 — Map jQuery Dependencies

## Objective

Identify code that depends on jQuery behavior before the runtime version changes.

## Dependency Scope

Review in this order:

```text
1. Custom application JavaScript
2. Template JavaScript
3. Custom components
4. Custom modules
5. Custom plugins
6. Third-party extensions
7. Vendor/minified libraries
```

## Dependency Table

| ID | Owner | File/Asset | jQuery dependency | Criticality | Test coverage |
|---:|---|---|---|---|---|
| DEP-001 | | | | High / Medium / Low | |

## Recommended Static Searches

### Ajax callbacks

```bash
rg '\.(success|error|complete)\s*\(' .
```

### Removed/deprecated APIs

```bash
rg '\.size\s*\(' .
rg '\.andSelf\s*\(' .
rg '\.(bind|unbind|delegate|undelegate)\s*\(' .
rg '\.(load|unload|error)\s*\(' .
```

### DOM/HTML manipulation

```bash
rg '\.(html|append|prepend|before|after)\s*\(' .
```

### Deep merge / Prototype Pollution review

```bash
rg '\$\.extend\s*\(\s*true' .
rg 'jQuery\.extend\s*\(\s*true' .
```

> Static search creates a review list. It does not automatically mean every match needs a code change.

## Exit Gate

- [ ] Critical jQuery-dependent code is mapped.
- [ ] Critical user flows have dependency coverage.
- [ ] High-risk API patterns are recorded.
- [ ] Third-party dependencies are classified.

---

# Step 04 — Build the Test Baseline

## Objective

Prove what currently works under jQuery `1.12.4` before upgrading.

## Baseline Rules

Do not compare jQuery `3.5.1` against assumptions. Compare it against an explicit `1.12.4` baseline.

## Critical Page Inventory

| Page ID | Page/Route | Main components | Criticality | Baseline |
|---:|---|---|---|---|
| PAGE-001 | Home | | High | PASS / FAIL |
| PAGE-002 | | | | |

## Functional Checklist

### Global

- [ ] Page loads successfully.
- [ ] Header works.
- [ ] Main navigation works.
- [ ] Mobile navigation works.
- [ ] Footer works.
- [ ] Search works.

### UI Components

- [ ] Dropdowns.
- [ ] Sliders/carousels.
- [ ] Tabs.
- [ ] Accordions.
- [ ] Modals.
- [ ] Tooltips.
- [ ] Date/time pickers.

### Forms

- [ ] Validation.
- [ ] Submit.
- [ ] AJAX submit.
- [ ] Select controls.
- [ ] Checkbox/radio controls.
- [ ] Uploads.

### Data / Interaction

- [ ] AJAX requests return expected data.
- [ ] Pagination works.
- [ ] Filters work.
- [ ] Sorting works.
- [ ] Dynamic content insertion works.

### Browser Diagnostics

- [ ] Existing console errors captured.
- [ ] Existing console warnings captured.
- [ ] Failed network requests captured.
- [ ] Runtime jQuery version captured.

## Baseline Evidence

Recommended evidence:

```text
Screenshots
Console log
Network log
Automated test output
Page checklist
Known defects list
```

## Exit Gate

- [ ] All critical pages are listed.
- [ ] All critical flows have test cases.
- [ ] Existing defects are documented.
- [ ] Baseline result is reproducible.

---

# Step 05 — Prepare Backup and Rollback

## Objective

Make the patch reversible before changing the active jQuery runtime.

## Required Preparation

- [ ] Create a dedicated upgrade branch.
- [ ] Record the pre-upgrade commit SHA.
- [ ] Create a Git tag or equivalent stable reference if appropriate.
- [ ] Preserve original jQuery asset/configuration.
- [ ] Document deployment rollback commands.
- [ ] Document cache/CDN rollback steps.
- [ ] Verify that rollback does not depend on undocumented manual changes.

Example:

```bash
git checkout -b upgrade/jquery-3.5.1

git tag jquery-before-3.5.1
```

## Rollback Trigger

Rollback immediately when a production-critical flow fails and a safe minimal fix is not available inside the approved release window.

## Exit Gate

- [ ] Rollback reference exists.
- [ ] Rollback steps are documented.
- [ ] Asset/cache rollback is understood.
- [ ] Team can restore the previous jQuery runtime deterministically.

---

# Step 06 — Upgrade Active jQuery to 3.5.1

## Objective

Change only the active jQuery runtime to `3.5.1` before making compatibility fixes.

## Actions

- [ ] Replace/update only the approved active jQuery source.
- [ ] Do not simultaneously refactor unrelated JavaScript.
- [ ] Preserve asset load order.
- [ ] Clear relevant application/browser/CDN caches.
- [ ] Verify runtime version.

Browser console:

```javascript
jQuery.fn.jquery
```

Required result:

```text
"3.5.1"
```

## jQuery Migrate Diagnostic Mode

When compatibility issues need to be discovered, load jQuery Migrate after jQuery and before dependent plugins/application code:

```text
jquery-3.5.1.js
        ↓
jquery-migrate-3.x.js
        ↓
plugins
        ↓
application JavaScript
```

Use Migrate as a temporary diagnostic/compatibility tool, not as proof that the migration is complete.

## Exit Gate

- [ ] Runtime version is exactly `3.5.1`.
- [ ] Only approved jQuery roots were changed.
- [ ] Page bootstrapping still completes.
- [ ] No duplicate legacy jQuery overrides the new runtime.

---

# Step 07 — Detect Compatibility Issues

## Objective

Build a complete issue list after the direct version jump.

## Detection Sources

```text
Browser console
jQuery Migrate warnings
Network failures
Automated test failures
Manual UI failures
Static scan findings
Third-party plugin failures
```

## Issue Register

| Issue ID | Page | Owner | File | Symptom | Source | Severity | Status |
|---:|---|---|---|---|---|---|---|
| JQ-ISSUE-001 | | | | | Console / Migrate / Test | | |

## Severity

| Severity | Definition |
|---|---|
| Critical | Blocks production-critical workflow or causes security exposure |
| High | Major function broken with no acceptable workaround |
| Medium | Limited feature broken or degraded |
| Low | Non-blocking warning or minor behavior difference |

## Exit Gate

- [ ] All critical pages have been traversed at least once under `3.5.1`.
- [ ] Console/Migrate warnings are captured.
- [ ] Test failures are mapped to issue IDs.
- [ ] Every issue has an owner/file or an investigation note.

---

# Step 08 — Fix Only Broken or Unsafe Code

## Objective

Apply the smallest compatible change required to restore expected behavior or remove a confirmed security-sensitive pattern.

## Minimal-Fix Rule

### Do not change working code just to modernize syntax

Example:

```javascript
$("#button").click(function () {
    // existing behavior
});
```

If it works correctly under jQuery `3.5.1`, leave it unchanged for this patch.

### Fix removed Ajax callbacks when they fail

Before:

```javascript
$.ajax("/api")
    .success(onSuccess)
    .error(onError)
    .complete(onComplete);
```

After:

```javascript
$.ajax("/api")
    .done(onSuccess)
    .fail(onError)
    .always(onComplete);
```

### Review unsafe HTML handling

Review code such as:

```javascript
$("#result").html(response);
```

Questions:

```text
Where does response come from?
Can the value contain user-controlled HTML?
Is HTML insertion required?
Can text() be used instead?
Is server-side sanitization guaranteed?
```

### Do not restore insecure legacy htmlPrefilter behavior

jQuery `3.5.x` intentionally changed HTML handling behavior as part of the security fixes. Avoid compatibility workarounds that simply restore the vulnerable behavior.

## Fix Record

For every change record:

| Field | Value |
|---|---|
| Issue ID | |
| Page/flow | |
| Owner | |
| File | |
| Old behavior | |
| Root cause | |
| Minimal fix | |
| Test case | |
| Result | |
| Commit | |

## Exit Gate

- [ ] Every Critical/High issue is resolved or explicitly blocks release.
- [ ] Every fix maps to a discovered issue.
- [ ] No unrelated refactor is mixed into the patch.
- [ ] Security-sensitive findings are resolved or formally documented.

---

# Step 09 — Regression Testing

## Objective

Re-run the approved baseline against jQuery `3.5.1` after fixes.

## Required Sequence

```text
Baseline checklist
      ↓
Critical pages
      ↓
Critical components
      ↓
AJAX/forms
      ↓
Third-party extensions
      ↓
Console/network review
      ↓
Cross-page regression
```

## Result Matrix

| Test ID | Page/Flow | Baseline 1.12.4 | 3.5.1 | Result | Issue |
|---:|---|---|---|---|---|
| TEST-001 | | PASS | PASS | PASS | — |

## Mandatory Checks

- [ ] No new unexplained JavaScript error.
- [ ] No new failed critical network request.
- [ ] All baseline Critical tests PASS.
- [ ] All fixed issues have regression coverage.
- [ ] No page unexpectedly loads a legacy jQuery copy.

## Exit Gate

```text
Critical tests = 100% PASS
High-priority tests = PASS or formally accepted
No unresolved new blocker
```

---

# Step 10 — Security Verification

## Objective

Prove that the target jQuery security findings are removed from the active runtime and that no old active copy reintroduces them.

## Runtime Verification

```javascript
jQuery.fn.jquery
```

Required:

```text
3.5.1
```

## Asset Verification

Repeat inventory/runtime checks and confirm:

- [ ] No active `1.12.4` runtime.
- [ ] No template re-injects old jQuery.
- [ ] No extension conditionally injects old jQuery on untested critical pages.
- [ ] No stale CDN/cache response serves old jQuery.

## Security Scan

Re-run the same scanner that reported the original findings where possible.

Expected target result:

| CVE | Expected |
|---|---|
| CVE-2015-9251 | PASS / Not detected |
| CVE-2019-11358 | PASS / Not detected |
| CVE-2020-11022 | PASS / Not detected |
| CVE-2020-11023 | PASS / Not detected |

## Important Distinction

```text
Version security verification
        ≠
Full application security audit
```

The workflow verifies the known jQuery patch scope. Application-level XSS and unrelated dependencies remain separate concerns.

## Exit Gate

- [ ] Runtime is `3.5.1`.
- [ ] No active vulnerable jQuery copy is known.
- [ ] Original jQuery CVEs are no longer reported against the active runtime.
- [ ] Any remaining scanner finding has documented evidence and disposition.

---

# Step 11 — GO / NO-GO Release Gate

## Objective

Prevent deployment based on subjective confidence.

## GO Criteria

Release only when all mandatory criteria pass:

- [ ] Active runtime jQuery is `3.5.1`.
- [ ] jQuery inventory is complete for known project scope.
- [ ] Dependency map covers all critical flows.
- [ ] Baseline is documented.
- [ ] Rollback path is verified.
- [ ] No unresolved Critical compatibility issue.
- [ ] No unexplained critical console error.
- [ ] No failed critical AJAX/network request.
- [ ] Critical regression tests are 100% PASS.
- [ ] Original jQuery CVEs are no longer reported against the active runtime.
- [ ] Production verification checklist is ready.

## NO-GO Conditions

Do not release when any of the following is true:

```text
Unknown active jQuery source
Unknown duplicate jQuery load
Critical page not tested
Critical regression failure
Critical extension failure
Security scanner still identifies the active vulnerable jQuery version
Rollback path is not available
```

## Gate Record

```text
Decision: GO / NO-GO
Date:
Commit:
Reviewer:
Outstanding Medium/Low issues:
Accepted residual risk:
Rollback reference:
```

---

# Step 12 — Production Verification

## Objective

Verify that deployment infrastructure, cache, CDN, and production configuration did not change the approved result.

## Production Smoke Test

- [ ] Verify `jQuery.fn.jquery === "3.5.1"`.
- [ ] Verify actual jQuery network URL.
- [ ] Verify cache/CDN serves the new asset.
- [ ] Test homepage.
- [ ] Test navigation.
- [ ] Test critical forms.
- [ ] Test critical AJAX actions.
- [ ] Test critical third-party extension flows.
- [ ] Review console errors.
- [ ] Review failed network requests.

## Post-Deploy Security Check

Where operationally feasible:

- [ ] Re-run external/internal security scan.
- [ ] Confirm old jQuery fingerprint is not exposed on production pages.

## Rollback Decision

```text
Production PASS
      ↓
Keep release

Production Critical FAIL
      ↓
Can minimal safe fix be applied immediately?
      ├── Yes → fix + retest
      └── No  → rollback
```

## Exit Gate

- [ ] Production runtime confirmed.
- [ ] Production critical smoke tests PASS.
- [ ] No deployment/cache regression.
- [ ] Security verification remains PASS.

---

# Issue Handling Loop

Use the same loop for every detected failure:

```text
Detect failure
    ↓
Assign Issue ID
    ↓
Identify page / owner / file
    ↓
Reproduce under 3.5.1
    ↓
Confirm whether it existed under 1.12.4
    ↓
Find root cause
    ↓
Apply minimal fix
    ↓
Run focused test
    ↓
Run related regression tests
    ↓
Close issue with evidence
```

## Root-Cause Classification

Use one of:

```text
REMOVED_JQUERY_API
CHANGED_JQUERY_BEHAVIOR
HTML_PARSING_CHANGE
AJAX_CALLBACK_CHANGE
THIRD_PARTY_PLUGIN_INCOMPATIBILITY
DUPLICATE_JQUERY_LOAD
LOAD_ORDER_ISSUE
CACHE_OR_CDN
APPLICATION_BUG_PREEXISTING
SECURITY_SENSITIVE_CODE
OTHER
```

---

# Traceability Matrix

The workflow should make every release decision traceable.

| Artifact | Must map to |
|---|---|
| jQuery asset | Asset owner + runtime page |
| Dependency | File/extension + test case |
| Test case | Page/flow + expected behavior |
| Issue | Test failure/warning + owner/file |
| Fix | Issue ID + test case + commit |
| Security finding | CVE + runtime asset + scan result |
| Release decision | Test evidence + security evidence + rollback reference |

## Traceability Chain

```text
jQuery Root
   ↓
Dependency
   ↓
Page / User Flow
   ↓
Test Case
   ↓
Issue (if any)
   ↓
Fix
   ↓
Regression Result
   ↓
Security Result
   ↓
Release Decision
```

---

# Required Deliverables

Recommended repository structure:

```text
docs/front-end/upgrades/jquery/
├── 1.12.4-to-3.5.1-migration-plan.md
├── jquery-3.5.1-controlled-patching-workflow.md
└── evidence/
    ├── jquery-inventory.md
    ├── jquery-dependency-map.md
    ├── baseline-test-checklist.md
    ├── compatibility-issues.md
    ├── regression-results.md
    ├── security-verification.md
    └── release-gate.md
```

> The `evidence/` files are recommended working artifacts. Create them only when the workflow is executed; they do not need to exist just to define the workflow.

---

# Definition of Done

The jQuery `3.5.1` patch is complete only when:

- [ ] The active original jQuery root was identified.
- [ ] All known jQuery copies were inventoried.
- [ ] Critical jQuery dependencies were mapped.
- [ ] A reproducible `1.12.4` baseline exists.
- [ ] Rollback was prepared before the upgrade.
- [ ] The active runtime was upgraded to `3.5.1`.
- [ ] Compatibility issues were discovered systematically.
- [ ] Only broken or unsafe code was changed.
- [ ] Critical regression tests are 100% PASS.
- [ ] No unexplained critical JavaScript/network error remains.
- [ ] No known active vulnerable jQuery copy remains.
- [ ] The original jQuery CVEs are no longer reported against the active runtime.
- [ ] The GO / NO-GO gate is documented.
- [ ] Production runtime and critical flows are verified after deployment.

---

# Residual Risk

It is not technically correct to claim that any finite test workflow controls an unknown legacy frontend with absolute `100%` certainty.

The realistic target is:

> **100% known-scope control + documented residual risk.**

This means:

```text
Every known jQuery root → accounted for
Every known critical dependency → mapped
Every critical flow → tested
Every discovered compatibility issue → dispositioned
Every code fix → traceable
Every target CVE → verified
Every release decision → evidence-backed
Unknown/uncovered areas → explicitly documented as residual risk
```

This is the appropriate control standard for a minimal-change security patch.

---

# References

## Official jQuery Documentation

- jQuery Upgrade Guide 3.0  
  https://jquery.com/upgrade-guide/3.0/

- jQuery Upgrade Guide 3.5  
  https://jquery.com/upgrade-guide/3.5/

- jQuery 3.5.0 release — security fixes  
  https://blog.jquery.com/2020/04/10/jquery-3-5-0-released/

- jQuery 3.5.1 release — regression fix  
  https://blog.jquery.com/2020/05/04/jquery-3-5-1-released-fixing-a-regression/

- jQuery Migrate project  
  https://github.com/jquery/jquery-migrate

## NVD Security References

- CVE-2015-9251  
  https://nvd.nist.gov/vuln/detail/CVE-2015-9251

- CVE-2019-11358  
  https://nvd.nist.gov/vuln/detail/CVE-2019-11358

- CVE-2020-11022  
  https://nvd.nist.gov/vuln/detail/CVE-2020-11022

- CVE-2020-11023  
  https://nvd.nist.gov/vuln/detail/CVE-2020-11023

---

## Final Workflow Summary

```text
DISCOVER
├── Identify active jQuery root
├── Inventory all jQuery copies
└── Map dependencies

BASELINE
├── Build page/flow test coverage
└── Capture existing errors

CONTROL
├── Prepare backup
└── Prepare rollback

PATCH
└── Upgrade active runtime directly to 3.5.1

DIAGNOSE
├── jQuery Migrate
├── Console/network
├── Static scan
└── Functional traversal

FIX
└── Change only broken or unsafe code

VERIFY
├── Regression testing
└── Security verification

RELEASE
└── GO / NO-GO gate

PRODUCTION
├── Runtime verification
├── Critical smoke tests
└── Security re-check
```
