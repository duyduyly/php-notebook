# Admin Tools 7.8.9 Installation, Usage, and Verification Guide for Joomla 6

This guide explains how to install, configure, use, verify, troubleshoot, and safely operate **Akeeba Admin Tools 7.8.9** on **Joomla 6**.

> **Important:** Admin Tools is not only a plugin. It is distributed as a Joomla **package extension** containing a component and several supporting plugins.

> **Security warning:** Configure Admin Tools on staging first. Incorrect WAF, IP, administrator-protection, or web-server rules can block valid users, APIs, AJAX requests, payment callbacks, webhooks, or the complete Joomla administrator area.

## Table of Contents

1. [Extension Information](#1-extension-information)
2. [Official Download and Documentation](#2-official-download-and-documentation)
3. [Main Features](#3-main-features)
4. [Prerequisites](#4-prerequisites)
5. [Install Using Joomla Upload Package File](#5-install-using-joomla-upload-package-file)
6. [Install Using Install from Folder](#6-install-using-install-from-folder)
7. [Install Using Joomla Discover](#7-install-using-joomla-discover)
8. [Initial Setup](#8-initial-setup)
9. [How to Use Admin Tools](#9-how-to-use-admin-tools)
10. [Safe Configuration Order](#10-safe-configuration-order)
11. [Verify the Installation](#11-verify-the-installation)
12. [Functional Test Checklist](#12-functional-test-checklist)
13. [Troubleshooting and Emergency Recovery](#13-troubleshooting-and-emergency-recovery)
14. [Production Operation Guide](#14-production-operation-guide)
15. [Migration from Admin Tools 5.3.2](#15-migration-from-admin-tools-532)
16. [Final Checklist](#16-final-checklist)

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
| Recommended installation | Upload Package File |
| Configuration strategy | Fresh configuration with selective migration |
| Testing priority | Critical |

Admin Tools can affect incoming requests before Joomla completes request processing. Treat it as a security-critical extension rather than a normal content plugin.

---

## 2. Official Download and Documentation

- Latest Admin Tools downloads: <https://www.akeeba.com/download/admintools.html>
- Admin Tools 7.8.9 release page: <https://www.akeeba.com/download/admintools/7-8-9.html>
- Official Admin Tools documentation: <https://www.akeeba.com/documentation/admin-tools-joomla.html>
- Joomla extension installation documentation: <https://docs.joomla.org/Installing_an_extension>

Download the edition that matches the project license:

```text
Admin Tools Core
Admin Tools Professional
```

A Core package normally has a filename similar to:

```text
pkg_admintools-7.8.9-core.zip
```

The Professional package requires an eligible Akeeba account and subscription.

### Package rules

- Do not rename files inside the ZIP archive.
- Do not remove nested ZIP packages.
- Do not extract the package directly into the Joomla root.
- Do not install Core over Professional unless intentionally changing editions.
- Keep the original installer package for repeatable deployments.
- Never commit an Akeeba Download ID or subscription credential to Git.

---

## 3. Main Features

### 3.1 Web Application Firewall

The Web Application Firewall, or WAF, inspects requests before Joomla finishes processing them.

It can help detect or block:

- Suspicious request patterns.
- Common SQL injection attempts.
- File inclusion attempts.
- Repeated failed administrator logins.
- Forbidden administrator usernames.
- Known malicious IP addresses.
- Direct access to restricted files.
- Abnormal request parameters.

Menu path:

```text
Components → Admin Tools → Web Application Firewall
```

The WAF is the most important Admin Tools feature, but it can also create false positives. Always test forms, APIs, AJAX, uploads, callbacks, and webhooks after changing WAF settings.

### 3.2 Administrator Protection

Admin Tools can protect `/administrator` with additional controls:

- Administrator Secret URL Parameter.
- Administrator Exclusive Allow IP List.
- HTTP password protection on supported Apache or LiteSpeed servers.
- Failed-login monitoring.
- Automatic IP blocking.
- Forbidden username blocking.

Example secret URL:

```text
https://example.com/administrator?secureadmin
```

Do not enable an exclusive administrator IP allowlist when your IP changes frequently, such as on mobile networks, home Internet, or changing VPN endpoints.

### 3.3 Security Exceptions and Blocked Request Logs

The security log helps identify why a request was blocked.

Typical information includes:

- Date and time.
- Source IP.
- URL and HTTP method.
- Component or endpoint.
- User agent.
- Security exception reason.

Use this log first when a valid form, API, upload, webhook, or administrator feature returns HTTP `403`.

### 3.4 IP Blocking

Admin Tools can manage:

- Permanently denied IP addresses.
- Allowed IP addresses.
- Administrator-only IP allowlists.
- Automatically blocked IP addresses.
- Automatic block history.

Do not permanently block an IP based on one unverified request. Proxy, CDN, office, and mobile IP addresses may be shared or may change.

### 3.5 Web-Server Configuration Makers

Use the correct feature for the actual web server:

| Web server | Admin Tools feature |
|---|---|
| Apache / LiteSpeed | `.htaccess Maker` |
| Nginx | NginX Configuration Maker |
| Microsoft IIS | `web.config Maker` |

These tools can add rules for:

- Blocking sensitive files.
- Disabling directory listing.
- Restricting PHP execution in selected directories.
- HTTPS redirection.
- Domain canonicalization.
- Security headers.
- Direct-file-access protection.

Generate web-server rules only after Joomla-level testing is complete.

### 3.6 PHP File Change Scanner

The scanner can detect files that are:

- Newly created.
- Modified.
- Deleted.
- Potentially suspicious.

A high threat score does not automatically prove that a file is malware. Legitimate extension and custom-code files may contain functions that require manual review.

Use Git history, Joomla core packages, extension packages, and vendor checksums when reviewing scan results.

### 3.7 Permission Repair

Admin Tools can help restore configured file and directory permissions.

Common values are:

```text
Files:       0644
Directories: 0755
```

Do not use `0777` as a general fix.

In Docker, permission issues may also depend on volume ownership, container UID/GID, Apache or PHP-FPM users, and host filesystem behavior.

### 3.8 Maintenance and Automation

Depending on the installed edition and configuration, Admin Tools may assist with:

- Cache cleanup.
- Temporary-directory cleanup.
- Security-log cleanup.
- Session maintenance.
- Scheduled file scans.
- Joomla Scheduled Tasks integration.
- CLI or cron-based automation.

### 3.9 URL Redirection

Redirect management is useful when Joomla 3 URLs change during migration to Joomla 6.

Example:

```text
/old-contact-page → /contact-us
```

Use permanent `301` redirects only when the new destination is final. Avoid redirect loops.

---

## 4. Prerequisites

Before installation, confirm:

- [ ] Joomla 6 is installed and working.
- [ ] You can log in as a Super User.
- [ ] The PHP version is supported.
- [ ] Joomla temporary and log paths are valid.
- [ ] Joomla can write to extension directories.
- [ ] The database user can create and alter tables.
- [ ] A source-code backup exists.
- [ ] A database backup exists.
- [ ] Direct filesystem or container access is available.
- [ ] Existing `.htaccess`, Nginx, or IIS configuration is backed up.

Check paths in:

```text
System → Global Configuration → Server
```

Example `configuration.php` values:

```php
public $tmp_path = '/absolute/path/to/tmp';
public $log_path = '/absolute/path/to/administrator/logs';
```

Example database backup:

```bash
mysqldump -u DB_USER -p DB_NAME > before-admin-tools.sql
```

Example Apache configuration backup:

```bash
cp .htaccess .htaccess.before-admin-tools
```

---

## 5. Install Using Joomla Upload Package File

This is the recommended installation method.

### Step 1: Download the package

Download Admin Tools 7.8.9 from the official Akeeba website. Keep the installer as a ZIP file.

### Step 2: Log in to Joomla

```text
https://your-domain.example/administrator
```

Use a Super User account.

### Step 3: Open the installer

```text
System → Install → Extensions
```

### Step 4: Upload the package

Under **Upload Package File**:

1. Select or drag the Admin Tools ZIP package.
2. Wait for Joomla to upload and install it.
3. Do not refresh or close the browser during installation.

Expected message:

```text
Installation of the package was successful.
```

### Step 5: Open Admin Tools

```text
Components → Admin Tools
```

Allow the first-run initialization to complete.

### Step 6: Clear Joomla cache

```text
System → Maintenance → Clear Cache
```

### Step 7: Verify child extensions

```text
System → Manage → Extensions
```

Search for:

```text
Admin Tools
```

Confirm that the package, component, and supporting plugins are present.

---

## 6. Install Using Install from Folder

Use this method when browser upload limits prevent normal upload.

### Step 1: Extract the package into a temporary directory

```bash
mkdir -p /path/to/joomla/tmp/admin-tools-install
unzip pkg_admintools-7.8.9-core.zip -d /path/to/joomla/tmp/admin-tools-install
```

Do not extract directly into the Joomla root.

### Step 2: Open Install from Folder

```text
System → Install → Extensions → Install from Folder
```

Enter:

```text
/path/to/joomla/tmp/admin-tools-install
```

Click **Check and Install**.

### Step 3: Remove temporary files

```bash
rm -rf /path/to/joomla/tmp/admin-tools-install
```

---

## 7. Install Using Joomla Discover

### When Discover is appropriate

Use Discover when extension files already exist in the correct Joomla directories but extension database records are missing.

Examples:

- Files were deployed using Git, rsync, or a Docker image.
- Installation stopped after copying files.
- A database was recreated.
- Extension files exist but Joomla does not list the extension.

> **Discover is not the preferred first installation method for Admin Tools.** Package installation is safer because it executes manifests, dependencies, and installation scripts in the expected order.

### Step 1: Inspect package contents

```bash
mkdir -p /tmp/admin-tools-package
unzip pkg_admintools-7.8.9-core.zip -d /tmp/admin-tools-package
find /tmp/admin-tools-package -maxdepth 5 -type f
find /tmp/admin-tools-package -maxdepth 5 -name '*.xml'
find /tmp/admin-tools-package -maxdepth 5 -name '*.zip'
```

### Step 2: Read each extension manifest

Do not guess target directories or plugin folder names. Read each XML manifest and follow its `<files>`, `<folder>`, `<filename>`, and `<media>` definitions.

Typical Joomla targets may include:

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

### Step 3: Preserve ownership and permissions

Example only:

```bash
chown -R www-data:www-data administrator/components/com_admintools
chown -R www-data:www-data media/com_admintools
```

Use project-specific ownership. Do not apply `777` permissions.

### Step 4: Run Discover

```text
System → Install → Discover
```

Then:

1. Click **Discover**.
2. Search for Admin Tools or Akeeba entries.
3. Install the component and required plugins according to dependencies.
4. Repeat Discover after each installation if necessary.
5. Stop if Joomla reports missing dependencies or installation-script errors.
6. Use the original package installer when Discover cannot complete installation safely.

### Step 5: Rebuild update sites

```text
System → Update → Update Sites
```

Rebuild update sites if required, then clear the extension-update cache.

### Discover acceptance criteria

- [ ] Admin Tools opens without an exception.
- [ ] All required plugins are registered.
- [ ] Database schema initializes successfully.
- [ ] Update sites exist.
- [ ] No missing-file warnings appear.
- [ ] Frontend and administrator requests work normally.

---

## 8. Initial Setup

Open:

```text
Components → Admin Tools
```

Run the Quick Setup Wizard once with conservative settings.

### Enable first

- Security exception logging.
- Basic malicious-request protection.
- Failed administrator-login monitoring.
- Standard request filtering recommended by the vendor.

### Postpone until testing is complete

- Administrator Exclusive Allow IP List.
- Administrator Secret URL Parameter.
- Country blocking.
- Aggressive automatic IP blocking.
- Immediate email for every blocked request.
- Strict direct-file-access restrictions.
- New `.htaccess`, Nginx, or IIS rules.
- Broad upload restrictions.

Keep an authenticated administrator tab open while enabling stronger protection.

---

## 9. How to Use Admin Tools

### 9.1 Configure the WAF

Open:

```text
Components → Admin Tools → Web Application Firewall → Configure WAF
```

Recommended process:

1. Enable logging.
2. Enable one group of protections.
3. Save the configuration.
4. Test frontend and administrator functions.
5. Review the Security Exceptions Log.
6. Fix false positives before enabling the next group.

Do not change many unrelated rules at once. Incremental changes make troubleshooting possible.

### 9.2 Review blocked requests

Open the blocked-request or security-exception log from the WAF section.

For every suspicious or valid blocked request, record:

- Request time.
- URL.
- HTTP method.
- Component or endpoint.
- Source IP.
- Exception reason.
- Whether the request was legitimate.

### 9.3 Handle a legitimate request blocked by WAF

Example: an RSForm Pro submission returns `403 Forbidden`.

1. Reproduce the error and note the exact time.
2. Open the Security Exceptions Log.
3. Find the matching request.
4. Confirm the user, URL, component, and request are legitimate.
5. Create the narrowest supported exception.
6. Submit the form again.
7. Confirm unrelated suspicious requests remain blocked.

Avoid:

```text
Disabling the complete WAF
Allowing every POST request
Whitelisting every API endpoint
Whitelisting an entire network without verification
```

### 9.4 Configure administrator protection

Configure one feature at a time:

1. Failed-login monitoring.
2. Automatic blocking with a moderate threshold.
3. Secret URL parameter, if required.
4. IP restriction only when reliable static IP access exists.
5. HTTP password protection only on a supported server.

After every change:

- Open a private browser window.
- Test the correct administrator URL.
- Test login and logout.
- Confirm filesystem recovery access remains available.

### 9.5 Configure automatic IP blocking

A reasonable starting policy is:

```text
Block after:        5–10 violations
Observation period: 10–30 minutes
Block duration:     15–60 minutes
```

These are starting values, not mandatory vendor defaults. Adjust them based on traffic, false positives, proxy architecture, and security requirements.

### 9.6 Configure email notifications

First verify Joomla email:

```text
System → Global Configuration → Server → Mail → Send Test Mail
```

Prefer alerts for important events:

- Successful or failed backend login when relevant.
- Automatic IP blocking.
- Important security exceptions.
- Suspicious file changes.

Do not send an email for every blocked bot request. High-volume notifications can overload mail delivery or PHP workers.

### 9.7 Use PHP File Change Scanner

Create a baseline after Joomla and all extensions are stable:

```text
Components → Admin Tools → PHP File Change Scanner → Scan Now
```

Review results using this priority:

| Result | Recommended action |
|---|---|
| Expected Joomla update | Verify version or checksum |
| Expected extension update | Compare with vendor package |
| Custom-code change | Compare with Git |
| PHP file in upload directory | Investigate immediately |
| Unknown new PHP file | Quarantine and investigate |
| Obfuscated code | High-priority review |

Do not immediately delete suspicious files. Back them up or move them outside the web root before analysis.

### 9.8 Schedule scans and maintenance

Open:

```text
System → Scheduled Tasks
```

Use the available Admin Tools task types for file scans or maintenance. Confirm the related Task plugin is enabled.

Run the task manually once before relying on cron or scheduled execution.

### 9.9 Use `.htaccess` Maker

For Apache or LiteSpeed only:

```bash
cp .htaccess .htaccess.before-admin-tools
```

Then open:

```text
Components → Admin Tools → .htaccess Maker
```

Enable conservative rules first. Immediately test:

- Homepage.
- Administrator.
- CSS, JavaScript, and images.
- API endpoints.
- Uploads.
- Forms.
- Payment callbacks.
- Webhooks.

Rollback if necessary:

```bash
cp .htaccess.before-admin-tools .htaccess
```

### 9.10 Use Nginx Configuration Maker

Nginx does not read `.htaccess`.

Generate the configuration, add it to the correct Nginx server block, and test:

```bash
nginx -t
```

Reload only after validation succeeds:

```bash
sudo systemctl reload nginx
```

For Docker, update the mounted configuration and restart or reload the appropriate container.

### 9.11 Use permission repair

Before running Fix Permissions:

1. Confirm expected file and directory permission values.
2. Confirm the PHP or web-server user.
3. Check Docker UID/GID and volume ownership.
4. Back up or commit current filesystem changes.
5. Run the repair.
6. Test uploads, cache, logs, and extension installation.

### 9.12 Export settings

After configuration is stable, export or document the Admin Tools settings.

Review environment-specific values before importing elsewhere:

- Domain.
- HTTPS state.
- IP allowlists.
- Proxy settings.
- Secret administrator URL.
- Notification email.
- Filesystem paths.
- Web-server type.

Do not blindly import production IP or secret configuration into local development.

---

## 10. Safe Configuration Order

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
10. Create the PHP File Scanner baseline
11. Configure scheduled tasks
12. Generate web-server rules last
13. Run complete regression testing
14. Export the final configuration
15. Deploy to production
```

Do not enable IP restrictions, a secret administrator URL, aggressive auto-blocking, and strict web-server rules simultaneously.

---

## 11. Verify the Installation

### Component check

```text
Components → Admin Tools
```

Success criteria:

- Dashboard opens.
- No PHP fatal error appears.
- No missing-table error appears.
- Version 7.8.9 is shown.
- Configuration pages can be opened and saved.

### Extension check

```text
System → Manage → Extensions
```

Search for Admin Tools and verify the expected package, component, and plugins.

| Field | Expected result |
|---|---|
| Name | Admin Tools or related Akeeba entry |
| Status | Enabled where required |
| Type | Package, Component, Plugin |
| Version | 7.8.9 or matching child version |
| Author | Akeeba Ltd |

### Plugin check

```text
System → Manage → Plugins
```

Search for Admin Tools. Enable only plugins required for the features in use.

### Database check

Use the real Joomla table prefix:

```sql
SHOW TABLES LIKE '%admintools%';
```

Do not require a fixed table count. The component must open without reporting an incomplete schema.

### Update-site check

```text
System → Update → Extensions
```

Clear the update cache and check for updates. Confirm the official Admin Tools update site is enabled.

---

## 12. Functional Test Checklist

### Joomla administrator

- [ ] Valid Super User login succeeds.
- [ ] Logout and login work.
- [ ] One invalid login does not unexpectedly block the developer.
- [ ] Global Configuration opens and saves.
- [ ] Extension Manager opens.
- [ ] Media Manager and uploads work.
- [ ] Template settings open and save.
- [ ] Scheduled Tasks open and run.

### Joomla frontend

- [ ] Homepage loads without `403` or `500`.
- [ ] CSS, JavaScript, and images load.
- [ ] SEF URLs work.
- [ ] Login and logout work.
- [ ] Search works.
- [ ] Forms submit successfully.
- [ ] AJAX features work.
- [ ] File uploads work.

### Project extensions

- [ ] AcyMailing subscription and test email work.
- [ ] HikaShop cart and checkout work.
- [ ] Payment callbacks are accepted.
- [ ] RSForm Pro submissions and uploads work.
- [ ] JCE media browser and uploads work.
- [ ] SP Page Builder opens and saves.
- [ ] DJ Image Slider assets load.
- [ ] JCH Optimize does not generate blocked asset URLs.
- [ ] Custom components and plugins work.

### API and integrations

- [ ] `/api/index.php/v1/` endpoints work.
- [ ] `com_ajax` endpoints work.
- [ ] Webhooks work.
- [ ] Cron endpoints work.
- [ ] Reverse proxy or CDN passes the correct client IP.

---

## 13. Troubleshooting and Emergency Recovery

### HTTP 403

Possible causes:

- WAF false positive.
- Administrator IP restriction.
- Secret administrator URL.
- Generated web-server rule.
- Incorrect proxy IP detection.

Actions:

1. Check the Security Exceptions Log.
2. Identify the exact endpoint and reason.
3. Disable only the suspected rule.
4. Reproduce the request.
5. Add a narrow exception only for a verified legitimate request.

### HTTP 500 after `.htaccess` generation

```bash
cp .htaccess.before-admin-tools .htaccess
```

Review unsupported Apache directives or missing modules before regenerating.

### API, webhook, or form failure

Capture:

- URL.
- HTTP method.
- Headers.
- Response status and body.
- Admin Tools exception reason.

Create an endpoint-specific exception only after verifying the request.

### Restore access to administrator

Before enabling strong protection, keep a logged-in administrator session open and verify filesystem access.

For Apache, restore the previous `.htaccess`.

Locate Admin Tools paths instead of guessing:

```bash
find plugins -maxdepth 3 -iname '*admintools*' -print
find administrator -maxdepth 4 -iname '*admintools*' -print
```

Temporarily rename only the confirmed Admin Tools system plugin directory when necessary:

```bash
mv plugins/system/CONFIRMED_ADMIN_TOOLS_DIRECTORY \
   plugins/system/CONFIRMED_ADMIN_TOOLS_DIRECTORY.disabled
```

After access is restored:

1. Correct the offending rule.
2. Restore the plugin directory name.
3. Clear Joomla and browser cache.
4. Confirm the plugin is enabled.
5. Repeat frontend and administrator testing.

Do not rename unrelated system, services, authentication, or user plugins.

### Database fallback

Use direct database modification only as a last resort and only after backup.

```sql
SELECT extension_id, name, type, element, folder, enabled
FROM `PREFIX_extensions`
WHERE name LIKE '%Admin Tools%'
   OR element LIKE '%admintools%';
```

Replace `PREFIX_` with the real Joomla prefix. Identify the exact record before making any change.

---

## 14. Production Operation Guide

### Daily or when alerted

- Review unusual administrator login alerts.
- Investigate new HTTP `403` errors.
- Confirm critical APIs, webhooks, and payment callbacks.
- Review automatically blocked IP addresses when users report access problems.

### Weekly

- Review Security Exceptions and blocked-request logs.
- Check for false positives.
- Review automatically blocked IP addresses.
- Check Joomla and extension updates.
- Review scheduled-task failures.

### Monthly

- Run or review a complete file-change scan.
- Review WAF exceptions and remove obsolete entries.
- Export or document the current configuration.
- Verify backup and rollback procedures.
- Review administrator accounts.
- Retest web-server rules after major extension or server changes.

### After every extension or Joomla update

- Test frontend and administrator access.
- Test forms, APIs, AJAX, uploads, and webhooks.
- Review new file-scanner results.
- Review security logs for new false positives.
- Regenerate web-server rules only when necessary.

---

## 15. Migration from Admin Tools 5.3.2

For a rebuilt Joomla 6 project, install Admin Tools 7.8.9 as a fresh package and recreate security configuration carefully.

Do not blindly import all Admin Tools 5.3.2 settings because these may have changed:

- Joomla request routing.
- Administrator URLs.
- Installed extensions.
- API endpoints.
- Template assets.
- Upload paths.
- Server and reverse-proxy architecture.
- Payment and webhook integrations.

Migrate only reviewed values, such as confirmed blocklists or narrow exceptions that remain valid.

Recommended approach:

```text
1. Install Admin Tools 7.8.9 on Joomla 6 staging
2. Run conservative initial setup
3. Recreate WAF rules gradually
4. Retest every project extension
5. Recreate administrator protection
6. Generate new server-level rules
7. Export the validated Joomla 6 configuration
8. Deploy to production
```

---

## 16. Final Checklist

### Installation

- [ ] Official Admin Tools 7.8.9 package was used.
- [ ] Correct Core or Professional edition was selected.
- [ ] Installation completed without Joomla errors.
- [ ] Dashboard opens.
- [ ] Required component and plugins exist.
- [ ] Version is verified.
- [ ] Update site works.

### Configuration

- [ ] Security logging is enabled.
- [ ] WAF was enabled gradually.
- [ ] Administrator protection was tested without lockout.
- [ ] Automatic IP blocking was tested.
- [ ] Proxy or CDN client-IP detection is correct.
- [ ] Email notification volume is controlled.
- [ ] File Scanner baseline exists.
- [ ] Environment-specific IP and URL values were reviewed.

### Regression testing

- [ ] Frontend passes.
- [ ] Administrator passes.
- [ ] APIs pass.
- [ ] AJAX passes.
- [ ] Forms and uploads pass.
- [ ] AcyMailing passes.
- [ ] HikaShop and payment callbacks pass.
- [ ] RSForm Pro passes.
- [ ] JCE passes.
- [ ] SP Page Builder passes.
- [ ] Custom extensions pass.
- [ ] Cron and Scheduled Tasks pass.

### Recovery

- [ ] Source and database backups exist.
- [ ] Previous web-server configuration exists.
- [ ] Direct filesystem or container access is available.
- [ ] The team knows how to temporarily disable the confirmed Admin Tools system plugin.
- [ ] Rollback was tested on staging.

### Final acceptance

```text
Installation status: Successful
Joomla frontend test: Passed
Joomla administrator test: Passed
API and integration test: Passed
WAF false-positive review: Completed
File Scanner baseline: Created
Web-server configuration test: Passed
Rollback procedure: Verified
```

## Final Recommendation

Use **Upload Package File** for normal installation. Use **Install from Folder** when upload limits prevent browser installation. Use **Discover** only for recovery or controlled file-based deployment.

Configure Admin Tools gradually. Validate each security layer before enabling the next one, and never treat “enable every option” as a secure production strategy.
