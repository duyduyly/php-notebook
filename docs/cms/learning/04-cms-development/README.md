# Stage 04 — CMS Development and Customization

This stage develops the ability to extend a CMS without creating unnecessary core modifications.

## Table of Contents

1. [Objectives](#objectives)
2. [Customization Priority](#customization-priority)
3. [Themes and Templates](#themes-and-templates)
4. [Modules and Plugins](#modules-and-plugins)
5. [Custom Components](#custom-components)
6. [APIs and Integrations](#apis-and-integrations)
7. [Engineering Standards](#engineering-standards)
8. [Completion Checklist](#completion-checklist)

## Objectives

Build maintainable presentation, behavior, business features, and integrations while respecting extension boundaries and upgrade compatibility.

## Customization Priority

Prefer the least invasive option that fully solves the requirement:

```text
Configuration
→ Template or layout override
→ Plugin or event listener
→ Module, block, or widget
→ Custom extension or application
→ Core modification
```

Core modification is a last resort because it increases upgrade cost, testing scope, security risk, and maintenance difficulty.

## Themes and Templates

Learn:

- theme directory structure;
- template hierarchy;
- layouts and reusable partials;
- responsive design;
- asset registration and bundling;
- content escaping;
- child themes;
- component and layout overrides;
- accessibility;
- separation of presentation and business logic.

Build a theme that includes article lists, article details, navigation, reusable page regions, error pages, and responsive layouts.

## Modules and Plugins

### Modules, Blocks, or Widgets

Create reusable display features such as:

- latest content;
- featured content;
- category-based content;
- permission-aware content;
- external API data.

### Plugins and Event Listeners

Implement behaviors such as:

- login auditing;
- article-save validation;
- content transformation;
- notifications;
- custom authentication;
- third-party synchronization.

Listeners should have explicit inputs, predictable side effects, error handling, and idempotency where retries are possible.

## Custom Components

A substantial feature package may contain:

```text
Custom Feature
├── Administrator interface
├── Frontend interface
├── API endpoints
├── Database schema and migrations
├── Controllers
├── Application services
├── Repositories
├── Views and templates
├── Permissions
├── Events
├── Scheduled tasks
└── Tests
```

Suitable practice projects include a knowledge base, job portal, event manager, product catalog, or support-ticket system.

## APIs and Integrations

Study:

- REST resource design;
- authentication and authorization;
- pagination, filtering, and sorting;
- API versioning;
- standardized error responses;
- rate limiting;
- webhooks;
- retries and idempotency;
- secret management;
- integration audit logs.

## Engineering Standards

Every extension should include:

- clear responsibility and boundaries;
- dependency declarations;
- installation and update migrations;
- permission checks on the server;
- input validation and output escaping;
- structured error handling;
- logs for important operations;
- automated tests for critical behavior;
- compatibility notes;
- uninstall behavior and data-retention decisions.

## Completion Checklist

- [ ] I have built a complete theme or template package.
- [ ] I have built a reusable module, block, or widget.
- [ ] I have built an event-driven plugin.
- [ ] I have built a custom feature with database migrations and permissions.
- [ ] I have exposed or consumed a secured API.
- [ ] My customizations do not require direct core changes.
- [ ] I can explain the upgrade and compatibility strategy for every extension.
