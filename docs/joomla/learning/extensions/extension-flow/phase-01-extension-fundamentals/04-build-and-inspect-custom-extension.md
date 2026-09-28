# 04 — Build and Inspect a Custom Extension

## 1. Learning Goal

Build one minimal custom extension from scratch and prove the complete flow:

~~~text
Requirement
→ extension type
→ technical name
→ package
→ manifest
→ namespace
→ services
→ runtime class
→ layout
→ install
→ configure
→ execute
→ trace
~~~

This is a disposable learning extension.

It is intentionally not the Book Library feature that will be developed in later phases.

---

## 2. Requirement

Build a small frontend block that displays:

~~~text
Extension Probe
Joomla loaded this custom module successfully.
~~~

It must:

- be independently publishable;
- be assigned to a template position;
- be assignable to selected pages;
- render through a layout file.

---

## 3. Choose the Extension Type

Decision:

~~~text
Does it own the main page?
NO

Does it react to an event?
NO

Is it a reusable visual block placed in the template?
YES

→ Module
~~~

Technical name:

~~~text
mod_extension_probe
~~~

Namespace prefix:

~~~text
Demo\Module\ExtensionProbe
~~~

---

## 4. Final Source Structure

Create:

~~~text
mod_extension_probe/
├── mod_extension_probe.xml
├── services/
│   └── provider.php
├── src/
│   └── Dispatcher/
│       └── Dispatcher.php
└── tmpl/
    └── default.php
~~~

At this stage there is deliberately:

- no database;
- no helper;
- no configuration form;
- no JavaScript;
- no CSS;
- no language package.

Those concepts can be added later without hiding the core extension flow.

---

## 5. Manifest

Create:

~~~text
mod_extension_probe/mod_extension_probe.xml
~~~

Content:

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<extension type="module" client="site" method="upgrade">
    <name>Extension Probe</name>
    <version>1.0.0</version>
    <author>Learning Demo</author>
    <creationDate>2026</creationDate>
    <description>Minimal module for learning Joomla extension definition and runtime flow.</description>

    <namespace path="src">Demo\Module\ExtensionProbe</namespace>

    <files>
        <folder module="mod_extension_probe">services</folder>
        <folder>src</folder>
        <folder>tmpl</folder>
    </files>
</extension>
~~~

Before continuing, explain each important line.

You should be able to identify:

~~~text
type
client
method
name
version
namespace
src path
module element
declared folders
~~~

---

## 6. Service Provider

Create:

~~~text
mod_extension_probe/services/provider.php
~~~

Content:

~~~php
<?php

\defined('_JEXEC') or die;

use Joomla\CMS\Extension\Service\Provider\Module as ModuleServiceProvider;
use Joomla\CMS\Extension\Service\Provider\ModuleDispatcherFactory as ModuleDispatcherFactoryServiceProvider;
use Joomla\DI\Container;
use Joomla\DI\ServiceProviderInterface;

return new class () implements ServiceProviderInterface {
    public function register(Container $container): void
    {
        $container->registerServiceProvider(
            new ModuleDispatcherFactoryServiceProvider(
                '\\Demo\\Module\\ExtensionProbe'
            )
        );

        $container->registerServiceProvider(
            new ModuleServiceProvider()
        );
    }
};
~~~

Mental model:

~~~text
provider.php
    ↓
register dispatcher factory
    ↓
register module service
    ↓
Joomla can create module runtime objects
~~~

Do not customise this file further until you understand why a dependency is needed.

---

## 7. Dispatcher

Create:

~~~text
mod_extension_probe/src/Dispatcher/Dispatcher.php
~~~

Content:

~~~php
<?php

namespace Demo\Module\ExtensionProbe\Site\Dispatcher;

\defined('_JEXEC') or die;

use Joomla\CMS\Dispatcher\DispatcherInterface;
use Joomla\CMS\Helper\ModuleHelper;

final class Dispatcher implements DispatcherInterface
{
    public function dispatch()
    {
        $title = 'Extension Probe';
        $message = 'Joomla loaded this custom module successfully.';

        require ModuleHelper::getLayoutPath('mod_extension_probe');
    }
}
~~~

Responsibility:

~~~text
Dispatcher
→ prepares runtime values
→ selects/resolves layout
~~~

For this lesson it does not contain business logic.

---

## 8. Layout

Create:

~~~text
mod_extension_probe/tmpl/default.php
~~~

Content:

~~~php
<?php

\defined('_JEXEC') or die;
?>

<section class="extension-probe">
    <h3><?php echo htmlspecialchars($title, ENT_QUOTES, 'UTF-8'); ?></h3>
    <p><?php echo htmlspecialchars($message, ENT_QUOTES, 'UTF-8'); ?></p>
</section>
~~~

Responsibility:

~~~text
Layout
→ HTML presentation
~~~

This separation becomes important later when template overrides are introduced.

---

## 9. Pre-install Validation

Before packaging, verify:

~~~text
Folder:
mod_extension_probe

Manifest:
mod_extension_probe.xml

Manifest module element:
mod_extension_probe

Namespace:
Demo\Module\ExtensionProbe

Provider namespace:
Demo\Module\ExtensionProbe

Dispatcher namespace:
Demo\Module\ExtensionProbe\Site\Dispatcher

Class:
Dispatcher

File:
src/Dispatcher/Dispatcher.php
~~~

Everything must describe the same extension identity.

---

## 10. Package

Create:

~~~text
mod_extension_probe.zip
~~~

The ZIP root should contain:

~~~text
mod_extension_probe.xml
services/
src/
tmpl/
~~~

Avoid an accidental extra parent folder unless the package has explicitly been designed around that structure.

---

## 11. Install on Joomla Fresh

In Joomla Administrator:

~~~text
System
→ Install
→ Extensions
→ Upload Package File
~~~

Install:

~~~text
mod_extension_probe.zip
~~~

Expected result:

~~~text
Module installation successful
~~~

If it fails, do not immediately edit PHP.

First determine which stage failed:

~~~text
manifest discovery?
manifest XML?
file copy?
namespace?
runtime?
~~~

Installation errors and runtime errors are different categories.

---

## 12. Inspect Installed State

### Filesystem

Verify:

~~~text
modules/
└── mod_extension_probe/
    ├── mod_extension_probe.xml
    ├── services/
    ├── src/
    └── tmpl/
~~~

### Extension Manager

Navigate to Joomla extension management and find the installed module.

Confirm its:

~~~text
type
element/name
enabled state
version
~~~

### Namespace mapping

For debugging and learning, inspect:

~~~text
administrator/cache/autoload_psr4.php
~~~

Find the namespace prefix related to:

~~~text
Demo\Module\ExtensionProbe
~~~

Do not edit this generated file manually.

---

## 13. Create a Module Instance

Installing a module extension does not automatically make a visible block appear on every page.

Create/configure a module instance through the site module manager.

Set:

~~~text
Status: Published
Position: choose a visible position from the active site template
Menu Assignment: On all pages
~~~

The exact available positions depend on the active template.

---

## 14. Runtime Trace

Reload the frontend page.

Expected output:

~~~text
Extension Probe
Joomla loaded this custom module successfully.
~~~

Now trace it backwards.

### Step A — HTML

~~~text
Where did the markup come from?

tmpl/default.php
~~~

### Step B — Values

~~~text
Where did $title and $message come from?

src/Dispatcher/Dispatcher.php
~~~

### Step C — Dispatcher creation

~~~text
How could Joomla create the module dispatcher?

services/provider.php
→ ModuleDispatcherFactory
~~~

### Step D — Class discovery

~~~text
How could Joomla locate Dispatcher.php?

manifest namespace
→ namespace mapping
→ PSR-4-style autoload
~~~

### Step E — Installed identity

~~~text
Why does Joomla know this extension exists?

manifest
→ installer
→ extension registration
~~~

This reverse trace is more important than the visible output itself.

---

## 15. Full Flow

~~~text
Requirement
   ↓
Module selected
   ↓
mod_extension_probe
   ↓
Manifest XML
   ↓
Install
   ↓
Extension registration
   ↓
Namespace mapping
   ↓
Create module instance
   ↓
Publish + assign position/page
   ↓
Frontend request
   ↓
Template renders module position
   ↓
Module runtime boot
   ↓
services/provider.php
   ↓
Dispatcher factory
   ↓
Dispatcher::dispatch()
   ↓
ModuleHelper::getLayoutPath()
   ↓
tmpl/default.php
   ↓
HTML
   ↓
Browser
~~~

---

## 16. Debug Exercises

### Exercise 1 — Break the namespace

Change the namespace in the Dispatcher class so it no longer matches the manifest/provider.

Observe the error, then restore the correct namespace.

Goal:

~~~text
Learn what a namespace mismatch looks like.
~~~

### Exercise 2 — Break filename casing

Rename Dispatcher.php with incorrect casing in a disposable local environment.

Goal:

~~~text
Understand why case-sensitive production filesystems matter.
~~~

Restore it afterwards.

### Exercise 3 — Remove tmpl from the manifest

Build a fresh package where tmpl is not declared.

Install it and inspect the resulting installed files and runtime behaviour.

Goal:

~~~text
Understand that package contents and manifest-declared files are not the same thing.
~~~

Restore the correct version after the test.

---

## 17. Completion Check

Do not continue to Phase 02 until you can explain the custom module without reading the source.

Answer:

1. Why was Module the correct type?
2. What is the extension's technical identity?
3. Which file defines installation?
4. Which line declares the namespace?
5. Which file registers runtime services?
6. Which class executes the module?
7. Which file owns HTML markup?
8. What must happen after installation before the module becomes visible?
9. How does Joomla locate the Dispatcher class?
10. What is the difference between install-time failure and runtime failure?

---

## 18. Final Mental Model

~~~text
A Joomla extension is not "just a folder".

It is:

technical identity
+ manifest definition
+ installed registration
+ namespace/class mapping
+ runtime service registration
+ runtime implementation
+ trigger
+ output/effect
~~~

That is the Phase 01 foundation.

---

## References

- Joomla Programmer Documentation — Basic Module: https://manual.joomla.org/docs/next/building-extensions/modules/module-development-tutorial/step1-basic-module/
- Joomla Programmer Documentation — Template Layout Step: https://manual.joomla.org/docs/next/building-extensions/modules/module-development-tutorial/step2-tmpl-file/
- Joomla Programmer Documentation — Namespaces: https://manual.joomla.org/docs/next/general-concepts/namespaces/
