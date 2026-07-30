# Joomla Templates

A structured learning guide for understanding, building, overriding, testing, and migrating Joomla templates.

## Table of Contents

- [1. Template Overview and Rendering](01-template-overview-and-rendering.md)
- [2. Template Structure and Important Files](02-template-structure-and-files.md)
- [3. Overrides and Loading Order](03-overrides-and-loading-order.md)
- [4. Assets, Languages, and Module Chrome](04-assets-languages-and-module-chrome.md)
- [5. Joomla 3 to Joomla 4+ Migration](05-joomla-3-to-4-migration.md)
- [6. Build, Test, Package, and Install a Custom Template](06-build-test-package-and-install.md)

---

## Learning Outcomes

After completing this section, you should be able to:

- Explain the role of a template in Joomla rendering and MVC.
- Identify the important files and folders in a Joomla template.
- Create component, module, plugin, and reusable layout overrides.
- Understand Joomla's layout resolution order.
- Load CSS and JavaScript correctly in Joomla 4 and later.
- Create custom module chrome.
- Migrate a Joomla 3 template toward Joomla 4, 5, or 6.
- Build, test, package, and install a custom template.

---

## Recommended Learning Order

```mermaid
flowchart LR
    A[Rendering and MVC] --> B[Template Structure]
    B --> C[Overrides]
    C --> D[Assets and Languages]
    D --> E[Migration]
    E --> F[Build and Test]
```

---

## Core Principle

> Components generate application content. Templates arrange that content and control the final page presentation.

Avoid modifying Joomla core files. Use template overrides, reusable layouts, child templates, and version-controlled custom code instead.
