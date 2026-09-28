# 01 — Extension Types and Naming

## 1. Learning Goal

Given a requirement, choose the correct Joomla extension type and give it a valid technical identity before writing implementation code.

---

## 2. Problem / Why It Exists

Joomla provides several extension types because different features participate in the application lifecycle in different ways.

If the wrong type is chosen, the implementation becomes unnecessarily complex.

Example:

~~~text
Requirement:
"Show a small reusable status block in the sidebar."
~~~

Possible choices:

~~~text
Component?  → too large; components provide the main page application
Plugin?     → wrong runtime model; plugins react to events
Template?   → presentation responsibility
Module?     → yes; small block rendered in a template position
~~~

Choosing the extension type is an architecture decision.

---

## 3. Core Concept

The eight Joomla extension types are:

| Type | Typical identity | Main responsibility |
|---|---|---|
| Component | com_example | Main application / central page feature |
| Module | mod_example | Small block rendered in a module position |
| Plugin | group + element, commonly described as plg_group_example | Event-driven behaviour |
| Template | template name | Page presentation and composition |
| Language | language tag | Translation files |
| Library | library name | Shared reusable code |
| Package | pkg_example | Bundle of multiple extensions |
| File | file extension name | Install arbitrary declared files |

For the custom-extension learning path, the most important runtime types are:

~~~text
Component
Module
Plugin
Template
~~~

---

## 4. Requirement → Extension Type Flow

Use this decision flow first:

~~~text
Does the feature own the main page/application?
        │
       YES
        ↓
    Component

        NO
        ↓
Is it a reusable visual block placed in the page layout?
        │
       YES
        ↓
      Module

        NO
        ↓
Should it execute when an event occurs?
        │
       YES
        ↓
      Plugin

        NO
        ↓
Does it define page presentation/layout?
        │
       YES
        ↓
     Template
~~~

This is a learning heuristic, not a replacement for architecture analysis. Real products can contain several extension types packaged together.

---

## 5. Naming Rules

### Component

Technical identity:

~~~text
com_<name>
~~~

Example:

~~~text
com_library
~~~

Typical installed locations:

~~~text
components/com_library/
administrator/components/com_library/
~~~

A component can have site and administrator parts while still representing one component extension.

### Module

Technical identity:

~~~text
mod_<name>
~~~

Example:

~~~text
mod_latest_books
~~~

Site module location:

~~~text
modules/mod_latest_books/
~~~

Administrator modules live under the administrator module path.

### Plugin

A plugin has two important identity parts:

~~~text
group
element
~~~

Example:

~~~text
group   = content
element = library
~~~

Installed path:

~~~text
plugins/content/library/
~~~

A convenient descriptive name is:

~~~text
plg_content_library
~~~

but the runtime/install identity must still be understood as plugin group + plugin element.

### Template

Template identity is its template name.

Example:

~~~text
library
~~~

Installed site template path:

~~~text
templates/library/
~~~

Its manifest is conventionally:

~~~text
templateDetails.xml
~~~

---

## 6. Internal Name vs Display Name

Do not confuse a human-readable display name with the technical extension identity.

Example module:

~~~xml
<name>Extension Probe</name>
~~~

Human-readable name:

~~~text
Extension Probe
~~~

Technical element:

~~~text
mod_extension_probe
~~~

The technical identity is what must remain stable across code, manifest metadata, installed paths, and service registration.

---

## 7. Practical Examples

### Requirement A

~~~text
Build a page with:
- list of books
- book detail route
- database data
- administrator management
~~~

Choice:

~~~text
Component
→ com_library
~~~

### Requirement B

~~~text
Display the newest three books in the sidebar.
~~~

Choice:

~~~text
Module
→ mod_latest_books
~~~

### Requirement C

~~~text
When content is processed, replace a custom token with generated book information.
~~~

Choice:

~~~text
Plugin
→ group: content
→ element: library
~~~

### Requirement D

~~~text
Control header, footer, grid, component area and module positions.
~~~

Choice:

~~~text
Template
~~~

---

## 8. Common Mistakes

### Mistake 1 — One extension for the whole product

A Joomla product can contain:

~~~text
Component
+ Module
+ Plugin
+ Package
~~~

when each part has a separate runtime responsibility.

### Mistake 2 — Choosing by folder shape

Do not say:

~~~text
"It has src/, so it must be a component."
~~~

Modern Joomla extension types can all use namespaced PHP classes.

The type comes from its extension definition and runtime responsibility.

### Mistake 3 — Treating plugins as page blocks

A plugin is primarily event-driven.

If a user needs to assign a visual block to a template position, a module is usually the more direct model.

---

## 9. Exercise

Choose the extension type and technical name for each requirement:

1. Product comparison page with its own routes.
2. Small weather summary in a sidebar.
3. Execute logic after a user event.
4. Define the overall frontend page layout.
5. Install a component, module, and plugin together as one product.

Do not write code yet.

For every answer explain:

~~~text
Requirement
→ runtime responsibility
→ extension type
→ technical identity
~~~

---

## 10. Completion Check

You pass this lesson when you can answer:

- What question does each extension type solve?
- Why is a module not just a small component?
- Why is a plugin not a fixed step after a component?
- What is the difference between plugin group and plugin element?
- Why must technical naming remain consistent?

---

## 11. Key Takeaway

Choose the extension type **before** choosing the folder structure.

~~~text
Requirement
→ Runtime responsibility
→ Extension type
→ Technical name
→ Structure
~~~

That order prevents many design mistakes.

---

## References

- Joomla Programmer Documentation — Build Extensions: https://manual.joomla.org/docs/next/building-extensions/
- Joomla Programmer Documentation — Manifest Files: https://manual.joomla.org/docs/4.4/building-extensions/install-update/installation/manifest/
