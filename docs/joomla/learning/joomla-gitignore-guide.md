# Joomla `.gitignore` Guide

A practical guide to deciding what Git should track in a Joomla project, including Joomla core files, custom extensions, third-party extensions, runtime data, secrets, SQL files, frontend build artifacts, and migration-specific repositories.

> [!IMPORTANT]
> A good Joomla `.gitignore` should protect secrets and exclude reproducible runtime artifacts **without hiding source code required to build, audit, migrate, or deploy the site**.

## Quick Navigation

- [1. Recommended Strategy](#1-recommended-strategy)
- [2. How to Classify Project Files](#2-how-to-classify-project-files)
- [3. Joomla Extension File Layout](#3-joomla-extension-file-layout)
- [4. Custom Extensions](#4-custom-extensions)
- [5. Third-Party Extensions](#5-third-party-extensions)
- [6. Joomla Core](#6-joomla-core)
- [7. Runtime and Generated Files](#7-runtime-and-generated-files)
- [8. Configuration and Secrets](#8-configuration-and-secrets)
- [9. SQL Files and Database Dumps](#9-sql-files-and-database-dumps)
- [10. Composer, Node.js, and Build Artifacts](#10-composer-nodejs-and-build-artifacts)
- [11. Uploaded Media](#11-uploaded-media)
- [12. IDE, OS, Docker, and Local Tooling](#12-ide-os-docker-and-local-tooling)
- [13. Recommended Strategy for Joomla Migration Projects](#13-recommended-strategy-for-joomla-migration-projects)
- [14. Complete Recommended `.gitignore`](#14-complete-recommended-gitignore)
- [15. Extension-Specific Ignore Examples](#15-extension-specific-ignore-examples)
- [16. Verify Ignore Rules Before Committing](#16-verify-ignore-rules-before-committing)
- [17. Stop Tracking Files That Are Already Committed](#17-stop-tracking-files-that-are-already-committed)
- [18. Common Mistakes](#18-common-mistakes)
- [19. Decision Matrix](#19-decision-matrix)
- [20. Verification Checklist](#20-verification-checklist)

## 1. Recommended Strategy

The safest default is:

```text
Source code                    -> Track
Custom Joomla extensions       -> Track
Extension manifests            -> Track
Extension SQL install/updates   -> Track
Build configuration            -> Track
Tests                          -> Track
Runtime cache/log/tmp           -> Ignore
Secrets/local configuration     -> Ignore
Database dumps                  -> Ignore
Reproducible dependencies       -> Usually ignore
Generated build output          -> Depends on deployment
Third-party extensions          -> Depends on repository purpose
Uploaded user content           -> Depends on deployment/content strategy
```

The key rule is simple:

> [!TIP]
> **Ignore files because they are generated, secret, machine-specific, or reproducible — not merely because they belong to Joomla or an extension.**

## 2. How to Classify Project Files

Before adding a path to `.gitignore`, decide which category it belongs to.

### Gitignore pattern basics

Use the smallest rule that expresses the real intent:

| Pattern | Meaning | Example |
| --- | --- | --- |
| `/path/` | Match from the repository root | `/tmp/` |
| `name/` | Match a directory named `name` at applicable levels | `node_modules/` |
| `*` | Match characters within one path level | `*.log` |
| `**` | Match across directory levels | `**/node_modules/` |
| `!pattern` | Re-include a previously ignored path | `!/cache/index.html` |
| `# comment` | Documentation only | `# Runtime files` |

> [!NOTE]
> Re-inclusion rules work only when Git can still traverse the parent path. Prefer ignoring directory **contents** such as `/cache/*` when you need to keep a file inside the directory.

| Category | Examples | Recommended Git policy |
| --- | --- | --- |
| Source code | PHP classes, controllers, models, services, templates | Track |
| Extension metadata | XML manifests, service providers, language files | Track |
| Database source | Extension install/update SQL | Track |
| Runtime data | Cache, logs, sessions, temporary files | Ignore |
| Secrets | `configuration.php`, `.env`, private keys | Ignore |
| Reproducible dependency | `node_modules/`, Composer vendor inside a custom package | Usually ignore |
| Build output | `dist/`, compiled JS/CSS | Depends on deployment |
| User content | `/images/`, uploaded documents | Depends on content/deployment strategy |
| Third-party extension code | HikaShop, RSForm, AcyMailing, etc. | Track or ignore based on restore strategy |
| Database backup | SQL dump, SQLite snapshot | Ignore |

### Repository purpose matters

There is no single correct `.gitignore` for every Joomla repository.

Two common repository models are:

| Repository model | What Git normally contains | Best for |
| --- | --- | --- |
| Full-site snapshot | Joomla core + custom code + possibly third-party extensions | Legacy maintenance, migration, forensic comparison, exact site snapshots |
| Application/source repository | Custom source + manifests + deployment definitions; reproducible dependencies installed separately | Modern CI/CD and repeatable deployments |

A migration repository often needs more files tracked than a clean production deployment repository.

## 3. Joomla Extension File Layout

A Joomla extension can place files in several locations. Ignoring only one folder may leave part of the extension tracked, while ignoring a broad parent directory may hide unrelated custom code.

A component or extension package can span locations such as:

```text
joomla-project/
├── components/
│   └── com_example/                  # Frontend component code
├── administrator/
│   ├── components/
│   │   └── com_example/              # Administrator component code
│   ├── modules/
│   │   └── mod_example_admin/        # Administrator module
│   └── language/
│       └── en-GB/                    # Administrator translations
├── modules/
│   └── mod_example/                  # Frontend module
├── plugins/
│   └── system/
│       └── example/                  # Plugin code
├── media/
│   └── com_example/                  # Extension CSS, JS, images, build assets
├── language/
│   └── en-GB/                        # Frontend translations
├── libraries/
│   └── example/                      # Optional extension library
└── templates/
    └── example/                      # Template extension, if applicable
```

Because of this structure, **do not ignore all of `/components/`, `/administrator/components/`, `/modules/`, `/plugins/`, `/media/`, or `/templates/`** just to exclude one extension.

## 4. Custom Extensions

Custom extensions are application source code and should normally remain under version control.

### What to track

For a custom component such as `com_example`, Git should normally track:

```text
components/com_example/
administrator/components/com_example/
media/com_example/
language/*/com_example*.ini
administrator/language/*/com_example*.ini
```

Inside the extension, track source files such as:

```text
com_example/
├── src/                              # PHP source
├── controllers/                      # Legacy controller source when applicable
├── models/                           # Legacy model source when applicable
├── views/                            # Legacy view source when applicable
├── tmpl/                             # Layout/template source
├── forms/                            # Joomla form XML
├── services/                         # Service provider definitions
├── sql/                              # Installer and schema update SQL
├── language/                         # Translation source
├── media/                            # Source assets owned by the extension
├── tests/                            # Automated tests
├── example.xml                         # Extension manifest
├── composer.json                     # Dependency definition
├── package.json                      # Frontend dependency definition
├── vite.config.*                     # Build configuration
├── webpack.config.*                  # Build configuration
└── README.md                         # Extension documentation
```

### What to ignore inside a custom extension

Ignore only generated or local-only files.

```gitignore
# Custom extension runtime files
/components/com_example/cache/
/components/com_example/tmp/
/components/com_example/logs/
/administrator/components/com_example/cache/
/administrator/components/com_example/tmp/
/administrator/components/com_example/logs/

# Local configuration / secrets
/components/com_example/.env
/components/com_example/.env.*
!/components/com_example/.env.example
/components/com_example/config.local.php

# Reproducible dependencies
/components/com_example/node_modules/
/components/com_example/vendor/

# Test output
/components/com_example/coverage/
/components/com_example/test-results/
```

> [!WARNING]
> Never add `/components/com_example/` or `/administrator/components/com_example/` to `.gitignore` if those directories contain the custom source that must be audited, migrated, or deployed.

### Custom modules and plugins

The same principle applies to custom modules and plugins.

```text
/modules/mod_featureditems/                 -> Track
/plugins/system/customrouter/         -> Track
/plugins/content/customcontent/       -> Track
```

Only their local/generated subdirectories should be ignored.

## 5. Third-Party Extensions

Third-party extensions require a policy decision rather than a blanket rule.

### Ignore them only when they are reproducible

A third-party extension is a good candidate for `.gitignore` when all of the following are true:

1. The exact compatible version is recorded.
2. The installation package is available from a trusted source.
3. A deployment or setup process reinstalls it reliably.
4. The extension has not been manually patched in production.
5. Any required configuration/data is migrated or restored separately.

The deployment flow should be reproducible:

```text
Checkout repository
    -> Install Joomla/core dependencies
    -> Install required third-party extensions
    -> Apply project configuration
    -> Restore or migrate database data
    -> Build frontend assets
    -> Verify site
```

### Track third-party code when exact source parity matters

Tracking third-party extension code is reasonable when:

- Maintaining a legacy site without reproducible package installation.
- Performing a Joomla 3 to Joomla 6 migration.
- Comparing old and new extension behavior.
- Auditing local patches made directly inside vendor extension code.
- Preserving an exact production source snapshot.
- The original extension package/version can no longer be obtained reliably.

> [!IMPORTANT]
> During a migration, ignoring a third-party extension too early can remove evidence needed to identify compatibility problems, overridden behavior, local patches, or Joomla/PHP API dependencies.

### Prefer extension-specific rules

If you decide to ignore a third-party extension, ignore its exact installed paths instead of broad Joomla directories.

```gitignore
# Example third-party component
/components/com_example_vendor/
/administrator/components/com_example_vendor/
/modules/mod_example_vendor/
/plugins/system/example_vendor/
/media/com_example_vendor/
```

Extension layouts vary by product and version. Confirm the installed package contents before copying a rule into the project `.gitignore`.

## 6. Joomla Core

Whether Joomla core itself should be tracked depends on the repository model.

### Full-site or migration repository

Track Joomla core when the repository is intended to preserve the exact site source or compare two Joomla installations.

This is useful for:

- Joomla migration work.
- Legacy maintenance.
- Template override auditing.
- Local core patches that must first be discovered and removed.
- Exact source parity checks.

### Reproducible application repository

Joomla core can be restored by the deployment process instead of committed when the project has a reliable installation/build mechanism.

Do not mix the two strategies accidentally. If core is excluded, the repository must still contain enough information to reproduce the exact Joomla version and deployment state.

## 7. Runtime and Generated Files

Runtime files should normally be ignored because Joomla regenerates them.

Typical runtime paths include:

```gitignore
/cache/*
!/cache/index.html

/administrator/cache/*
!/administrator/cache/index.html

/tmp/*
!/tmp/index.html

/logs/*
!/logs/index.html

/administrator/logs/*
!/administrator/logs/index.html
```

Global runtime patterns can also include:

```gitignore
*.log
*.tmp
*.temp
*.cache
*.pid
*.sess
```

> [!NOTE]
> Keep placeholder/security files such as `index.html` when the project intentionally uses them. The `!` rule re-includes those files after the directory contents are ignored.

## 8. Configuration and Secrets

Joomla's `configuration.php` commonly contains environment-specific values and credentials. It should normally not be committed to a shared repository.

```gitignore
/configuration.php
/configuration.local.php
/configuration.*.local.php

.env
.env.*
!.env.example

*.secret
*.secrets
.credentials/
secrets/
```

Use sanitized templates instead:

```text
configuration.example.php             -> Track
.env.example                           -> Track
configuration.php                     -> Ignore
.env                                   -> Ignore
```

Private key material should also stay out of Git:

```gitignore
*.key
*.p12
*.pfx
*.pem
```

> [!WARNING]
> Adding a leaked secret to `.gitignore` does **not** remove it from Git history. Rotate the credential and clean the repository history when a real secret has already been committed.

## 9. SQL Files and Database Dumps

This is one of the most important Joomla-specific rules.

### Do not globally ignore `*.sql`

Custom extensions commonly store schema source under paths such as:

```text
administrator/components/com_example/sql/
├── install.mysql.utf8.sql
├── uninstall.mysql.utf8.sql
└── updates/
    ├── 1.0.1.sql
    └── 1.0.2.sql
```

These SQL files are part of the extension source and **must be tracked**.

Therefore, avoid this rule:

```gitignore
# BAD: hides both database dumps and legitimate extension source
*.sql
```

### Ignore database dumps by location or dump-specific extensions

Use dedicated backup directories instead:

```gitignore
/database-dump/
/database-dumps/
/db-dump/
/db-dumps/
/dumps/

*.sql.gz
*.sql.zip
*.dump
*.sqlite
*.sqlite3
```

This keeps extension migration SQL visible to Git while still excluding database backups.

### Recommended database layout

```text
project/
├── administrator/components/com_custom/sql/updates/  # Track
├── database/migrations/                              # Track
├── sql/                                              # Track when it contains source scripts
└── dumps/                                            # Ignore
```

## 10. Composer, Node.js, and Build Artifacts

Dependencies and build outputs need separate decisions.

### Composer dependencies

For a custom extension with its own Composer manifest:

```gitignore
/components/com_custom/vendor/
```

Track the dependency definition and lock file according to the project's dependency policy:

```text
composer.json                         -> Track
composer.lock                         -> Usually track for an application
vendor/                               -> Usually ignore when reproducible
```

Do **not** blindly ignore Joomla library directories such as `/libraries/` or `/libraries/vendor/` unless the project's deployment process explicitly restores them.

### Node.js dependencies

`node_modules` is normally reproducible and should be ignored:

```gitignore
/node_modules/
**/node_modules/
```

Track:

```text
package.json                          -> Track
package-lock.json                     -> Track
pnpm-lock.yaml                        -> Track
yarn.lock                            -> Track
vite.config.*                         -> Track
webpack.config.*                      -> Track
```

### Build output: `dist/`, `build/`, minified assets

Build artifacts are conditional.

Use this decision flow:

```text
Can CI/deployment rebuild the exact asset?
    |
    +-- Yes -> Ignore generated build output
    |
    +-- No  -> Track the files required by Joomla at runtime
```

For example:

```text
src/js/app.js
    -> Vite/Webpack
    -> media/com_custom/js/app.min.js
```

If production expects `app.min.js` to already exist and deployment does not run the build, that generated file must be tracked.

> [!TIP]
> Do not add global `dist/`, `build/`, `*.min.js`, or `*.min.css` rules until you know how the site is deployed.

## 11. Uploaded Media

Do not ignore `/images/` by default.

Joomla sites often store business-critical content under `/images/`, and the correct policy depends on how content is deployed.

### Track media when

- The repository is an exact site snapshot.
- Images are part of the template or application source.
- Deployment relies on Git to deliver those files.

### Ignore media when

- User uploads are stored in object storage or another persistent volume.
- Content files are synchronized by a dedicated deployment/content process.
- Git is intentionally source-code-only.

Optional rules:

```gitignore
# Enable only when uploaded content is managed outside Git
# /images/*
# !/images/index.html
# /uploads/
# /media/uploads/
```

## 12. IDE, OS, Docker, and Local Tooling

Developer-machine artifacts usually do not belong in the repository.

### IDE and OS files

```gitignore
.idea/
*.iml

.DS_Store
Thumbs.db
Desktop.ini

*.swp
*.swo
*~
```

For VS Code, project settings can be useful to the team. A safer pattern is:

```gitignore
.vscode/*
!.vscode/extensions.json
!.vscode/settings.example.json
!.vscode/tasks.example.json
!.vscode/launch.example.json
```

### Docker

Ignore local overrides and persistent data, not Docker source configuration.

```gitignore
docker-compose.override.yml
docker-compose.local.yml
docker-compose.dev.yml

docker-data/
docker-data-*/
mysql-data/
mysql_data/
mariadb-data/
postgres-data/
redis-data/
```

Track files such as:

```text
Dockerfile                            -> Track
docker-compose.yml                    -> Track
.dockerignore                         -> Track
docker/ scripts/config                -> Track when they are project source
```

Do not automatically ignore an entire `.docker/` or `docker/` directory if it contains deployment configuration.

### Personal tool state

Local-only AI/editor state should be ignored only when it is not intentionally shared as project configuration.

Examples that may be local-only:

```gitignore
.cursorignore.local
.aider*
.continue/
```

Project instructions for tools such as Claude, Codex, Cursor, or Copilot may be valuable repository source. Review those directories before ignoring them globally.

### Use global Git excludes for personal preferences

OS and editor artifacts that are specific to one developer can also be kept outside the repository `.gitignore`:

```bash
git config --global core.excludesFile ~/.gitignore_global
```

This keeps shared `.gitignore` focused on project-wide rules.

## 13. Recommended Strategy for Joomla Migration Projects

For a Joomla 3 to Joomla 6 migration, preserving evidence is more important than having the smallest repository.

A practical migration policy is:

| Area | During migration | After migration is stable |
| --- | --- | --- |
| Joomla core | Track or preserve exact source snapshot | May move to reproducible install strategy |
| Custom extensions | Track | Track |
| Third-party extensions | Prefer tracking when needed for audit/parity | May ignore if reliably reinstallable |
| Runtime cache/log/tmp | Ignore | Ignore |
| Secrets | Ignore | Ignore |
| Extension SQL schema/update files | Track | Track |
| Database dumps | Ignore from normal Git; store securely elsewhere | Ignore |
| Generated build output | Track if required for parity | Decide based on CI/CD |
| Uploaded media | Preserve according to migration plan | Decide based on storage architecture |

For custom migration-critical code such as:

```text
/components/com_example/
/administrator/components/com_example/
/components/com_catalog/
/administrator/components/com_catalog/
/modules/mod_featureditems/
```

Git should keep the source visible so it can be searched, compared, ported, and reviewed.

A migration workflow typically looks like:

```text
Preserve source snapshot
    -> Classify core / custom / third-party
    -> Ignore only runtime + secrets + local artifacts
    -> Audit extension ownership
    -> Port custom code
    -> Reinstall/upgrade third-party extensions where possible
    -> Compare Joomla 3 and Joomla 6 behavior
    -> Stabilize deployment
    -> Simplify repository policy later
```

## 14. Complete Recommended `.gitignore`

The following template is intentionally conservative. It ignores high-confidence generated/local files while leaving Joomla source, custom extensions, SQL source, and potentially important deployment files visible.

```gitignore
# ============================================================
# Joomla Project - .gitignore
# ============================================================


# ------------------------------------------------------------
# Joomla runtime
# ------------------------------------------------------------

/cache/*
!/cache/index.html

/administrator/cache/*
!/administrator/cache/index.html

/tmp/*
!/tmp/index.html

/logs/*
!/logs/index.html

/administrator/logs/*
!/administrator/logs/index.html


# ------------------------------------------------------------
# Joomla configuration / secrets
# ------------------------------------------------------------

/configuration.php
/configuration.local.php
/configuration.*.local.php

.env
.env.*
!.env.example

*.secret
*.secrets
secrets/
.credentials/


# ------------------------------------------------------------
# Joomla installation directory
# ------------------------------------------------------------

/installation/


# ------------------------------------------------------------
# Runtime / temporary files
# ------------------------------------------------------------

*.tmp
*.temp
*.cache
*.log
*.pid
*.sess
*.lock.tmp

sessions/
php_sessions/

# Extension-generated media cache only.
# Keep disabled if this path contains source assets in your project.
# /media/cache/


# ------------------------------------------------------------
# Backups / archives
# ------------------------------------------------------------

*.bak
*.backup
*.old
*.orig
*.save

*.tar
*.tar.gz
*.tgz
*.bz2
*.7z
*.rar

# Generic ZIP files may be extension packages or intentional artifacts.
# Enable only when ZIP files are never intentional repository assets.
# *.zip

backup/
backups/
_backup/
_backups/

akeeba-backup/
administrator/components/com_akeebabackup/backup/
administrator/components/com_akeeba/backup/

*.jpa
*.jps
*.j01
*.j02
*.j03
*.j04
*.j05


# ------------------------------------------------------------
# Database dumps
# IMPORTANT: do NOT ignore *.sql globally.
# ------------------------------------------------------------

/database-dump/
/database-dumps/
/db-dump/
/db-dumps/
/dumps/

*.sql.gz
*.sql.zip
*.dump
*.db
*.sqlite
*.sqlite3


# ------------------------------------------------------------
# Node.js / frontend dependencies
# ------------------------------------------------------------

/node_modules/
**/node_modules/

npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

.npm/
.pnpm-store/
.yarn/cache/
.yarn/unplugged/

*.tsbuildinfo


# ------------------------------------------------------------
# Test / coverage output
# ------------------------------------------------------------

coverage/
.nyc_output/

.phpunit.result.cache
.phpunit.cache/

coverage.xml
clover.xml

/test-results/
/tests/_output/
/tests/output/
/playwright-report/
/blob-report/
playwright/.cache/

/cypress/videos/
/cypress/screenshots/
/cypress/downloads/


# ------------------------------------------------------------
# PHP development tools
# ------------------------------------------------------------

.php-cs-fixer.cache
.phpstan.cache
.psalm-cache/

phpstan.neon.local
phpstan.local.neon
phpcs.xml.local

composer.phar


# ------------------------------------------------------------
# IDE / editors
# ------------------------------------------------------------

.idea/
.idea_modules/
*.iml
*.ipr
*.iws

.vscode/*
!.vscode/extensions.json
!.vscode/settings.example.json
!.vscode/tasks.example.json
!.vscode/launch.example.json

.project
.classpath
.settings/

nbproject/private/
.nb-gradle/

*.swp
*.swo
*.swn
*~


# ------------------------------------------------------------
# Operating systems
# ------------------------------------------------------------

.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
Desktop.ini
$RECYCLE.BIN/

.directory
.Trash-*


# ------------------------------------------------------------
# Docker local overrides / persistent data
# ------------------------------------------------------------

docker-compose.override.yml
docker-compose.local.yml
docker-compose.dev.yml

docker-data/
docker-data-*/
mysql-data/
mysql_data/
mariadb-data/
postgres-data/
redis-data/


# ------------------------------------------------------------
# Local keys / credentials
# ------------------------------------------------------------

*.key
*.p12
*.pfx
*.pem

credentials.json
service-account.json
service-account*.json
auth.local.json
*.credentials.json
*.token
*.tokens

.ssh/
id_rsa
id_ed25519


# ------------------------------------------------------------
# Cloud / infrastructure local state
# ------------------------------------------------------------

.aws/
.azure/
.gcloud/

terraform.tfstate
terraform.tfstate.*
.terraform/

*.tfvars
*.tfvars.json
!*.tfvars.example


# ------------------------------------------------------------
# Local web-server overrides
# ------------------------------------------------------------

.htaccess.local
.htaccess.dev
.htaccess.development
.htaccess.test

web.config.local
web.config.dev

nginx.local.conf
nginx.dev.conf
apache.local.conf


# ------------------------------------------------------------
# Joomla extension package/build artifacts
# ------------------------------------------------------------

package-build/
extension-build/
extension-packages/


# ------------------------------------------------------------
# Profiling / debug output
# ------------------------------------------------------------

.profile/
.profiler/

.cachegrind
cachegrind.out.*
*.prof

debug.log
debug.txt
php_errors.log
error_log
xdebug.log
xdebug.log.*


# ------------------------------------------------------------
# Local scratch files
# ------------------------------------------------------------

scratch/
sandbox/
working/

notes.local.*
todo.local.*
*.patch.local
*.diff.local


# ------------------------------------------------------------
# Local tool state - include only when truly developer-local
# ------------------------------------------------------------

.cursorignore.local
.aider*
.continue/


# ------------------------------------------------------------
# IMPORTANT: intentionally NOT ignored
# ------------------------------------------------------------
#
# Joomla/custom source directories remain visible to Git:
#
# /components/
# /administrator/components/
# /modules/
# /administrator/modules/
# /plugins/
# /templates/
# /administrator/templates/
# /media/
# /libraries/
#
# SQL source remains visible:
#
# administrator/components/*/sql/**/*.sql
# database/migrations/**/*.sql
# sql/**/*.sql
#
# Build output such as dist/ and build/ is NOT globally ignored because
# some Joomla deployments require compiled assets to be committed.
```

### Optional rules that require a project decision

Do not add these automatically:

```gitignore
# Composer dependency directory inside a custom package
# /components/com_custom/vendor/

# Generated frontend output only when CI/deployment rebuilds it
# /components/com_custom/dist/
# /components/com_custom/build/

# Uploaded user content only when stored/synchronized elsewhere
# /images/*
# !/images/index.html
# /uploads/
# /media/uploads/

# Third-party extension only when reinstallable
# /components/com_vendor/
# /administrator/components/com_vendor/
```

## 15. Extension-Specific Ignore Examples

Use extension-specific rules only after deciding that the extension should not be stored in Git.

### Example: component + module + plugin package

```gitignore
# Vendor extension example
/components/com_vendorname/
/administrator/components/com_vendorname/
/modules/mod_vendorname/
/plugins/system/vendorname/
/media/com_vendorname/
```

### Example: ignore only generated files from a custom component

```gitignore
# Keep the custom component source, ignore only generated/local state
/components/com_example/cache/
/components/com_example/tmp/
/components/com_example/logs/
/components/com_example/node_modules/
/components/com_example/coverage/

/administrator/components/com_example/cache/
/administrator/components/com_example/tmp/
/administrator/components/com_example/logs/
```

### Language files

Third-party extensions can install language files outside the main extension directory:

```text
/language/en-GB/com_example.ini
/language/en-GB/com_example.sys.ini
/administrator/language/en-GB/com_example.ini
/administrator/language/en-GB/com_example.sys.ini
```

Do not add broad patterns such as `/language/` or `*.ini`; they would hide unrelated Joomla and custom extension source.

If exact third-party language files need to be ignored, list their exact extension prefix and confirm the installed package layout first.

## 16. Verify Ignore Rules Before Committing

Never assume a `.gitignore` pattern behaves the way you intended.

### Check why a file is ignored

```bash
git check-ignore -v path/to/file
```

Example:

```bash
git check-ignore -v administrator/components/com_example/sql/updates/1.0.2.sql
```

For a custom extension SQL source file, this command should normally return no ignore match.

### List ignored files

```bash
git status --ignored
```

### Check whether a path is already tracked

```bash
git ls-files components/com_example
```

### Test multiple important paths

```bash
git check-ignore -v \
  configuration.php \
  logs/error.php \
  administrator/components/com_example/sql/updates/1.0.2.sql \
  components/com_example/src/Service/ExampleService.php
```

Expected result:

```text
configuration.php                                  -> Ignored
runtime log                                         -> Ignored
custom extension SQL update                        -> NOT ignored
custom extension PHP source                        -> NOT ignored
```

## 17. Stop Tracking Files That Are Already Committed

`.gitignore` affects untracked files. It does not automatically remove files that Git already tracks.

### Remove one tracked file from the index

```bash
git rm --cached configuration.php
```

The local file remains on disk, but Git stops tracking it after the change is committed.

### Remove a tracked directory from the index

```bash
git rm -r --cached path/to/generated-directory
```

> [!CAUTION]
> Do not run `git rm -r --cached .` blindly on a migration repository. Review the resulting changes carefully because a broad re-index can expose mistakes in ignore rules and produce a very large commit.

After changing tracking rules:

```bash
git status
```

Review every deletion/addition before committing.

## 18. Common Mistakes

### Mistake 1: Ignoring all SQL files

```gitignore
*.sql
```

**Problem:** hides Joomla/custom extension installer and update SQL.

**Use instead:** dedicated dump directories and compressed dump extensions.

### Mistake 2: Ignoring all components

```gitignore
/components/
/administrator/components/
```

**Problem:** hides custom application code and extension source.

**Use instead:** exact third-party extension paths.

### Mistake 3: Ignoring all media

```gitignore
/media/
/images/
```

**Problem:** can hide extension assets, template assets, or business content required by deployment.

**Use instead:** exact generated/upload directories only after confirming the storage strategy.

### Mistake 4: Ignoring `dist/` and `build/` globally

**Problem:** some Joomla sites deploy precompiled assets directly from Git.

**Use instead:** ignore build output only when CI/deployment rebuilds it.

### Mistake 5: Ignoring third-party extensions without a reinstall plan

**Problem:** a clean checkout may no longer produce a working site.

**Use instead:** record extension name/version/package source and automate or document installation first.

### Mistake 6: Assuming `.gitignore` removes secrets from history

**Problem:** previously committed credentials remain in Git history.

**Use instead:** rotate the credential and clean history when necessary.

### Mistake 7: Ignoring shared project configuration as personal tooling

**Problem:** directories such as Docker, Claude/Codex instructions, or editor settings may contain useful team configuration.

**Use instead:** ignore only the local state files you have confirmed are machine-specific.

## 19. Decision Matrix

Use this table before adding a new rule.

| Question | Yes | No |
| --- | --- | --- |
| Is the file a secret? | Ignore and provide a sanitized example | Continue |
| Is it runtime cache/log/tmp/session data? | Ignore | Continue |
| Is it generated and exactly reproducible? | Usually ignore | Continue |
| Is it source required to build or migrate the site? | Track | Continue |
| Is it custom extension code? | Track | Continue |
| Is it extension install/update SQL? | Track | Continue |
| Is it a database dump? | Ignore | Continue |
| Is it a third-party extension? | Ignore only with reliable reinstall strategy | Track/preserve when exact source matters |
| Is it compiled frontend output? | Ignore only if deployment rebuilds it | Track |
| Is it uploaded content? | Ignore only if stored/synchronized elsewhere | Track/preserve |
| Is it developer-specific rather than project-specific? | Prefer local/global Git excludes | Track if shared project configuration |

## 20. Verification Checklist

Before accepting a Joomla `.gitignore`, verify all of the following:

- [ ] `configuration.php` and real environment secrets are ignored.
- [ ] `.env.example` or another sanitized configuration template remains trackable.
- [ ] Joomla cache, logs, temporary files, and sessions are ignored.
- [ ] Database backup directories are ignored.
- [ ] `*.sql` is **not** ignored globally.
- [ ] Custom extension install/update SQL remains trackable.
- [ ] Custom components, modules, plugins, templates, and libraries remain trackable.
- [ ] Third-party extensions are ignored only when their exact version can be restored reliably.
- [ ] `/images/` is ignored only when uploaded content is managed outside Git.
- [ ] `dist/` and `build/` are ignored only when the deployment pipeline recreates them.
- [ ] Docker source configuration is not accidentally ignored.
- [ ] Shared AI/editor/project instructions are not accidentally ignored.
- [ ] `git check-ignore -v` confirms critical source files remain visible.
- [ ] `git status --ignored` shows only expected generated/local files.
- [ ] Already tracked secrets/generated files are removed from the Git index intentionally.
- [ ] A clean checkout plus documented setup steps can reproduce the required project state.

The final rule is the most useful test:

> [!IMPORTANT]
> **If deleting the ignored file would prevent a clean checkout from being rebuilt, audited, migrated, or deployed, do not ignore it until you have a reliable replacement process.**
