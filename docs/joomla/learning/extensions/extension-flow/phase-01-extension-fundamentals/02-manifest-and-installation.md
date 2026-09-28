# 02 — Manifest and Installation

## 1. Learning Goal

Understand how an extension package becomes an installed Joomla extension.

After this lesson, the manifest should no longer look like passive metadata. You should understand that it is part of the installer's definition of the extension.

---

## 2. Problem / Why It Exists

Creating PHP files inside a ZIP does not tell Joomla:

- what extension type this is;
- what its internal name is;
- which files belong to it;
- where files should be copied;
- which namespace should be registered;
- whether it is a site or administrator module;
- which plugin group should contain a plugin;
- which SQL or media resources belong to the extension.

The manifest provides this installation definition.

---

## 3. Installation Flow

~~~text
ZIP / Install Folder
        ↓
Find manifest XML
        ↓
Read <extension ...>
        ↓
Determine extension type
        ↓
Determine technical element/name
        ↓
Process declared files
        ↓
Process namespace
        ↓
Process media/language/SQL if declared
        ↓
Register installed extension
        ↓
Installation complete
~~~

Important:

~~~text
Manifest ≠ runtime business logic
~~~

Its main responsibility is extension definition and installation/update metadata.

---

## 4. Minimal Module Manifest

For the Phase 01 training extension:

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<extension type="module" client="site" method="upgrade">
    <name>Extension Probe</name>
    <version>1.0.0</version>
    <author>Learning Demo</author>
    <creationDate>2026</creationDate>
    <description>Minimal module used to learn Joomla extension loading.</description>

    <namespace path="src">Demo\Module\ExtensionProbe</namespace>

    <files>
        <folder module="mod_extension_probe">services</folder>
        <folder>src</folder>
        <folder>tmpl</folder>
    </files>
</extension>
~~~

Filename:

~~~text
mod_extension_probe.xml
~~~

---

## 5. Read the Manifest as Instructions

### Extension element

~~~xml
<extension type="module" client="site" method="upgrade">
~~~

Meaning:

~~~text
type="module"
→ install as a module

client="site"
→ frontend/site module

method="upgrade"
→ allow an existing installed version to be upgraded
~~~

### Display metadata

~~~xml
<name>Extension Probe</name>
<version>1.0.0</version>
<author>Learning Demo</author>
~~~

These identify the package to administrators and help version management.

Do not use the display name as a substitute for understanding the extension's technical element.

### Namespace

~~~xml
<namespace path="src">Demo\Module\ExtensionProbe</namespace>
~~~

This tells Joomla that the extension's PHP classes are under the declared namespace prefix and that the class source root is src/.

For a site module the effective site namespace follows Joomla's client namespace conventions.

The mapping is explored in the next lesson.

### Files

~~~xml
<files>
    <folder module="mod_extension_probe">services</folder>
    <folder>src</folder>
    <folder>tmpl</folder>
</files>
~~~

This does two important things:

1. Declares extension files/folders to the installer.
2. The module="mod_extension_probe" attribute identifies the module element and points Joomla toward the module's service-provider entry path.

A file that exists in your development folder but is not declared appropriately may not be processed/copied as you expect.

---

## 6. Package Structure vs Installed Structure

Development package:

~~~text
mod_extension_probe/
├── mod_extension_probe.xml
├── services/
├── src/
└── tmpl/
~~~

After installing a site module, the runtime code is placed under Joomla's module location:

~~~text
<Joomla Root>/
└── modules/
    └── mod_extension_probe/
        ├── mod_extension_probe.xml
        ├── services/
        ├── src/
        └── tmpl/
~~~

Do not assume every extension type installs to the same root.

Examples:

~~~text
Component site:
components/com_example/

Component admin:
administrator/components/com_example/

Site module:
modules/mod_example/

Plugin:
plugins/<group>/<element>/

Site template:
templates/<template>/
~~~

---

## 7. Manifest Naming

Naming consistency matters.

Common rules:

~~~text
Component:
example.xml or com_example.xml

Module:
mod_example.xml

Plugin:
example.xml

Template:
templateDetails.xml
~~~

If manifest naming and the extension element are inconsistent, installation may appear to succeed while namespace/runtime loading fails later.

---

## 8. Install Methods for Development

For a fresh Joomla development environment you can typically use:

~~~text
Upload Package File
~~~

or:

~~~text
Install from Folder
~~~

For repeatable release testing, a ZIP package is useful because it tests the package exactly as another environment would receive it.

For fast local development, Install from Folder can reduce repeated ZIP creation.

---

## 9. What Installation Changes

Conceptually:

~~~text
Before install

source package
   ↓
not known as an installed extension

After install

files copied
+ extension registered
+ namespace information available
+ extension can be configured/triggered
~~~

This distinction matters when debugging.

A folder manually copied into Joomla is not automatically equivalent to a correctly installed extension.

Joomla has a Discover mechanism for certain extension situations, but development should not depend on accidental filesystem state.

---

## 10. Observe and Trace

After installing mod_extension_probe, inspect:

### Filesystem

~~~text
modules/mod_extension_probe/
~~~

### Joomla Administrator

Check:

~~~text
System
→ Manage
→ Extensions
~~~

Find the installed module extension and inspect its type, element, version, and status.

### Database

For learning purposes, inspect the extension registration record in:

~~~text
#__extensions
~~~

Do not modify it manually.

The purpose is to connect manifest metadata with Joomla's registered extension record.

---

## 11. Common Mistakes

### Missing folder from the files section

Symptom:

~~~text
Code exists in source package
but is missing after install
~~~

Check the manifest.

### Wrong manifest filename

Symptom:

~~~text
install/runtime namespace problems
~~~

Check the naming rule for that extension type.

### Technical identity mismatch

Example mismatch:

~~~text
manifest element: mod_extension_probe
service/provider expects: mod_probe
folder: mod_extension_probe
~~~

Keep one stable identity.

### Editing installed files as the only source

Treat your development package/repository as the source of truth.

Installed Joomla files are deployment output.

---

## 12. Exercise

Without copying the example, design only the manifest/package definition for:

~~~text
mod_system_notice
~~~

Requirement:

~~~text
A site module that will eventually display a short notice.
~~~

Define:

- manifest filename;
- extension type;
- client;
- namespace;
- files section;
- expected installed path.

No runtime implementation is required yet.

---

## 13. Completion Check

You pass when you can explain:

- why the manifest is required;
- how the installer learns the extension type;
- how the technical element is determined;
- why the files section matters;
- why namespace metadata belongs in the manifest;
- difference between package structure and installed structure;
- difference between installing and simply copying files.

---

## 14. Key Takeaway

Think of the manifest as the installer's contract:

~~~text
"This is what I am,
these are my files,
this is my namespace,
this is how Joomla should install/register me."
~~~

---

## References

- Joomla Programmer Documentation — Manifest Files: https://manual.joomla.org/docs/4.4/building-extensions/install-update/installation/manifest/
- Joomla Programmer Documentation — Basic Module: https://manual.joomla.org/docs/next/building-extensions/modules/module-development-tutorial/step1-basic-module/
