# PHP & CMS Developer Documentation

Welcome to the demo documentation website for PHP and popular content management systems.

This website is generated from Markdown files with **MkDocs Material** and deployed as a static website through **GitHub Pages**.

## Documentation areas

<div class="grid cards" markdown>

-   :material-language-php: **PHP**

    ---

    Core PHP, object-oriented programming, packages, testing, security, and practical projects.

    [Open PHP documentation](../php/overview.md)

-   :material-view-dashboard-outline: **CMS**

    ---

    Shared CMS concepts such as content models, users, permissions, themes, extensions, and migrations.

    [Open CMS documentation](../cms/overview.md)

-   :material-drupal: **Drupal**

    ---

    Drupal architecture, modules, themes, configuration, content entities, and development practices.

    [Open Drupal documentation](../drupal/overview.md)

-   :material-wordpress: **WordPress**

    ---

    WordPress themes, plugins, hooks, templates, administration, security, and deployment.

    [Open WordPress documentation](../wordpress/overview.md)

-   :material-joomla: **Joomla**

    ---

    Joomla architecture, extensions, templates, migration, security, and Joomla 6 development.

    [Open Joomla documentation](../joomla/overview.md)

</div>

## How the website works

```text
Markdown files in docs/
        ↓
MkDocs reads mkdocs.yml
        ↓
MkDocs builds HTML, CSS, and JavaScript
        ↓
GitHub Actions uploads the generated site/
        ↓
GitHub Pages publishes the website
```

## Structure guide

Read the [Structure and Deployment Guide](explain.md) for a detailed explanation of every important file and folder.

## Adding new lessons

Create additional folders and Markdown files inside `docs/`. Since this project uses automatic navigation, MkDocs discovers new Markdown pages during the next build.
