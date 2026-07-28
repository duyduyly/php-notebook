# AcyMailing 10.11.1 Installation Guide for Joomla 6

This guide documents the project workflow below:

```text
Local environment
→ install AcyMailing through Joomla Administrator
→ verify the installed files
→ commit and push the extension source
→ development environment pulls the source
→ use Joomla Discover to register and install the extension
→ verify the database and component
```

> Important: this workflow is acceptable only after it has been tested against a clean Joomla 6 database. For AcyMailing, installing the official ZIP package again on the development environment remains the safer fallback because AcyMailing is a multi-extension package.

## Table of Contents

- [1. Scope](#1-scope)
- [2. Workflow Summary](#2-workflow-summary)
- [3. Prerequisites](#3-prerequisites)
- [4. Local Installation Through Joomla Administrator](#4-local-installation-through-joomla-administrator)
- [5. Review and Push the Installed Source](#5-review-and-push-the-installed-source)
- [6. Development Installation Through Discover](#6-development-installation-through-discover)
- [7. Required Verification](#7-required-verification)
- [8. Known Limitations](#8-known-limitations)
- [9. Troubleshooting](#9-troubleshooting)
- [10. Completion Checklist](#10-completion-checklist)
- [11. Official Documentation](#11-official-documentation)

---

## 1. Scope

This guide covers only the technical installation of AcyMailing 10.11.1 on Joomla 6.

It does not cover:

- SMTP configuration.
- License configuration.
- Campaigns or templates.
- Subscribers and mailing lists.
- Migration of AcyMailing data from Joomla 3.
- Production secrets.

The target result is:

```text
AcyMailing is registered in Joomla,
its database tables exist,
and the component dashboard opens successfully.
```

---

## 2. Workflow Summary

| Environment | Action |
|---|---|
| Local | Install the official AcyMailing ZIP through Joomla Administrator |
| Local | Verify all AcyMailing files created by the installer |
| Git | Commit and push the installed extension source files |
| Development | Pull the source code |
| Development | Run Joomla Discover and install every detected AcyMailing extension |
| Development | Verify extension records, database tables, version, and dashboard |

This workflow transfers the source through Git, but it does not transfer the local database.

On development, Joomla Discover must create the target database registration.

---

## 3. Prerequisites

Before starting, confirm:

```text
[ ] Joomla 6 is already installed locally
[ ] Joomla 6 is already installed on development
[ ] Both environments use compatible PHP versions
[ ] Both databases are reachable
[ ] The official AcyMailing 10.11.1 Joomla ZIP is available
[ ] The Git working tree is clean before local installation
```

Check Git:

```bash
git status
```

Create a branch:

```bash
git checkout -b feature/install-acymailing-10.11.1
```

Back up the local database before installing.

Example:

```bash
mysqldump \
  -h host.docker.internal \
  -P 3307 \
  -u root \
  -p \
  honda_corp_v6 \
  > backup-before-acymailing.sql
```

Do not commit the database backup.

---

## 4. Local Installation Through Joomla Administrator

### 4.1 Open the Joomla extension installer

Navigate to:

```text
Joomla Administrator
→ System
→ Install
→ Extensions
```

### 4.2 Upload the official package

Select:

```text
Upload Package File
```

Upload the official Joomla package, for example:

```text
acymailing_10.11.1.zip
```

Do not manually extract the ZIP into Joomla extension directories.

### 4.3 Wait for Joomla to complete the installation

Joomla should:

1. Extract the package.
2. Install the AcyMailing component.
3. Install related plugins and modules.
4. Copy media and language files.
5. Register extensions in `#__extensions`.
6. Run AcyMailing SQL installation scripts.
7. Create AcyMailing database tables.

### 4.4 Verify the local installation

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search for:

```text
AcyMailing
```

Then open:

```text
Components
→ AcyMailing
```

The dashboard must open without an HTTP 500 error.

Check the installed version:

```text
10.11.1
```

---

## 5. Review and Push the Installed Source

### 5.1 Review changed files

Run:

```bash
git status --short
```

Review the summary:

```bash
git diff --stat
```

AcyMailing files may exist under paths such as:

```text
administrator/components/
components/
media/
modules/
plugins/
language/
administrator/language/
libraries/
```

Use the actual `git status` output as the source of truth.

### 5.2 Confirm that required files are tracked

Check AcyMailing-related paths:

```bash
find administrator components media modules plugins libraries \
  -iname '*acym*' 2>/dev/null
```

Do not commit:

```text
configuration.php
.env
SMTP passwords
API keys
license keys
database dumps
production subscriber data
```

### 5.3 Commit and push

Example:

```bash
git add administrator components media modules plugins language libraries

git commit -m "feat: install AcyMailing 10.11.1 for Joomla 6"

git push origin feature/install-acymailing-10.11.1
```

Adjust the `git add` paths based on the files that actually changed.

> The AcyMailing ZIP itself should not be committed to a public repository, especially for a paid edition.

---

## 6. Development Installation Through Discover

### 6.1 Back up the development database

Always create a backup before Discover installation.

### 6.2 Pull the source

```bash
git checkout develop
git pull origin develop
```

Or pull the feature branch being tested:

```bash
git checkout feature/install-acymailing-10.11.1
git pull origin feature/install-acymailing-10.11.1
```

At this point, the files exist on development, but AcyMailing may not yet be registered in the development database.

### 6.3 Open Discover

Navigate to:

```text
Joomla Administrator
→ System
→ Install
→ Discover
```

Click:

```text
Discover
```

### 6.4 Find all AcyMailing entries

Search for names containing:

```text
AcyMailing
acym
```

Do not install only the main component if Joomla detects additional AcyMailing extensions.

Possible detected types include:

```text
Component
Plugin
Module
Library
Package
```

The exact list depends on the AcyMailing edition and package contents.

### 6.5 Install detected extensions

If Joomla detects a package entry, install the package first.

If Joomla detects only separate entries, use this preferred order:

```text
Library
→ Component
→ Plugin
→ Module
```

Select the related AcyMailing entries and click:

```text
Install
```

After installation, enable any required AcyMailing plugins that remain disabled.

### 6.6 Clear Joomla cache

Navigate to:

```text
System
→ Maintenance
→ Clear Cache
```

Clear administrator and site cache as needed.

---

## 7. Required Verification

Discover installation is considered successful only when all checks below pass.

### 7.1 Verify extension registration

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search for:

```text
AcyMailing
```

Confirm that:

```text
[ ] The main component exists
[ ] Related plugins exist
[ ] Related modules exist when included
[ ] Required extensions are enabled
[ ] The displayed version is 10.11.1
```

### 7.2 Verify database records

Replace `yourprefix_` with the real Joomla database prefix.

```sql
SELECT
    extension_id,
    name,
    type,
    element,
    folder,
    enabled,
    manifest_cache
FROM yourprefix_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%'
   OR folder LIKE '%acym%'
ORDER BY type, name;
```

### 7.3 Verify AcyMailing tables

```sql
SHOW TABLES LIKE 'yourprefix_acym_%';
```

The result must contain AcyMailing tables.

If no tables are returned, the Discover installation did not complete the required database installation.

### 7.4 Open the component

Navigate to:

```text
Components
→ AcyMailing
```

The dashboard must open without:

```text
HTTP 500
Table not found
Class not found
Plugin not found
Missing dependency
```

### 7.5 Review logs

Docker example:

```bash
docker compose logs --tail=200 joomla
```

Check Joomla logs using the path configured in Joomla Global Configuration.

---

## 8. Known Limitations

This workflow is not guaranteed to behave exactly like installing the original AcyMailing ZIP package on development.

Reasons:

- AcyMailing is a family of multiple extensions.
- Discover may detect extensions separately instead of as one package.
- Package relationships may not be recreated exactly.
- An installer script may treat `discover_install` differently from a normal install.
- Some initialization logic may run only from the package installer.
- Missing untracked files can cause an incomplete installation.

Therefore:

```text
Git source + Discover
```

is acceptable only after the team proves that it works on a clean Joomla 6 database.

The fallback is:

```text
Install the official AcyMailing 10.11.1 ZIP
through Joomla Administrator on development.
```

Do not manually insert rows into `#__extensions` or manually create AcyMailing tables as the normal deployment method.

---

## 9. Troubleshooting

### 9.1 Discover does not find AcyMailing

Check:

```text
- All AcyMailing files were committed and pulled.
- Manifest XML files exist.
- Files are under Joomla's standard extension directories.
- File ownership and permissions allow the web server to read them.
- The extension is not already registered in #__extensions.
```

Search for manifests:

```bash
find administrator components modules plugins libraries \
  -type f -name '*.xml' \
  | grep -i acym
```

### 9.2 The component appears but database tables are missing

This means file registration succeeded but database installation did not complete.

Recommended recovery:

1. Restore the development database backup if the state is inconsistent.
2. Install the official AcyMailing 10.11.1 ZIP through Joomla Administrator.
3. Verify `#__extensions` and `#__acym_*` tables again.

### 9.3 AcyMailing opens with a missing class or file error

Compare development files with local:

```bash
git status
find administrator components media modules plugins libraries \
  -iname '*acym*' 2>/dev/null
```

Check whether `.gitignore` excluded required vendor files.

### 9.4 A plugin is installed but disabled

Navigate to:

```text
System
→ Manage
→ Plugins
```

Search for:

```text
AcyMailing
acym
```

Enable only the plugins required by the project.

### 9.5 Discover creates only part of the AcyMailing family

Do not consider the installation complete.

Use the official ZIP package on development instead.

---

## 10. Completion Checklist

```text
Local
[ ] Joomla 6 runs correctly
[ ] The local database is backed up
[ ] AcyMailing 10.11.1 is installed through Joomla Administrator
[ ] AcyMailing appears in Extension Manager
[ ] The AcyMailing dashboard opens
[ ] The installed version is 10.11.1
[ ] All installed source files were reviewed
[ ] Required source files were committed
[ ] Secrets and database dumps were not committed
[ ] The branch was pushed successfully

Development
[ ] Joomla 6 core is already installed
[ ] The development database is backed up
[ ] The branch was pulled successfully
[ ] Joomla Discover detects AcyMailing entries
[ ] All required AcyMailing entries were installed
[ ] Required plugins were enabled
[ ] AcyMailing records exist in #__extensions
[ ] AcyMailing tables exist with the development prefix
[ ] The installed version is 10.11.1
[ ] Components → AcyMailing opens without errors
[ ] Joomla and PHP logs contain no new fatal errors
```

---

## 11. Official Documentation

| Purpose | URL |
|---|---|
| AcyMailing documentation | https://docs.acymailing.com/ |
| Download AcyMailing | https://docs.acymailing.com/setup/installation/download-acymailing |
| Install AcyMailing | https://docs.acymailing.com/setup/installation/install-acymailing |
| Update AcyMailing | https://docs.acymailing.com/setup/installation/update-acymailing |
| AcyMailing changelog | https://www.acymailing.com/changelog/ |
| Joomla extension installation | https://manual.joomla.org/docs/next/building-extensions/install-update/installation/ |

---

## Final Recommendation

Use this project workflow only after validating it on a clean Joomla 6 database:

```text
Local: Joomla Administrator package installation
→ Git: commit installed AcyMailing source
→ Development: pull source and Discover Install
→ Verify extension records, database tables, version, and dashboard
```

If Discover does not create the complete AcyMailing installation, stop using Discover for this extension and install the official ZIP package directly on each target environment.