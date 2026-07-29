# Documentation Website Demo — Structure and Deployment Guide

## Purpose

This page explains the documentation website structure used by the `structure` branch. It is a reference document only. It does not run GitHub Actions or deploy the website.

The actual deployment behavior is controlled by:

```text
.github/workflows/deploy-docs.yml
```

## Website type

This project is a **static documentation website**. Markdown files are converted into HTML, CSS, and JavaScript by MkDocs Material, then published by GitHub Pages.

```text
Markdown files
      ↓
MkDocs
      ↓
Static website files
      ↓
GitHub Actions
      ↓
GitHub Pages
```

It can be used as:

- A developer handbook.
- An online programming book.
- A technical knowledge base.
- A learning-note website.
- A documentation portal.

## Project structure

```text
php-notebook/
├── README.md
├── mkdocs.yml
├── requirements.txt
├── docs/
│   ├── index.md
│   ├── home/
│   │   ├── overview.md
│   │   └── explain.md
│   ├── cms/
│   │   └── overview.md
│   ├── php/
│   │   ├── overview.md
│   │   └── demo/
│   │       └── demo.md
│   ├── drupal/
│   │   └── overview.md
│   ├── wordpress/
│   │   └── overview.md
│   └── joomla/
│       └── overview.md
└── .github/
    └── workflows/
        └── deploy-docs.yml
```

## Important files

### `README.md`

This file is displayed on the GitHub repository page. It introduces the repository to developers and visitors. It is not the MkDocs homepage.

### `docs/index.md`

This is the root homepage of the deployed documentation website.

### `docs/home/overview.md`

This is the main demo page for the documentation website. It contains the title **PHP & CMS Developer Documentation**, links to all documentation areas, and a summary of how the website works.

### `docs/home/explain.md`

This is the current guide. It explains the structure and deployment process.

### Topic folders

The following folders contain separate documentation domains:

```text
docs/cms/
docs/php/
docs/drupal/
docs/wordpress/
docs/joomla/
```

Each topic folder has an `overview.md` file that introduces the lessons inside that section.

## `mkdocs.yml`

`mkdocs.yml` is the main MkDocs configuration file. MkDocs reads it when these commands run:

```bash
mkdocs serve
mkdocs build
```

It controls:

- Website name and description.
- GitHub repository links.
- Material theme settings.
- Navigation behavior.
- Search.
- Markdown extensions.
- Code highlighting.
- Tables, tabs, checklists, icons, and admonitions.

This project intentionally does not define a manual `nav:` section. Therefore, MkDocs automatically discovers Markdown files and folders under `docs/`.

## `requirements.txt`

This file lists the Python packages required to build the website.

```text
mkdocs-material
```

The workflow installs it with:

```bash
pip install -r requirements.txt
```

The package provides MkDocs, the Material theme, and related dependencies.

For production, pin an approved version to make builds more predictable:

```text
mkdocs-material==<approved-version>
```

## `.github/workflows/deploy-docs.yml`

The `.github` folder is a special folder recognized by GitHub. Workflow files placed under `.github/workflows/` define GitHub Actions automation.

The deployment workflow performs these steps:

1. Detects a push to the `structure` branch.
2. Creates a temporary Ubuntu runner.
3. Checks out the repository.
4. Installs Python.
5. Installs dependencies from `requirements.txt`.
6. Runs `mkdocs build --strict`.
7. Uploads the generated `site/` directory.
8. Publishes the artifact through GitHub Pages.

GitHub can deploy the project because GitHub Actions builds the static website and GitHub Pages hosts the generated files.

## Automatic nested navigation

For example:

```text
docs/php/
├── overview.md
└── demo/
    └── demo.md
```

MkDocs discovers the nested folder during the next build. The navigation conceptually becomes:

```text
PHP
├── Overview
└── Demo
    └── Demo
```

Adding this nested folder does not break the website as long as:

- The page uses the `.md` extension.
- The Markdown is valid.
- Internal links use valid paths.
- The build completes successfully.

## `overview.md` versus `index.md`

An `overview.md` file appears as an explicit Overview page in the folder.

An `index.md` file becomes the default landing page for the folder URL.

Example:

```text
docs/php/index.md
```

maps naturally to:

```text
/php/
```

## Local development

```bash
pip install -r requirements.txt
mkdocs serve
```

Open:

```text
http://127.0.0.1:8000
```

Validate the production build with:

```bash
mkdocs build --strict
```

## GitHub Pages setting

Configure the repository with:

```text
Settings
→ Pages
→ Build and deployment
→ Source: GitHub Actions
```
