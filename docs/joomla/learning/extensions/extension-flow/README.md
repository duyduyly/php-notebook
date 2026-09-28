# Joomla Extension Flow Learning Roadmap

A practical learning roadmap for understanding how Joomla extensions are defined, discovered, installed, executed, rendered, and connected during a real request.

> **Target environment:** Joomla 6 fresh installation.
>
> **Demo project:** Book Library. This demo is intentionally independent from existing production/custom projects so the architecture can be studied without project-specific assumptions.

---

## Goal

After completing this roadmap, you should be able to:

1. Explain the Joomla request lifecycle from browser request to final response.
2. Identify the role of Component, Module, Plugin, Template, and Media.
3. Explain how these extension types interact without treating them as one linear pipeline.
4. Read an extension folder and identify its type, entry points, manifest, runtime classes, layouts, and assets.
5. Explain how Joomla discovers and registers an extension.
6. Define a new extension from scratch using the correct naming, manifest, namespace, service registration, and installed paths.
7. Install the extension on a fresh Joomla project and trace its runtime execution.
8. Decide which extension type should be used for a new requirement.

---

## Learning Method

Every phase follows the same learning loop:

```text
Concept
  ↓
Runtime Flow
  ↓
Structure
  ↓
Real-world Function
  ↓
Build on Joomla Fresh
  ↓
Run and Observe
  ↓
Debug / Trace
  ↓
Connect to Previous Layers
```

The purpose is not to memorize folders. The purpose is to understand why each folder exists and when Joomla uses it.

---

# Demo Project

We will progressively build a small **Book Library** website.

Final demo scope:

```text
Joomla Fresh
│
├── Component
│   └── com_library
│       ├── Book list
│       ├── Book detail
│       └── Administrator CRUD
│
├── Module
│   └── mod_latest_books
│
├── Plugin
│   └── plg_content_library
│
├── Template
│   └── tpl_library
│
└── Media
    ├── Component assets
    ├── Module assets
    └── Template assets
```

The demo remains intentionally small so runtime behavior stays visible.

---

# Roadmap Overview

| Phase | Topic | Main outcome |
|---:|---|---|
| 0 | Joomla Request Lifecycle | Understand the global request/response pipeline |
| 1 | Extension Fundamentals | Understand how Joomla defines, installs, discovers, and registers extensions |
| 2 | Component | Build and trace the main application extension |
| 3 | Database + Administrator | Add persistence and backend CRUD |
| 4 | Module | Understand independently rendered template-position blocks |
| 5 | Plugin + Events | Understand event-driven execution |
| 6 | Template | Understand page composition and module positions |
| 7 | Template Overrides | Understand presentation overrides without editing extension code |
| 8 | Media + Web Assets | Understand asset registration and public files |
| 9 | Complete Runtime Flow | Trace all layers together |
| 10 | Extension From Scratch Challenge | Prove the architecture can be applied independently |

---

# Phase 0 — Joomla Request Lifecycle

## Question

What happens after the browser requests a Joomla page?

## Flow

```text
Browser
   ↓
index.php
   ↓
Joomla Application
   ↓
Routing
   ↓
Main Component
   ↓
Document preparation
   ↓
Template
   ├── Component output
   └── Modules
   ↓
Response
   ↓
Browser

Events may be dispatched throughout the lifecycle
        ↓
      Plugins
```

## Practical exercise

Start with Joomla Fresh only.

Create:

- one article;
- one menu item;
- one module assigned to a template position.

Open the page and identify:

- selected menu item;
- active component;
- module positions;
- active template;
- generated HTML;
- loaded CSS/JS.

## Completion criteria

You can explain why Component, Module, Plugin, Template, and Media are not simply executed one after another.

---

# Phase 1 — Extension Fundamentals

This phase answers:

> How does Joomla know that a folder/package is an extension?

## Topics

### Extension types

Focus first on the runtime types used by the demo:

```text
Component
Module
Plugin
Template
```

Then understand supporting extension types separately:

```text
Library
Language
Package
File
```

### Naming conventions

Examples:

```text
com_library
mod_latest_books
plg_content_library
tpl_library
```

### Manifest

Study the manifest as the installation definition:

```text
Extension package
      ↓
manifest XML
      ↓
Installer
      ↓
files / namespaces / media / language / SQL
      ↓
Installed extension
```

### Namespace mapping

Understand how a namespace declared by the extension maps to namespaced PHP classes.

### Service registration

Study the purpose of:

```text
services/provider.php
```

where applicable.

### Installation vs installed structure

Do not assume the ZIP structure and final Joomla filesystem paths are identical.

### Discovery

Understand the difference between:

- installing a package;
- discovering files already present in Joomla;
- enabling/disabling an installed extension.

## Practical exercise

Inspect several Joomla Core extensions and identify:

```text
type
name
manifest
namespace
service provider
runtime classes
layout
media
installed path
```

## Completion criteria

Given an unfamiliar Joomla extension folder, you can explain how Joomla identifies and registers it.

---

# Phase 2 — Component

Build:

```text
com_library
```

Initial feature:

```text
Books
----------------
Clean Architecture
The Pragmatic Programmer
Refactoring
```

## Runtime flow

```text
Request
   ↓
Router
   ↓
com_library
   ↓
Controller
   ↓
Model
   ↓
View
   ↓
Layout
   ↓
Component HTML
```

## Structure to learn

```text
com_library/
├── services/
├── src/
│   ├── Controller/
│   ├── Extension/
│   ├── Model/
│   └── View/
├── tmpl/
├── language/
└── manifest.xml
```

Exact installed paths must also be inspected after installation.

## Build

Implement:

1. book list;
2. book detail;
3. menu item pointing to the component;
4. basic routing.

## Observe

Trace one request from URL to layout.

## Completion criteria

You can explain what Controller, Model, View, and Layout each contribute to the final output.

---

# Phase 3 — Database and Administrator Component

Add persistence.

Example table:

```text
#__library_books

id
title
author
description
published
created
```

## Flow

```text
Administrator
     ↓
com_library
     ↓
Controller
     ↓
Model / Table / Form
     ↓
Database

Site
     ↓
com_library
     ↓
Model
     ↓
Database
     ↓
View
```

## Build

Add:

- SQL install/update files;
- administrator list view;
- create form;
- edit form;
- publish/unpublish;
- delete;
- site rendering from database records.

## Topics

```text
ListModel
AdminModel
Table
Form XML
ACL basics
SQL installation
SQL updates
Site vs Administrator client
```

## Completion criteria

You can explain how one component can have separate Site and Administrator applications while sharing one extension identity.

---

# Phase 4 — Module

Build:

```text
mod_latest_books
```

Feature:

```text
Latest Books
----------------
Refactoring
Clean Architecture
```

## Runtime flow

```text
Template
   ↓
Module position
   ↓
Joomla loads assigned module instance
   ↓
Module dispatcher/helper
   ↓
Layout
   ↓
Module HTML
```

## Structure

```text
mod_latest_books/
├── services/
│   └── provider.php
├── src/
│   ├── Dispatcher/
│   └── Helper/
├── tmpl/
│   └── default.php
├── language/
└── manifest.xml
```

## Build

The module should read latest books from the same database table used by `com_library`.

## Important comparison

```text
Component
→ main application output

Module
→ independent small block rendered in a template position
```

## Completion criteria

Given a feature requirement, you can explain when it should be a module rather than a component.

---

# Phase 5 — Plugin and Events

Build:

```text
plg_content_library
```

Simple feature:

```text
{book 12}
```

becomes rendered book information when a relevant content event is processed.

## Runtime model

Do NOT learn Plugin as:

```text
Component → Module → Plugin
```

Instead:

```text
Joomla / Extension
       ↓
dispatch Event
       ↓
Event Dispatcher
       ↓
Subscribed Plugins
       ↓
Plugin handler
       ↓
Flow continues
```

## Structure

```text
plugins/
└── content/
    └── library/
        ├── services/
        │   └── provider.php
        ├── src/
        │   └── Extension/
        │       └── Library.php
        ├── language/
        └── library.xml
```

## Build

Implement one event subscriber and log/inspect when it executes.

## Completion criteria

You can explain:

- plugin group;
- plugin name;
- event;
- event subscriber;
- why plugins can execute at many points of a request.

---

# Phase 6 — Template

Build:

```text
tpl_library
```

## Responsibility

Template composes the page.

```text
┌─────────────────────────────┐
│ Header / Menu Module        │
├───────────────────┬─────────┤
│                   │ Latest  │
│ Component         │ Books   │
│ Output            │ Module  │
│                   │         │
├───────────────────┴─────────┤
│ Footer                      │
└─────────────────────────────┘
```

## Structure

```text
templates/
└── library/
    ├── index.php
    ├── component.php
    ├── error.php
    ├── templateDetails.xml
    ├── html/
    └── language/
```

## Build

Define:

- component area;
- header position;
- sidebar position;
- footer position.

Assign the module created in Phase 4.

## Completion criteria

You can explain how the template receives component output and independently renders assigned modules.

---

# Phase 7 — Template Overrides

Learn how presentation can change without modifying the original extension.

## Component example

Default:

```text
components/com_library/tmpl/books/default.php
```

Override:

```text
templates/library/html/com_library/books/default.php
```

## Module example

Default:

```text
modules/mod_latest_books/tmpl/default.php
```

Override:

```text
templates/library/html/mod_latest_books/default.php
```

## Resolution flow

```text
Extension requests layout
        ↓
Template override exists?
       / \
     yes  no
      ↓    ↓
template  extension
/html     /tmpl
      \    /
       rendered HTML
```

## Completion criteria

You can distinguish extension business/runtime code from template-level presentation customization.

---

# Phase 8 — Media and Web Asset Manager

Study public assets separately from extension PHP code.

Example installed paths:

```text
media/
├── com_library/
│   ├── css/
│   ├── js/
│   └── joomla.asset.json
│
├── mod_latest_books/
│   └── ...
│
└── templates/
    └── site/
        └── library/
            ├── css/
            ├── js/
            └── joomla.asset.json
```

## Flow

```text
Component / Module / Template
            ↓
     Web Asset Manager
            ↓
     joomla.asset.json
            ↓
          media/
       ├── CSS
       └── JS
            ↓
         Browser
```

## Build

Move/register demo CSS and JavaScript through the appropriate media structure and Web Asset Manager.

## Completion criteria

You can explain why Joomla separates executable extension code from browser-facing assets.

---

# Phase 9 — Complete Runtime Flow

Trace one real request end-to-end.

Example:

```text
GET /books/refactoring
```

## Full flow

```text
Browser
   ↓
index.php
   ↓
Joomla Application
   ↓
Routing
   ↓
com_library
   ↓
Controller
   ↓
Model
   ↓
Database
   ↓
View
   ↓
Layout resolution
   ↓
Component output
   ↓
Template
   ├── component output
   ├── menu module
   └── latest-books module
   ↓
Document
   ↓
Web Asset Manager
   ↓
media/
   ↓
HTTP Response
   ↓
Browser
```

Plugins are drawn separately because they react to events throughout the lifecycle:

```text
Application ─── event ───→ Plugins
Component   ─── event ───→ Plugins
Content     ─── event ───→ Plugins
Rendering   ─── event ───→ Plugins
```

## Completion criteria

You can trace a visible piece of HTML back to:

- the extension responsible for the data;
- the class responsible for execution;
- the layout responsible for markup;
- the template/position responsible for placement;
- the media file responsible for styling or JavaScript;
- any plugin event that may have modified the flow.

---

# Phase 10 — Extension From Scratch Challenge

This phase validates that the architecture is understood rather than memorized.

## Challenge A

Requirement:

> Display a reusable small block in a sidebar.

You must decide:

- correct extension type;
- naming;
- package structure;
- manifest;
- service registration;
- runtime class;
- layout;
- installation;
- module/template assignment;
- runtime trace.

## Challenge B

Requirement:

> Execute logic whenever a specific Joomla event occurs without rendering a permanent page block.

You must independently identify that an event-driven extension is appropriate and implement it.

## Challenge C

Requirement:

> Build a feature with its own route, data model, list screen, detail screen, and backend management.

You must independently design the component structure.

## Pass condition

The roadmap is complete when you can receive a new requirement and answer:

```text
1. Which extension type should implement this?
2. Why?
3. What is its minimum valid structure?
4. How is it defined in the manifest?
5. How does Joomla register/load it?
6. At what point of the runtime flow does it execute?
7. Where does its HTML come from?
8. Where do its assets live?
9. How can its execution be traced and debugged?
```

---

# Final Architecture Mental Model

```text
                         REQUEST
                            │
                            ▼
                    Joomla Application
                            │
                   ┌────────┴────────┐
                   │                 │
                   ▼                 ▼
                Router            Events
                   │                 │
                   ▼                 ▼
               Component         Plugins
                   │
          Controller → Model
                   │
                   ▼
                  View
                   │
                   ▼
                 Layout
                   │
                   ▼
            Component Output
                   │
                   ▼
                Template
                   │
         ┌─────────┼─────────┐
         ▼         ▼         ▼
      Modules   Component   Modules
                   │
                   ▼
                Document
                   │
            Web Asset Manager
                   │
                   ▼
                 media/
                   │
                   ▼
                RESPONSE
```

---

# Rules for Future Lessons

Every lesson created from this roadmap should include:

1. **Purpose** — what problem this Joomla mechanism solves.
2. **Runtime flow** — where it participates in execution.
3. **Structure** — only folders/files relevant to that lesson.
4. **Definition** — manifest, namespace, services, registration where applicable.
5. **Demo feature** — one small observable behavior.
6. **Build steps** — implement on Joomla Fresh.
7. **Observation** — what to inspect in browser/admin/filesystem/database.
8. **Debug trace** — how to prove the flow actually executed.
9. **Interaction** — how it connects to previously learned layers.
10. **Completion check** — questions the learner must be able to answer without copying the example.

---

## Related Learning Documents

This roadmap should be used together with the existing extension references in the parent directory:

- `extension-in-joomla.md` — extension concepts and types.
- `extension-install-tutorial.md` — installation-focused reference.
- `joomla-6-extension-structure.md` — detailed Joomla 6 extension structures.

Those files are references. This folder focuses specifically on **learning the runtime flow by building and tracing a fresh demo project**.
