# Admin Tools 7.8.9 Installation and Verification Guide for Joomla 6

This guide explains how to install **Akeeba Admin Tools 7.8.9** on **Joomla 6**, configure it safely, verify the installation, troubleshoot common problems, and recover access if a security rule blocks the Joomla administrator area.

> **Important:** Admin Tools is not only a plugin. It is distributed as a Joomla **package extension** containing a component and several supporting plugins. Installing the complete package is the recommended method.

> **Security note:** Install and configure Admin Tools on a staging environment before enabling it on production. Incorrect WAF, IP, administrator protection, or web-server rules can block valid users, APIs, AJAX requests, payment callbacks, or the Joomla administrator area.

## Table of Contents

1. [Extension Information](#1-extension-information)
2. [Official Download and Documentation](#2-official-download-and-documentation)
3. [Prerequisites](#3-prerequisites)
4. [Recommended Installation Using Joomla Upload Package File](#4-recommended-installation-using-joomla-upload-package-file)
5. [Alternative Installation Using Install from Folder](#5-alternative-installation-using-install-from-folder)
6. [Alternative Installation Using Joomla Discover](#6-alternative-installation-using-joomla-discover)
7. [Initial Setup](#7-initial-setup)
8. [Safe Configuration Order](#8-safe-configuration-order)
9. [Verify That Installation Was Successful](#9-verify-that-installation-was-successful)
10. [Functional Test Checklist](#10-functional-test-checklist)
11. [Web Application Firewall Validation](#11-web-application-firewall-validation)
12. [Web-Server Configuration](#12-web-server-configuration)
13. [Update Configuration](#13-update-configuration)
14. [Deployment to Another Environment](#14-deployment-to-another-environment)
15. [Troubleshooting](#15-troubleshooting)
16. [Emergency Recovery](#16-emergency-recovery)
17. [Uninstallation](#17-uninstallation)
18. [Production Readiness Checklist](#18-production-readiness-checklist)

---

## 1. Extension Information

| Field | Value |
|---|---|
| Extension | Akeeba Admin Tools |
| Target version | 7.8.9 |
| Vendor | Akeeba Ltd |
| Target CMS | Joomla 6.0 / 6.1 |
| Extension format | Joomla package extension |
| Editions | Core and Professional |
| Recommended installation method | Upload Package File |
| Configuration strategy | Fresh configuration with selective migration of old rules |
| Testing priority | Critical |

Admin Tools can affect every incoming request before Joomla finishes processing it. Treat it as a security-critical extension rather than a normal content plugin.

---

## 2. Official Download and Documentation

### Official links

- Latest Admin Tools downloads: <https://www.akeeba.com/download/admintools.html>
- Admin Tools 7.8.9 release page: <https://www.akeeba.com/download/admintools/7-8-9.html>
- Official documentation: <https://www.akeeba.com/documentation/admin-tools-joomla.html>
- Joomla extension installation documentation: <https://docs.joomla.org/Installing_an_extension>

### Package selection

Download the edition that matches the project license:

```text
Admin Tools Core
Admin Tools Professional
```

A Core package normally follows a filename similar to:

```text
pkg_admintools-7.8.9-core.zip
```

The Professional package is available from an Akeeba account with an active subscription.

### Important package rules

- Do not rename files inside the ZIP archive.
- Do not remove nested ZIP packages.
- Do not upload an extracted component directory through **Upload Package File**.
- Do not install Core over Professional unless intentionally changing editions and following Akeeba's instructions.
- Keep a copy of the original package for repeatable deployments.

---

## 3. Prerequisites

Before installation, confirm the following:

- [ ] Joomla 6 is installed and working.
- [ ] You can log in as a Super User.
- [ ] The PHP version is supported by both Joomla 6 and Admin Tools 7.8.9.
- [ ] The Joomla temporary directory is valid and writable.
- [ ] Joomla can write to its extension directories.
- [ ] The database user can create and alter tables.
- [ ] The website has a current source-code backup.
- [ ] The website has a current database backup.
- [ ] You have direct filesystem or container access for emergency recovery.
- [ ] Existing `.htaccess`, Nginx, or IIS configuration has been backed up.

### Check Joomla paths

In the Joomla administrator area, open:

```text
System → Global Configuration → Server
```

Verify that the temporary path exists and is writable.

The configured temporary path is also available in `configuration.php`:

```php
public $tmp_path = '/absolute/path/to/tmp';
public $log_path = '/absolute/path/to/administrator/logs';
```

### Recommended backup commands

Example MySQL backup:

```bash
mysqldump -u DB_USER -p DB_NAME > before-admin-tools.sql
```

Example filesystem backup for an Apache website:

```bash
cp .htaccess .htaccess.before-admin-tools
```

For a Git-managed project:

```bash
git status
git add .
git commit -m "Backup before installing Admin Tools 7.8.9"
```

Do not commit credentials, production database dumps, private keys, or Akeeba Download IDs into Git.

---

## 4. Recommended Installation Using Joomla Upload Package File

This is the recommended and safest installation method.

### Step 1: Download the package

Download Admin Tools 7.8.9 from the official Akeeba download page.

Keep the downloaded package as a ZIP file, for example:

```text
pkg_admintools-7.8.9-core.zip
```

### Step 2: Log in to Joomla

Open:

```text
https://your-domain.example/administrator
```

Log in using a Super User account.

### Step 3: Open the extension installer

Navigate to:

```text
System → Install → Extensions
```

### Step 4: Upload the package

Under **Upload Package File**:

1. Drag the Admin Tools ZIP file into the upload area, or select it manually.
2. Wait until Joomla finishes uploading and installing the package.
3. Do not refresh or close the browser during installation.

A successful installation should display a message similar to:

```text
Installation of the package was successful.
```

### Step 5: Open Admin Tools

Navigate to:

```text
Components → Admin Tools
```

Allow Admin Tools to complete any first-run database or configuration initialization.

### Step 6: Clear Joomla cache

Navigate to:

```text
System → Maintenance → Clear Cache
```

Clear relevant administrator and site cache entries.

### Step 7: Verify installed extensions

Navigate to:

```text
System → Manage → Extensions
```

Search for:

```text
Admin Tools
```

Confirm that the package, component, and supporting plugins are present.

---

## 5. Alternative Installation Using Install from Folder

Use this method when browser upload limits prevent normal ZIP upload.

### Step 1: Copy the package to the server

Copy the original Admin Tools ZIP package to a server directory accessible by Joomla, for example:

```text
/path/to/joomla/tmp/pkg_admintools-7.8.9-core.zip
```

### Step 2: Extract the package into a temporary folder

Example:

```bash
mkdir -p /path/to/joomla/tmp/admin-tools-install
unzip pkg_admintools-7.8.9-core.zip -d /path/to/joomla/tmp/admin-tools-install
```

Do not extract the files directly into the Joomla root directory.

### Step 3: Open Install from Folder

Navigate to:

```text
System → Install → Extensions → Install from Folder
```

Enter the absolute extracted directory path:

```text
/path/to/joomla/tmp/admin-tools-install
```

Click **Check and Install**.

### Step 4: Clean temporary files

After successful installation, remove the extracted temporary installer directory:

```bash
rm -rf /path/to/joomla/tmp/admin-tools-install
```

Keep the original package in a secure deployment-artifact location if required.

---

## 6. Alternative Installation Using Joomla Discover

### When Discover should be used

Joomla Discover is useful when extension files already exist in the correct Joomla directories but the extension records are missing from the database. Common cases include:

- Files were deployed through Git, rsync, Docker image, or another deployment pipeline.
- A previous installation was interrupted after copying files.
- A database was recreated without reinstalling extensions.
- An extension exists in the filesystem but is not listed in Joomla Extension Manager.

### Important limitation

**Discover is not the preferred first installation method for Admin Tools.** Admin Tools is a package containing multiple extensions and installation scripts. Uploading the complete package lets Joomla process dependencies and manifests in the expected order.

Use Discover only when the files have already been placed correctly and normal package installation is not possible.

### 6.1 Prepare the package files

Do not copy the outer package ZIP directly into the Joomla root.

First inspect the package in a temporary directory:

```bash
mkdir -p /tmp/admin-tools-package
unzip pkg_admintools-7.8.9-core.zip -d /tmp/admin-tools-package
find /tmp/admin-tools-package -maxdepth 3 -type f
```

A Joomla package may contain nested installable archives and a package manifest. Each nested extension archive must be handled according to its own manifest.

### 6.2 Copy extension files to their target directories

The exact target is defined by each extension manifest. Typical Joomla locations include:

```text
administrator/components/com_admintools/
components/com_admintools/
plugins/system/<plugin-name>/
plugins/task/<plugin-name>/
administrator/manifests/packages/
media/com_admintools/
language/<language-tag>/
administrator/language/<language-tag>/
```

Do not guess plugin folder names. Read the XML manifest inside each nested package and use its `<files>`, `<folder>`, `<filename>`, `<media>`, and destination definitions.

Example inspection commands:

```bash
find /tmp/admin-tools-package -name '*.xml' -maxdepth 5
find /tmp/admin-tools-package -name '*.zip' -maxdepth 5
```

When a nested ZIP exists, extract it separately before copying its files:

```bash
mkdir -p /tmp/admin-tools-component
unzip component-package.zip -d /tmp/admin-tools-component
```

### 6.3 Preserve ownership and permissions

After copying files, apply the same ownership used by the Joomla web server.

Example for a Debian-based Apache container:

```bash
chown -R www-data:www-data administrator/components/com_admintools
chown -R www-data:www-data media/com_admintools
```

Use project-specific ownership. Do not blindly apply `777` permissions.

Typical safe defaults are:

```text
Directories: 755
Files:       644
```

### 6.4 Run Joomla Discover

In Joomla administrator, navigate to:

```text
System → Install → Discover
```

Then:

1. Click **Discover**.
2. Search for entries related to Admin Tools or Akeeba.
3. Select the component first if dependency ordering requires it.
4. Install the discovered component.
5. Repeat Discover.
6. Install the supporting plugins.
7. Install the package record last if it is discoverable and required.

The exact order may depend on the package manifest. If Joomla reports a missing dependency or installation script error, stop and use the normal package installer instead.

### 6.5 Rebuild the update sites

Navigate to:

```text
System → Update → Update Sites
```

Run the available rebuild action if Admin Tools update-site records are missing.

Then navigate to:

```text
System → Update → Extensions
```

Clear the update cache and check for updates.

### 6.6 Validate database schema

Open:

```text
Components → Admin Tools
```

If the component reports missing tables, schema mismatch, or incomplete installation, reinstall the original package through **Upload Package File**. Do not manually invent database tables from another Admin Tools version.

### Discover installation acceptance criteria

Discover installation is acceptable only when all of the following are true:

- [ ] Admin Tools opens without an exception.
- [ ] All required plugins are listed in Extension Manager.
- [ ] Database tables and schema initialize successfully.
- [ ] Update sites are registered.
- [ ] No missing-file warnings appear.
- [ ] Joomla administrator and frontend requests work normally.

---

## 7. Initial Setup

After installation, navigate to:

```text
Components → Admin Tools
```

If a Quick Setup Wizard is displayed, use conservative settings first.

### Recommended first-run settings

Enable or retain basic protections such as:

- Security exception logging.
- Protection from clearly malicious request patterns.
- Basic administrator-login monitoring.
- Standard request filtering recommended by the vendor.

### Settings to postpone

Do not enable all advanced options during the first configuration session. Postpone these until staging tests are complete:

- Administrator Exclusive Allow IP List.
- Administrator Secret URL Parameter.
- Aggressive automatic IP blocking.
- Country blocking.
- Immediate email notification for every blocked request.
- Strict direct-file-access restrictions.
- New `.htaccess`, Nginx, or IIS rules.
- Broad upload restrictions.

### Why conservative setup is required

A security feature can be technically functional but still break legitimate project behavior. Admin Tools rules may affect:

- Joomla Web Services API.
- `com_ajax` requests.
- AcyMailing subscription forms and callbacks.
- HikaShop cart, checkout, and payment callbacks.
- RSForm Pro form submission and file upload.
- JCE media upload.
- SP Page Builder editor requests.
- Cron jobs and Joomla Scheduled Tasks.
- External webhook integrations.

---

## 8. Safe Configuration Order

Configure Admin Tools in the following order:

```text
1. Install the package
2. Verify the component and plugins
3. Enable security exception logging
4. Test frontend and administrator behavior
5. Enable basic WAF protection
6. Test APIs, AJAX, forms, uploads, and callbacks
7. Add narrow exceptions for confirmed false positives
8. Configure administrator protection
9. Configure automatic IP blocking
10. Generate web-server rules last
11. Run complete regression testing
12. Deploy to production
```

Do not enable administrator IP restrictions, a secret URL, and strict web-server rules at the same time. Enable and verify one protection layer at a time.

---

## 9. Verify That Installation Was Successful

### 9.1 Check the component

Navigate to:

```text
Components → Admin Tools
```

Success criteria:

- The Admin Tools dashboard opens.
- No PHP fatal error is displayed.
- No missing database table error is displayed.
- The installed version is shown as 7.8.9.
- Configuration pages can be opened and saved.

### 9.2 Check Extension Manager

Navigate to:

```text
System → Manage → Extensions
```

Search for:

```text
Admin Tools
```

Confirm that the expected package, component, and plugins are installed.

Record at least:

| Field | Expected result |
|---|---|
| Name | Admin Tools / related Akeeba entry |
| Status | Enabled where required |
| Type | Package, Component, Plugin |
| Version | 7.8.9 or package-specific matching version |
| Author | Akeeba Ltd |

### 9.3 Check plugins

Navigate to:

```text
System → Manage → Plugins
```

Search for:

```text
Admin Tools
```

Verify required plugins are enabled. A Task plugin is needed only for related scheduled-task functionality.

### 9.4 Check database tables

Use the actual Joomla table prefix instead of `#__`.

Example inspection query:

```sql
SHOW TABLES LIKE '%admintools%';
```

Do not require a hard-coded table count because the schema may differ by edition and release. The important result is that the component opens and does not report missing schema.

### 9.5 Check logs

Review:

```text
System → Maintenance → System Information
System → Manage → Extensions
Components → Admin Tools → Security Exceptions Log
```

Also inspect the Joomla log directory configured in `configuration.php`.

### 9.6 Check extension updates

Navigate to:

```text
System → Update → Extensions
```

Clear the update cache and check for updates. Admin Tools should have an active official update site.

---

## 10. Functional Test Checklist

### Joomla administrator

- [ ] Log in successfully using a valid Super User account.
- [ ] Log out and log in again.
- [ ] A single invalid login does not unexpectedly block the developer IP.
- [ ] Global Configuration opens and saves.
- [ ] Extension Manager opens.
- [ ] Plugin Manager opens.
- [ ] Media Manager opens.
- [ ] An image can be uploaded.
- [ ] Template settings open and save.
- [ ] Joomla Scheduled Tasks open and run.
- [ ] Joomla extension update checking works.

### Joomla frontend

- [ ] The homepage loads without HTTP 403 or 500.
- [ ] CSS and JavaScript assets load.
- [ ] Images load.
- [ ] SEF URLs work.
- [ ] Login and logout work.
- [ ] Search works.
- [ ] Contact or custom forms submit successfully.
- [ ] AJAX-based features work.
- [ ] File uploads work where expected.

### Project extensions

- [ ] AcyMailing subscription form works.
- [ ] AcyMailing sends a test email.
- [ ] HikaShop cart and checkout work.
- [ ] HikaShop payment callbacks are accepted.
- [ ] RSForm Pro forms submit successfully.
- [ ] RSForm Pro upload fields work.
- [ ] JCE file browser and uploads work.
- [ ] SP Page Builder editor opens and saves.
- [ ] DJ Image Slider assets load.
- [ ] JCH Optimize does not produce blocked asset URLs.
- [ ] Custom components and plugins work.

### API and integrations

- [ ] Joomla API endpoints under `/api/index.php/v1/` work.
- [ ] `com_ajax` endpoints work.
- [ ] External webhooks are accepted.
- [ ] Cron endpoints work.
- [ ] Payment provider callbacks work.
- [ ] Reverse proxy or CDN reports the correct client IP.

---

## 11. Web Application Firewall Validation

After enabling WAF protection, repeat all functional tests and review:

```text
Components → Admin Tools → Web Application Firewall → Security Exceptions Log
```

For each blocked request, record:

- Request date and time.
- URL and HTTP method.
- Component or endpoint.
- Security exception reason.
- Request source IP.
- Whether the request was legitimate.
- The narrow exception applied, if any.

### Correct false-positive handling

Use the narrowest possible exception based on the affected component, endpoint, or request condition.

Avoid these unsafe approaches:

```text
Disable the complete WAF permanently
Whitelist every POST request
Whitelist all API endpoints
Whitelist an entire third-party network without validation
Ignore repeated 403 responses
```

After adding an exception, reproduce the exact request and confirm that unrelated malicious-looking requests remain blocked.

---

## 12. Web-Server Configuration

Admin Tools Professional can generate configuration for supported web servers. Generate these rules only after Joomla and extension-level testing is complete.

### 12.1 Apache or LiteSpeed

Back up the current file:

```bash
cp .htaccess .htaccess.before-admin-tools
```

Open:

```text
Components → Admin Tools → .htaccess Maker
```

Generate conservative rules first. Immediately test:

- Frontend.
- Administrator.
- Static assets.
- API endpoints.
- Uploads.
- Webhooks.

Restore the previous file if necessary:

```bash
cp .htaccess.before-admin-tools .htaccess
```

### 12.2 Nginx

Nginx does not read `.htaccess`. Generate the Nginx configuration and include it in the relevant `server` block according to the deployment architecture.

Validate configuration before reload:

```bash
nginx -t
```

Reload only after validation succeeds:

```bash
sudo systemctl reload nginx
```

For Docker, update the mounted configuration and reload or restart the Nginx container according to the project deployment process.

### 12.3 Microsoft IIS

Back up `web.config` before using the IIS configuration maker. Validate rewrite and access-control behavior after generation.

---

## 13. Update Configuration

### Core edition

Use Joomla extension updates:

```text
System → Update → Extensions
```

### Professional edition

Configure the Akeeba update authentication or Download ID according to the active Akeeba subscription and current vendor documentation.

Security rules:

- Do not commit the Download ID to a public repository.
- Do not place it in screenshots or public documentation.
- Use environment-specific secret management where possible.
- Remove production credentials from cloned development databases.

After configuration:

1. Clear the Joomla update cache.
2. Check for updates.
3. Confirm that the official Admin Tools update site is enabled.
4. Confirm Joomla can retrieve update metadata without authentication errors.

---

## 14. Deployment to Another Environment

### Recommended strategy

Treat the original Admin Tools package as a deployment dependency.

For each target environment:

1. Deploy Joomla source code and database according to the project process.
2. Install the original Admin Tools package through Joomla or an approved automation process.
3. Apply environment-specific Admin Tools configuration.
4. Do not copy production IP allowlists into local development.
5. Do not copy production Download IDs into public configuration.
6. Rebuild web-server configuration for the target server.
7. Run the full verification checklist.

### Git considerations

Installing a Joomla extension changes both files and database records. Committing extension files alone does not reproduce the complete installation.

A deployment process must account for:

- Extension files.
- Joomla `#__extensions` records.
- Admin Tools database tables.
- Plugin enabled state.
- Update-site records.
- Configuration values.
- Web-server rules.

Do not assume that copying a Joomla database from another environment is always safe. IP addresses, domains, proxy settings, secret URLs, paths, and notification email addresses may be environment-specific.

---

## 15. Troubleshooting

### 15.1 Upload size error

Symptoms:

```text
The uploaded file exceeds the upload_max_filesize directive
Maximum PHP upload size exceeded
```

Check PHP settings:

```ini
upload_max_filesize = 16M
post_max_size = 16M
memory_limit = 256M
```

Restart or reload the PHP service after changing configuration. Alternatively, use **Install from Folder**.

### 15.2 Temporary directory error

Symptoms:

```text
JFolder::create: Could not create directory
Unable to write entry
Path does not have a valid package
```

Verify:

- `configuration.php` contains the correct absolute temporary path.
- The directory exists.
- The web-server user can write to it.
- The disk is not full.

Example:

```bash
mkdir -p /path/to/joomla/tmp
chown -R www-data:www-data /path/to/joomla/tmp
chmod 755 /path/to/joomla/tmp
```

Adjust user and path for the actual environment.

### 15.3 HTTP 403 after setup

Possible causes:

- WAF false positive.
- Administrator IP restriction.
- Secret administrator URL setting.
- Generated `.htaccess` or Nginx rule.
- Incorrect reverse-proxy client IP detection.

Actions:

1. Check the Security Exceptions Log.
2. Identify the exact blocked endpoint.
3. Disable only the suspected rule.
4. Reproduce the request.
5. Add a narrow exception only when the request is confirmed legitimate.

### 15.4 HTTP 500 after generating `.htaccess`

Restore the previous file:

```bash
cp .htaccess.before-admin-tools .htaccess
```

Then review unsupported Apache directives and server modules before regenerating rules.

### 15.5 CSS, JavaScript, or images are blocked

Check browser developer tools for HTTP 403 responses. Review direct-file-access rules and Security Exceptions Log.

Do not disable all protection before determining the affected path.

### 15.6 API or webhook fails

Capture:

- URL.
- HTTP method.
- Request headers.
- Response status.
- Response body.
- Admin Tools security exception reason.

Create a narrow exception for the verified endpoint. Retest invalid requests to ensure the exception is not too broad.

### 15.7 Extension appears in files but not Joomla

Use:

```text
System → Install → Discover
```

If Discover does not list the extension, verify that its manifest is in the correct directory and that the extracted file structure matches the Joomla manifest.

### 15.8 Component opens with missing tables

Reinstall the exact original Admin Tools package through **Upload Package File**. Joomla extension reinstall normally refreshes files and runs required installation/update logic without requiring manual SQL edits.

Always back up first.

---

## 16. Emergency Recovery

### Recovery principle

Before enabling strong administrator protection, keep an authenticated administrator browser session open and confirm direct filesystem access is available.

### 16.1 Restore web-server configuration

For Apache:

```bash
cp .htaccess.before-admin-tools .htaccess
```

For Nginx, remove or disable the generated include, validate with `nginx -t`, and reload Nginx.

### 16.2 Locate Admin Tools plugin directories

Use filesystem search instead of guessing folder names:

```bash
find plugins -maxdepth 3 -iname '*admintools*' -print
find administrator -maxdepth 4 -iname '*admintools*' -print
```

### 16.3 Temporarily disable the system plugin directory

Only after identifying the exact Admin Tools system plugin directory, rename it temporarily. Example pattern:

```bash
mv plugins/system/IDENTIFIED_ADMIN_TOOLS_DIRECTORY \
   plugins/system/IDENTIFIED_ADMIN_TOOLS_DIRECTORY.disabled
```

Then try to open Joomla administrator again.

After access is restored:

1. Disable or correct the offending rule.
2. Restore the plugin directory name.
3. Clear Joomla and browser cache.
4. Confirm the plugin is enabled correctly.
5. Repeat frontend and administrator tests.

Do not rename unrelated Joomla system, services, authentication, or user plugins.

### 16.4 Database fallback

Direct database modification should be a last resort. Back up the database first and identify the exact extension record using queries rather than hard-coded IDs.

Example inspection query:

```sql
SELECT extension_id, name, type, element, folder, enabled
FROM `PREFIX_extensions`
WHERE name LIKE '%Admin Tools%'
   OR element LIKE '%admintools%';
```

Replace `PREFIX_` with the real Joomla database prefix. Do not modify records until the exact system plugin has been identified.

---

## 17. Uninstallation

Before uninstalling Admin Tools:

1. Back up the website and database.
2. Export or document required configuration.
3. Restore or replace generated `.htaccess`, Nginx, or IIS rules.
4. Confirm no deployment automation depends on Admin Tools CLI or scheduled tasks.
5. Confirm removing the extension will not leave the administrator protected by an unknown external rule.

Navigate to:

```text
System → Manage → Extensions
```

Search for the **Admin Tools package** and uninstall the package instead of removing individual child plugins first.

After uninstalling:

- Clear Joomla cache.
- Verify frontend and administrator access.
- Check remaining Akeeba-related entries.
- Check scheduled tasks.
- Check update sites.
- Review the database for leftovers only if there is a confirmed uninstall problem.

Do not manually delete database tables unless backup and retention requirements are understood.

---

## 18. Production Readiness Checklist

### Installation

- [ ] The official Admin Tools 7.8.9 package was used.
- [ ] The selected Core or Professional edition matches the project license.
- [ ] Installation completed without Joomla errors.
- [ ] The Admin Tools dashboard opens.
- [ ] Required component and plugins are present.
- [ ] The installed version is verified.
- [ ] Update-site configuration works.

### Configuration

- [ ] Security exception logging is enabled.
- [ ] WAF was enabled gradually.
- [ ] Administrator protection was tested without lockout.
- [ ] Automatic IP blocking was tested.
- [ ] Proxy or CDN client IP detection is correct.
- [ ] Notification email does not overload PHP workers or mail delivery.
- [ ] Environment-specific IP and URL settings were reviewed.

### Regression testing

- [ ] Joomla frontend passes testing.
- [ ] Joomla administrator passes testing.
- [ ] API endpoints pass testing.
- [ ] AJAX requests pass testing.
- [ ] Forms and uploads pass testing.
- [ ] AcyMailing passes testing.
- [ ] HikaShop and payment callbacks pass testing.
- [ ] RSForm Pro passes testing.
- [ ] JCE passes testing.
- [ ] SP Page Builder passes testing.
- [ ] Custom extensions pass testing.
- [ ] Cron jobs and Scheduled Tasks pass testing.

### Recovery

- [ ] Source and database backups are available.
- [ ] The previous web-server configuration is available.
- [ ] The team knows how to locate and temporarily disable the Admin Tools system plugin.
- [ ] Direct filesystem or container access is available.
- [ ] Rollback was tested on staging.

### Final acceptance

Admin Tools is ready for production only when:

```text
Installation status: Successful
Joomla frontend test: Passed
Joomla administrator test: Passed
API and integration test: Passed
WAF false-positive review: Completed
Web-server configuration test: Passed
Rollback procedure: Verified
```

---

## Recommended Migration Approach from Joomla 3

For a rebuilt Joomla 6 project, install Admin Tools 7.8.9 as a fresh package and recreate security rules carefully.

Do not blindly import every Admin Tools 5.3.2 rule because the following may have changed:

- Joomla request routing.
- Administrator URLs.
- Installed extensions.
- API endpoints.
- Template assets.
- Upload paths.
- Server and reverse-proxy architecture.
- Payment and webhook integrations.

Migrate only reviewed items such as confirmed blocklists or narrow exceptions that remain valid in Joomla 6.

## Final Recommendation

Use **Upload Package File** for the normal installation. Use **Install from Folder** when upload limits prevent browser installation. Use **Discover** only for recovery or controlled file-based deployments where extension files are already in the correct Joomla directories.

Always configure Admin Tools gradually and validate every security layer before enabling it in production.
