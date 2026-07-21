# Warning Notes for Major CMS Upgrades

## Overview

A major CMS upgrade generally follows one of two approaches. The appropriate approach depends on factors such as:

- The current and target major versions
- The volume and complexity of content and data
- The compatibility of templates and extensions
- The amount of custom code
- Existing third-party integrations

The following examples use an upgrade from Joomla 3 to Joomla 6.

## Approach 1 – Upgrade Through Intermediate Versions

**Core upgrade path:** Joomla 3 → Joomla 4 → Joomla 5 → Joomla 6

### Approach

Upgrade sequentially through each major version. At every stage, update or replace incompatible templates, components, modules, plugins, and custom code.

### Pros

- Retains most of the existing content structure, menus, URL aliases, and data.
- Reduces the risk of missing content during migration.
- Allows compatibility issues to be tested and resolved at each upgrade stage.

### Cons and Risks

- Requires multiple intermediate PHP environments during the upgrade process.
- Legacy extensions or custom packages may not support Joomla 4, 5, or 6.
- Some components, modules, or plugins may need to be replaced or rewritten.
- Existing technical debt and legacy structures may remain in the upgraded system.
- Regression testing must be performed after every major-version upgrade.

### Estimated Development Timeline

**More than 3 months**, depending on the number of custom extensions and their compatibility with each Joomla version.

## Approach 2 – Rebuild on a Fresh Joomla 6 Installation

**Core setup:** Fresh Joomla 6 installation

### Approach

Rebuild the website on Joomla 6 by recreating the content structure, template, and required features. Then migrate the content and data from the legacy website.

### Pros

- Provides an opportunity to redesign the content schema and code architecture more clearly.
- Removes legacy code, outdated extensions, and accumulated technical debt.
- Uses only extensions that are directly compatible with Joomla 6.
- Improves long-term maintainability and extensibility.

### Cons and Risks

- Requires comprehensive discovery to identify every existing page, feature, form, and integration.
- Content types, custom fields, menus, modules, and permissions must be configured again.
- Content, media, URL aliases, SEO metadata, and redirects must be migrated.
- Form configurations must be rebuilt.
- If historical form submissions must be retained, their database structures require separate analysis and migration.
- Incomplete discovery may result in missing features or data.

### Estimated Development Timeline

**More than 4 months**, depending on the volume of content, number of forms, custom features, and third-party integrations.

## Important Warning

The estimated timelines are preliminary and should not be treated as final commitments. A detailed discovery and compatibility assessment is required before confirming the upgrade approach, project scope, effort, risks, and delivery schedule.
