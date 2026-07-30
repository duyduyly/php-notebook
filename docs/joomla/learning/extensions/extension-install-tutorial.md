# How to Install Joomla Extensions

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Installation methods at a glance](#2-installation-methods-at-a-glance)
- [3. Upload Package File](#3-upload-package-file)
- [4. Install from Folder](#4-install-from-folder)
- [5. Install from URL](#5-install-from-url)
- [6. Install from Web](#6-install-from-web)
- [7. Discover Install](#7-discover-install)
- [8. Install through a parent package](#8-install-through-a-parent-package)
- [9. Examples by extension source](#9-examples-by-extension-source)
- [10. How to choose the correct method](#10-how-to-choose-the-correct-method)
- [11. Post-installation checklist](#11-post-installation-checklist)
- [12. Safety recommendations](#12-safety-recommendations)
- [13. Key takeaways](#13-key-takeaways)

## 1. Purpose

This guide explains how Joomla extensions are installed, with practical examples for components, modules, plugins, templates, libraries, and packages.

The installation method does **not** determine the extension source:

- **Core**: distributed with Joomla.
- **Third-party**: developed and distributed by an external vendor or community developer.
- **Custom**: developed specifically for the project.

A third-party or custom extension can use the same installation method.

> **Important:** Joomla provides several installer methods. Installing through a **parent package** is a packaging scenario, not a separate installer screen: the administrator installs one package, and Joomla installs the bundled child extensions.

## 2. Installation methods at a glance

| Method | Typical use | Example |
|---|---|---|
| Upload Package File | A ZIP package is available | Install Akeeba Backup from an official ZIP |
| Install from Folder | The extracted package is already on the server | Install a large custom module from a temporary directory |
| Install from URL | A direct package URL is available | Install a vendor plugin from a direct ZIP URL |
| Install from Web | The extension is available through Joomla's web installer | Search for and install a published SEO extension |
| Discover Install | Source files were copied to their final Joomla directory but are not registered | Register a deployed custom system plugin |
| Parent Package | Multiple child extensions are bundled in one installable package | Install AcyMailing and its bundled component, modules, and plugins |

## 3. Upload Package File

This is the most common method. It supports third-party packages, custom packages, and packages containing multiple extensions.

### Administrator path

**Joomla 3**

```text
Extensions → Manage → Install → Upload Package File
```

**Joomla 4, 5, and 6**

```text
System → Install → Extensions → Upload Package File
```

### Third-party example

Download the official package:

```text
com_akeebabackup-9.9.0.zip
```

Upload it through Extension Installer. Joomla extracts the package, reads its manifest, registers the extension, and runs its installation script when provided.

### Custom plugin example

A project team may package this custom plugin:

```text
plg_system_companyapi-1.0.0.zip
```

Example package content:

```text
plg_system_companyapi/
├── companyapi.php
├── companyapi.xml
└── language/
```

Upload the ZIP, install it, open Plugin Manager, configure the plugin, and enable it.

### Use this method when

- The vendor provides an official ZIP.
- The custom extension has a valid installable package.
- A repeatable installation is required across environments.
- Joomla should execute manifest operations and installation scripts.

## 4. Install from Folder

This method installs an extracted package from a directory that Joomla can access.

Example directory:

```text
/tmp/install_company_banner/
├── mod_company_banner.php
├── mod_company_banner.xml
├── tmpl/
└── language/
```

Enter the extracted directory path in **Install from Folder**:

```text
/tmp/install_company_banner
```

Joomla reads the manifest XML and performs the normal installation process.

### Use this method when

- The ZIP exceeds the server upload limit.
- Uploading through the browser fails.
- The package is already available on the server.
- A deployment process places the extracted package in a temporary directory.

### Important distinction

The folder must contain an **installation package**, including a valid manifest. This is different from copying files directly into their final runtime path and using Discover.

## 5. Install from URL

This method lets the Joomla server download and install a package from a direct URL.

Example:

```text
https://vendor.example.com/releases/plg_system_example-1.2.0.zip
```

Joomla will normally:

1. Download the package.
2. Extract it.
3. Read the manifest XML.
4. Register the extension.
5. Run installation operations or scripts.

### Requirements

- The URL must point directly to the installable package.
- The Joomla server must have outbound network access.
- The URL must not require an unsupported interactive login.
- The server must trust the HTTPS certificate.

A URL that opens a product page, login form, or HTML download page may not work.

## 6. Install from Web

Install from Web allows administrators to find and install supported extensions through Joomla's web installer.

Typical flow:

```text
Extension Installer
→ Install from Web
→ Search for an extension
→ Review the extension
→ Install
```

Example: search for a published SEO extension, open its details, and select **Install**.

### Use this method when

- The extension is published through the supported Joomla extension ecosystem.
- The administrator wants to discover and install it without manually downloading a ZIP.

### Limitations

- Not every third-party extension is listed.
- Commercial extensions may require an account, subscription, or download key.
- Custom project extensions are normally not available here.

## 7. Discover Install

Discover registers an extension whose files already exist in the correct Joomla runtime directory but whose database registration is missing.

### Custom plugin example

Deploy the source to:

```text
plugins/system/companyapi/
├── companyapi.php
└── companyapi.xml
```

Then use:

**Joomla 3**

```text
Extensions → Manage → Discover
```

**Joomla 4, 5, and 6**

```text
System → Install → Discover
```

Select the discovered extension, install it, and then enable it in Plugin Manager.

### Common use cases

- A custom extension is deployed with the application source.
- Files were restored but the extension database record is missing.
- Files were copied from another environment.
- A deployment pipeline does not use an installable ZIP.

### Requirements and limitations

- The files must be in the correct extension directory.
- A valid manifest XML must exist in the expected location.
- Discover does not make arbitrary or incomplete source code installable.
- Copying only part of an extension can omit database changes, media, languages, or installation-script operations.

## 8. Install through a parent package

A package can bundle several related extensions. The administrator uploads one package, and Joomla installs each child package.

Example:

```text
pkg_acymailing.zip
├── com_acymailing.zip
├── mod_acymailing_subscribe.zip
├── plg_system_acymailing.zip
├── plg_acymailing_tagcontent.zip
└── plg_acymailing_tagsubscriber.zip
```

Installation flow:

```text
Extension Installer
→ Upload pkg_acymailing.zip
→ Install
→ Joomla installs the bundled child extensions
```

This explains why an individual ZIP may not be available for every AcyMailing plugin. Some plugins are installed and maintained as part of the official AcyMailing distribution.

An integration such as an AcyMailing–HikaShop plugin may instead be distributed as a separate official add-on package.

### Recommended report wording

For a bundled plugin:

```text
Installation Method: Parent Package
Installation Package: Official AcyMailing package
Individual Installation: Not normally required
```

For a separate integration:

```text
Installation Method: Package Upload
Installation Package: Official vendor integration add-on
```

## 9. Examples by extension source

| Extension | Type | Source | Example installation |
|---|---|---|---|
| `com_content` | Component | Core | Installed with Joomla |
| Akeeba Backup | Component | Third-party | Upload official package |
| AcyMailing child plugins | Plugins | Third-party | Installed through the parent package |
| Published SEO extension | Plugin/Component | Third-party | Install from Web |
| `com_company_product` | Component | Custom | Upload a custom ZIP |
| `plg_system_companyapi` | Plugin | Custom | Deploy source and use Discover |
| `mod_company_banner` | Module | Custom | Install from an extracted folder |

## 10. How to choose the correct method

| Situation | Recommended method |
|---|---|
| An official or custom installable ZIP is available | Upload Package File |
| The installable package is extracted on the server | Install from Folder |
| A trusted direct download URL is available | Install from URL |
| The extension is available through Joomla's web installer | Install from Web |
| Files are already deployed to the final Joomla directory | Discover Install |
| The extension is a child of a vendor suite | Install or update the official parent package |
| The historical method cannot be proven | Record it as Unknown; recommend the official package for reinstallation |

When inventory data only proves that an extension is present, do not guess its historical installation method.

Use:

```text
Installation Method: Unknown
Recommended Reinstallation Method: Official vendor package
```

## 11. Post-installation checklist

```text
[ ] Confirm that Joomla reports a successful installation
[ ] Verify the extension in Extension Manager
[ ] Enable the plugin or module if required
[ ] Review and save its configuration
[ ] Confirm required dependencies are installed
[ ] Check database schema and update sites
[ ] Clear Joomla and extension caches
[ ] Test administrator functionality
[ ] Test frontend functionality
[ ] Review PHP and Joomla logs
[ ] Record the package source, version, license, and installation method
```

## 12. Safety recommendations

- Download third-party packages only from the official vendor or another trusted source.
- Back up files and the database before installing or updating production extensions.
- Verify compatibility with the exact Joomla and PHP versions.
- Do not copy legacy extension directories directly from Joomla 3 to Joomla 6.
- Prefer the current official package and the vendor's documented migration path.
- Test parent packages and integration add-ons in a staging environment.
- Keep the original install package or an approved artifact so installation can be reproduced.

## 13. Key takeaways

```text
Extension type     = Component, Module, Plugin, Template, Library, Package, etc.
Extension source   = Core, Third-party, or Custom
Installer method   = Upload, Folder, URL, Web, or Discover
Packaging scenario = Standalone package or Parent Package
```

The extension type and source do not determine the installer method. A third-party and a custom extension may both be installed from ZIP, from a folder, from a URL, or through Discover when appropriately packaged and deployed.
