# AcyMailing 10.11.1 Installation and Verification Guide for Joomla 6

This guide explains how to install AcyMailing 10.11.1 on Joomla 6, deploy it to another environment, verify the installation, manage test subscribers, and test the main AcyMailing features.

> **Terminology:** In AcyMailing, an email recipient is called a **user** or **subscriber**. An AcyMailing subscriber does not have to be a Joomla login account.

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Install AcyMailing Locally](#2-install-acymailing-locally)
3. [Commit the Installed Files](#3-commit-the-installed-files)
4. [Install on Another Environment](#4-install-on-another-environment)
5. [Verify the Installation](#5-verify-the-installation)
6. [Create a Test Subscriber](#6-create-a-test-subscriber)
7. [Change or Replace a Subscriber](#7-change-or-replace-a-subscriber)
8. [Final Verification Checklist](#8-final-verification-checklist)
9. [Feature Testing Guide](#9-feature-testing-guide)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Prerequisites

Confirm the following before installation:

- [ ] Joomla 6 is running correctly.
- [ ] The database connection works.
- [ ] The PHP version meets the Joomla 6 requirements.
- [ ] The official AcyMailing 10.11.1 installation package is available.
- [ ] The database has been backed up.
- [ ] The Git working tree is clean.

Check the repository status:

```bash
git status
```

Create a dedicated branch:

```bash
git checkout -b feature/install-acymailing-10.11.1
```

Do not commit sensitive or environment-specific data:

- `configuration.php`
- `.env`
- SMTP passwords
- API keys
- License keys
- Database backups
- Production subscriber data

---

## 2. Install AcyMailing Locally

### 2.1 Open the Joomla extension installer

In Joomla Administrator, go to:

```text
System → Install → Extensions
```

### 2.2 Upload the installation package

Select **Upload Package File**, then upload the official package:

```text
acymailing_10.11.1.zip
```

Do not extract the ZIP file and manually copy its contents into Joomla. The package installer registers the extensions, executes database scripts, and installs dependencies.

### 2.3 Confirm the installation

Go to:

```text
System → Manage → Extensions
```

Search for `AcyMailing`, then open:

```text
Components → AcyMailing
```

Expected results:

- [ ] The AcyMailing component is installed.
- [ ] Related plugins and modules are installed.
- [ ] Required extensions are enabled.
- [ ] The displayed version is `10.11.1`.
- [ ] The dashboard opens without an HTTP 500 error.

---

## 3. Commit the Installed Files

Review the files created or changed by the installation:

```bash
git status --short
git diff --stat
```

AcyMailing may add files under these directories:

```text
administrator/components/
administrator/language/
components/
language/
libraries/
media/
modules/
plugins/
```

Find AcyMailing-related files:

```bash
find administrator components media modules plugins libraries \
  -iname '*acym*' 2>/dev/null
```

Stage only the files shown by `git status`:

```bash
git add administrator components media modules plugins language libraries
git commit -m "feat: install AcyMailing 10.11.1 for Joomla 6"
git push origin feature/install-acymailing-10.11.1
```

Adjust the `git add` paths to match the actual installation output.

> Do not commit a paid AcyMailing ZIP package to a public repository.

---

## 4. Install on Another Environment

### Recommended method: Install the official ZIP package

The safest method for development, staging, and production is:

```text
Joomla Administrator
→ System
→ Install
→ Extensions
→ Upload Package File
```

AcyMailing is distributed as a package containing multiple Joomla extensions. Installing the official ZIP ensures that manifests, dependencies, and database scripts are processed correctly.

### Alternative method: Deploy files with Git and use Discover

Use this method only after validating it on a clean Joomla 6 database.

After pulling the source code, go to:

```text
System → Install → Discover → Discover
```

Search for:

```text
AcyMailing
acym
```

Install every related extension found by Joomla. If no package entry is available, use this order:

```text
Library → Component → Plugin → Module
```

Clear the Joomla cache:

```text
System → Maintenance → Clear Cache
```

> If the component exists but database tables or dependencies are missing, restore the database and reinstall AcyMailing from the official ZIP package.

---

## 5. Verify the Installation

### 5.1 Verify registered extensions

Go to:

```text
System → Manage → Extensions
```

Search for `AcyMailing` and confirm:

- [ ] The main component exists.
- [ ] Related plugins exist.
- [ ] Related modules exist when included in the package.
- [ ] Required extensions are enabled.
- [ ] The displayed version is `10.11.1`.

### 5.2 Verify administrator pages

Open:

```text
Components → AcyMailing
```

Check that these pages load successfully:

- Dashboard
- Users
- Lists
- Campaigns
- Templates
- Configuration
- Queue
- Statistics

There should be no errors such as:

```text
HTTP 500
Table not found
Class not found
Plugin not found
Missing dependency
```

### 5.3 Verify the database

Replace `yourprefix_` with the actual Joomla database prefix.

```sql
SHOW TABLES LIKE 'yourprefix_acym_%';
```

Check the registered Joomla extensions:

```sql
SELECT
    extension_id,
    name,
    type,
    element,
    folder,
    enabled
FROM yourprefix_extensions
WHERE name LIKE '%AcyMailing%'
   OR element LIKE '%acym%'
   OR folder LIKE '%acym%'
ORDER BY type, name;
```

### 5.4 Verify Joomla mail configuration

Go to:

```text
System → Global Configuration → Server → Mail
```

Select **Send Test Mail**. Fix the Joomla SMTP or mail configuration before testing AcyMailing campaigns if this test fails.

### 5.5 Send an AcyMailing test email

Go to:

```text
Components → AcyMailing → Configuration → Mail Settings
```

Confirm:

- [ ] AcyMailing reports a successful send.
- [ ] The email arrives in the inbox or spam folder.
- [ ] The sender name and sender email are correct.
- [ ] The reply-to address is correct.
- [ ] The HTML content renders correctly.
- [ ] Links use the correct website domain.

### 5.6 Test a basic campaign

1. Create a test list.
2. Create a test subscriber.
3. Add the subscriber to the test list.
4. Create a simple campaign.
5. Send it to the test list.
6. Confirm that the email arrives.
7. Check that the queue contains no errors.
8. Test the unsubscribe link.

Expected results:

- [ ] The campaign is sent successfully.
- [ ] The subscriber receives the email.
- [ ] The queue item changes from pending to sent.
- [ ] The unsubscribe page opens correctly.
- [ ] The subscriber is unsubscribed from the correct list.

### 5.7 Test the frontend subscription form

When the website uses an AcyMailing subscription form:

1. Publish the AcyMailing subscription module.
2. Open the website frontend.
3. Subscribe with a new test email address.
4. Confirm that the subscriber appears under **AcyMailing → Users**.
5. Confirm that the subscriber belongs to the correct list.
6. Confirm the email address when double opt-in is enabled.

---

## 6. Create a Test Subscriber

Go to:

```text
Components → AcyMailing → Users → New
```

Example values:

```text
Name: Test User
Email: your-email@example.com
Active: Yes
Confirmed: Yes
```

Save the subscriber, then assign it to the test list.

For Gmail accounts, plus addressing can create multiple test subscribers while delivering all messages to the same inbox:

```text
yourname+acym-active@gmail.com
yourname+acym-confirm@gmail.com
yourname+acym-unsubscribe@gmail.com
```

---

## 7. Change or Replace a Subscriber

Choose the action based on the required result.

| Requirement | Recommended action |
|---|---|
| Keep the current subscriptions but use a new email address | Edit the existing subscriber |
| Preserve the old test history | Create a new subscriber |
| Stop messages from one list only | Unsubscribe from that list |
| Permanently remove the subscriber | Delete the subscriber |
| The subscriber is synchronized with Joomla | Update the Joomla user first |

### 7.1 Change the email address of an existing subscriber

```text
Components
→ AcyMailing
→ Users
→ Open the subscriber
→ Change Email
→ Save & Close
```

Verify:

- [ ] The new email address is saved.
- [ ] The subscriber remains assigned to the correct lists.
- [ ] `Active` is set to `Yes`.
- [ ] `Confirmed` is set to `Yes` when required.
- [ ] New campaigns are delivered to the new email address.

### 7.2 Create a separate test subscriber

```text
Components → AcyMailing → Users → New
```

This is the preferred method for testing active, unconfirmed, unsubscribed, or bounced subscriber states without changing existing test history.

### 7.3 Stop an old address from receiving messages

```text
Components
→ AcyMailing
→ Users
→ Open the subscriber
→ Subscriptions
→ Unsubscribe from the test list
→ Save
```

| Action | Result |
|---|---|
| Change email | Keeps the subscriber and subscriptions but uses a new address |
| Unsubscribe | Keeps the subscriber but stops messages from the selected list |
| Delete | Removes the subscriber from AcyMailing |

### 7.4 Update a subscriber linked to a Joomla user

When the subscriber has a CMS user ID or is synchronized with Joomla, update the Joomla account first:

```text
Users → Manage → Open the Joomla user → Change Email → Save & Close
```

Then verify the updated value under:

```text
Components → AcyMailing → Users
```

Do not update only the AcyMailing record when Joomla synchronization is enabled. A later synchronization may overwrite the email address.

---

## 8. Final Verification Checklist

The installation is complete when all applicable checks pass:

- [ ] AcyMailing appears in Joomla Extensions.
- [ ] The dashboard opens without errors.
- [ ] Version `10.11.1` is displayed.
- [ ] AcyMailing database tables exist.
- [ ] Joomla can send a test email.
- [ ] AcyMailing can send a test email.
- [ ] A test list and subscriber can be created.
- [ ] A campaign can be sent successfully.
- [ ] The queue processes messages successfully.
- [ ] The frontend subscription form works when used.
- [ ] The unsubscribe flow works.
- [ ] Subscribers can be changed or replaced from the backend.
- [ ] Joomla logs contain no critical AcyMailing errors.

### Post-deployment smoke test

1. Open **Components → AcyMailing**.
2. Send a test email.
3. Check the test subscriber and test list.
4. Send a small test campaign.
5. Verify delivery, queue processing, and unsubscribe behavior.

---

## 9. Feature Testing Guide

Use a dedicated QA list and test subscribers. Do not use production recipient data.

### 9.1 Recommended end-to-end flow

```text
Create a list
→ Create a subscriber
→ Subscribe from the frontend
→ Confirm the subscription
→ Create an email
→ Send a campaign
→ Process the queue
→ Receive the email
→ Verify open and click tracking
→ Unsubscribe
→ Review statistics and logs
```

### 9.2 Prepare test data

Create a dedicated list:

```text
Name: QA - AcyMailing Test
Active: Yes
Visible: Yes
Track This List: Yes
```

Suggested Gmail test addresses:

```text
yourname+acym-active@gmail.com
yourname+acym-confirm@gmail.com
yourname+acym-unsubscribe@gmail.com
yourname+acym-import@gmail.com
```

Create a test email containing:

- A heading and paragraph
- An image with alternative text
- An internal Joomla link
- An external link
- A call-to-action button
- A subscriber name tag
- An unsubscribe link

### 9.3 Test dashboard and administrator pages

Open each AcyMailing page and use the browser developer tools to inspect failed requests.

```text
F12 → Console
F12 → Network
```

Expected results:

- [ ] All pages load without HTTP 500 errors.
- [ ] No JavaScript errors block the interface.
- [ ] No requests return unexpected `403`, `404`, or `500` responses.
- [ ] Styles, icons, dialogs, and buttons render correctly.
- [ ] No database table, class, plugin, or dependency errors appear.

### 9.4 Test mail configuration

Go to:

```text
Components → AcyMailing → Configuration → Mail Settings
```

Verify the sender name, sender address, reply-to address, SMTP host, SMTP port, encryption, and authentication settings.

Expected results:

- [ ] A test email is sent successfully.
- [ ] The email arrives in the inbox or spam folder.
- [ ] Sender and reply-to information is correct.
- [ ] The subject supports UTF-8 characters.
- [ ] Images and HTML content render correctly.
- [ ] No SMTP password or sensitive value is exposed in an error message.

### 9.5 Test subscriber management

Run the following cases:

| Test case | Expected result |
|---|---|
| Create a valid subscriber | The subscriber is saved and searchable |
| Create the same email again | No unintended duplicate record is created |
| Edit the name or email | The new value is saved |
| Disable a subscriber | The subscriber does not receive campaigns |
| Set `Confirmed` to `No` | Confirmation rules are applied correctly |
| Delete a subscriber | The subscriber is removed |
| Search and filter | Results match the selected criteria |

Optional database verification:

```sql
SELECT
    id,
    email,
    name,
    active,
    confirmed,
    creation_date
FROM yourprefix_acym_user
WHERE email LIKE '%acym-%'
ORDER BY id DESC;
```

> Confirm the actual AcyMailing table names before running queries because database structures can vary by version.

### 9.6 Test list management

Test creating, editing, enabling, disabling, and deleting a QA list.

Expected results:

- [ ] A subscriber can be added to and removed from the list.
- [ ] The displayed subscriber count is correct.
- [ ] An inactive list cannot be selected for normal subscription or sending.
- [ ] Tracking behavior follows the list configuration.
- [ ] Changes do not affect unrelated lists.

### 9.7 Test the frontend subscription form

Publish the AcyMailing subscription module and assign it to a test page.

Test valid submission:

- [ ] The form displays correctly on desktop and mobile.
- [ ] A valid email creates or updates one subscriber only.
- [ ] The subscriber is assigned to the correct list.
- [ ] The success message and redirect are correct.

Test validation with:

```text
Empty email
Invalid email: abc
Invalid email: abc@
Existing subscriber email
Missing required name
Terms checkbox not selected
Very long input
HTML input: <b>test</b>
Script input: <script>alert(1)</script>
```

Expected results:

- [ ] Invalid data is rejected with a clear message.
- [ ] No invalid or duplicate subscriber is created.
- [ ] HTML and JavaScript input is safely handled.
- [ ] No HTTP 500 error occurs.

### 9.8 Test double opt-in and confirmation

1. Enable confirmation in AcyMailing configuration.
2. Subscribe with a new test address.
3. Confirm that the subscriber initially has `Confirmed = No`.
4. Open the confirmation email and select the confirmation link.
5. Verify that the subscriber changes to `Confirmed = Yes`.

Expected results:

- [ ] An unconfirmed subscriber does not receive protected campaigns.
- [ ] The confirmation link opens the correct website.
- [ ] The link confirms only the intended subscriber.
- [ ] Reusing the link does not create a duplicate subscriber.
- [ ] The redirect page works on desktop and mobile.

### 9.9 Test welcome emails

Assign a welcome email to the QA list, then subscribe from the frontend.

Expected results:

- [ ] The welcome email is sent at the configured point in the subscription flow.
- [ ] It is not sent repeatedly for the same action.
- [ ] Subscriber personalization is rendered correctly.
- [ ] Links and images use the correct environment domain.
- [ ] Backend-only edits do not unexpectedly trigger welcome emails.

### 9.10 Test the email editor and templates

Create an email with text, an image, a button, multiple columns, dynamic content, and unsubscribe content.

Expected results:

- [ ] Drag-and-drop editing works.
- [ ] Draft save, duplicate, preview, and image selection work.
- [ ] Content remains intact after saving and reopening.
- [ ] Desktop and mobile previews are usable.
- [ ] Gmail and Outlook render the email acceptably when available.
- [ ] Vietnamese and other UTF-8 characters display correctly.
- [ ] No links contain `localhost`, `127.0.0.1`, or an old environment domain.

### 9.11 Test immediate and scheduled campaigns

#### Send immediately

- [ ] The estimated receiver count is correct.
- [ ] Active and confirmed subscribers receive the message.
- [ ] Inactive, unconfirmed, or unsubscribed users are excluded according to configuration.
- [ ] The campaign changes to the correct sent status.

#### Schedule a campaign

- [ ] The campaign changes to a scheduled state.
- [ ] The displayed time matches the configured timezone.
- [ ] It is not sent before the scheduled time.
- [ ] Cron or the scheduled task sends it automatically.
- [ ] The campaign is sent once only.

For Vietnam deployments, compare the Joomla, PHP, server, database, and AcyMailing timezones with:

```text
Asia/Ho_Chi_Minh (UTC+07:00)
```

### 9.12 Test queue processing

Go to:

```text
Components → AcyMailing → Queue
```

Expected results:

- [ ] Queued messages show the correct campaign and recipient.
- [ ] Scheduled times are correct.
- [ ] Pause prevents processing.
- [ ] Resume continues processing without duplicates.
- [ ] Manual processing works in the QA environment.
- [ ] Removing one recipient does not remove unrelated queue items.
- [ ] Failed items show a useful error or log entry.

Only test **Empty Queue** in a non-production environment.

### 9.13 Test cron or scheduled tasks

1. Schedule a campaign a few minutes in the future.
2. Do not process it manually.
3. Allow the cron job or Joomla scheduled task to run.
4. Verify the queue and recipient inbox.

Expected results:

- [ ] The cron endpoint or scheduled task is reachable.
- [ ] It is not blocked by authentication, firewall, or a `403` response.
- [ ] It uses the correct environment URL, not localhost.
- [ ] The campaign sends automatically and once only.
- [ ] The last execution time and logs are updated.

### 9.14 Test unsubscribe and resubscribe flows

1. Send a campaign to the unsubscribe test address.
2. Select the unsubscribe link.
3. Verify the subscription status in the backend.
4. Send another campaign to the same list.

Expected results:

- [ ] The unsubscribe page opens without login when configured.
- [ ] Only the intended list or subscription is changed.
- [ ] The subscriber does not receive the next campaign.
- [ ] Statistics record the unsubscribe action.
- [ ] Resubscription follows the defined business rule.
- [ ] Resubscribing does not create a duplicate user.

### 9.15 Test statistics and tracking

Send a campaign containing one internal and one external link. Open the email and select both links.

Expected results:

- [ ] Sent, failed, open, click, and unsubscribe data are recorded where supported.
- [ ] Tracked URLs match the original destinations.
- [ ] List-level tracking settings are respected.
- [ ] Repeated opens or clicks do not produce obviously invalid totals.

> Open tracking is not fully reliable because email clients may block or preload tracking images. Click tracking is generally more useful for functional verification.

### 9.16 Test subscriber import and export

Example CSV:

```csv
email,name,active
yourname+acym-import1@gmail.com,Import User 1,1
yourname+acym-import2@gmail.com,Import User 2,1
invalid-email,Invalid User,1
```

Expected results:

- [ ] CSV headers map to the correct fields.
- [ ] Valid subscribers are imported into the selected list.
- [ ] Invalid email addresses are rejected or reported.
- [ ] Existing emails do not create unintended duplicates.
- [ ] UTF-8 names are preserved.
- [ ] Exported CSV data opens correctly in a spreadsheet application.
- [ ] Previously unsubscribed users are not silently resubscribed.

### 9.17 Test Joomla user synchronization

When Joomla users are synchronized with AcyMailing:

- [ ] Creating a Joomla user creates or links the expected subscriber.
- [ ] Changing the Joomla name or email synchronizes correctly.
- [ ] Synchronization does not create duplicates.
- [ ] Existing list subscriptions are preserved.
- [ ] Disabling or deleting a Joomla user follows the expected business rule.

Document the system of record:

```text
Joomla Users is the source of truth
or
AcyMailing Users is the source of truth
```

### 9.18 Test permissions and data security

Test with Super User, Administrator, marketing, and normal registered-user roles.

Expected results:

- [ ] Only authorized users can access AcyMailing administration pages.
- [ ] Direct backend URLs are blocked for unauthorized users.
- [ ] Unauthorized users cannot view, export, or modify subscriber data.
- [ ] Marketing users receive only the permissions required for their work.
- [ ] Frontend management pages do not expose another user's lists or campaigns.

### 9.19 Joomla 3 to Joomla 6 migration checks

Compare the source and target environments:

- [ ] Subscriber totals match.
- [ ] List totals match.
- [ ] Subscriber-to-list mappings are preserved.
- [ ] Active, confirmed, and unsubscribed states are preserved.
- [ ] Custom fields and required values are preserved.
- [ ] Templates and campaign history remain accessible where expected.
- [ ] Automation rules are not activated unexpectedly.
- [ ] Internal links, images, confirmation links, tracking links, and unsubscribe links use the new domain.
- [ ] Old Joomla 3 template overrides do not break the AcyMailing interface.
- [ ] Cron, SMTP, plugins, and subscription modules use the Joomla 6 environment settings.

### 9.20 Minimum smoke test after every deployment

- [ ] Open the AcyMailing dashboard.
- [ ] Send a configuration test email.
- [ ] Create or update a test subscriber.
- [ ] Assign the subscriber to the QA list.
- [ ] Submit the frontend subscription form.
- [ ] Send a small campaign.
- [ ] Verify queue processing.
- [ ] Open the received email and select a tracked link.
- [ ] Test the unsubscribe flow.
- [ ] Review statistics and Joomla logs.

### 9.21 QA report template

| Test ID | Feature | Test case | Expected result | Actual result | Status | Evidence |
|---|---|---|---|---|---|---|
| ACY-001 | Dashboard | Open the dashboard | Page loads without errors |  | Not Run |  |
| ACY-002 | Mail | Send a test email | Email is received |  | Not Run |  |
| ACY-003 | Subscriber | Create a subscriber | Subscriber is saved |  | Not Run |  |
| ACY-004 | List | Assign a subscriber | Subscription is created |  | Not Run |  |
| ACY-005 | Frontend form | Submit a valid email | Subscriber joins the list |  | Not Run |  |
| ACY-006 | Validation | Submit invalid input | Validation error is shown |  | Not Run |  |
| ACY-007 | Campaign | Send to the QA list | Eligible users receive email |  | Not Run |  |
| ACY-008 | Queue | Process queued messages | Items are sent once |  | Not Run |  |
| ACY-009 | Tracking | Open and select a link | Statistics are updated |  | Not Run |  |
| ACY-010 | Unsubscribe | Select unsubscribe | Subscription is disabled |  | Not Run |  |
| ACY-011 | Cron | Run a scheduled campaign | Campaign sends automatically |  | Not Run |  |
| ACY-012 | Security | Access without permission | Access is denied |  | Not Run |  |

### 9.22 Acceptance criteria

Mark AcyMailing as **Passed for Joomla 6** only when:

- [ ] All critical test cases pass.
- [ ] No HTTP 500 errors remain.
- [ ] Subscriber and list data are reconciled.
- [ ] Immediate and scheduled campaigns send correctly.
- [ ] Queue and cron processing work reliably.
- [ ] Confirmation and unsubscribe flows work.
- [ ] Inactive or unsubscribed recipients do not receive campaigns.
- [ ] Permissions protect subscriber data.
- [ ] Joomla and AcyMailing logs contain no unresolved critical errors.

---

## 10. Troubleshooting

### 10.1 AcyMailing dashboard returns HTTP 500

Check Joomla and container logs:

```bash
docker compose logs --tail=200 joomla
```

Look for:

```text
Missing class
Missing file
Missing database table
PHP compatibility error
```

### 10.2 The component exists but database tables are missing

1. Restore the database backup if the installation state is inconsistent.
2. Reinstall AcyMailing with the official ZIP package.
3. Recheck `#__extensions` and `#__acym_%` tables.

Do not manually insert records into `#__extensions` or manually create AcyMailing tables as a normal deployment method.

### 10.3 Joomla Discover does not find AcyMailing

Confirm:

- [ ] All source files were pulled.
- [ ] Extension manifest XML files exist.
- [ ] Files are in the correct Joomla extension directories.
- [ ] The web server can read the files.
- [ ] The extension is not already registered in `#__extensions`.

Find AcyMailing manifest files:

```bash
find administrator components modules plugins libraries \
  -type f -name '*.xml' \
  | grep -i acym
```

### 10.4 Joomla mail works but AcyMailing does not send

Check:

- AcyMailing mail configuration
- SMTP credentials and encryption settings
- Sender and reply-to addresses
- Queue status
- Cron job or scheduled task
- Spam folder
- Mail provider logs

### 10.5 Scheduled campaigns remain in the queue

Check:

- [ ] The cron job or Joomla scheduled task is enabled.
- [ ] The configured URL uses the correct environment domain.
- [ ] The server can access the cron endpoint.
- [ ] The campaign time and server timezone are correct.
- [ ] Queue processing is not paused.
- [ ] Mail provider limits have not been reached.

### 10.6 Frontend subscription form does not submit

Check:

- [ ] The AcyMailing module is published.
- [ ] The module is assigned to the current menu item.
- [ ] The selected list is active.
- [ ] Required fields and terms checkboxes are configured correctly.
- [ ] Browser console and network logs contain no JavaScript or request errors.
- [ ] Joomla caching or template overrides are not serving outdated markup.
