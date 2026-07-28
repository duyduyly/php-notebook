# Upgrade Admin Tools Core to Professional on Joomla 6

This guide explains how to replace **Admin Tools Core (Free)** with **Admin Tools Professional** on an existing Joomla 6 website.

## Summary

You do not normally need to uninstall Admin Tools Core before installing Admin Tools Professional. After purchasing or receiving a valid Akeeba subscription, download the Professional installation package and install it over the existing Core edition through Joomla's Extension Installer.

```text
Admin Tools Core 7.8.9
        ↓ Install Professional package
Admin Tools Professional 7.8.9
```

The Professional package replaces the Core edition and adds the Professional-only files and features. Existing Admin Tools configuration is normally retained, but the upgrade must still be tested on staging before production deployment.

## Requirements

Before upgrading, confirm:

- [ ] Joomla 6 is working normally.
- [ ] Admin Tools Core is installed and opens without errors.
- [ ] You have an active Akeeba subscription that includes Admin Tools Professional.
- [ ] You can log in to the Akeeba website and download the Professional package.
- [ ] You have Joomla Super User access.
- [ ] You have a current source-code backup.
- [ ] You have a current database backup.
- [ ] You have direct filesystem or container access in case administrator access is blocked.

## Upgrade Procedure

### Step 1: Record the current installation

Open:

```text
Components → Admin Tools
```

Record the installed version and any important configuration, including:

- WAF settings and exceptions.
- Administrator protection settings.
- IP allowlists and blocklists.
- Secret administrator URL parameter.
- Notification email addresses.
- Generated `.htaccess`, Nginx, or IIS rules.
- Scheduled tasks.

Export the configuration when the installed edition provides an export feature.

### Step 2: Create backups

Back up the Joomla files and database before changing editions.

Example database backup:

```bash
mysqldump -u DB_USER -p DB_NAME > before-admin-tools-professional.sql
```

For Apache or LiteSpeed, also back up the active `.htaccess` file:

```bash
cp .htaccess .htaccess.before-admin-tools-professional
```

### Step 3: Download the Professional package

1. Sign in to the official Akeeba website using the account that owns the subscription.
2. Open the Admin Tools download page.
3. Download the **Admin Tools Professional** package compatible with the installed Joomla and PHP versions.
4. Keep the downloaded file as a ZIP archive.

Official download page:

<https://www.akeeba.com/download/admintools.html>

Do not extract the package into the Joomla root, rename files inside the archive, or commit subscription credentials to Git.

### Step 4: Install Professional over Core

In Joomla Administrator, open:

```text
System → Install → Extensions
```

Under **Upload Package File**:

1. Select or drag the Admin Tools Professional ZIP package.
2. Wait for Joomla to complete the installation.
3. Do not refresh or close the browser during installation.

Expected result:

```text
Installation of the package was successful.
```

> **Do not uninstall Admin Tools Core first.** Uninstalling can remove extension records, files, or configuration that the Professional installer could otherwise upgrade in place.

### Step 5: Clear caches

Open:

```text
System → Maintenance → Clear Cache
```

Clear the Joomla cache and then refresh the administrator browser session.

### Step 6: Verify the Professional edition

Open:

```text
Components → Admin Tools
```

Confirm:

- The dashboard opens without a PHP or database error.
- The installed version is the expected version.
- Professional-only features are available.
- Existing configuration is still present.

Also check:

```text
System → Manage → Extensions
```

Search for `Admin Tools` and verify that the package, component, and supporting plugins are installed and enabled where required.

## Post-upgrade Tests

Run these tests immediately after upgrading:

- [ ] Joomla administrator login and logout work.
- [ ] The frontend homepage loads without HTTP `403` or `500`.
- [ ] Forms and file uploads work.
- [ ] AJAX requests work.
- [ ] Joomla API endpoints work.
- [ ] Payment callbacks and webhooks work.
- [ ] Scheduled tasks work.
- [ ] Security exception logging works.
- [ ] Existing WAF exceptions remain valid.
- [ ] Administrator protection does not lock out valid users.
- [ ] Generated web-server rules still allow CSS, JavaScript, images, and extension assets.

## Version Guidance

Prefer installing the same or a newer supported Professional version.

| Current installation | Professional package | Recommendation |
|---|---|---|
| Core 7.8.9 | Professional 7.8.9 | Preferred direct edition upgrade |
| Core 7.8.x | Newer supported Professional 7.8.x | Usually acceptable; review the release notes |
| Core 7.x | Professional from a newer major version | Check Joomla, PHP, and vendor compatibility first |
| Professional | Core | Not recommended unless intentionally downgrading the edition |

Do not install an older Professional package over a newer Core package unless Akeeba explicitly documents that downgrade path.

## License and Update Notes

Installing the Core package does not provide a free Professional license. Professional access requires a valid Akeeba subscription.

After installing Professional:

- Configure the Akeeba Download ID or update credentials using the supported Joomla/Akeeba interface when required.
- Never store the Download ID in a public repository.
- Confirm the official update site is enabled.
- Clear the Joomla extension-update cache and check for updates.
- Remove expired credentials when the project changes ownership or subscription accounts.

## Troubleshooting

### Professional features do not appear

1. Confirm that the downloaded file is the Professional package, not the Core package.
2. Confirm that installation completed successfully.
3. Clear Joomla and browser caches.
4. Open `System → Manage → Extensions` and verify the Admin Tools package and plugins.
5. Re-download the package from the subscribed Akeeba account if necessary.

### Installation fails

Check:

- PHP upload and post-size limits.
- Joomla temporary directory configuration.
- File and directory permissions.
- Available disk space.
- PHP and Joomla compatibility.
- Whether the package file is complete and unmodified.

When browser upload limits are the cause, use Joomla's **Install from Folder** method with the original package.

### The website returns HTTP 403 or 500

- Restore the previous `.htaccess` or server configuration.
- Review Admin Tools Security Exceptions.
- Temporarily disable only the confirmed Admin Tools system plugin when emergency recovery is required.
- Correct the offending rule before re-enabling protection.

## Rollback

Do not attempt to roll back by installing Core over Professional without reviewing Akeeba's documentation. A safer rollback is:

1. Restore the pre-upgrade source-code backup.
2. Restore the pre-upgrade database backup.
3. Restore the previous web-server configuration.
4. Clear Joomla and browser caches.
5. Retest frontend and administrator access.

## Final Checklist

- [ ] A valid Professional subscription was used.
- [ ] A backup was created before installation.
- [ ] Core was not uninstalled before the edition upgrade.
- [ ] The Professional package was installed through Joomla Extension Installer.
- [ ] The dashboard and Professional features were verified.
- [ ] Existing configuration was reviewed.
- [ ] Frontend, administrator, APIs, AJAX, forms, uploads, callbacks, and webhooks were tested.
- [ ] Update credentials were configured securely.
- [ ] Rollback access remains available.

## Final Recommendation

Install Admin Tools Professional directly over the existing Core edition using **System → Install → Extensions**. Do not uninstall Core first. Perform the edition upgrade on staging, verify all security rules and integrations, and only then repeat the process in production.