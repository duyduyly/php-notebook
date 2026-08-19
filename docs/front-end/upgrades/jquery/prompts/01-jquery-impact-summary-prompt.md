# Claude Code Prompt 1 — jquery-impact-summary.md

## Task

Analyze the current **Joomla 3.4.6** project before upgrading:

```text
media/jui/js/jquery.js

jQuery 1.11.3
      ↓
jQuery 3.5.1
```

Do **not upgrade or modify jQuery yet**.

Generate:

```text
reports/jquery-impact/jquery-impact-summary.md
```

The purpose of this phase is discovery and baseline inventory only.

---

## 1. Verify Environment

Detect and record:

- Joomla version
- PHP version
- current Git commit and branch
- project root
- active frontend template
- database prefix if available
- Node.js version
- Playwright availability
- `ripgrep` availability

Verify:

```text
media/jui/js/jquery.js
```

and confirm its real jQuery version from the file header.

---

## 2. Inventory All jQuery Assets

Search the entire project for:

```text
jquery.js
jquery.min.js
jquery-*.js
jquery-migrate*
jquery-ui*
```

Include at least:

```text
components/
administrator/components/
modules/
plugins/
templates/
administrator/templates/
media/
libraries/
```

Do not scan only Joomla core.

For every jQuery copy determine:

```text
path
version
owner
core / third-party / custom
minified
potentially loaded
```

Highlight duplicate or old jQuery versions.

---

## 3. Find jQuery Loaders

Search PHP/template files for:

```php
JHtml::_('jquery.framework');
JHtml::_('bootstrap.framework');
addScript(...)
```

Also search references to:

```text
media/jui/js/jquery
jquery.js
jquery.min.js
code.jquery.com
cdnjs
ajax.googleapis.com
```

Identify which Joomla component/module/plugin/template owns each loader.

---

## 4. Joomla Extension Inventory

Inspect Joomla extension information where possible.

Cover:

```text
components
modules
plugins
templates
libraries
packages
```

Use Joomla DB tables such as:

```text
#__extensions
#__modules
#__menu
#__modules_menu
#__template_styles
```

Do not modify database data.

---

## 5. Create Initial Risk Summary

Classify discovered areas using:

```text
CRITICAL
HIGH
MEDIUM
LOW
INFO
```

At this stage distinguish:

```text
Potential Impact
Confirmed Impact
Unknown / Not Tested
```

Do not claim static findings are confirmed runtime failures.

---

## 6. Required Output

Generate:

```text
reports/jquery-impact/jquery-impact-summary.md
```

Use this structure:

```markdown
# jQuery 1.11.3 → 3.5.1 Impact Summary

## 1. Executive Summary
## 2. Environment
## 3. Current jQuery State
## 4. jQuery Asset Inventory
## 5. Duplicate jQuery Versions
## 6. jQuery Loader Inventory
## 7. Joomla Extension Inventory
## 8. Initial Impact Areas
## 9. Risk Summary
## 10. Coverage Status
## 11. Unknown / Not Yet Tested
## 12. Next Scan
```

### jQuery Assets

| Path | Version | Owner | Type | Loaded? | Risk |
|---|---:|---|---|---|---|

### Loader Usage

| File | Line | Extension | Loader | Asset | Risk |
|---|---:|---|---|---|---|

### Extension Summary

| Extension | Type | Enabled | jQuery Files | Loader Usage | Initial Risk |
|---|---|---|---:|---:|---|

### Risk Summary

| Risk | Count | Meaning |
|---|---:|---|
| CRITICAL | | |
| HIGH | | |
| MEDIUM | | |
| LOW | | |
| INFO | | |

---

## 7. Important Rules

Do not:

- replace `jquery.js`;
- modify Joomla source;
- fix deprecated code;
- delete duplicate jQuery;
- claim runtime compatibility;
- claim 100% coverage.

Only:

```text
DISCOVER
→ INVENTORY
→ CLASSIFY
→ REPORT
```

Every finding must contain evidence such as:

```text
file path
line number
jQuery version
extension owner
reason for risk
```

---

## 8. Completion Criteria

Before finishing verify that:

- [ ] Joomla version was confirmed.
- [ ] `media/jui/js/jquery.js` was inspected.
- [ ] jQuery `1.11.3` was confirmed or discrepancy documented.
- [ ] all jQuery files were searched.
- [ ] duplicate versions were identified.
- [ ] jQuery loaders were searched.
- [ ] Joomla extensions were inventoried.
- [ ] initial risks were classified.
- [ ] unknown areas were explicitly listed.
- [ ] `jquery-impact-summary.md` was generated.

End with:

```text
STATUS: DISCOVERY COMPLETE / INCOMPLETE

Files requiring deeper static compatibility analysis: X
Extensions potentially affected: X
Duplicate jQuery copies: X
Unknown areas: X
```

Do not proceed to fixing anything.
