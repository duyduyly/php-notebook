# AcyMailing 10.11.1 Installation Guide for Joomla 6

This document provides a developer-focused process for installing, validating, configuring, and testing AcyMailing 10.11.1 on Joomla 6.

> Recommended approach: install the official ZIP package through Joomla CLI or the Joomla Administrator Extension Installer. Do not manually copy extracted files into Joomla extension directories.

## Table of Contents

- [1. Scope](#1-scope)
- [2. Installation Summary](#2-installation-summary)
- [3. Prerequisites](#3-prerequisites)
- [4. Option 1: Install with Joomla CLI](#4-option-1-install-with-joomla-cli)
- [5. Option 2: Install from Joomla Administrator](#5-option-2-install-from-joomla-administrator)
- [6. Download AcyMailing 10.11.1](#6-download-acymailing-10111)
- [7. Create a Backup and Git Checkpoint](#7-create-a-backup-and-git-checkpoint)
- [8. Why Manual File Copy Is Not Recommended](#8-why-manual-file-copy-is-not-recommended)
- [9. Verify the Installed Extensions](#9-verify-the-installed-extensions)
- [10. Verify the Database](#10-verify-the-database)
- [11. Confirm the Installed Version](#11-confirm-the-installed-version)
- [12. Configure AcyMailing for Development](#12-configure-acymailing-for-development)
- [13. Configure Permissions and Security](#13-configure-permissions-and-security)
- [14. Run Smoke Tests](#14-run-smoke-tests)
- [15. Review Source-Code Changes](#15-review-source-code-changes)
- [16. Reproduce the Installation Across Environments](#16-reproduce-the-installation-across-environments)
- [17. Update an Existing AcyMailing Installation](#17-update-an-existing-acymailing-installation)
- [18. Migrate AcyMailing Data from Joomla 3](#18-migrate-acymailing-data-from-joomla-3)
- [19. Troubleshooting](#19-troubleshooting)
- [20. Completion Checklist](#20-completion-checklist)
- [21. Official Documentation](#21-official-documentation)

---

## 1. Scope

This guide covers:

- Installing AcyMailing 10.11.1 on Joomla 6.
- Installing through Joomla CLI or the Administrator interface.
- Running Joomla inside Docker or directly on the host machine.
- Verifying the extension files and database records.
- Configuring a safe local email-testing environment.
- Updating an existing AcyMailing installation.
- Preparing for an AcyMailing migration from Joomla 3.

This guide does not assume that installing AcyMailing automatically migrates historical AcyMailing data from a Joomla 3 website.

---

## 2. Installation Summary

Use one of these supported installation options:

| Option | Method | Recommended use |
|---|---|---|
| Option 1 | Joomla CLI | Local development, Docker, repeatable deployment, and scripted installation |
| Option 2 | Joomla Administrator | Manual installation and quick validation through the backend UI |

Both options must use the official AcyMailing Joomla ZIP package.

Do not extract the package and manually copy files into `components`, `administrator/components`, `plugins`, or `modules`.

---

## 3. Prerequisites

Before installing AcyMailing, confirm that Joomla 6 is running correctly.

### 3.1 Check PHP

```bash
php -v
```

For Joomla 6, use a PHP version supported by your exact Joomla 6 release. PHP 8.3 or PHP 8.4 is generally appropriate for a current Joomla 6 development environment, but the project must follow Joomla's current technical requirements.

### 3.2 Check Joomla CLI

Run this command from the Joomla root directory:

```bash
php cli/joomla.php --version
```

List available Joomla CLI commands:

```bash
php cli/joomla.php list
```

### 3.3 Check required PHP extensions

```bash
php -m | grep -E "curl|dom|fileinfo|filter|gd|intl|json|mbstring|mysqli|openssl|pdo|session|simplexml|xml|zip"
```

Commonly required extensions include:

```text
curl
dom
fileinfo
intl
json
mbstring
mysqli or pdo_mysql
openssl
simplexml
xml
zip
```

### 3.4 Check the Joomla installation

Confirm that:

- The Joomla frontend opens without a fatal error.
- The Joomla Administrator page is accessible.
- The database connection works.
- The Joomla update database schema is valid.
- The filesystem permissions allow Joomla to install extensions.
- The PHP upload and POST limits are large enough for the installation package.

---

## 4. Option 1: Install with Joomla CLI

This is the recommended option for developers because it is easier to repeat in local, test, staging, and deployment environments.

### 4.1 Go to the Joomla root directory

```bash
cd /path/to/joomla
```

### 4.2 Confirm that the package exists

Example:

```bash
ls -lh packages/acymailing_10.11.1.zip
```

Use the real downloaded filename if it is different.

### 4.3 Install from an absolute path

```bash
php cli/joomla.php extension:install \
  --path=/absolute/path/to/packages/acymailing_10.11.1.zip
```

Expected result:

```text
Extension installation successful.
```

### 4.4 Install inside Docker

Assume the Joomla project is mounted at `/var/www/html` and the service is named `joomla`:

```bash
docker compose exec joomla \
  php cli/joomla.php extension:install \
  --path=/var/www/html/packages/acymailing_10.11.1.zip
```

If the PHP service is named `web`:

```bash
docker compose exec web \
  php cli/joomla.php extension:install \
  --path=/var/www/html/packages/acymailing_10.11.1.zip
```

### 4.5 Check the command from inside the container

```bash
docker compose exec joomla sh
```

Then run:

```bash
cd /var/www/html
php cli/joomla.php extension:install \
  --path=/var/www/html/packages/acymailing_10.11.1.zip
```

### 4.6 Developer notes

- Always use an absolute package path when running the CLI command.
- The package must be readable by the PHP user inside the container.
- Confirm that the package is mounted into the container.
- Do not store commercial packages in a public repository.
- Do not store license credentials in shell scripts.

---

## 5. Option 2: Install from Joomla Administrator

Use this option when you want to perform and verify the installation through the Joomla backend.

### 5.1 Open the extension installer

Navigate to:

```text
Joomla Administrator
→ System
→ Install
→ Extensions
```

### 5.2 Upload the package

Select the **Upload Package File** tab and upload the official AcyMailing ZIP file.

Example filename:

```text
acymailing_10.11.1.zip
```

The real filename may be different depending on the AcyMailing edition and download source.

### 5.3 Wait for the installation result

Joomla should:

1. Upload the ZIP file.
2. Extract the package.
3. Run the package installer.
4. Register the included component, modules, and plugins.
5. Run database installation or update scripts.
6. Display a successful installation message.

### 5.4 Alternative installer tabs

Joomla may also provide:

- Install from Folder.
- Install from URL.
- Install from Web.

For a controlled developer workflow, prefer **Upload Package File** or **Joomla CLI**.

Use **Install from Folder** only when the ZIP upload fails because of upload size, timeout, or filesystem limitations.

---

## 6. Download AcyMailing 10.11.1

Download the package only from the official AcyMailing website or an official AcyMailing account.

Official download documentation:

```text
https://docs.acymailing.com/setup/installation/download-acymailing
```

Official website:

```text
https://www.acymailing.com/
```

The Starter edition may be available through public installation channels. Essential and Enterprise packages may require an AcyMailing account and an active subscription.

### 6.1 Suggested project structure

```text
project/
├── docker/
├── packages/
│   └── acymailing_10.11.1.zip
├── scripts/
└── src/
    ├── administrator/
    ├── components/
    ├── cli/
    └── configuration.php
```

If Joomla is located at the repository root, adjust the paths accordingly.

### 6.2 Protect commercial packages

Add ZIP packages to `.gitignore`:

```gitignore
/packages/*.zip
```

Do not commit:

- Paid AcyMailing packages.
- License keys.
- SMTP passwords.
- Production API credentials.
- Production subscriber data.

---

## 7. Create a Backup and Git Checkpoint

Create a database backup and a clean Git checkpoint before installing the extension.

### 7.1 Back up MySQL

Example for a database outside Docker:

```bash
mysqldump \
  -h host.docker.internal \
  -P 3307 \
  -u root \
  -p \
  honda_corp_v6 \
  > backup-before-acymailing.sql
```

Change the host, port, username, and database name to match the project.

### 7.2 Back up from a container

```bash
docker compose exec joomla sh
```

Then:

```bash
mysqldump \
  -h host.docker.internal \
  -P 3307 \
  -u root \
  -p \
  honda_corp_v6 \
  > /tmp/backup-before-acymailing.sql
```

The container must include the MySQL client for this command to work.

### 7.3 Create a Git checkpoint

```bash
git status
git add .
git commit -m "chore: checkpoint before installing AcyMailing 10.11.1"
```

This makes it easier to identify every file added or changed by the installation.

---

## 8. Why Manual File Copy Is Not Recommended

Do not install AcyMailing like this:

```bash
cp -R acymailing/components/com_acym components/
cp -R acymailing/administrator/components/com_acym administrator/components/
cp -R acymailing/plugins/* plugins/
```

Manual copying can skip important installation steps:

- Extension registration in `#__extensions`.
- Package relationship registration.
- SQL installation and update scripts.
- Installer lifecycle hooks.
- Plugin and module registration.
- Update-site registration.
- Language installation.
- Cleanup logic.

A Joomla installer script may execute lifecycle methods such as:

```text
preflight
install
update
uninstall
postflight
```

Copying files directly does not run the normal Joomla installation process.

---

## 9. Verify the Installed Extensions

### 9.1 Verify with Joomla CLI

List all extensions and filter AcyMailing:

```bash
php cli/joomla.php extension:list | grep -i acymailing
```

Depending on the available CLI options, you may also filter by type:

```bash
php cli/joomla.php extension:list --type=component | grep -i acymailing
php cli/joomla.php extension:list --type=plugin | grep -i acymailing
php cli/joomla.php extension:list --type=module | grep -i acymailing
```

Check the exact supported parameters with:

```bash
php cli/joomla.php help extension:list
```

### 9.2 Verify in Joomla Administrator

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

The package normally installs a family of related extensions. The exact list depends on the edition and package version.

You should at least confirm that the main AcyMailing component is installed and enabled.

### 9.3 Open the component

Navigate to:

```text
Components
→ AcyMailing
```

The dashboard should load without a PHP fatal error or HTTP 500 response.

---

## 10. Verify the Database

AcyMailing tables normally use the Joomla database prefix followed by an AcyMailing-specific name.

For example, if the Joomla prefix is `ty08n_`, inspect tables with:

```sql
SHOW TABLES LIKE 'ty08n_acym_%';
```

Count matching tables:

```sql
SELECT COUNT(*) AS acymailing_table_count
FROM information_schema.tables
WHERE table_schema = 'honda_corp_v6'
  AND table_name LIKE 'ty08n_acym_%';
```

Change the database name and prefix to match the target environment.

### 10.1 Check Joomla extension records

```sql
SELECT
    extension_id,
    name,
    type,
    element,
    folder,
    enabled,
    manifest_cache
FROM ty08n_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%'
   OR folder = 'acymailing'
ORDER BY type, name;
```

Use these queries only for verification. Do not manually edit extension records unless you are recovering from a diagnosed installation failure and understand the Joomla extension schema.

---

## 11. Confirm the Installed Version

### 11.1 Confirm from Joomla Administrator

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search for `AcyMailing` and check the displayed version.

Expected version:

```text
10.11.1
```

### 11.2 Inspect the manifest cache

If the database supports JSON functions and the stored data is valid JSON:

```sql
SELECT
    name,
    type,
    element,
    JSON_UNQUOTE(JSON_EXTRACT(manifest_cache, '$.version')) AS version
FROM ty08n_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%';
```

Fallback query:

```sql
SELECT
    name,
    type,
    element,
    manifest_cache
FROM ty08n_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%';
```

The main component or package record should report version `10.11.1`.

---

## 12. Configure AcyMailing for Development

Navigate to:

```text
Components
→ AcyMailing
→ Configuration
```

Do not use a production SMTP account for local development.

Use a local mail-capture service such as:

- Mailpit.
- MailHog.
- A controlled SMTP sandbox.

### 12.1 Mailpit Docker example

Add Mailpit to `docker-compose.yml`:

```yaml
services:
  joomla:
    build:
      context: .
    depends_on:
      - mailpit

  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "8025:8025"
      - "1025:1025"
```

Configure AcyMailing SMTP:

```text
Sending method: SMTP
SMTP host: mailpit
SMTP port: 1025
Security: None
Authentication: No
```

Open the Mailpit interface:

```text
http://localhost:8025
```

### 12.2 Suggested development sender

```text
From name: Joomla Development
From email: no-reply@example.test
Reply-to: developer@example.test
```

Use test domains and sandbox email addresses. Do not send campaigns to production subscribers from a developer environment.

Official mail configuration documentation:

```text
https://docs.acymailing.com/setup/configuration/mail-configuration
```

---

## 13. Configure Permissions and Security

Review AcyMailing access rules and Joomla ACL after installation.

Suggested access model:

| Joomla group | Suggested access |
|---|---|
| Super Users | Full access |
| Administrator | Campaign and configuration management |
| Manager | Content-level access only when required |
| Registered | No Administrator access |
| Public | Subscription form access only when required |

Security recommendations:

- Do not give configuration or ACL permissions to non-administrators.
- Disable unused AcyMailing modules and plugins.
- Protect public subscription forms against automated abuse.
- Use CAPTCHA or another anti-bot control where appropriate.
- Review file upload and attachment settings.
- Do not expose APIs that the website does not use.
- Keep Joomla, PHP, AcyMailing, and integrated extensions updated.
- Review every AcyMailing add-on separately from the main component.
- Never commit SMTP credentials or license keys.

Official security configuration documentation:

```text
https://docs.acymailing.com/setup/configuration/security
```

---

## 14. Run Smoke Tests

After installation, run at least these tests:

1. Open the AcyMailing dashboard.
2. Confirm there is no HTTP 500 error.
3. Create a test mailing list.
4. Create a sandbox subscriber.
5. Create a test campaign.
6. Send a test email to Mailpit or another sandbox.
7. Verify the unsubscribe link.
8. Test the subscription form if the project uses one.
9. Confirm that disabled users cannot access restricted pages.
10. Review Joomla and PHP logs.
11. Confirm that no production cron task was accidentally enabled.
12. Confirm that the installed version is 10.11.1.

### 14.1 Review Docker logs

```bash
docker compose logs -f joomla
```

Or, when the service is named `web`:

```bash
docker compose logs -f web
```

### 14.2 Review Joomla logs

The exact log filename depends on Joomla configuration. A common command is:

```bash
tail -f administrator/logs/everything.php
```

Check the configured log path before assuming this filename exists.

---

## 15. Review Source-Code Changes

Run:

```bash
git status --short
```

Review the change summary:

```bash
git diff --stat
```

Possible AcyMailing-related paths may include:

```text
administrator/components/
components/
media/
modules/
plugins/
```

Use `git status` to identify the real paths installed by the package. Do not rely only on expected directory names.

Important:

> Installing a Joomla extension changes both the filesystem and the database. Committing only the installed files does not reproduce the full installation on another database.

For repeatable deployments, retain a legal internal copy of the package or retrieve it securely during deployment, then run the Joomla installer on each target environment.

---

## 16. Reproduce the Installation Across Environments

Create a controlled installation script rather than manually repeating backend steps.

Example `scripts/install-acymailing.sh`:

```bash
#!/usr/bin/env bash

set -euo pipefail

JOOMLA_ROOT="${JOOMLA_ROOT:-/var/www/html}"
PACKAGE_PATH="${1:-${JOOMLA_ROOT}/packages/acymailing_10.11.1.zip}"

if [[ ! -f "${PACKAGE_PATH}" ]]; then
    echo "Error: AcyMailing package not found: ${PACKAGE_PATH}" >&2
    exit 1
fi

if [[ ! -f "${JOOMLA_ROOT}/cli/joomla.php" ]]; then
    echo "Error: Joomla CLI not found in ${JOOMLA_ROOT}" >&2
    exit 1
fi

echo "Installing AcyMailing package: ${PACKAGE_PATH}"

php "${JOOMLA_ROOT}/cli/joomla.php" extension:install \
    --path="${PACKAGE_PATH}"

echo "Checking installed AcyMailing extensions..."

php "${JOOMLA_ROOT}/cli/joomla.php" extension:list \
    | grep -i acymailing || {
        echo "Warning: No AcyMailing extension was found in the CLI output." >&2
        exit 1
    }

echo "AcyMailing installation completed."
```

Make it executable:

```bash
chmod +x scripts/install-acymailing.sh
```

Run on the host:

```bash
./scripts/install-acymailing.sh \
  "$(pwd)/packages/acymailing_10.11.1.zip"
```

Run inside Docker:

```bash
docker compose exec joomla \
  /var/www/html/scripts/install-acymailing.sh \
  /var/www/html/packages/acymailing_10.11.1.zip
```

Do not put license keys, production passwords, or subscriber data inside the script.

---

## 17. Update an Existing AcyMailing Installation

When Joomla 6 already contains an older AcyMailing release:

1. Back up the database.
2. Back up or checkpoint the filesystem.
3. Do not uninstall the old version first.
4. Install the 10.11.1 ZIP package over the existing installation.
5. Allow Joomla and the AcyMailing installer to run update scripts.
6. Confirm the installed version.
7. Verify the AcyMailing database schema and data.
8. Run the smoke-test checklist again.

CLI example:

```bash
php cli/joomla.php extension:install \
  --path=/absolute/path/acymailing_10.11.1.zip
```

Official update documentation:

```text
https://docs.acymailing.com/setup/installation/update-acymailing
```

Uninstalling before an update may remove extension-family relationships, configuration, or data depending on the extension behavior. Upgrade by installing the new package over the existing version unless official documentation instructs otherwise.

---

## 18. Migrate AcyMailing Data from Joomla 3

Installing AcyMailing on Joomla 6 is not the same as migrating AcyMailing data from Joomla 3.

```text
Install the extension
≠
Migrate historical AcyMailing data
```

A migration may need to preserve:

- Subscribers.
- Lists.
- List subscriptions.
- Campaigns and templates.
- Unsubscribe state.
- Bounce information.
- Statistics.
- Automation rules.
- Custom fields.
- Add-on configuration.

### 18.1 Suggested migration process

1. Preserve a complete backup of the Joomla 3 source and database.
2. Identify the current AcyMailing major and minor version.
3. Inventory all AcyMailing components, modules, plugins, and add-ons.
4. Confirm whether the old installation is AcyMailing 5 or a later major version.
5. Update the old installation only when required by the official migration path.
6. Install the supported AcyMailing release on Joomla 6.
7. Use the official AcyMailing migration feature where supported.
8. Validate subscriber counts, list counts, campaign data, and unsubscribe status.
9. Send test emails only to controlled accounts.
10. Document any data that cannot be migrated automatically.

Do not copy old `#__acymailing_*` or `#__acym_*` tables directly into Joomla 6 without validating the source and target schemas.

Official migration documentation:

```text
https://docs.acymailing.com/setup/migration
```

Joomla migration documentation provided by AcyMailing:

```text
https://docs.acymailing.com/setup/move-acymailing-between-websites/switch-from-joomla-3-to-joomla-4-5
```

Even when the official page mentions Joomla 4 or 5, confirm the current supported path before applying it to Joomla 6.

---

## 19. Troubleshooting

### 19.1 Package file not found

Example error:

```text
Package file does not exist.
```

Check:

```bash
ls -lh /absolute/path/to/acymailing_10.11.1.zip
```

Inside Docker, confirm the host package is mounted:

```bash
docker compose exec joomla \
  ls -lh /var/www/html/packages/
```

### 19.2 Permission denied

Check ownership and permissions:

```bash
ls -ld administrator components media modules plugins tmp
```

The PHP or web-server user must be able to write to Joomla extension directories and the Joomla temporary directory.

Do not use `chmod -R 777` as a permanent fix.

### 19.3 Upload size error

Check PHP values:

```bash
php -i | grep -E "upload_max_filesize|post_max_size|max_execution_time|memory_limit"
```

Ensure:

```text
post_max_size >= upload_max_filesize
```

Restart the PHP or web container after changing PHP configuration.

### 19.4 Missing ZIP support

Check:

```bash
php -m | grep -i zip
```

Install or enable the PHP ZIP extension if it is missing.

### 19.5 Installation succeeds but the menu is missing

Check:

- `System → Manage → Extensions`.
- Whether the main component is enabled.
- Joomla Administrator menu cache.
- Joomla and PHP error logs.
- Database records in `#__extensions`.
- Whether the current user has permission to access AcyMailing.

### 19.6 Database tables are missing

Possible causes:

- The installer script failed.
- The database user cannot create or alter tables.
- The package was copied manually instead of installed.
- The installation timed out.
- The Joomla temporary directory is invalid.

Restore the backup before retrying if the installation is partially complete.

### 19.7 Test email does not arrive in Mailpit

Check:

- SMTP host is the Docker service name, normally `mailpit`.
- SMTP port is `1025`.
- Authentication is disabled.
- Encryption is disabled for local Mailpit.
- Joomla and AcyMailing are using the intended mail configuration.
- Both services are on the same Docker network.

---

## 20. Completion Checklist

```text
[ ] Joomla 6 runs correctly before installation
[ ] The PHP version is supported by the Joomla release
[ ] Required PHP extensions are installed
[ ] The database has been backed up
[ ] A Git checkpoint has been created
[ ] The official AcyMailing 10.11.1 package has been downloaded
[ ] Commercial ZIP packages are excluded from public Git repositories
[ ] Option 1 or Option 2 has completed successfully
[ ] The AcyMailing component appears in Extension Manager
[ ] Related modules and plugins have been inventoried
[ ] AcyMailing database tables exist
[ ] Extension records exist in #__extensions
[ ] Version 10.11.1 has been confirmed
[ ] The AcyMailing dashboard opens without an HTTP 500 error
[ ] Development SMTP uses Mailpit, MailHog, or another sandbox
[ ] A test email has been delivered to the sandbox
[ ] The unsubscribe link has been tested
[ ] Joomla ACL has been reviewed
[ ] Unused AcyMailing add-ons have been disabled or removed
[ ] Joomla and PHP logs contain no new fatal errors
[ ] No production cron task was enabled accidentally
[ ] License keys and SMTP credentials are not committed
[ ] A repeatable installation process has been documented
[ ] Joomla 3 data migration is tracked as a separate task when applicable
```

---

## 21. Official Documentation

| Purpose | URL |
|---|---|
| AcyMailing documentation | https://docs.acymailing.com/ |
| Download AcyMailing | https://docs.acymailing.com/setup/installation/download-acymailing |
| Install AcyMailing | https://docs.acymailing.com/setup/installation/install-acymailing |
| Update AcyMailing | https://docs.acymailing.com/setup/installation/update-acymailing |
| AcyMailing migration | https://docs.acymailing.com/setup/migration |
| Mail configuration | https://docs.acymailing.com/setup/configuration/mail-configuration |
| Security configuration | https://docs.acymailing.com/setup/configuration/security |
| Developer documentation | https://docs.acymailing.com/developers |
| AcyMailing changelog | https://www.acymailing.com/changelog/ |
| Joomla technical requirements | https://manual.joomla.org/docs/next/get-started/technical-requirements/ |
| Joomla extension installation concepts | https://manual.joomla.org/docs/next/building-extensions/install-update/installation/ |

---

## Final Recommendation

For a Joomla 6 development project, use **Option 1: Joomla CLI** as the primary installation method because it is repeatable and can be automated across environments.

Use **Option 2: Joomla Administrator** when a developer needs a manual installation flow or wants to validate the package through the backend UI.

In both cases:

- Use the official ZIP package.
- Back up the database first.
- Do not manually copy extension files.
- Verify both filesystem and database changes.
- Use a sandbox SMTP service.
- Treat Joomla 3 data migration as a separate, tested migration process.
