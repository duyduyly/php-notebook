# PHP & CMS Developer Documentation

Welcome to the demo documentation website for PHP and popular content management systems.

This website is generated from Markdown files with **MkDocs Material** and deployed as a static website through **GitHub Pages**.

## Documentation areas

<div class="grid cards" markdown>

-   :material-language-php: **PHP**

    ---

    Core PHP, object-oriented programming, packages, testing, security, and practical projects.

    [Open PHP documentation](php/overview.md)

-   :material-view-dashboard-outline: **CMS**

    ---

    Shared CMS concepts such as content models, users, permissions, themes, extensions, and migrations.

    [Open CMS documentation](cms/overview.md)

-   :material-drupal: **Drupal**

    ---

    Drupal architecture, modules, themes, configuration, content entities, and development practices.

    [Open Drupal documentation](drupal/overview.md)

-   :material-wordpress: **WordPress**

    ---

    WordPress themes, plugins, hooks, templates, administration, security, and deployment.

    [Open WordPress documentation](wordpress/overview.md)

-   :material-joomla: **Joomla**

    ---

    Joomla architecture, extensions, templates, migration, security, and Joomla 6 development.

    [Open Joomla documentation](joomla/overview.md)

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

The [`explain.md`](explain.md) page documents the purpose of every important folder and configuration file in this demo branch.

## Adding new lessons

Create additional folders and Markdown files inside `docs/`. Because this project currently uses automatic navigation, MkDocs discovers new Markdown pages during the next build.

Example:

```text
docs/php/extensions/
├── 01-introduction.md
├── 02-installation.md
└── 03-examples.md
```

After the next deployment, the new section appears in the navigation automatically.
