# 03 — Namespace, Services, and Runtime Registration

## 1. Learning Goal

Understand the bridge between an installed Joomla extension and the PHP class that Joomla executes.

This lesson focuses on:

~~~text
Manifest namespace
        ↓
PSR-4 class mapping
        ↓
services/provider.php
        ↓
Dependency Injection Container
        ↓
Runtime extension service
        ↓
Dispatcher / Extension class
~~~

---

## 2. Problem / Why It Exists

After installation, Joomla still needs to answer:

~~~text
Which PHP class should I load?
Where is its file?
How should the runtime service be constructed?
What Joomla services does it depend on?
~~~

Modern Joomla solves much of this through:

- namespaces;
- PSR-4-style autoloading;
- service providers;
- dependency injection containers.

---

## 3. Namespace Mapping

Example manifest:

~~~xml
<namespace path="src">Demo\Module\ExtensionProbe</namespace>
~~~

Conceptually:

~~~text
Namespace prefix
Demo\Module\ExtensionProbe
        ↓
source root
src/
~~~

For a site module, a class such as:

~~~text
Demo\Module\ExtensionProbe\Site\Dispatcher\Dispatcher
~~~

maps to:

~~~text
src/Dispatcher/Dispatcher.php
~~~

The important Phase 01 rule is:

> namespace, directory names, class names, and filename casing must agree.

---

## 4. Why PSR-4 Matters

Without autoloading, code would need many manual file includes.

With namespace/autoload mapping:

~~~text
Joomla needs class:
Demo\Module\ExtensionProbe\Site\Dispatcher\Dispatcher

        ↓

autoload mapping identifies source root

        ↓

src/Dispatcher/Dispatcher.php
~~~

The extension code can work with classes instead of manual file loading.

---

## 5. Autoload Cache

Joomla caches namespace mappings.

A useful debugging location is:

~~~text
administrator/cache/autoload_psr4.php
~~~

If a class cannot be found, inspect the mapping before randomly changing code.

Debug chain:

~~~text
Class not found
    ↓
Correct FQCN?
    ↓
Correct manifest namespace?
    ↓
Correct src path?
    ↓
Correct Site / Administrator segment?
    ↓
Correct directory/file casing?
    ↓
Autoload mapping contains expected prefix?
~~~

Do not manually maintain this generated cache file.

---

## 6. Service Provider

Training module:

~~~text
mod_extension_probe/
└── services/
    └── provider.php
~~~

Minimal provider:

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

At Phase 01, do not memorise every Joomla DI class.

Understand the responsibility:

~~~text
services/provider.php
        ↓
register extension-specific services
        ↓
tell Joomla how runtime objects are created
~~~

---

## 7. Extension Child Container

When Joomla boots an extension, it can use an extension-specific child dependency injection container.

Mental model:

~~~text
Main Joomla DI Container
          │
          ▼
Extension Child Container
          │
          ├── extension-specific factories
          ├── dispatcher factory
          └── extension runtime service
~~~

The child container can obtain shared services from the parent container while keeping extension-specific registrations scoped to the extension.

---

## 8. Runtime Entry for the Training Module

Dispatcher class:

~~~text
src/
└── Dispatcher/
    └── Dispatcher.php
~~~

Example:

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
        $message = 'Joomla loaded this custom module successfully.';

        require ModuleHelper::getLayoutPath('mod_extension_probe');
    }
}
~~~

The dispatcher prepares runtime data and resolves the layout.

---

## 9. Runtime Flow

Once the module is installed, published, assigned a position, and selected for the current page:

~~~text
Template renders module position
        ↓
Joomla identifies module instance
        ↓
Extension/module runtime boot
        ↓
services/provider.php
        ↓
Module dispatcher factory
        ↓
Dispatcher class
        ↓
dispatch()
        ↓
ModuleHelper::getLayoutPath(...)
        ↓
tmpl/default.php or template override
        ↓
HTML
~~~

This is the first complete runtime chain you should be able to trace.

---

## 10. Installation Registration vs Runtime Registration

These are related but different ideas.

### Installation

~~~text
manifest
→ installer
→ files + extension metadata registered
~~~

### Runtime

~~~text
installed extension requested
→ Joomla creates/uses extension service container
→ service provider registers services
→ runtime class instantiated
→ execution
~~~

Do not describe services/provider.php as the file that installs the extension.

Do not describe the manifest as the file that implements runtime logic.

---

## 11. Component / Module / Plugin Difference

The infrastructure idea is shared, but runtime classes differ.

Conceptually:

~~~text
Component
services/provider.php
    ↓
Component service + MVC/dispatcher factories
    ↓
Component dispatcher / MVC

Module
services/provider.php
    ↓
Module dispatcher factory
    ↓
Module Dispatcher

Plugin
services/provider.php
    ↓
PluginInterface registration
    ↓
Plugin Extension class / event subscriber
~~~

This shared pattern is why learning namespace + services early is useful.

---

## 12. Common Mistakes

### Namespace mismatch

Manifest:

~~~text
Demo\Module\ExtensionProbe
~~~

Provider:

~~~text
Demo\Module\Probe
~~~

Result:

~~~text
class loading / dispatcher creation failure
~~~

### Wrong case

Development on Windows may hide casing errors that fail later on Linux.

Be strict:

~~~text
Dispatcher.php
Dispatcher
src/Dispatcher/
~~~

### Wrong Site / Administrator namespace

Client-specific namespace segments matter.

### Treating provider.php as business logic

Keep provider code focused on service registration.

Business/data/rendering code belongs in the appropriate runtime classes.

---

## 13. Exercise

Given:

~~~text
mod_system_notice
namespace prefix:
Acme\Module\SystemNotice
~~~

Design the expected:

~~~text
services/provider.php
src/Dispatcher/Dispatcher.php
FQCN of Dispatcher
~~~

Then explain how Joomla gets from the namespace declaration to that class.

---

## 14. Completion Check

You pass when you can explain:

- what namespace mapping solves;
- why src/ exists;
- what PSR-4-style autoloading does;
- what services/provider.php does;
- what the DI container contributes;
- how a module dispatcher becomes executable;
- where to investigate a Class not found error.

---

## 15. Key Takeaway

The runtime bridge is:

~~~text
Manifest namespace
→ autoload mapping
→ services/provider.php
→ DI registration
→ runtime class
→ extension execution
~~~

Once this makes sense, modern Joomla extension structures stop looking like unrelated boilerplate files.

---

## References

- Joomla Programmer Documentation — Defining Namespace Prefix: https://manual.joomla.org/docs/next/general-concepts/namespaces/defining-your-namespace/
- Joomla Programmer Documentation — Class Autoloading: https://manual.joomla.org/docs/next/general-concepts/namespaces/autoloading/
- Joomla Programmer Documentation — Extension Child Containers: https://manual.joomla.org/docs/next/general-concepts/dependency-injection/extension-child-containers/
- Joomla Programmer Documentation — Basic Module: https://manual.joomla.org/docs/next/building-extensions/modules/module-development-tutorial/step1-basic-module/
