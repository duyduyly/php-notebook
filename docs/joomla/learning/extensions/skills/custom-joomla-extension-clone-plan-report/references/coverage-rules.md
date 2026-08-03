# Clone Coverage Rules

Use separate coverage categories. Never hide an incomplete critical area inside one combined percentage.

## Required categories

| Category | Calculation or decision | PASS target |
|---|---|---:|
| Source files | Matching required files / total required files | 100% |
| Structure | Complete required structure items / total required items | 100% |
| Manifest | Passed applicable manifest checks / applicable checks | 100% |
| Database schema | Recreated required schema objects / total required objects | 100% |
| Logic preservation | Unchanged required logic files with matching checksums / total unchanged required logic files | 100% |
| Discover readiness | Result of Discover requirements checklist | Ready |
| Blocking dependencies | Unresolved required dependencies | 0 |

## File-count rules

A matching file count is supporting evidence, not proof of completeness.

A file is counted as successfully cloned only when:

- Its expected relative path exists in the target.
- Filename and directory case match.
- Its checksum matches the source, unless an approved compatibility change is documented.
- It is not an accidental generated runtime file.

Report at least:

```text
Original files
Required files
Cloned files
Missing files
Unexpected files
Unexpectedly modified files
Approved compatibility changes
```

## Status decisions

### PASS

Use only when all required category targets pass.

```text
Source files = 100%
Structure = 100%
Manifest = 100%
Database schema = 100%
Logic preservation = 100%
Discover readiness = Ready
Missing required files = 0
Unexpected logic changes = 0
Blocking dependencies = 0
```

### INCOMPLETE

Use when inventory or evidence is missing, but no proven hard blocker has been confirmed.

### BLOCKED

Use when a required file, manifest condition, database object, dependency, or Discover requirement prevents a safe clone.

## Prohibited conclusions

Do not claim completion based only on:

- 100% file count.
- A successful Discover operation.
- Matching table counts.
- Successful PHP syntax checks.
- One working frontend or backend page.

These checks validate different layers and must remain separate in the report.
