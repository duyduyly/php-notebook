# Phase 01 — Extension Fundamentals

This phase teaches Joomla extension development from the **creator's point of view**.

The goal is not only to recognise an existing extension. The goal is to start from a requirement, choose the correct extension type, define the package correctly, install it on a fresh Joomla site, and understand how Joomla can load it at runtime.

> **Target environment:** Joomla 6.x fresh installation.
>
> **Learning direction:** custom extension development.
>
> **Training extension:** mod_extension_probe, a disposable module used only to prove the extension definition and loading flow.

---

## 1. Learning Goal

After this phase you should be able to explain this complete chain:

~~~text
Requirement
    ↓
Choose Extension Type
    ↓
Choose Extension Name
    ↓
Create Package Structure
    ↓
Define Manifest XML
    ↓
Define Namespace
    ↓
Register Runtime Services
    ↓
Build Runtime Class
    ↓
Package / Install
    ↓
Joomla Registers Extension
    ↓
Trigger Extension
    ↓
Trace Runtime Execution
~~~

You do **not** need to understand full component MVC yet. That starts in Phase 02.

---

## 2. Why This Phase Exists

A common learning mistake is to start by copying a component or plugin folder and editing filenames until it works.

That may produce a working extension, but it does not answer:

- Why is this extension a module instead of a component?
- Which value is Joomla's internal extension name?
- Which file tells the installer what to copy?
- How does a PHP namespace map to src/?
- Why does services/provider.php exist?
- How does Joomla know which runtime class to instantiate?
- What is installation-time configuration and what is runtime configuration?

Phase 01 establishes those concepts before the larger demo project begins.

---

## 3. Phase Structure

~~~text
phase-01-extension-fundamentals/
├── README.md
├── 01-extension-types-and-naming.md
├── 02-manifest-and-installation.md
├── 03-namespace-services-and-registration.md
└── 04-build-and-inspect-custom-extension.md
~~~

Recommended order:

~~~text
01 Extension Types + Naming
        ↓
02 Manifest + Installation
        ↓
03 Namespace + Services + Registration
        ↓
04 Build + Install + Trace a Custom Extension
~~~

---

## 4. Two Flows You Must Keep Separate

### Installation flow

~~~text
Extension package
      ↓
Manifest XML
      ↓
Joomla Installer
      ↓
Validate extension metadata
      ↓
Copy extension files
      ↓
Register extension
      ↓
Generate/update namespace mappings
      ↓
Installed extension
~~~

### Runtime flow

~~~text
Page / event / module position / route
              ↓
       Joomla Application
              ↓
      Extension is requested
              ↓
     Runtime services loaded
              ↓
        PHP classes loaded
              ↓
       Extension executes
              ↓
          Output/effect
~~~

Installation makes an extension available.

Runtime is when Joomla actually executes it.

---

## 5. Final Exercise

The final exercise builds a minimal site module:

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

It renders:

~~~text
Extension Probe
Joomla loaded this custom module successfully.
~~~

The visible feature is intentionally trivial. The important part is proving:

~~~text
manifest
   ↓
namespace
   ↓
service provider
   ↓
dispatcher
   ↓
layout
   ↓
HTML
~~~

---

## 6. Completion Check

Phase 01 is complete when you can answer these questions without copying the example:

1. What extension type should be used for a main page application?
2. What extension type should be used for a reusable block in a template position?
3. What extension type should be used for event-driven logic?
4. What is the purpose of the manifest XML file?
5. What is Joomla's internal extension element/name?
6. How does a namespace declared in the manifest map to PHP classes?
7. What is the purpose of services/provider.php?
8. What happens during installation that does not happen on every normal request?
9. What triggers the runtime execution of the extension?
10. How would you debug a Class not found error?

If any answer is unclear, revisit the corresponding lesson before Phase 02.

---

## 7. Key Takeaway

Do not think:

~~~text
Create folders
→ Joomla somehow runs them
~~~

Think:

~~~text
Requirement
→ extension type
→ extension identity
→ manifest definition
→ install/register
→ namespace/services
→ runtime trigger
→ execution
~~~

That mental model is the foundation for custom Joomla extension development.

---

## References

- Joomla Programmer Documentation — Build Extensions: https://manual.joomla.org/docs/next/building-extensions/
- Joomla Programmer Documentation — Module Development Tutorial: https://manual.joomla.org/docs/next/building-extensions/modules/module-development-tutorial/
- Joomla Programmer Documentation — Namespaces: https://manual.joomla.org/docs/next/general-concepts/namespaces/
