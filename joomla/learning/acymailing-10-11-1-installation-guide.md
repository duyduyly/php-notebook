# AcyMailing 10.11.1 Installation and Verification Guide for Joomla 6

This guide covers how to install AcyMailing 10.11.1 on Joomla 6, deploy it to another environment, verify the installation, and manage test subscribers.

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
9. [Troubleshooting](#9-troubleshooting)

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

Do not commit sensitive or environment-specific data, including:

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

Select **Upload Package File**, then upload the official package, for example:

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

### Recommended: Install the official ZIP package

The safest approach for development, staging, and production is:

```text
Joomla Administrator
→ System
→ Install
→ Extensions
→ Upload Package File
```

AcyMailing is distributed as a package containing multiple Joomla extensions. Installing the official ZIP ensures that manifests, dependencies, and database scripts are processed correctly.

### Alternative: Deploy files with Git and use Discover

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

Then clear the Joomla cache:

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

### 5.2 Verify the administrator pages

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

Check the AcyMailing tables:

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

Select **Send Test Mail**.

Fix the Joomla SMTP or mail configuration before testing AcyMailing campaigns if this test fails.

### 5.5 Send an AcyMailing test email

Go to:

```text
Components → AcyMailing → Configuration → Mail settings
```

Send a test email and confirm:

- [ ] AcyMailing reports a successful send.
- [ ] The email arrives in the inbox or spam folder.
- [ ] The sender name and sender email are correct.
- [ ] The HTML content renders correctly.
- [ ] Links use the correct website domain.

### 5.6 Test a campaign

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
- [ ] The subscriber is removed from the correct list.

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

Use this option to keep the current list subscriptions and replace only the email address.

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

Use this option when the existing subscriber and its test history should remain unchanged.

```text
Components → AcyMailing → Users → New
```

Create the subscriber and assign it to the required test list.

This is the preferred method for testing different states such as active, unconfirmed, unsubscribed, or bounced users.

### 7.3 Stop the old email from receiving messages

The subscriber does not need to be deleted. Unsubscribe it from the relevant list:

```text
Components
→ AcyMailing
→ Users
→ Open the subscriber
→ Subscriptions
→ Unsubscribe from the test list
→ Save
```

Action comparison:

| Action | Result |
|---|---|
| Change email | Keeps the subscriber and its subscriptions but uses a new address |
| Unsubscribe | Keeps the subscriber but stops messages from the selected list |
| Delete | Removes the subscriber from AcyMailing |

### 7.4 Update a subscriber linked to a Joomla user

When the subscriber has a CMS user ID or is synchronized with Joomla, update the Joomla account first:

```text
Users → Manage → Open the Joomla user → Change Email → Save & Close
```

Then confirm the updated value under:

```text
Components → AcyMailing → Users
```

Do not update only the AcyMailing record when Joomla synchronization is enabled. A later synchronization may overwrite the email address.

---

## 8. Final Verification Checklist

The installation is complete when all applicable checks pass:

- [ ] AcyMailing appears in Joomla Extensions.
- [ ] The AcyMailing dashboard opens without errors.
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

## 9. Troubleshooting

### AcyMailing dashboard returns HTTP 500

Check the Joomla and container logs:

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

### The component exists but database tables are missing

1. Restore the database backup if the installation state is inconsistent.
2. Reinstall AcyMailing with the official ZIP package.
3. Recheck `#__extensions` and `#__acym_%` tables.

Do not manually insert records into `#__extensions` or manually create AcyMailing tables as a normal deployment method.

### Joomla Discover does not find AcyMailing

Confirm:

- [ ] All source files were pulled.
- [ ] The extension manifest XML files exist.
- [ ] Files are in the correct Joomla extension directories.
- [ ] The web server can read the files.
- [ ] The extension is not already registered in `#__extensions`.

Find AcyMailing manifest files:

```bash
find administrator components modules plugins libraries \
  -type f -name '*.xml' \
  | grep -i acym
```

### Joomla mail works but AcyMailing does not send

Check:

- AcyMailing mail configuration
- SMTP credentials and encryption settings
- Sender email address
- Reply-to email address
- Queue status
- Cron job or scheduled task
- Spam folder
- Mail provider logs
