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

---

# Additional Guide: Features and Configuration

# JB Cookies — Features and Configuration Guide for Joomla 6

## 1. Extension này dùng để làm gì?

**JB Cookies**, còn được gọi là **JoomBall Cookies**, là một Joomla site module dùng để:

* Hiển thị thông báo website đang sử dụng cookie.
* Cho phép người dùng chấp nhận hoặc từ chối cookie.
* Hiển thị màn hình cấu hình cookie preferences.
* Phân loại cookie theo từng nhóm.
* Liên kết hoặc hiển thị nội dung Cookie Policy.
* Hỗ trợ website đa ngôn ngữ.
* Lưu lựa chọn consent mà không cần tải lại trang.
* Hiển thị giao diện responsive trên desktop và mobile.

Extension element:

```text
mod_jbcookies
```

Loại extension:

```text
Site Module
```

JB Cookies phù hợp với website cần một giao diện cookie consent đơn giản, nhẹ và tích hợp trực tiếp vào Joomla. Extension được công bố hỗ trợ Joomla 3, 4, 5 và 6.

---

## 2. Extension hỗ trợ những gì?

### 2.1 Cookie consent notice

JB Cookies hiển thị thông báo cookie khi người dùng truy cập website lần đầu.

Thông báo có thể gồm:

* Tiêu đề.
* Nội dung giải thích.
* Nút chấp nhận cookie.
* Nút từ chối cookie.
* Nút mở cookie preferences.
* Link hoặc popup chứa thông tin bổ sung.

Joomla Extensions Directory mô tả extension có chức năng chấp nhận hoặc từ chối cookie, preference selection và confirmation không cần reload trang.

### 2.2 Cookie preferences

Extension cung cấp giao diện để người dùng xem và chọn các nhóm cookie.

Ví dụ:

* Essential cookies.
* Functional cookies.
* Analytics cookies.
* Marketing cookies.
* Third-party cookies.

Phiên bản 6.0.2 có cải thiện việc hiển thị và sắp xếp các nhóm cookie theo dữ liệu do administrator cấu hình trong module.

### 2.3 Cookie discovery

JB Cookies có khả năng tìm các cookie đang tồn tại trên homepage và đưa chúng vào phần quản lý cookie preferences.

Tuy nhiên, việc scan homepage không đảm bảo phát hiện toàn bộ cookie trên website.

Một số cookie chỉ xuất hiện khi:

* Người dùng đăng nhập.
* Mở một trang cụ thể.
* Xem video YouTube.
* Gửi form.
* Thêm sản phẩm vào cart.
* Truy cập trang checkout.
* Google Tag Manager kích hoạt một event.
* Một third-party script được load sau tương tác.

Vì vậy, cookie discovery chỉ nên được sử dụng như dữ liệu ban đầu. Website vẫn cần được kiểm tra thủ công bằng browser Developer Tools.

### 2.4 Multilingual support

JB Cookies hỗ trợ website đa ngôn ngữ. Các ngôn ngữ đã được cài trong Joomla được hiển thị trong phần cấu hình module để administrator nhập nội dung riêng cho từng ngôn ngữ.

Repository chính thức liệt kê sẵn nhiều language package, gồm:

* English.
* Spanish.
* Catalan.
* Italian.
* German.
* Dutch.
* Polish.
* Portuguese.
* Swedish.
* Greek.
* French.

Có thể bổ sung nội dung tiếng Việt trực tiếp trong module hoặc tạo Joomla language override nếu extension chưa cung cấp file `vi-VN`.

### 2.5 Bootstrap responsive interface

JB Cookies sử dụng Bootstrap cho:

* Modal.
* Buttons.
* Background colors.
* Responsive layout.
* Desktop và mobile display.

Vendor yêu cầu template có Bootstrap, ví dụ Joomla core template hoặc Helix Ultimate.

### 2.6 Additional information

Extension hỗ trợ bật hoặc tắt phần thông tin bổ sung.

Nội dung bổ sung có thể dùng để:

* Giải thích cookie là gì.
* Mô tả mục đích sử dụng cookie.
* Link tới Cookie Policy.
* Link tới Privacy Policy.
* Hiển thị chi tiết các nhóm cookie.

### 2.7 Article popup

JB Cookies hỗ trợ mở Joomla article trong Bootstrap modal thay vì chuyển người dùng sang một trang mới.

Chức năng này phù hợp để hiển thị:

* Cookie Policy.
* Privacy Policy.
* Data Protection Notice.
* Cookie-category explanation.

### 2.8 Module cache

Extension hỗ trợ Joomla module cache. Joomla Extensions Directory liệt kê module cache là một trong các chức năng được hỗ trợ.

Caching có thể giảm việc render lại module, nhưng cần test kỹ vì consent là dữ liệu khác nhau theo từng browser hoặc người dùng.

### 2.9 Display position and icon alignment

Repository chính thức liệt kê khả năng đặt icon hoặc giao diện theo hướng:

* Left.
* Right.

Module có thể được publish tại position `debug` hoặc một module position tồn tại trên mọi trang.

---

## 3. JB Cookies mạnh nhất ở điểm nào?

### 3.1 Dễ cài đặt và cấu hình

JB Cookies là một module, không phải một component lớn. Vì vậy quy trình setup tương đối đơn giản:

```text
Install module
→ Create module instance
→ Configure languages
→ Configure cookie groups
→ Publish on all pages
```

Extension phù hợp với website muốn triển khai cookie notice nhanh mà không cần một hệ thống consent-management phức tạp.

### 3.2 Hỗ trợ đa ngôn ngữ tốt

Đây là một trong những điểm mạnh rõ nhất.

Module tự lấy danh sách language đã được cài trong Joomla và cho phép nhập nội dung riêng theo từng ngôn ngữ. Điều này phù hợp với website doanh nghiệp hoạt động ở nhiều quốc gia.

### 3.3 Tích hợp Bootstrap tốt

JB Cookies tận dụng Bootstrap có sẵn trong Joomla hoặc template, nên:

* Không cần một UI framework riêng.
* Giao diện dễ tương thích với Joomla frontend.
* Modal và button có thể dùng style Bootstrap.
* Responsive khá thuận tiện.

### 3.4 Cookie groups và preference selection

Khác với cookie notice chỉ có nút “Accept”, JB Cookies hỗ trợ nhóm cookie và cho người dùng mở phần Settings để chọn preferences. Joomla Extensions Directory ghi rõ extension hỗ trợ preference selection và cookie rejection.

### 3.5 Không reload trang sau khi xác nhận

Người dùng có thể accept hoặc reject mà không cần reload toàn bộ page. Điều này tạo trải nghiệm tốt hơn và giảm gián đoạn khi truy cập website.

### 3.6 Miễn phí và có source code công khai

JB Cookies được phân phối miễn phí, có repository GitHub công khai và release history rõ ràng.

Điều này thuận tiện cho:

* Audit source code.
* Theo dõi bug fix.
* Tự kiểm tra compatibility.
* Fork hoặc tạo template override khi cần.

---

## 4. Giới hạn của extension

JB Cookies không nên được hiểu là một giải pháp pháp lý hoàn chỉnh chỉ vì nó hiển thị cookie banner.

Cần phân biệt hai chức năng:

```text
Consent UI
```

và:

```text
Actual script and cookie blocking
```

JB Cookies có thể cung cấp giao diện accept, reject và settings. Tuy nhiên, website cần kiểm tra riêng xem:

* Google Analytics có chạy trước consent không.
* Google Tag Manager có tạo cookie trước consent không.
* Meta Pixel có load trước consent không.
* YouTube iframe có tạo cookie trước consent không.
* Script marketing có bị block sau khi người dùng chọn Reject không.

Nếu third-party scripts được hard-code trực tiếp trong template, JB Cookies có thể không tự động chặn chúng nếu không có thêm integration.

Do đó, extension mạnh ở:

* Cookie notice.
* Multilingual content.
* Consent interface.
* Cookie groups.
* Bootstrap modal.

Nhưng không nên mặc định rằng nó là một Consent Management Platform đầy đủ giống các nền tảng chuyên dụng.

---

# 5. Setup từng chức năng

## 5.1 Cấu hình module cơ bản

### Mục đích

Tạo module JB Cookies và hiển thị trên toàn website.

### Các bước

1. Đăng nhập Joomla Administrator:

```text
https://your-domain.example/administrator
```

2. Mở:

```text
Content
→ Site Modules
```

3. Tìm module:

```text
JB Cookies
```

4. Nếu chưa có module instance, chọn:

```text
New
→ JB Cookies
```

5. Cấu hình:

```text
Title: Cookie Consent
Show Title: Hide
Status: Published
Access: Public
Language: All
```

6. Chọn position:

```text
debug
```

Nếu custom template không có position `debug`, chọn một position:

* Có trên mọi page.
* Không nằm trong container nhỏ.
* Không bị hidden trên mobile.
* Được render gần cuối HTML page.

7. Trong Menu Assignment, chọn:

```text
On all pages
```

8. Nhấn:

```text
Save
```

### Kết quả mong đợi

* Module được publish.
* Cookie notice xuất hiện khi browser chưa có consent cookie.
* Module xuất hiện trên tất cả frontend pages.

---

## 5.2 Cấu hình nội dung thông báo cookie

### Mục đích

Hiển thị nội dung giải thích cookie cho người truy cập.

### Các bước

1. Mở JB Cookies module.
2. Tìm tab nội dung hoặc language configuration.
3. Chọn ngôn ngữ cần cấu hình.
4. Nhập tiêu đề:

```text
Cookie Settings
```

5. Nhập nội dung:

```text
We use essential cookies to operate this website and optional cookies
to improve performance and user experience. You can accept, reject,
or configure your cookie preferences.
```

6. Cấu hình button labels:

```text
Accept button: Accept all
Reject button: Reject optional cookies
Settings button: Cookie settings
```

7. Nhấn Save.

### Nội dung tiếng Việt đề xuất

```text
Tiêu đề:
Cài đặt cookie

Nội dung:
Trang web sử dụng cookie thiết yếu để vận hành và cookie tùy chọn để
cải thiện hiệu suất cũng như trải nghiệm người dùng. Bạn có thể chấp
nhận, từ chối hoặc tùy chỉnh lựa chọn cookie.

Nút chấp nhận:
Chấp nhận tất cả

Nút từ chối:
Từ chối cookie tùy chọn

Nút cài đặt:
Cài đặt cookie
```

### Kết quả mong đợi

Cookie notice hiển thị đầy đủ:

* Tiêu đề.
* Nội dung.
* Accept.
* Reject.
* Settings.

---

## 5.3 Cấu hình đa ngôn ngữ

### Mục đích

Hiển thị cookie notice theo ngôn ngữ frontend hiện tại.

### Các bước

1. Xác nhận Joomla đã cài các ngôn ngữ cần dùng:

```text
System
→ Install
→ Languages
```

2. Xác nhận content languages đã được publish:

```text
System
→ Manage
→ Content Languages
```

3. Mở:

```text
Content
→ Site Modules
→ JB Cookies
```

4. Mở tab:

```text
Languages
```

5. Các ngôn ngữ đã cài trong Joomla sẽ được hiển thị.
6. Chọn từng ngôn ngữ.
7. Nhập riêng:

* Title.
* Description.
* Accept label.
* Reject label.
* Settings label.
* Additional information.
* Cookie group descriptions.

8. Lưu module.
9. Chuyển frontend sang từng ngôn ngữ để test.

### Kết quả mong đợi

* English page hiển thị English consent.
* Vietnamese page hiển thị Vietnamese consent.
* Không xuất hiện raw language key như:

```text
MOD_JBCOOKIES_ACCEPT
```

---

## 5.4 Cấu hình nút Accept

### Mục đích

Cho phép người dùng chấp nhận cookie.

### Các bước

1. Mở JB Cookies module.
2. Tìm phần button hoặc consent action.
3. Bật nút Accept.
4. Nhập label:

```text
Accept all
```

5. Chọn Bootstrap button class nếu có:

```text
btn-success
```

hoặc:

```text
btn-primary
```

6. Save module.
7. Mở website bằng private browser.
8. Nhấn Accept.
9. Reload page.
10. Kiểm tra banner không xuất hiện lại.

### Kiểm tra kỹ thuật

Mở:

```text
Developer Tools
→ Application
→ Cookies
```

Kiểm tra consent cookie đã được tạo.

### Kết quả mong đợi

* Banner đóng sau khi accept.
* Consent state được lưu.
* Optional cookie groups được đánh dấu accepted.
* Banner không hiện lại ngay sau reload.

---

## 5.5 Cấu hình nút Reject

### Mục đích

Cho phép người dùng từ chối cookie không thiết yếu.

### Các bước

1. Mở module.
2. Bật Reject button.
3. Nhập label:

```text
Reject optional cookies
```

4. Chọn button style:

```text
btn-secondary
```

hoặc:

```text
btn-outline-secondary
```

5. Save.
6. Xóa toàn bộ browser cookies.
7. Reload page.
8. Nhấn Reject.
9. Mở Developer Tools.
10. Kiểm tra optional cookies.

### Kết quả mong đợi

* Consent choice được lưu.
* Banner đóng.
* Essential Joomla session cookies vẫn hoạt động.
* Analytics hoặc marketing cookies không được tạo, nếu website đã tích hợp cơ chế blocking đúng.

### Lưu ý

Nếu Google Analytics vẫn chạy sau khi Reject, cần kiểm tra:

* Google Tag Manager consent mode.
* Template scripts.
* Custom HTML modules.
* Analytics plugins.
* Third-party embeds.

Không nên kết luận đó chỉ là lỗi của JB Cookies.

---

## 5.6 Cấu hình Cookie Settings

### Mục đích

Cho phép người dùng chọn cookie theo nhóm.

### Các bước

1. Mở module.
2. Bật nút:

```text
Settings
```

3. Nhập label:

```text
Cookie settings
```

4. Bật Bootstrap modal.
5. Tạo hoặc cấu hình cookie groups.
6. Save.
7. Clear cookies.
8. Reload frontend.
9. Nhấn Settings.
10. Kiểm tra modal.

### Kết quả mong đợi

* Modal mở đúng.
* Các nhóm cookie được hiển thị.
* Group được sắp xếp đúng.
* Người dùng có thể bật/tắt optional groups.
* Người dùng có thể lưu preferences.
* Preferences vẫn được giữ sau reload.

Phiên bản 6.0.2 có sửa và cải thiện việc hiển thị, sắp xếp các cookie groups do người dùng cấu hình.

---

## 5.7 Cấu hình Essential Cookies group

### Mục đích

Mô tả cookie bắt buộc để website hoạt động.

### Ví dụ cookie

```text
Joomla session cookie
CSRF-related cookie
Authentication cookie
Language preference cookie
Shopping cart session cookie
```

### Các bước

1. Mở cookie-group configuration.
2. Tạo group:

```text
Essential Cookies
```

3. Nhập description:

```text
These cookies are required for the website to operate and cannot be
disabled through the cookie settings.
```

4. Đặt trạng thái:

```text
Always enabled
```

5. Không cho phép user tắt group này, nếu module hỗ trợ khóa trạng thái.
6. Thêm các cookie đã xác định là essential.
7. Save.

### Kết quả mong đợi

* Essential group luôn bật.
* User không thể disable.
* Login, forms và Joomla session vẫn hoạt động sau khi Reject optional cookies.

---

## 5.8 Cấu hình Analytics Cookies group

### Mục đích

Quản lý cookie dùng để đo traffic và hành vi người dùng.

### Ví dụ

```text
Google Analytics
Matomo
Microsoft Clarity
Hotjar
```

### Các bước

1. Tạo group:

```text
Analytics Cookies
```

2. Nhập description:

```text
These cookies help us understand how visitors use the website and
improve its performance.
```

3. Đặt trạng thái mặc định:

```text
Disabled until consent
```

4. Thêm cookie names, ví dụ:

```text
_ga
_gid
_ga_*
```

5. Kết nối việc load analytics script với consent state.
6. Save.
7. Clear cookies.
8. Reload website.
9. Không accept.
10. Kiểm tra `_ga` chưa được tạo.
11. Accept analytics.
12. Reload và kiểm tra `_ga` được tạo.

### Kết quả mong đợi

Analytics chỉ hoạt động sau khi người dùng đồng ý.

---

## 5.9 Cấu hình Marketing Cookies group

### Mục đích

Quản lý cookie quảng cáo hoặc tracking bên thứ ba.

### Ví dụ

```text
Meta Pixel
Google Ads
LinkedIn Insight Tag
TikTok Pixel
```

### Các bước

1. Tạo group:

```text
Marketing Cookies
```

2. Nhập description:

```text
These cookies are used to measure advertising performance and provide
more relevant marketing content.
```

3. Đặt mặc định:

```text
Disabled until consent
```

4. Thêm known cookie names.
5. Chỉ load marketing scripts sau consent.
6. Save.
7. Test Reject.
8. Kiểm tra không có marketing network request.
9. Test Accept.
10. Kiểm tra scripts được load.

### Kết quả mong đợi

Marketing scripts không chạy trước consent.

---

## 5.10 Cấu hình Additional Information

### Mục đích

Hiển thị nội dung giải thích thêm ngoài notice chính.

### Các bước

1. Mở module.
2. Tìm option:

```text
Additional Information
```

3. Chọn:

```text
Show
```

4. Nhập nội dung:

```text
You can change your cookie preferences at any time by opening the
Cookie Settings panel.
```

5. Có thể thêm link:

```text
Read our Cookie Policy
```

6. Save.

Repository chính thức liệt kê Additional Information với hai trạng thái Hide hoặc Show.

### Kết quả mong đợi

Thông tin bổ sung xuất hiện trong notice hoặc settings modal.

---

## 5.11 Cấu hình Cookie Policy article

### Mục đích

Hiển thị chính sách cookie chi tiết.

### Các bước

1. Vào:

```text
Content
→ Articles
→ New
```

2. Tạo article:

```text
Title: Cookie Policy
Status: Published
Access: Public
```

3. Nội dung nên gồm:

* Cookie là gì.
* Website dùng cookie nào.
* Mục đích từng nhóm.
* Cookie duration.
* Third-party providers.
* Cách thay đổi consent.
* Contact information.

4. Save article.
5. Mở JB Cookies module.
6. Chọn article vừa tạo trong field liên quan.
7. Chọn cách mở:

```text
Popup modal: Yes
```

8. Save.

JB Cookies hỗ trợ lựa chọn hiển thị Joomla article trong popup Bootstrap modal.

### Kết quả mong đợi

Người dùng click Cookie Policy và article mở trong modal mà không rời page.

---

## 5.12 Cấu hình Bootstrap colors

### Mục đích

Điều chỉnh màu notice và buttons theo Bootstrap.

### Các bước

1. Mở module.
2. Tìm phần Background Color.
3. Chọn một Bootstrap background class, ví dụ:

```text
bg-light
bg-dark
bg-primary
bg-secondary
```

4. Cấu hình link hoặc button colors:

```text
btn-primary
btn-success
btn-secondary
btn-outline-light
```

5. Save.
6. Test desktop và mobile.
7. Kiểm tra contrast.

Repository chính thức ghi rõ extension sử dụng Bootstrap backgrounds và Bootstrap button colors.

### Kết quả mong đợi

* Text dễ đọc.
* Button có contrast tốt.
* Không bị custom template ghi đè làm mất màu.

---

## 5.13 Cấu hình icon position

### Mục đích

Đặt icon mở lại Cookie Settings ở bên trái hoặc bên phải.

### Các bước

1. Mở module.
2. Tìm option:

```text
Position icon
```

3. Chọn:

```text
Left
```

hoặc:

```text
Right
```

4. Save.
5. Reload frontend.
6. Kiểm tra icon không che:

* Chat widget.
* Back-to-top button.
* Mobile navigation.
* Accessibility controls.

Repository liệt kê hai lựa chọn position icon là Left và Right.

### Kết quả mong đợi

Người dùng có thể mở lại Cookie Settings sau khi đã lưu consent.

---

## 5.14 Cấu hình module cache

### Mục đích

Giảm thời gian render lại module.

### Các bước

1. Mở:

```text
Content
→ Site Modules
→ JB Cookies
```

2. Mở Advanced tab.
3. Tìm:

```text
Caching
```

4. Ban đầu nên chọn:

```text
No caching
```

5. Hoàn tất toàn bộ functional test.
6. Sau đó có thể test:

```text
Use Global
```

7. Clear Joomla cache.
8. Test với nhiều browser sessions.
9. Xác nhận consent state không bị dùng chung giữa users.

### Khuyến nghị

Trong giai đoạn development và migration:

```text
Caching: No caching
```

Sau khi production testing thành công mới cân nhắc bật cache.

### Kết quả mong đợi

Consent banner không bị:

* Ẩn sai.
* Hiện lại sai.
* Dùng chung state giữa sessions.
* Cache nội dung sai ngôn ngữ.

---

## 5.15 Cấu hình cookie discovery

### Mục đích

Tìm các cookie đang tồn tại trên homepage.

### Các bước

1. Hoàn tất cấu hình cơ bản của module.
2. Mở chức năng cookie scan hoặc cookie preferences.
3. Chạy scan trên homepage.
4. Xem danh sách cookie được phát hiện.
5. Phân loại từng cookie:

```text
Essential
Functional
Analytics
Marketing
Unknown
```

6. Xóa các record duplicate.
7. Thêm description cho từng cookie.
8. Lưu cấu hình.
9. Kiểm tra thêm các page đặc biệt:

* Login.
* Contact form.
* Search.
* Product.
* Cart.
* Checkout.
* Video page.

10. Bổ sung các cookie không được homepage scan phát hiện.

Joomla Extensions Directory cho biết module tìm kiếm các cookie hiện có từ homepage.

### Kết quả mong đợi

Danh sách cookie ban đầu được tạo, sau đó được administrator kiểm tra và hoàn thiện thủ công.

---

# 6. Quy trình setup đề xuất hoàn chỉnh

Thứ tự triển khai nên là:

```text
1. Install JB Cookies
2. Publish module on all pages
3. Disable module cache during development
4. Configure default language
5. Configure all additional languages
6. Create Cookie Policy article
7. Configure Accept, Reject and Settings
8. Create Essential cookie group
9. Create Analytics cookie group
10. Create Marketing cookie group
11. Run homepage cookie discovery
12. Manually test special pages
13. Integrate analytics and marketing script blocking
14. Test Bootstrap modal
15. Test desktop and mobile
16. Test Chrome, Firefox, Safari, Edge and Brave
17. Test Accept
18. Test Reject
19. Test custom preferences
20. Enable cache only after all tests pass
```

---

# 7. Final acceptance checklist

## Extension

* [ ] JB Cookies is installed.
* [ ] `mod_jbcookies` is enabled.
* [ ] Module is published.
* [ ] Module is assigned to all pages.
* [ ] Template position is valid.

## Content

* [ ] Cookie notice content is complete.
* [ ] Cookie Policy article is published.
* [ ] Accept label is configured.
* [ ] Reject label is configured.
* [ ] Settings label is configured.
* [ ] Every active language is configured.

## Cookie groups

* [ ] Essential group exists.
* [ ] Analytics group exists.
* [ ] Marketing group exists where applicable.
* [ ] Cookie descriptions are accurate.
* [ ] Cookie groups are displayed in the intended order.

## Functional behavior

* [ ] Notice appears on first visit.
* [ ] Accept works.
* [ ] Reject works.
* [ ] Settings modal works.
* [ ] Preferences persist after reload.
* [ ] Users can reopen settings.
* [ ] Policy article opens correctly.
* [ ] No page reload is required after confirmation.

## Technical behavior

* [ ] No JavaScript errors.
* [ ] No PHP warnings.
* [ ] No missing assets.
* [ ] Bootstrap modal works.
* [ ] Brave modal works.
* [ ] Mobile layout works.
* [ ] Multilingual content works.

## Consent validation

* [ ] Essential cookies work without optional consent.
* [ ] Analytics does not run before consent.
* [ ] Marketing scripts do not run before consent.
* [ ] Reject prevents optional tracking.
* [ ] Changing preferences updates script behavior.

---

# 8. Final assessment

```text
Primary purpose:
Display cookie information and provide a multilingual cookie-consent
interface for Joomla websites.

Strongest capabilities:
Multilingual configuration, Bootstrap-based responsive UI, cookie
preference groups, accept/reject actions, article popup, and simple
Joomla module integration.

Best use case:
Small or medium Joomla websites requiring a lightweight and free cookie
consent module.

Main limitation:
The administrator must verify that third-party analytics and marketing
scripts are actually blocked before consent. A visible cookie banner
alone does not guarantee legal or technical compliance.

Joomla 6 recommendation:
Suitable for Joomla 6 after template compatibility, multilingual,
consent persistence, and real cookie-blocking tests have passed.
```
