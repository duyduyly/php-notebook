# JB Cookies 6.0.2 — Joomla 6 Installation and Verification Guide

## 1. Extension information

| Field                | Value                                |
| -------------------- | ------------------------------------ |
| Extension name       | JoomBall Cookies / JB Cookies        |
| Extension element    | `mod_jbcookies`                      |
| Extension type       | Site Module                          |
| Developer            | JoomBall Project                     |
| Recommended version  | `6.0.2`                              |
| Joomla compatibility | Joomla 3, 4, 5 and 6                 |
| Distribution         | Free download                        |
| Commercial edition   | No Pro edition identified            |
| Template requirement | Bootstrap-compatible Joomla template |

JB Cookies 6.0.2 is distributed as a Joomla module. The Joomla Extensions Directory identifies it as a free extension and confirms compatibility with Joomla 6. The extension also uses the Joomla Update System.

---

## 2. Official download links

### Recommended download source

Download the installable ZIP package from the official GitHub Releases page:

* **Official GitHub Releases:**
  `https://github.com/JoomBall/JBCookies/releases`

* **Joomla Extensions Directory listing:**
  `https://extensions.joomla.org/extension/joomball-cookies/`

* **Official source repository:**
  `https://github.com/JoomBall/JBCookies`

Select the latest release:

```text
mod_jbcookies_6.0.2
```

Download the asset that has the `.zip` extension and contains the installable Joomla module.

Do not use the following GitHub files as the Joomla installation package:

```text
Source code (zip)
Source code (tar.gz)
```

These files are GitHub-generated source archives and may not have the exact structure expected by the Joomla installer. Use the release asset prepared by the developer whenever it is available.

Version 6.0.2 is marked as the current release, while version 6.0.0 introduced Joomla 5 and Joomla 6 support.

---

## 3. Prerequisites

Before installing JB Cookies, confirm the following:

* Joomla 6 has been installed successfully.
* The Joomla administrator account has Super User permissions.
* The template supports Bootstrap.
* PHP ZIP support is enabled.
* Joomla temporary and log directories are writable.
* A database and file backup has been created.
* The website is being tested in a staging environment before production.

JB Cookies 6.x requires a Bootstrap-compatible template. The vendor specifically states that the 6.x frontend module works with templates using Bootstrap.

### Recommended backup

Before installation:

```text
System → Maintenance → Database
```

Confirm there are no database schema errors.

Create a complete backup using the project’s normal backup process or a Joomla backup extension.

---

# 4. Method 1 — Install using Joomla Upload Package File

This is the recommended installation method.

## Step 1: Download the package

Download the JB Cookies 6.0.2 installable ZIP package from:

```text
https://github.com/JoomBall/JBCookies/releases
```

Expected package name:

```text
mod_jbcookies_6.0.2.zip
```

Do not extract the ZIP file before using the normal Joomla installer.

## Step 2: Open the Joomla extension installer

Log in to the Joomla 6 administrator panel:

```text
https://your-domain.example/administrator
```

Navigate to:

```text
System
→ Install
→ Extensions
```

Depending on the administrator menu configuration, the page may also be accessible from:

```text
System
→ Install
→ Extensions
→ Upload Package File
```

## Step 3: Upload the ZIP package

In the **Upload Package File** tab:

1. Drag `mod_jbcookies_6.0.2.zip` into the upload area.
2. Alternatively, click **Browse for file**.
3. Select the ZIP package.
4. Wait for Joomla to upload and install it.
5. Confirm that Joomla displays a successful installation message.

Expected result:

```text
Installation of the module was successful.
```

## Step 4: Verify that the module is installed

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search for:

```text
JB Cookies
```

Or search by element:

```text
mod_jbcookies
```

Confirm:

| Field   | Expected value  |
| ------- | --------------- |
| Type    | Module          |
| Client  | Site            |
| Element | `mod_jbcookies` |
| Status  | Enabled         |
| Version | `6.0.2`         |

## Step 5: Create or open the module instance

Navigate to:

```text
Content
→ Site Modules
```

In some Joomla administrator layouts:

```text
System
→ Manage
→ Site Modules
```

Search for:

```text
JB Cookies
```

If an instance was created automatically, open it.

If no module instance exists:

1. Click **New**.
2. Select **JB Cookies**.
3. Enter the title:

```text
Cookie Consent
```

4. Set **Show Title** to `Hide`.
5. Set **Status** to `Published`.

## Step 6: Select the module position

The Joomla Extensions Directory recommends the `debug` position for this module.

Set:

```text
Position: debug
```

If the custom template does not define `debug`, select a template position that:

* Exists on every page.
* Is rendered near the end of the page.
* Is not visually restricted by a small container.
* Is not hidden on mobile devices.

To inspect available positions, temporarily enable:

```text
System
→ Global Configuration
→ Templates
→ Preview Module Positions: Enabled
```

Then access:

```text
https://your-domain.example/?tp=1
```

Disable module-position preview after testing.

## Step 7: Configure menu assignment

Open the **Menu Assignment** tab.

For a site-wide cookie notice, select:

```text
Module Assignment: On all pages
```

Do not limit the module to only the home page unless that is an explicit project requirement.

## Step 8: Configure languages

Open the language-related tab in the module configuration.

The vendor recommends reviewing the language tab after installation. Installed Joomla languages can be configured independently.

For every active site language:

1. Enable the language entry.
2. Enter the cookie notice title.
3. Enter the cookie notice description.
4. Configure the Accept button.
5. Configure the Reject button.
6. Configure the Settings button.
7. Configure cookie-group descriptions.
8. Link the relevant cookie or privacy-policy article.

Example English content:

```text
Title:
Cookie Settings

Description:
We use essential cookies to operate this website and optional cookies
to improve your experience. You can accept, reject, or configure your
cookie preferences.

Accept:
Accept all

Reject:
Reject optional cookies

Settings:
Cookie settings
```

Example Vietnamese content:

```text
Tiêu đề:
Cài đặt cookie

Nội dung:
Trang web sử dụng cookie thiết yếu để hoạt động và cookie tùy chọn để
cải thiện trải nghiệm của bạn. Bạn có thể chấp nhận, từ chối hoặc thay
đổi tùy chọn cookie.

Chấp nhận:
Chấp nhận tất cả

Từ chối:
Từ chối cookie tùy chọn

Cài đặt:
Cài đặt cookie
```

## Step 9: Configure the cookie policy article

Create or identify the relevant Joomla article:

```text
Content
→ Articles
```

Suggested article title:

```text
Cookie Policy
```

The article should describe:

* Essential cookies.
* Preference cookies.
* Analytics cookies.
* Marketing cookies.
* Third-party providers.
* Cookie lifetimes.
* How users can change consent.
* Contact information.

Select this article in the JB Cookies module configuration if the module provides a policy-article field.

## Step 10: Save the module

Click:

```text
Save
```

Then:

```text
Save & Close
```

Clear Joomla cache:

```text
System
→ Maintenance
→ Clear Cache
```

Also clear browser cookies before testing.

---

# 5. Method 2 — Install using Joomla Discover

## Important limitation

The **Discover** feature does not upload or extract the extension ZIP package.

Discover only detects extension files that have already been manually copied into the correct Joomla filesystem location.

Therefore, the process is:

```text
Download ZIP
→ Extract ZIP
→ Copy files to Joomla
→ Run Discover
→ Install discovered extension
```

Use this method only when:

* Normal ZIP installation fails.
* The project is managed through Git or deployment scripts.
* The files have already been deployed manually.
* The hosting upload limit prevents normal ZIP installation.
* A developer needs to install the extension from mounted source files.

For standard installations, use **Upload Package File** instead.

## Step 1: Download and extract the package

Download:

```text
mod_jbcookies_6.0.2.zip
```

Extract it locally.

The extracted package should contain files similar to:

```text
mod_jbcookies.xml
script.php
services/
src/
tmpl/
media/
language/
```

The current repository contains the modern Joomla extension directories `services`, `src`, `tmpl`, `media`, and the `mod_jbcookies.xml` manifest.

## Step 2: Identify the module source root

Confirm that the manifest file is at the root of the extracted module:

```text
mod_jbcookies/mod_jbcookies.xml
```

Do not copy an unnecessary parent directory such as:

```text
JBCookies-6.0.2/mod_jbcookies/
```

The directory copied into Joomla must directly contain the module manifest and PHP directories.

## Step 3: Copy module files

Copy the module files into:

```text
<Joomla root>/modules/mod_jbcookies/
```

Expected result:

```text
modules/
└── mod_jbcookies/
    ├── mod_jbcookies.xml
    ├── script.php
    ├── services/
    ├── src/
    ├── tmpl/
    └── ...
```

Example Docker command:

```bash
docker cp ./mod_jbcookies \
  <joomla-container>:/var/www/html/modules/mod_jbcookies
```

Example local project command:

```bash
cp -R ./mod_jbcookies \
  ./modules/mod_jbcookies
```

Adjust ownership when Joomla runs inside Linux or Docker:

```bash
chown -R www-data:www-data modules/mod_jbcookies
find modules/mod_jbcookies -type d -exec chmod 755 {} \;
find modules/mod_jbcookies -type f -exec chmod 644 {} \;
```

## Step 4: Copy media files when necessary

Some Joomla extensions place media files through the installer script rather than directly in the module directory.

If the extracted package contains media assets intended for Joomla’s root `media` directory, verify the install script before copying files manually.

Possible destination:

```text
<Joomla root>/media/mod_jbcookies/
```

or:

```text
<Joomla root>/media/jbmedia/
```

Do not guess the media destination. Check:

```text
mod_jbcookies.xml
script.php
```

Look for:

```xml
<media destination="...">
```

or PHP file-copy logic in `script.php`.

The normal Upload Package method is safer because Joomla performs these media-copy operations automatically.

## Step 5: Run Discover

In Joomla administrator, navigate to:

```text
System
→ Install
→ Discover
```

Click:

```text
Discover
```

Joomla should detect:

```text
JB Cookies
```

or:

```text
mod_jbcookies
```

## Step 6: Install the discovered module

1. Select the JB Cookies row.
2. Click **Install**.
3. Wait for the installation result.
4. Confirm that the extension is registered successfully.

## Step 7: Verify registration

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search:

```text
mod_jbcookies
```

Confirm that Joomla has created an extension record.

You may also verify it in the database:

```sql
SELECT
    extension_id,
    name,
    type,
    element,
    client_id,
    enabled,
    manifest_cache
FROM #__extensions
WHERE element = 'mod_jbcookies';
```

Expected result:

```text
type      = module
element   = mod_jbcookies
client_id = 0
enabled   = 1
```

## Step 8: Create and configure the module instance

Continue with the normal configuration process:

```text
Content
→ Site Modules
→ New
→ JB Cookies
```

Configure:

* Published status.
* Template position.
* All-pages menu assignment.
* Language content.
* Cookie categories.
* Cookie-policy article.
* Accept, Reject and Settings buttons.

---

# 6. Free and Pro upgrade process

## Current product model

JB Cookies is distributed as a free download. The Joomla Extensions Directory does not list a paid or Pro edition, and the official repository does not provide a commercial upgrade package.

Therefore:

```text
Free edition: Available
Pro edition: Not identified
Free-to-Pro upgrade: Not applicable
Subscription key: Not required
Download ID: Not required
```

Do not include the following instruction in the migration report:

```text
Install JB Cookies Free and then upload JB Cookies Pro.
```

That workflow applies to extensions that actually have separate Core and Professional packages, such as certain Akeeba products. It does not currently apply to JB Cookies.

## Updating the free version

JB Cookies supports the Joomla Update System.

To update:

```text
System
→ Update
→ Extensions
```

Click:

```text
Check for Updates
```

If a newer JB Cookies version appears:

1. Select JB Cookies.
2. Review the target version.
3. Create a backup.
4. Click **Update**.
5. Clear Joomla cache.
6. Retest the cookie banner and consent behavior.

The 6.0.1 release changed the update-server URL to:

```text
https://www.joomball.com/updates/mod_jbcookies.xml
```

This indicates that versions 6.0.1 and later are configured to use the current vendor update feed.

## Manual update

When Joomla Update does not detect the new release:

1. Download the newer installation ZIP.
2. Create a backup.
3. Navigate to:

```text
System
→ Install
→ Extensions
```

4. Upload the new ZIP over the existing installation.
5. Do not uninstall the old version first unless the vendor explicitly requires it.
6. Confirm that Joomla reports a successful installation or update.
7. Verify that the existing module configuration remains intact.
8. Retest all cookie functions.

---

# 7. Post-installation verification

## 7.1 Backend installation test

Navigate to:

```text
System
→ Manage
→ Extensions
```

Search for:

```text
mod_jbcookies
```

Pass conditions:

* Extension exists.
* Type is Module.
* Client is Site.
* Status is Enabled.
* Version is 6.0.2.
* No duplicate JB Cookies entries exist.

## 7.2 Module configuration test

Navigate to:

```text
Content
→ Site Modules
```

Open JB Cookies and verify:

* Status is `Published`.
* Module position exists in the active template.
* Menu assignment is `On all pages`.
* At least one language configuration is complete.
* Accept, Reject and Settings labels are configured.
* Cookie-policy content or article is configured.
* The module has been saved successfully.

## 7.3 Frontend display test

Open the website in a private/incognito browser window.

Expected behavior:

1. The cookie notice appears.
2. The notice is readable.
3. The modal is not transparent or hidden.
4. Accept, Reject and Settings buttons are visible.
5. The layout works on desktop and mobile.
6. The banner does not break the page layout.
7. No PHP error is displayed.
8. No JavaScript error prevents the modal from opening.

Test at minimum:

* Chrome.
* Edge.
* Firefox.
* Safari.
* Brave.
* Mobile viewport.

Version 6.0.2 specifically includes a fix for modal display in Brave, so Brave should be part of acceptance testing.

## 7.4 Browser-console test

Open browser Developer Tools:

```text
F12
→ Console
```

Reload the page.

Pass conditions:

* No `Uncaught TypeError`.
* No Bootstrap modal errors.
* No duplicate Bootstrap initialization.
* No missing JavaScript or CSS assets.
* No 404 response for JB Cookies assets.
* No Content Security Policy error caused by the module.

Also inspect:

```text
Developer Tools
→ Network
```

Filter using:

```text
jbcookies
cookie
jbmedia
```

All required assets should return:

```text
HTTP 200
```

## 7.5 Accept test

Before testing:

1. Delete all site cookies.
2. Open a private browser window.
3. Reload the home page.

Click:

```text
Accept all
```

Verify:

* The notice closes.
* The consent choice is stored.
* Reloading the page does not show the initial notice again.
* The expected optional cookies are allowed.
* The Settings interface reflects the accepted state.

## 7.6 Reject test

Delete all site cookies and reload.

Click:

```text
Reject
```

Verify:

* The notice closes.
* The rejection choice is stored.
* The notice does not immediately reopen.
* Optional analytics and marketing cookies are not created, where blocking has been properly integrated.
* Essential Joomla cookies continue to work.
* Login, session and CSRF functions are unaffected.

## 7.7 Cookie-settings test

Delete all site cookies and reload.

Click:

```text
Settings
```

Verify:

* The Bootstrap modal opens.
* Cookie groups are displayed in the configured order.
* Essential cookies cannot be disabled when they are mandatory.
* Optional categories can be enabled or disabled.
* Saving preferences closes the modal.
* Reloading preserves the selected preferences.

Version 6.0.2 includes changes related to displaying and sorting user-configured cookie groups.

## 7.8 Real cookie-blocking test

A visible cookie banner alone does not prove that tracking is blocked.

Open:

```text
Developer Tools
→ Application
→ Storage
→ Cookies
```

Before giving consent, check whether the website creates cookies belonging to:

* Google Analytics.
* Google Ads.
* Meta Pixel.
* YouTube.
* Vimeo.
* Hotjar.
* Microsoft Clarity.
* Other advertising or analytics providers.

Also inspect the Network panel for calls to:

```text
google-analytics.com
googletagmanager.com
connect.facebook.net
clarity.ms
hotjar.com
```

Pass condition:

```text
Non-essential tracking scripts and cookies do not run before the
required consent has been provided.
```

Important: JB Cookies may manage the consent interface, but the website may still require additional template, plugin, Google Tag Manager or script-loader configuration to prevent third-party scripts from loading before consent.

## 7.9 Multilingual test

For every published site language:

1. Change the frontend language.
2. Clear consent cookies.
3. Reload the page.
4. Confirm the notice appears in the correct language.
5. Verify all buttons.
6. Verify the cookie-policy article.
7. Check that no untranslated language keys appear.

Failure example:

```text
MOD_JBCOOKIES_ACCEPT
```

A raw language key indicates a missing or incorrectly loaded translation.

## 7.10 Responsive test

Test these viewport widths:

```text
320px
375px
768px
1024px
1440px
```

Verify:

* Text remains readable.
* Buttons do not overlap.
* The modal fits within the screen.
* The close button remains accessible.
* The page can still scroll.
* The banner does not cover important navigation or form controls.

## 7.11 Joomla debug test

Temporarily enable:

```text
System
→ Global Configuration
→ System
→ Debug System: Yes
```

Set appropriate error reporting in the staging environment:

```text
System
→ Global Configuration
→ Server
→ Error Reporting: Maximum
```

Reload the frontend and administrator module page.

Confirm there are no:

* PHP warnings.
* Deprecated API messages.
* Missing class errors.
* Undefined variable notices.
* Template layout errors.
* Database query errors.

Disable Debug System after testing.

---

# 8. Troubleshooting

## Module does not appear

Check:

```text
Content
→ Site Modules
```

Confirm:

* Status is Published.
* Position exists.
* Menu assignment includes the current page.
* Access is Public.
* Language is All or matches the current language.

Clear cache:

```text
System
→ Maintenance
→ Clear Cache
```

## Modal does not open

Likely causes:

* Template does not load Bootstrap.
* Bootstrap JavaScript is missing.
* Multiple Bootstrap versions conflict.
* Template overrides the modal styles.
* JavaScript compression changed execution order.

Test with Joomla’s default Cassiopeia template. If it works with Cassiopeia but not with the custom template, the issue is template compatibility rather than the JB Cookies installation.

## Banner is transparent or unreadable

Inspect the element using browser Developer Tools.

Check whether the custom template overrides:

```css
.modal
.modal-content
.bg-body
.bg-light
.text-body
```

Add template-level CSS overrides instead of editing the extension source directly.

## Discover does not find the module

Verify the exact path:

```text
modules/mod_jbcookies/mod_jbcookies.xml
```

Common incorrect path:

```text
modules/mod_jbcookies/JBCookies-master/mod_jbcookies.xml
```

The manifest must be directly inside:

```text
modules/mod_jbcookies/
```

Also confirm filesystem permissions allow Joomla to read the directory.

## Update is not detected

Navigate to:

```text
System
→ Update
→ Update Sites
```

Search for:

```text
JB Cookies
JoomBall
```

Confirm the update site is enabled.

Then:

```text
System
→ Update
→ Extensions
→ Check for Updates
```

If the update site is missing or broken, perform a manual package update.

---

# 9. Production acceptance checklist

## Installation

* [ ] JB Cookies 6.0.2 is installed.
* [ ] `mod_jbcookies` exists in Extension Manager.
* [ ] Only one active module instance is configured.
* [ ] The module is assigned to all required pages.
* [ ] The active template position is valid.

## Display

* [ ] Banner displays on first visit.
* [ ] Bootstrap modal opens successfully.
* [ ] Desktop layout passes.
* [ ] Mobile layout passes.
* [ ] Brave display passes.
* [ ] No console or network errors occur.

## Consent

* [ ] Accept action is stored.
* [ ] Reject action is stored.
* [ ] Settings action is stored.
* [ ] Users can revise their decision.
* [ ] Essential cookies continue to work.
* [ ] Optional scripts respect the selected consent.

## Content

* [ ] All active languages are configured.
* [ ] Cookie categories are accurate.
* [ ] Cookie-policy article is published.
* [ ] Privacy-policy links are valid.
* [ ] Button labels are understandable.

## Security and quality

* [ ] Joomla and browser caches were cleared.
* [ ] Debug testing produced no PHP errors.
* [ ] No unescaped administrator content appears.
* [ ] No third-party tracking runs before required consent.
* [ ] Backup and rollback procedures are available.

---

# 10. Final migration decision

```text
Installation method:
Upload Package File is recommended.

Discover method:
Supported only after the extracted extension files have been copied
manually to the correct Joomla module directory.

Edition:
Free only. No Pro edition or Free-to-Pro upgrade process was identified.

Recommended version:
6.0.2.

Joomla 6 status:
Supported by the vendor.

Production approval:
Approve only after Bootstrap-template compatibility, browser display,
multilingual content, and actual cookie-consent behavior have passed
testing.
```
